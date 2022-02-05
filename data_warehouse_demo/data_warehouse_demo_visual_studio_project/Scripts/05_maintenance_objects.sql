-- 05_maintenance_objects.sql creates database maintenance objects.
-- Before executing this script, the DWIndependentBookSellers database must be created by running 03_destination_database.

USE DWIndependentBookSellers;
GO

IF NOT EXISTS (SELECT [name] FROM sys.tables WHERE Name = 'MaintLog')
BEGIN
	CREATE TABLE dbo.MaintLog (
		[MaintLogID] INT identity PRIMARY KEY
		, [MaintDateAndTime] DATETIME DEFAULT GetDate()
		, [MaintAction] VARCHAR(100)
		, [MaintLogMessage] VARCHAR(2000)
	);
END
GO

CREATE OR ALTER VIEW dbo.vMaintLog AS (
	SELECT [MaintLogID]
		, [MaintDate] = Format([MaintDateAndTime], 'D', 'en-us')
		, [MaintTime] = Format(Cast([MaintDateAndTime] AS DATETIME2), 'HH:mm', 'en-us')
		, [MaintAction]
		, [MaintLogMessage]
	FROM dbo.MaintLog
);
GO

CREATE OR ALTER PROCEDURE dbo.pInsMaintLog @MaintAction VARCHAR(100), @MaintLogMessage VARCHAR(2000), @RC INT = 0 AS
BEGIN
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

			INSERT INTO dbo.MaintLog([MaintAction], [MaintLogMessage])
			VALUES (@MaintAction, @MaintLogMessage);

			SET @RC = 1;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		EXEC pErrorHandler;
		RETURN 55555;
		
		DECLARE @ErrorMessage NVARCHAR(1000) = Error_Message();
		SET @ErrorMessage = 'Insert to MaintLog failed' + @ErrorMessage;

		SET @RC = -1;
	END CATCH

	RETURN @RC;
END
GO

-- EXEC dbo.pInsMaintLog 'Test Action', 'Test Message';
-- SELECT * FROM vMaintLog;
-- DROP TABLE ValidationLog;

IF NOT EXISTS (SELECT [name] FROM sys.tables WHERE [name] = 'ValidationLog')
BEGIN
	CREATE TABLE dbo.ValidationLog (
		[ValidationID] INT PRIMARY KEY Identity
		, [ValidationDateTime] DATETIME
		, [ValidationObject] VARCHAR(100)
		, [ValidationStatus] VARCHAR(10) CONSTRAINT [ckValidationStatus] CHECK ([ValidationStatus] IN ('Success', 'Failed', 'Skipped'))
		, [ValidationMessage] VARCHAR(1000)
	);
END
GO

CREATE OR ALTER VIEW dbo.vValidationLog AS (
	SELECT [ValidationID], [ValidationDateTime], [ValidationObject], [ValidationStatus], [ValidationMessage]
	FROM dbo.ValidationLog
);
GO

CREATE OR ALTER PROCEDURE dbo.pInsValidationLog @ValidationDateTime DATETIME, @ValidationObject VARCHAR(100), @ValidationStatus VARCHAR(10), @ValidationMessage VARCHAR(1000), @RC INT = 0 AS
BEGIN
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

			INSERT INTO dbo.ValidationLog([ValidationDateTime], [ValidationObject], [ValidationStatus], [ValidationMessage])
			VALUES (@ValidationDateTime, @ValidationObject, @ValidationStatus, @ValidationMessage);
			
			SET @RC = 1;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		EXEC pErrorHandler;
		RETURN 55555;
		
		DECLARE @ErrorMessage NVARCHAR(1000) = Error_Message();
		EXEC dbo.pInsMaintLog @MaintAction = 'pInsValidationLog', @MaintLogMessage = @ErrorMessage;

		SET @RC = -1;
	END CATCH

	RETURN @RC;
END
GO

/*
DECLARE @CurrentDT DateTime = GetDate();
EXEC dbo.pInsValidationLog @CurrentDT, 'Test Object', 'Skipped', 'Test Message';
SELECT * FROM vValidationLog;
*/

CREATE OR ALTER PROCEDURE dbo.pMaintIndexes @RC INT = 0 AS
BEGIN
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

			IF (SELECT COUNT(*) FROM sys.SysIndexes WHERE [Id] = Object_id('FactTitleAuthors') AND [name] = 'nciTitleKeyFK') = 1
			BEGIN
				DROP INDEX nciTitleKeyFK ON dbo.FactTitleAuthors;
			END
			
			CREATE NONCLUSTERED INDEX nciTitleKeyFK ON dbo.FactTitleAuthors([TitleKey]);

			IF (SELECT COUNT(*) FROM sys.SysIndexes WHERE [Id] =Object_id('FactTitleAuthors') AND [name] = 'nciAuthorKeyFK') = 1
			BEGIN
				DROP INDEX nciAuthorKeyFK ON dbo.FactTitleAuthors;
			END

			CREATE NONCLUSTERED INDEX nciAuthorKeyFK ON dbo.FactTitleAuthors([AuthorKey]);

			IF (SELECT COUNT(*) FROM sys.SysIndexes WHERE [Id] =Object_id('FactSales') AND [name] = 'nciTitleKeyFK') = 1
			BEGIN
				DROP INDEX nciTitleKeyFK ON dbo.FactSales;
			END

			CREATE NONCLUSTERED INDEX nciTitleKeyFK ON dbo.FactSales([TitleKey]);

			IF (SELECT COUNT(*) FROM sys.SysIndexes WHERE [Id] =Object_id('FactSales') AND [name] = 'nciStoreKeyFK') > = 1
			BEGIN
				DROP INDEX nciStoreKeyFK ON dbo.FactSales;
			END
			
			CREATE NONCLUSTERED INDEX nciStoreKeyFK ON dbo.FactSales([StoreKey]);

			IF (SELECT COUNT(*) FROM sys.SysIndexes WHERE [Id] =Object_id('FactSales') AND [name] = 'nciOrderDateFK') > = 1
			BEGIN
				DROP INDEX nciOrderDateFK ON dbo.FactSales;
			END
			
			CREATE NONCLUSTERED INDEX nciOrderDateFK ON dbo.FactSales([OrderDateKey]);

			EXEC dbo.pInsMaintLog @MaintAction = 'pMaintIndexes', @MaintLogMessage = 'DWIndependentBookSellers Index Recreation: Success';

			SET @RC = 1;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		EXEC pErrorHandler;
		RETURN 55555;
		
		DECLARE @ErrorMessage NVARCHAR(1000) = Error_Message();
		EXEC pInsMaintLog @MaintAction = 'pMaintIndexes', @MaintLogMessage = @ErrorMessage;

		SET @RC = -1;
	END CATCH

	RETURN @RC;
END
GO

-- EXEC dbo.pMaintIndexes;
-- SELECT * FROM dbo.vMaintLog;

CREATE OR ALTER PROCEDURE dbo.pMaintDBBackup @RC INT = 0 AS
BEGIN
	SET NOCOUNT, XACT_ABORT ON;

	DECLARE @BackupPath NVARCHAR(100) = N'C:\data_warehouse_demo\data_warehouse_demo_visual_studio_project\Admin\Backups\DWIndependentBookSellersFull.bak';

	BEGIN TRY
		BACKUP DATABASE DWIndependentBookSellers TO DISK = @BackupPath WITH INIT;

		EXEC dbo.pInsMaintLog @MaintAction = 'pMaintDBBackup', @MaintLogMessage = 'DWIndependentBookSellers Full Backup: Success';

		SET @RC = 1;
	END TRY
	BEGIN CATCH
		
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		EXEC pErrorHandler;
		RETURN 55555;
		
		DECLARE @ErrorMessage NVARCHAR(1000) = Error_Message();
		EXEC pInsMaintLog @MaintAction = 'pMaintDBBackup', @MaintLogMessage = @ErrorMessage;

		SET @RC = -1;
	END CATCH

	RETURN @RC;
END
GO

-- EXEC dbo.pMaintDBBackup;
-- SELECT * FROM dbo.vMaintLog;

CREATE OR ALTER PROCEDURE dbo.pMaintRestore @RC INT = 0 AS
BEGIN
	SET NOCOUNT, XACT_ABORT ON;

	DECLARE @BackupPath NVARCHAR(100) = N'C:\data_warehouse_demo\data_warehouse_demo_visual_studio_project\Admin\Backups\DWIndependentBookSellersFull.bak';

	BEGIN TRY
		RESTORE DATABASE DWIndependentBookSellersRestored
		FROM DISK = @BackupPath
		WITH FILE = 1
			, MOVE N'DWIndependentBookSellers' TO N'C:\data_warehouse_demo\data_warehouse_demo_visual_studio_project\Admin\Backups\DWIndependentBookSellersRestored.mdf'
			, MOVE N'DWIndependentBookSellers_log' TO N'C:\data_warehouse_demo\data_warehouse_demo_visual_studio_project\Admin\Backups\DWIndependentBookSellersRestored.ldf'
			, RECOVERY
			, REPLACE;
		
		EXEC dbo.pInsMaintLog @MaintAction = 'pMaintDBBackup', @MaintLogMessage = 'DWIndependentBookSellers Backup Restore: Success';

		SET @RC = 1;
	END TRY
	BEGIN CATCH
		
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		EXEC pErrorHandler;
		RETURN 55555;
		
		DECLARE @ErrorMessage NVARCHAR(1000) = Error_Message();
		EXEC pInsMaintLog @MaintAction = 'pMaintRestore', @MaintLogMessage = @ErrorMessage;

		SET @RC = -1;
	END CATCH

	RETURN @RC;
END
GO

-- EXEC dbo.pMaintRestore;
-- SELECT * FROM dbo.vMaintLog

CREATE OR ALTER PROCEDURE dbo.pMaintValidateDimAuthorsRestore @RC INT = 0 AS
BEGIN
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @CurrentCount INT;
		DECLARE @RestoredCount INT;
		DECLARE @CurrentDateTime DATETIME = GetDate();

		-- test row counts
		SELECT @CurrentCount = COUNT(*)
		FROM DWIndependentBookSellers.dbo.DimAuthors;

		SELECT @RestoredCount = COUNT(*)
		FROM DWIndependentBookSellersRestored.dbo.DimAuthors;

		IF (@CurrentCount = @RestoredCount)
		BEGIN
			EXEC dbo.pInsValidationLog @ValidationDateTime = @CurrentDateTime
				, @ValidationObject = 'pMaintValidateDimAuthorsRestore'
				, @ValidationStatus = 'Success'
				, @ValidationMessage = 'DimAuthors Row Count Test';
		END
		ELSE
		BEGIN
			EXEC dbo.pInsValidationLog @ValidationDateTime = @CurrentDateTime
				, @ValidationObject = 'pMaintValidateDimAuthorsRestore'
				, @ValidationStatus = 'Failed'
				, @ValidationMessage = 'DimAuthors Row Count Test';
		END
		-- compare data
		DECLARE @DuplicateCount INT;

		SELECT @DuplicateCount = COUNT(*)
		FROM (
				SELECT * FROM DWIndependentBookSellers.dbo.DimAuthors
				EXCEPT
				SELECT * FROM DWIndependentBookSellersRestored.dbo.DimAuthors
		) AS Results;

		IF @DuplicateCount = 0
		BEGIN
			EXEC dbo.pInsValidationLog @ValidationDateTime = @CurrentDateTime
				, @ValidationObject = 'pMaintValidateDimAuthorsRestore'
				, @ValidationStatus = 'Success'
				, @ValidationMessage = 'DimAuthors Duplicate Test';
		END
		ELSE
		BEGIN
			EXEC dbo.pInsValidationLog @ValidationDateTime = @CurrentDateTime
				, @ValidationObject = 'pMaintValidateDimAuthorsRestore'
				, @ValidationStatus = 'Failed'
				, @ValidationMessage = 'DimAuthors Duplicate Test';
		END

		EXEC dbo.pInsMaintLog @MaintAction = 'pMaintValidateDimAuthorsRestore'
			, @MaintLogMessage = 'DimAuthors Validated. Check Validation Log.';

		SET @RC = 1;
	END TRY
	BEGIN CATCH
		
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		EXEC pErrorHandler;
		RETURN 55555;
		
		DECLARE @ErrorMessage NVARCHAR(1000) = Error_Message();
		EXEC dbo.pInsMaintLog @MaintAction = 'pMaintValidateDimAuthorsRestore', @MaintLogMessage = @ErrorMessage;

		SET @RC = -1;
	END CATCH

	RETURN @RC;
END
GO

-- EXEC dbo.pMaintValidateDimAuthorsRestore;
-- SELECT * FROM dbo.vMaintLog;
-- SELECT * FROM dbo.vValidationLog;

CREATE OR ALTER PROCEDURE dbo.pMaintValidateDimDatesRestore @RC INT = 0 AS
BEGIN
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @CurrentCount INT;
		DECLARE @RestoredCount INT;
		DECLARE @CurrentDateTime DATETIME = GetDate();

		-- test row counts
		SELECT @CurrentCount = COUNT(*)
		FROM DWIndependentBookSellers.dbo.DimDates;

		SELECT @RestoredCount = COUNT(*)
		FROM DWIndependentBookSellersRestored.dbo.DimDates;

		IF (@CurrentCount = @RestoredCount)
		BEGIN
			EXEC dbo.pInsValidationLog @ValidationDateTime = @CurrentDateTime
				, @ValidationObject = 'pMaintValidateDimDatesRestore'
				, @ValidationStatus = 'Success'
				, @ValidationMessage = 'DimDates Row Count Test';
		END
		ELSE
		BEGIN
			EXEC dbo.pInsValidationLog @ValidationDateTime = @CurrentDateTime
				, @ValidationObject = 'pMaintValidateDimDatesRestore'
				, @ValidationStatus = 'Failed'
				, @ValidationMessage = 'DimDates Row Count Test';
		END

		-- compare data
		DECLARE @DuplicateCount INT;

		SELECT @DuplicateCount = COUNT(*)
		FROM (
				SELECT * FROM DWIndependentBookSellers.dbo.DimDates
				EXCEPT
				SELECT * FROM DWIndependentBookSellersRestored.dbo.DimDates
		) AS Results;

		IF @DuplicateCount = 0
		BEGIN
			EXEC dbo.pInsValidationLog @ValidationDateTime = @CurrentDateTime
				, @ValidationObject = 'pMaintValidateDimDatesRestore'
				, @ValidationStatus = 'Success'
				, @ValidationMessage = 'DimDates Duplicate Test';
		END
		ELSE
		BEGIN
			EXEC dbo.pInsValidationLog @ValidationDateTime = @CurrentDateTime
				, @ValidationObject = 'pMaintValidateDimDatesRestore'
				, @ValidationStatus = 'Failed'
				, @ValidationMessage = 'DimDates Duplicate Test';
		END

		EXEC dbo.pInsMaintLog @MaintAction = 'pMaintValidateDimDatesRestore', @MaintLogMessage = 'DimDates Validated. Check Validation Log.';

		SET @RC = 1;
	END TRY
	BEGIN CATCH
	
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		EXEC pErrorHandler;
		RETURN 55555;
		
		DECLARE @ErrorMessage NVARCHAR(1000) = Error_Message();
		EXEC dbo.pInsMaintLog @MaintAction = 'pMaintValidateDimDatesRestore', @MaintLogMessage = @ErrorMessage;

		SET @RC = -1;
	END CATCH

	RETURN @RC;
END
GO

-- EXEC dbo.pMaintValidateDimDatesRestore
-- SELECT * FROM dbo.vMaintLog;
-- SELECT * FROM dbo.vValidationLog;

CREATE OR ALTER PROCEDURE dbo.pMaintValidateDimStoresRestore @RC INT = 0 AS
BEGIN
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @CurrentCount INT;
		DECLARE @RestoredCount INT;
		DECLARE @CurrentDateTime DATETIME = GetDate();

		-- test row counts
		SELECT @CurrentCount = COUNT(*)
		FROM DWIndependentBookSellers.dbo.DimStores;

		SELECT @RestoredCount = COUNT(*)
		FROM DWIndependentBookSellersRestored.dbo.DimStores;

		IF (@CurrentCount = @RestoredCount)
		BEGIN
			EXEC dbo.pInsValidationLog @ValidationDateTime = @CurrentDateTime
				, @ValidationObject = 'pMaintValidateDimStoresRestore'
				, @ValidationStatus = 'Success'
				, @ValidationMessage = 'DimStores Row Count Test';
		END
		ELSE
		BEGIN
			EXEC dbo.pInsValidationLog @ValidationDateTime = @CurrentDateTime
				, @ValidationObject = 'pMaintValidateDimStoresRestore'
				, @ValidationStatus = 'Failed'
				, @ValidationMessage = 'DimStores Row Count Test';
		END

		-- compare data
		DECLARE @DuplicateCount INT;

		SELECT @DuplicateCount = COUNT(*)
		FROM (
				SELECT * FROM DWIndependentBookSellers.dbo.DimStores	
				EXCEPT		
				SELECT * FROM DWIndependentBookSellersRestored.dbo.DimStores
		) AS Results;

		IF @DuplicateCount = 0
		BEGIN
			EXEC dbo.pInsValidationLog @ValidationDateTime = @CurrentDateTime
				, @ValidationObject = 'pMaintValidateDimStoresRestore'
				, @ValidationStatus = 'Success'
				, @ValidationMessage = 'DimStores Duplicate Test';
		END
		ELSE
		BEGIN
			EXEC dbo.pInsValidationLog @ValidationDateTime = @CurrentDateTime
				, @ValidationObject = 'pMaintValidateDimStoresRestore'
				, @ValidationStatus = 'Failed'
				, @ValidationMessage = 'DimStores Duplicate Test';
		END

		EXEC dbo.pInsMaintLog @MaintAction = 'pMaintValidateDimStoresRestore', @MaintLogMessage = 'DimStores Validated. Check Validation Log.';

		SET @RC = 1;
	END TRY
	BEGIN CATCH
	
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		EXEC pErrorHandler;
		RETURN 55555;
		
		DECLARE @ErrorMessage NVARCHAR(1000) = Error_Message();
		EXEC dbo.pInsMaintLog @MaintAction = 'pMaintValidateDimStoresRestore', @MaintLogMessage = @ErrorMessage;

		SET @RC = -1;
	END CATCH

	RETURN @RC;
END
GO

-- EXEC dbo.pMaintValidateDimStoresRestore;
-- SELECT * FROM dbo.vMaintLog;
-- SELECT * FROM dbo.vValidationLog;

CREATE OR ALTER PROCEDURE dbo.pMaintValidateDimTitlesRestore @RC INT = 0 AS
BEGIN
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @CurrentCount INT;
		DECLARE @RestoredCount INT;
		DECLARE @CurrentDateTime DATETIME = GetDate();

		-- test row counts
		SELECT @CurrentCount = COUNT(*)
		FROM DWIndependentBookSellers.dbo.DimTitles;

		SELECT @RestoredCount = COUNT(*)
		FROM DWIndependentBookSellersRestored.dbo.DimTitles;

		IF (@CurrentCount = @RestoredCount)
		BEGIN
			EXEC dbo.pInsValidationLog @ValidationDateTime = @CurrentDateTime
				, @ValidationObject = 'pMaintValidateDimTitlesRestore'
				, @ValidationStatus = 'Success'
				, @ValidationMessage = 'DimTitles Row Count Test';
		END
		ELSE
		BEGIN
			EXEC dbo.pInsValidationLog @ValidationDateTime = @CurrentDateTime
				, @ValidationObject = 'pMaintValidateDimTitlesRestore'
				, @ValidationStatus = 'Failed'
				, @ValidationMessage = 'DimTitles Row Count Test';
		END

		-- compare data
		DECLARE @DuplicateCount INT;

		SELECT @DuplicateCount = COUNT(*)
		FROM (
				SELECT * FROM DWIndependentBookSellers.dbo.DimTitles
				EXCEPT
			SELECT * FROM DWIndependentBookSellersRestored.dbo.DimTitles
		) AS Results;

		IF @DuplicateCount = 0
		BEGIN
			EXEC dbo.pInsValidationLog @ValidationDateTime = @CurrentDateTime
				, @ValidationObject = 'pMaintValidateDimTitlesRestore'
				, @ValidationStatus = 'Success'
				, @ValidationMessage = 'DimTitles Duplicate Test';
		END
		ELSE
		BEGIN
			EXEC dbo.pInsValidationLog @ValidationDateTime = @CurrentDateTime
				, @ValidationObject = 'pMaintValidateDimTitlesRestore'
				, @ValidationStatus = 'Failed'
				, @ValidationMessage = 'DimTitles Duplicate Test';
		END

		EXEC dbo.pInsMaintLog @MaintAction = 'pMaintValidateDimTitlesRestore', @MaintLogMessage = 'DimTitles Validated. Check Validation Log.';

		SET @RC = 1;
	END TRY
	BEGIN CATCH
	
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		EXEC pErrorHandler;
		RETURN 55555;
		
		DECLARE @ErrorMessage NVARCHAR(1000) = Error_Message();
		EXEC dbo.pInsMaintLog @MaintAction = 'pMaintValidateDimTitlesRestore', @MaintLogMessage = @ErrorMessage;

		SET @RC = -1;
	END CATCH

	RETURN @RC;
END
GO

-- EXEC dbo.pMaintValidateDimTitlesRestore;
-- SELECT * FROM dbo.vMaintLog;
-- SELECT * FROM dbo.vValidationLog;

CREATE OR ALTER PROCEDURE dbo.pMaintValidateFactSalesRestore @RC INT = 0 AS
BEGIN
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @CurrentCount INT;
		DECLARE @RestoredCount INT;
		DECLARE @CurrentDateTime DATETIME = GetDate();

		-- test row counts
		SELECT @CurrentCount = COUNT(*)
		FROM DWIndependentBookSellers.dbo.FactSales;

		SELECT @RestoredCount = COUNT(*)
		FROM DWIndependentBookSellersRestored.dbo.FactSales;

		IF (@CurrentCount = @RestoredCount)
		BEGIN
			EXEC dbo.pInsValidationLog @ValidationDateTime = @CurrentDateTime
				, @ValidationObject = 'pMaintValidateFactSalesRestore'
				, @ValidationStatus = 'Success'
				, @ValidationMessage = 'FactSales Row Count Test';
		END
		ELSE
		BEGIN
			EXEC dbo.pInsValidationLog @ValidationDateTime = @CurrentDateTime
				, @ValidationObject = 'pMaintValidateFactSalesRestore'
				, @ValidationStatus = 'Failed'
				, @ValidationMessage = 'FactSales Row Count Test';
		END

		-- compare data
		DECLARE @DuplicateCount INT;

		SELECT @DuplicateCount = COUNT(*)
		FROM (
				SELECT * FROM DWIndependentBookSellers.dbo.FactSales
				EXCEPT
				SELECT * FROM DWIndependentBookSellersRestored.dbo.Factsales
		) AS Results;

		IF @DuplicateCount = 0
		BEGIN
			EXEC dbo.pInsValidationLog @ValidationDateTime = @CurrentDateTime
				, @ValidationObject = 'pMaintValidateFactSalesRestore'
				, @ValidationStatus = 'Success'
				, @ValidationMessage = 'FactSales Duplicate Test';
		END
		ELSE
		BEGIN
			EXEC dbo.pInsValidationLog @ValidationDateTime = @CurrentDateTime
				, @ValidationObject = 'pMaintValidateFactSalesRestore'
				, @ValidationStatus = 'Failed'
				, @ValidationMessage = 'FactSales Duplicate Test';
		END

		EXEC dbo.pInsMaintLog @MaintAction = 'pMaintValidateFactSalesRestore', @MaintLogMessage = 'FactSales Validated. Check Validation Log.';

		SET @RC = 1;
	END TRY
	BEGIN CATCH
		
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		EXEC pErrorHandler;
		RETURN 55555;
		
		DECLARE @ErrorMessage NVARCHAR(1000) = Error_Message();
		EXEC dbo.pInsMaintLog @MaintAction = 'pMaintValidateFactSalesRestore', @MaintLogMessage = @ErrorMessage;

		SET @RC = -1;
	END CATCH

	RETURN @RC;
END
GO

-- EXEC dbo.pMaintValidateFactSalesRestore;
-- SELECT * FROM dbo.vMaintLog;
-- SELECT * FROM dbo.vValidationLog;

CREATE OR ALTER PROCEDURE dbo.pMaintValidateFactTitleAuthorsRestore @RC INT = 0 AS
BEGIN
	SET NOCOUNT, XACT_ABORT ON;

	BEGIN TRY
		DECLARE @CurrentCount INT;
		DECLARE @RestoredCount INT;
		DECLARE @CurrentDateTime DATETIME = GetDate();

		-- test row counts
		SELECT @CurrentCount = COUNT(*)
		FROM DWIndependentBookSellers.dbo.FactTitleAuthors;

		SELECT @RestoredCount = COUNT(*)
		FROM DWIndependentBookSellersRestored.dbo.FactTitleAuthors;

		IF (@CurrentCount = @RestoredCount)
		BEGIN
			EXEC dbo.pInsValidationLog @ValidationDateTime = @CurrentDateTime
				, @ValidationObject = 'pMaintValidateFactTitleAuthorsRestore'
				, @ValidationStatus = 'Success'
				, @ValidationMessage = 'FactTitleAuthors Row Count Test';
		END
		ELSE
		BEGIN
			EXEC dbo.pInsValidationLog @ValidationDateTime = @CurrentDateTime
				, @ValidationObject = 'pMaintValidateFactTitleAuthorsRestore'
				, @ValidationStatus = 'Failed'
				, @ValidationMessage = 'FactTitleAuthors Row Count Test';
		END

		-- compare data
		DECLARE @DuplicateCount INT;

		SELECT @DuplicateCount = COUNT(*)
		FROM (
				SELECT * FROM DWIndependentBookSellers.dbo.FactTitleAuthors
				EXCEPT
				SELECT * FROM DWIndependentBookSellersRestored.dbo.FactTitleAuthors
		) AS Results;

		IF @DuplicateCount = 0
		BEGIN
			EXEC dbo.pInsValidationLog @ValidationDateTime = @CurrentDateTime
				, @ValidationObject = 'pMaintValidateFactTitleAuthorsRestore'
				, @ValidationStatus = 'Success'
				, @ValidationMessage = 'FactTitleAuthors Duplicate Test';
		END
		ELSE
		BEGIN
			EXEC dbo.pInsValidationLog @ValidationDateTime = @CurrentDateTime
				, @ValidationObject = 'pMaintValidateFactTitleAuthorsRestore'
				, @ValidationStatus = 'Failed'
				, @ValidationMessage = 'FactTitleAuthors Duplicate Test';
		END

		EXEC dbo.pInsMaintLog @MaintAction = 'pMaintValidateFactTitleAuthorsRestore', @MaintLogMessage = 'FactTitleAuthors Validated. Check Validation Log.';

		SET @RC = 1;
	END TRY
	BEGIN CATCH
		
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		EXEC pErrorHandler;
		RETURN 55555;
		
		DECLARE @ErrorMessage NVARCHAR(1000) = Error_Message();
		EXEC dbo.pInsMaintLog @MaintAction = 'pMaintValidateFactTitleAuthorsRestore', @MaintLogMessage = @ErrorMessage;
		
		SET @RC = -1;
	END CATCH

	RETURN @RC;
END
GO

-- EXEC dbo.pMaintValidateFactTitleAuthorsRestore;
-- SELECT * FROM dbo.vMaintLog;
-- SELECT * FROM dbo.vValidationLog;

/****** Test ******/
/*
	-- clear tables before test
	TRUNCATE TABLE DWIndependentBookSellers.dbo.MaintLog;

	SELECT * FROM vMaintLog;

	TRUNCATE TABLE DWIndependentBookSellers.dbo.ValidationLog;

	SELECT * FROM vValidationLog;

	-- test maint
	EXEC dbo.pMaintIndexes;

	EXEC dbo.pMaintDBBackup;

	EXEC dbo.pMaintRestore;

	EXEC dbo.pMaintValidateDimDatesRestore;

	EXEC dbo.pMaintValidateDimAuthorsRestore;

	EXEC dbo.pMaintValidateDimTitlesRestore;

	EXEC dbo.pMaintValidateDimStoresRestore;

	EXEC dbo.pMaintValidateFactTitleAuthorsRestore;

	EXEC dbo.pMaintValidateFactSalesRestore;
	GO

	SELECT * FROM dbo.vMaintLog;

	SELECT * FROM dbo.vValidationLog;

	-- test validation
	-- force a failure
	UPDATE dbo.DimTitles
	SET [TitleName] = 'ZZZZThe Busy Executive''s Database Guide'
	WHERE [TitleId] = 'BU1032';

	SELECT * FROM DWIndependentBookSellers.dbo.DimTitles;

	SELECT * FROM DWIndependentBookSellersRestored.dbo.DimTitles;

	EXEC dbo.pMaintValidateDimTitlesRestore;

	SELECT *
	FROM vValidationLog
	WHERE ValidationObject = 'pMaintValidateDimTitlesRestore';

	-- reset to original value
	UPDATE dbo.DimTitles
	SET [TitleName] = 'The Busy Executive''s Database Guide'
	WHERE [TitleId] = 'BU1032';
	GO
*/
