-- 06_etl_reportin_objects.sql creates ETL views that are used in reports.
-- Before executing this script, the DWIndependentBookSellers database must be created by running 03_destination_database.

USE DWIndependentBookSellers
GO

-- SELECT * FROM msdb.dbo.sysjobs;
-- SELECT * FROM msdb.dbo.sysjobhistory;
-- EXEC MSDB.dbo.sp_purge_jobhistory;  

CREATE OR ALTER VIEW dbo.vDWIndependentBookSellersETLJobHistory AS (
	SELECT TOP 100000 [JobName] = j.[name]
		, [StepName] = h.[step_name]
		, [RunDateTime] = [msdb].[dbo].[agent_datetime]([run_date], [run_time])
		, [RunDurationSeconds] = h.[run_duration]
	FROM msdb.dbo.sysjobs AS j
	INNER JOIN msdb.dbo.sysjobhistory AS h
		ON j.[job_id] = h.[job_id]
	WHERE j.[enabled] = 1
		AND j.[name] = 'DWIndependentBookSellersETL'
		AND h.[step_name] <> '(Job outcome)'
	ORDER BY 1, 3 DESC
);
GO

CREATE OR ALTER VIEW dbo.vDimDatesTopTen AS (
	SELECT TOP(10) [DateKey], [FullDate], [USADateName], [MonthKey], [MonthName], [QuarterKey], [QuarterName], [YearKey], [YearName]
	FROM dbo.DimDates
	ORDER BY 1 DESC
);
GO

SELECT *
FROM dbo.vDimDatesTopTen;
GO

CREATE OR ALTER VIEW dbo.vDimAuthorsTopTen AS (
	SELECT TOP(10) [AuthorKey], [AuthorID], [AuthorName], [AuthorCity], [AuthorState]
	FROM dbo.DimAuthors
	ORDER BY 1 ASC
);
GO

SELECT *
FROM dbo.vDimAuthorsTopTen;
GO

CREATE OR ALTER VIEW dbo.vDimTitlesTopTen AS (
	SELECT TOP(10) [TitleKey], [TitleID], [TitleName], [TitleType], [TitleListPrice]
	FROM dbo.DimTitles
	ORDER BY 1 ASC
);
GO

SELECT *
FROM dbo.vDimTitlesTopTen;
GO

CREATE OR ALTER VIEW dbo.vDimStoresTopTen AS (
	SELECT TOP(10) [StoreKey], [StoreID], [StoreName], [StoreCity], [StoreState]
	FROM dbo.DimStores
	ORDER BY 1 ASC
);
GO

SELECT *
FROM dbo.vDimStoresTopTen;
GO

CREATE OR ALTER VIEW dbo.vFactTitleAuthorsTopTen AS (
	SELECT TOP(10) [AuthorKey], [TitleKey], [AuthorOrder]
	FROM [FactTitleAuthors]
	ORDER BY 1 ASC
);
GO

SELECT *
FROM dbo.vFactTitleAuthorsTopTen;
GO

CREATE OR ALTER VIEW dbo.vFactSalesTopTen AS (
	SELECT TOP(10) [OrderNumber], [OrderDateKey], [StoreKey], [TitleKey], [SalesQty], [SalesPrice]
	FROM dbo.FactSales
	ORDER BY 1 ASC
);
GO

SELECT *
FROM dbo.vFactSalesTopTen;
GO

CREATE OR ALTER VIEW dbo.DWIndependentBookSellersRowCounts AS
	WITH RowCounts AS (
		SELECT [SortCol] = 1
			, [TableName] = 'DimDates'
			, [CurrentNumberOfRows] = Count(*)
		FROM [DimDates]
		
		UNION
		
		SELECT [SortCol] = 2
			, [TableName] = 'DimAuthors'
			, [CurrentNumberOfRows] = Count(*)
		FROM [DimAuthors]
		
		UNION
		
		SELECT [SortCol] = 3
			, [TableName] = 'DimTitles'
			, [CurrentNumberOfRows] = Count(*)
		FROM [DimTitles]
		
		UNION
		
		SELECT [SortCol] = 3
			, [TableName] = 'DimStores'
			, [CurrentNumberOfRows] = Count(*)
		FROM [DimStores]
		
		UNION
		
		SELECT [SortCol] = 4
			, [TableName] = 'FactTitleAuthors'
			, [CurrentNumberOfRows] = Count(*)
		FROM [FactTitleAuthors]
		
		UNION
		
		SELECT [SortCol] = 4
			, [TableName] = 'FactSales'
			, [CurrentNumberOfRows] = Count(*)
		FROM [FactSales]
		
		UNION
		
		SELECT [SortCol] = 5
			, [TableName] = 'ETLMetadata'
			, [CurrentNumberOfRows] = Count(*)
		FROM [ETLMetadata]
	)
	SELECT TOP 100000 [SortCol], [TableName], [CurrentNumberOfRows]
	FROM RowCounts
	ORDER BY [SortCol] ASC;
GO

SELECT *
FROM DWIndependentBookSellersRowCounts;
GO

/*
-- test validation
-- create a differences between the source and destination databases
UPDATE IndependentBookSellers.dbo.Stores
SET [stor_name] = 'Bookbeatzz'
WHERE [stor_id] = 8042;
GO

SELECT *
FROM IndependentBookSellers.dbo.Stores;
GO

-- verify the difference
SELECT *
FROM dbo.vETLDimStores;
GO

SELECT *
FROM dbo.DimStores;
GO

-- reset the data
UPDATE IndependentBookSellers.dbo.Stores
SET [stor_name] = 'Bookbeat'
WHERE [stor_id] = 8042;
GO
*/
