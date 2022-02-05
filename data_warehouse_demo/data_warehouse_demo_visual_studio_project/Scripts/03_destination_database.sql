-- 03_destination_database.sql creates the data warehouse DWIndependentBookSellers.
-- Before executing this script, the IndependentBookSellers database must be created by running 01_source_database.

USE master
GO

IF EXISTS (SELECT [name] FROM sysdatabases WHERE [name] = 'DWIndependentBookSellers')
BEGIN
	ALTER DATABASE DWIndependentBookSellers SET Single_User WITH ROLLBACK Immediate;
	DROP DATABASE DWIndependentBookSellers;
END
GO

CREATE DATABASE DWIndependentBookSellers;
GO

USE DWIndependentBookSellers;
GO

CREATE TABLE dbo.DimDates (
	[DateKey] INT CONSTRAINT pkDimDates PRIMARY KEY
	, [FullDate] DATE NOT NULL
	, [USADateName] NVARCHAR(100) NOT NULL
	, [MonthKey] INT NOT NULL
	, [MonthName] NVARCHAR(100) NOT NULL
	, [QuarterKey] INT NOT NULL
	, [QuarterName] NVARCHAR(100) NOT NULL
	, [YearKey] INT NOT NULL
	, [YearName] NVARCHAR(100) NOT NULL
);
GO

CREATE TABLE dbo.DimAuthors (
	[AuthorKey] INT Identity CONSTRAINT pkDimAuthors PRIMARY KEY
	, [AuthorID] NVARCHAR(11) NOT NULL
	, [AuthorName] NVARCHAR(100) NOT NULL
	, [AuthorCity] NVARCHAR(100) NOT NULL
	, [AuthorState] NCHAR(2) NOT NULL
);
GO

CREATE TABLE dbo.DimTitles (
	[TitleKey] INT Identity CONSTRAINT pkDimTitles PRIMARY KEY
	, [TitleID] NVARCHAR(6) NOT NULL
	, [TitleName] NVARCHAR(100) NOT NULL
	, [TitleType] NVARCHAR(100) NOT NULL
	, [TitleListPrice] DECIMAL(18, 4) NOT NULL
);
GO

CREATE TABLE dbo.DimStores (
	[StoreKey] INT Identity CONSTRAINT pkDimStores PRIMARY KEY
	, [StoreID] NCHAR(4) NOT NULL
	, [StoreName] NVARCHAR(100) NOT NULL
	, [StoreCity] NVARCHAR(100) NOT NULL
	, [StoreState] NCHAR(2) NOT NULL
);
GO

CREATE TABLE dbo.FactTitleAuthors (
	[AuthorKey] INT NOT NULL
	, [TitleKey] INT NOT NULL
	, [AuthorOrder] INT NOT NULL CONSTRAINT pkFactTitleAuthors PRIMARY KEY ([AuthorKey], [TitleKey], [AuthorOrder])
);
GO

CREATE TABLE dbo.FactSales (
	[OrderNumber] NVARCHAR(20) NOT NULL
	, [OrderDateKey] INT NOT NULL
	, [StoreKey] INT NOT NULL
	, [TitleKey] INT NOT NULL
	, [SalesQty] INT NOT NULL
	, [SalesPrice] DECIMAL(18, 4) NOT NULL CONSTRAINT pkFactSales PRIMARY KEY ([OrderNumber], [OrderDateKey], [StoreKey], [TitleKey])
);
GO

ALTER TABLE dbo.FactTitleAuthors ADD CONSTRAINT fkFactTitleAuthorsToDimAuthors FOREIGN KEY ([AuthorKey]) REFERENCES [DimAuthors] ([AuthorKey]);
GO

ALTER TABLE FactTitleAuthors ADD CONSTRAINT fkFactTitleAuthorsToDimTitles FOREIGN KEY ([TitleKey]) REFERENCES [DimTitles] ([TitleKey]);
GO

ALTER TABLE FactSales ADD CONSTRAINT fkFactSalesToDimDates FOREIGN KEY ([OrderDateKey]) REFERENCES [DimDates] ([DateKey]);
GO

ALTER TABLE FactSales ADD CONSTRAINT fkFactSalesToDimTitles FOREIGN KEY ([TitleKey]) REFERENCES [DimTitles] ([TitleKey]);
GO

ALTER TABLE FactSales ADD CONSTRAINT fkFactSalesToDimStores FOREIGN KEY ([StoreKey]) REFERENCES [DimStores] ([StoreKey]);
GO

SELECT SourceObjectName = TABLE_CATALOG + '.' + TABLE_SCHEMA + '.' + TABLE_NAME + '.' + COLUMN_NAME
	, DataType = DATA_TYPE + IIF(CHARACTER_MAXIMUM_LENGTH IS NULL, '', '(' + Cast(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(10)) + ')')
	, Nullable = IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
GO
