-- 04_etl_objects.sql drops and creates ETL process Objects.
-- Before executing this script, the DWIndependentBookSellers database must be created by running 03_destination_database.

USE DWIndependentBookSellers
GO

IF NOT EXISTS (SELECT [name] FROM sys.tables WHERE [name] = 'ETLMetadata')
BEGIN
	CREATE TABLE dbo.ETLMetadata (
		[ETLMetadataID] INT identity PRIMARY KEY
		, [ETLDateAndTime] DATETIME DEFAULT GetDate()
		, [ETLAction] VARCHAR(100)
		, [ETLMetadata] VARCHAR(2000)
	);
END
GO

CREATE OR ALTER VIEW dbo.vETLMetadata AS (
	SELECT [ETLMetadataID]
	, [ETLDate] = Format([ETLDateAndTime], 'D', 'en-us')
	, [ETLTime] = Format(Cast(ETLDateAndTime AS DATETIME2), 'HH:mm', 'en-us')
	, [ETLAction]
	, [ETLMetadata]
	FROM dbo.[ETLMetadata]
);
GO

-- Erland Sommarskog's error_handler_sp
-- https://www.sommarskog.se/error_handling/Part1.html
CREATE PROCEDURE dbo.pErrorHandler AS
BEGIN
	DECLARE @errmsg NVARCHAR(2048), @severity TINYINT, @state TINYINT, @errno INT, @proc SYSNAME, @lineno INT;

	SELECT @errmsg = error_message(), @severity = error_severity(), @state = error_state(), @errno = error_number(), @proc = error_procedure(), @lineno = error_line();

	IF @errmsg NOT LIKE '***%'
	BEGIN

		SELECT @errmsg = '*** ' + COALESCE(quotename(@proc), '<dynamic SQL>') + ', Line ' + ltrim(str(@lineno)) + '. Errno ' + ltrim(str(@errno)) + ': ' + @errmsg;
		
	END
	RAISERROR('%s', @severity, @state, @errmsg);
END
GO

-- pInsETLLog creates an admin table for logging ETL metadata
CREATE OR ALTER PROCEDURE dbo.pInsETLLog @ETLAction VARCHAR(100), @ETLMetadata VARCHAR(2000) , @RC INT = 0 AS
BEGIN
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

			INSERT INTO dbo.ETLMetadata([ETLAction], [ETLMetadata])
			VALUES (@ETLAction, @ETLMetadata);
			
			SET @RC = 1;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH

			IF @@trancount > 0 ROLLBACK TRANSACTION;
			EXEC error_handler_sp;
			RETURN 55555;

	END CATCH

	RETURN @RC;
END
GO

-- pETLDropFks drops the DW foreign keys
CREATE OR ALTER PROCEDURE dbo.pETLDropFks @RC INT = 0 AS
BEGIN
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

			ALTER TABLE dbo.FactSales DROP CONSTRAINT fkFactSalesToDimTitles;
			ALTER TABLE dbo.FactSales DROP CONSTRAINT fkFactSalesToDimStores;
			ALTER TABLE dbo.FactSales DROP CONSTRAINT fkFactSalesToDimDates;
			ALTER TABLE dbo.FactTitleAuthors DROP CONSTRAINT fkFactTitleAuthorsToDimTitles;
			ALTER TABLE dbo.FactTitleAuthors DROP CONSTRAINT fkFactTitleAuthorsToDimAuthors;
			
			EXEC dbo.pInsETLLog @ETLAction = 'pETLDropFks', @ETLMetadata = 'Dropped Foreign Keys';
			
			SET @RC = 1;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		EXEC error_handler_sp;
		RETURN 55555;
		
		DECLARE @ErrorMessage NVARCHAR(1000) = Error_Message();
		EXEC dbo.pInsETLLog @ETLAction = 'pETLDropFks', @ETLMetadata = @ErrorMessage;
		
		SET @RC = -1;

	END CATCH

	RETURN @RC;
END
GO

-- pETLTruncateTables clears the data from all DW tables
CREATE OR ALTER PROCEDURE dbo.pETLTruncateTables @RC INT = 0 AS
BEGIN
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

			TRUNCATE TABLE dbo.DimAuthors;
			TRUNCATE TABLE dbo.DimDates;
			TRUNCATE TABLE dbo.DimStores;
			TRUNCATE TABLE dbo.DimTitles;
			TRUNCATE TABLE dbo.FactSales;
			TRUNCATE TABLE dbo.FactTitleAuthors;
			
			EXEC dbo.pInsETLLog @ETLAction = 'pETLTruncateTables', @ETLMetadata = 'Truncated Tables';
			
			SET @RC = 1;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		EXEC error_handler_sp;
		RETURN 55555;
		
		DECLARE @ErrorMessage NVARCHAR(1000) = Error_Message();
		EXEC dbo.pInsETLLog @ETLAction = 'pETLTruncateTables', @ETLMetadata = @ErrorMessage;

		SET @RC = -1;
	END CATCH

	RETURN @RC;
END
GO

-- pETLDimDates fills the DimDates table
CREATE OR ALTER PROCEDURE dbo.pETLDimDates @RC INT = 1, @Message VARCHAR(1000) = '' AS
BEGIN
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @StartDate DATETIME = '01/01/1992';
		DECLARE @EndDate DATETIME = '12/31/1994';
		DECLARE @DateInProcess DATETIME = @StartDate;
		DECLARE @TotalRows INT = 0;

		WHILE @DateInProcess <= @EndDate
		BEGIN
			BEGIN TRANSACTION;

				INSERT INTO dbo.DimDates([DateKey], [FullDate], [USADateName], [MonthKey], [MonthName], [QuarterKey], [QuarterName], [YearKey], [YearName])
				VALUES (Cast(Convert(NVARCHAR(50), @DateInProcess, 112) AS INT)
					, @DateInProcess
					, DateName(weekday, @DateInProcess) + ', ' + Convert(NVARCHAR(50), @DateInProcess, 110)
					, Left(Cast(Convert(NVARCHAR(50), @DateInProcess, 112) AS INT), 6)
					, DateName(MONTH, @DateInProcess) + ', ' + Cast(Year(@DateInProcess) AS NVARCHAR(50))
					, Cast(Cast(YEAR(@DateInProcess) AS NVARCHAR(50)) + '0' + DateName(QUARTER, @DateInProcess) AS INT)
					, 'Q' + DateName(QUARTER, @DateInProcess) + ', ' + Cast(Year(@DateInProcess) AS NVARCHAR(50))
					, Year(@DateInProcess)
					, Cast(Year(@DateInProcess) AS NVARCHAR(50))
				);
				
				SET @DateInProcess = DateAdd(d, 1, @DateInProcess);
				
				SET @TotalRows += 1;

			COMMIT TRANSACTION;
		END

		BEGIN TRANSACTION;

			INSERT INTO dbo.DimDates([DateKey], [FullDate], [USADateName], [MonthKey], [MonthName], [QuarterKey], [QuarterName], [YearKey], [YearName])
			SELECT [DateKey] = - 1
				, [FullDate] = '19000101'
				, [DateName] = Cast('Unknown Day' AS NVARCHAR(50))
				, [MonthKey] = - 1
				, [MonthName] = Cast('Unknown Month' AS NVARCHAR(50))
				, [QuarterKey] = - 1
				, [QuarterName] = Cast('Unknown Quarter' AS NVARCHAR(50))
				, [YearKey] = - 1
				, [YearName] = Cast('Unknown Year' AS NVARCHAR(50))
			
			UNION
			
			SELECT [DateKey] = - 2
				, [FullDate] = '19000102'
				, [DateName] = Cast('Corrupt Day' AS NVARCHAR(50))
				, [MonthKey] = - 2
				, [MonthName] = Cast('Corrupt Month' AS NVARCHAR(50))
				, [QuarterKey] = - 2
				, [QuarterName] = Cast('Corrupt Quarter' AS NVARCHAR(50))
				, [YearKey] = - 2
				, [YearName] = Cast('Corrupt Year' AS NVARCHAR(50));
			
			SET @TotalRows += 2;
			
			SET @Message = 'Filled DimDates (' + Cast(@TotalRows AS VARCHAR(100)) + ' rows)';
			
			EXEC dbo.pInsETLLog @ETLAction = 'pETLDimDates', @ETLMetadata = @Message;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		EXEC error_handler_sp;
		RETURN 55555;
		
		DECLARE @ErrorMessage NVARCHAR(1000) = Error_Message();
		EXEC dbo.pInsETLLog @ETLAction = 'pETLDimDates', @ETLMetadata = @ErrorMessage;

		SET @RC = -1;
	END CATCH

	RETURN @RC;
END
GO

CREATE OR ALTER VIEW dbo.vETLDimAuthors AS (
	SELECT [AuthorID] = Cast([au_id] AS NVARCHAR(11))
		, [AuthorName] = Cast(([au_fname] + ' ' + [au_lname]) AS NVARCHAR(100))
		, [AuthorCity] = Cast([city] AS NVARCHAR(100))
		, [AuthorState] = Cast([state] AS NCHAR(2))
	FROM IndependentBookSellers.dbo.Authors
);
GO

-- pETLDimAuthors fills the DimAuthors table
CREATE OR ALTER PROCEDURE dbo.pETLDimAuthors @RC INT = 0, @Message VARCHAR(1000) = '' AS
BEGIN
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

			INSERT INTO dbo.DimAuthors([AuthorID], [AuthorName], [AuthorCity], [AuthorState])
			SELECT [AuthorID], [AuthorName], [AuthorCity], [AuthorState]
			FROM dbo.vETLDimAuthors;
			
			SET @Message = 'Filled DimAuthors (' + Cast(@@RowCount AS VARCHAR(100)) + ' rows)';
			
			EXEC dbo.pInsETLLog @ETLAction = 'pETLDimAuthors', @ETLMetadata = @Message;
			
			SET @RC = 1;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		EXEC error_handler_sp;
		RETURN 55555;
		
		DECLARE @ErrorMessage NVARCHAR(1000) = Error_Message();
		EXEC dbo.pInsETLLog @ETLAction = 'pETLDimAuthors', @ETLMetadata = @ErrorMessage;

		SET @RC = -1;
	END CATCH

	RETURN @RC;
END
GO

CREATE OR ALTER VIEW dbo.vETLDimTitles AS (
	SELECT [TitleID] = CAST([title_id] AS NVARCHAR(6))
		, [TitleName] = CAST([title] AS NVARCHAR(100))
		, [TitleType] = CAST([type] AS NVARCHAR(100))
		, [TitleListPrice] = CAST([price] AS DECIMAL(18, 4))
	FROM IndependentBookSellers.dbo.Titles
	WHERE [price] IS NOT NULL
);
GO

-- pETLDimTitles fills the DimTitles table 
CREATE OR ALTER PROCEDURE dbo.pETLDimTitles @RC INT = 0, @Message VARCHAR(1000) = '' AS
BEGIN
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

			INSERT INTO dbo.DimTitles([TitleID], [TitleName], [TitleType], [TitleListPrice])
			SELECT [TitleID], [TitleName], [TitleType], [TitleListPrice]
			FROM dbo.vETLDimTitles;

			SET @Message = 'Filled DimTitles (' + Cast(@@RowCount AS VARCHAR(100)) + ' rows)';

			EXEC dbo.pInsETLLog @ETLAction = 'pETLDimTitles', @ETLMetadata = @Message;

			SET @RC = 1;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		EXEC error_handler_sp;
		RETURN 55555;
		
		DECLARE @ErrorMessage NVARCHAR(1000) = Error_Message();
		EXEC dbo.pInsETLLog @ETLAction = 'pETLDimTitles', @ETLMetadata = @ErrorMessage;

		SET @RC = -1;
	END CATCH

	RETURN @RC;
END
GO

CREATE OR ALTER VIEW dbo.vETLDimStores AS (
	SELECT [StoreID] = CAST([stor_id] AS NCHAR(4))
		, [StoreName] = CAST([stor_name] AS NVARCHAR(100))
		, [StoreCity] = CAST([city] AS NVARCHAR(100))
		, [StoreState] = CASt([state] AS NCHAR(2))
	FROM IndependentBookSellers.dbo.Stores
);
GO

-- pETLDimStores fills the DimStores table
CREATE OR ALTER PROCEDURE dbo.pETLDimStores @RC INT = 0, @Message VARCHAR(1000) = '' AS
BEGIN
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

			INSERT INTO dbo.DimStores([StoreID], [StoreName], [StoreCity], [StoreState])
			SELECT [StoreID], [StoreName], [StoreCity], [StoreState]
			FROM dbo.vETLDimStores;

			SET @Message = 'Filled DimStores (' + Cast(@@RowCount AS VARCHAR(100)) + ' rows)';

			EXEC dbo.pInsETLLog @ETLAction = 'pETLDimStores', @ETLMetadata = @Message;

			SET @RC = 1;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		EXEC error_handler_sp;
		RETURN 55555;
		
		DECLARE @ErrorMessage NVARCHAR(1000) = Error_Message();
		EXEC dbo.pInsETLLog @ETLAction = 'pETLDimStores', @ETLMetadata = @ErrorMessage;

		SET @RC = -1;
	END CATCH

	RETURN @RC;
END
GO

CREATE OR ALTER VIEW dbo.vETLFactTitleAuthors AS (
	SELECT t2.[AuthorKey]
		, t3.[TitleKey]
		, [AuthorOrder] = t1.[au_ord]
	FROM IndependentBookSellers.dbo.TitleAuthors AS t1
		, DWIndependentBookSellers.dbo.DimAuthors AS t2
		, DWIndependentBookSellers.dbo.DimTitles AS t3
	WHERE t1.[au_id] = t2.[AuthorID]
		AND t1.[title_id] = t3.[TitleID]
);
GO

-- pETLFactTitleAuthors fills the FactTitleAuthors table
CREATE OR ALTER PROCEDURE dbo.pETLFactTitleAuthors @RC INT = 0, @Message VARCHAR(1000) = '' AS
BEGIN
	SET NOCOUNT, XACT_ABORT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION;

			INSERT INTO dbo.FactTitleAuthors([AuthorKey], [TitleKey], [AuthorOrder])
			SELECT [AuthorKey], [TitleKey], [AuthorOrder]
			FROM dbo.vETLFactTitleAuthors;

			SET @Message = 'Filled FactTitleAuthors (' + Cast(@@RowCount AS VARCHAR(100)) + ' rows)';

			EXEC dbo.pInsETLLog @ETLAction = 'pETLFactTitleAuthors', @ETLMetadata = @Message;

			SET @RC = 1;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		EXEC error_handler_sp;
		RETURN 55555;
		
		DECLARE @ErrorMessage NVARCHAR(1000) = Error_Message();
		EXEC dbo.[pInsETLLog] @ETLAction = 'pETLFactTitleAuthors', @ETLMetadata = @ErrorMessage;

		SET @RC = -1;
	END CATCH

	RETURN @RC;
END
GO

CREATE OR ALTER VIEW dbo.vETLFactSales AS (
	SELECT [OrderNumber] = CAST(t1.[ord_num] AS NVARCHAR(20))
		, [OrderDateKey] = t3.[DateKey]
		, [StoreKey] = t4.[StoreKey]
		, [TitleKey] = t5.[TitleKey]
		, [SalesQty] = CAST(t2.[qty] AS INT)
		, [SalesPrice] = CAST(t2.[price] AS DECIMAL(18, 4))
	FROM IndependentBookSellers.dbo.SalesHeaders AS t1
		, IndependentBookSellers.dbo.SalesDetails AS t2
		, DWIndependentBookSellers.dbo.DimDates AS t3
		, DWIndependentBookSellers.dbo.DimStores AS t4
		, DWIndependentBookSellers.dbo.DimTitles AS t5
	WHERE t1.[ord_num] = t2.[ord_num]
		AND t1.[stor_id] = t4.[StoreID]
		AND t2.[title_id] = t5.[TitleID]
		AND Cast(Convert(NVARCHAR(50), t1.[ord_date], 112) AS INT) = t3.[DateKey]
);
GO

-- pETLFactSales fills the FactSales table
CREATE OR ALTER PROCEDURE dbo.pETLFactSales @RC INT = 0, @Message VARCHAR(1000) = '' AS
BEGIN
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

			INSERT INTO dbo.FactSales([OrderNumber], [OrderDateKey], [StoreKey], [TitleKey], [SalesQty], [SalesPrice])
			SELECT [OrderNumber], [OrderDateKey], [StoreKey], [TitleKey], [SalesQty], [SalesPrice]
			FROM dbo.vETLFactSales;

			SET @Message = 'Filled FactSales (' + Cast(@@RowCount AS VARCHAR(100)) + ' rows)';

			EXEC dbo.pInsETLLog @ETLAction = 'pETLFactSales', @ETLMetadata = @Message;

			SET @RC = 1;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		EXEC error_handler_sp;
		RETURN 55555;
		
		DECLARE @ErrorMessage NVARCHAR(1000) = Error_Message();
		EXEC dbo.pInsETLLog @ETLAction = 'pETLFactSales', @ETLMetadata = @ErrorMessage;

		SET @RC = -1;
	END CATCH

	RETURN @RC;
END
GO

-- pETLReplaceFks replaces the DW foreign keys
CREATE OR ALTER PROCEDURE dbo.pETLReplaceFks @RC INT = 0
AS
BEGIN
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

			ALTER TABLE dbo.FactTitleAuthors ADD CONSTRAINT fkFactTitleAuthorsToDimTitles FOREIGN KEY ([TitleKey]) REFERENCES dbo.DimTitles ([TitleKey]);
			ALTER TABLE dbo.FactTitleAuthors ADD CONSTRAINT fkFactTitleAuthorsToDimAuthors FOREIGN KEY ([AuthorKey]) REFERENCES dbo.DimAuthors ([AuthorKey]);
			ALTER TABLE dbo.FactSales ADD CONSTRAINT fkFactSalesToDimTitles FOREIGN KEY ([TitleKey]) REFERENCES dbo.DimTitles ([TitleKey]);
			ALTER TABLE dbo.FactSales ADD CONSTRAINT fkFactSalesToDimStores FOREIGN KEY ([StoreKey]) REFERENCES dbo.DimStores ([StoreKey]);
			ALTER TABLE dbo.FactSales ADD CONSTRAINT fkFactSalesToDimDates FOREIGN KEY ([OrderDateKey]) REFERENCES dbo.DimDates ([DateKey]);

			EXEC dbo.pInsETLLog @ETLAction = 'pETLReplaceFks', @ETLMetadata = 'Replaced Foreign Keys';

			SET @RC = 1;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		EXEC error_handler_sp;
		RETURN 55555;
		
		DECLARE @ErrorMessage NVARCHAR(1000) = Error_Message();
		EXEC dbo.[pInsETLLog] @ETLAction = 'pETLReplaceFks', @ETLMetadata = @ErrorMessage;

		SET @RC = -1;
	END CATCH

	RETURN @RC;
END
GO

EXEC dbo.pETLDropFks;

EXEC dbo.pETLTruncateTables;

EXEC dbo.pETLDimDates;

EXEC dbo.pETLDimAuthors;

EXEC dbo.pETLDimTitles;

EXEC dbo.pETLDimStores;

EXEC dbo.pETLFactTitleAuthors;

EXEC dbo.pETLFactSales;

EXEC dbo.pETLReplaceFks;
GO

SELECT *
FROM dbo.ETLMetadata;
GO

SELECT *
FROM dbo.DimAuthors;

SELECT *
FROM dbo.DimTitles;

SELECT *
FROM dbo.DimStores;

SELECT *
FROM dbo.FactTitleAuthors;

SELECT *
FROM dbo.FactSales;

SELECT *
FROM dbo.DimDates;
GO
