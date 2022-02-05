-- 01_source_database.sql creates the data warehouse source IndependentBookSellers.
-- Before executing this script, the Pubs database must be created by running 00_Pubs.sql.

USE master
GO

IF EXISTS (SELECT [name] FROM sysdatabases WHERE Name = 'IndependentBookSellers')
BEGIN
	ALTER DATABASE IndependentBookSellers SET Single_User WITH ROLLBACK Immediate;
	DROP DATABASE IndependentBookSellers;
END
GO

CREATE DATABASE IndependentBookSellers;
GO

USE IndependentBookSellers;
GO

SELECT [au_id], [au_lname], [au_fname], [phone], [address], [city], [state], [zip]
INTO Authors
FROM Pubs.dbo.authors;
GO

SELECT [title_id], [title], [type], [price]
INTO Titles
FROM Pubs.dbo.titles;
GO

SELECT [au_id], [title_id], [au_ord] = CAST([au_ord] AS INT)
INTO TitleAuthors
FROM Pubs.dbo.titleauthor;
GO

SELECT [stor_id], [stor_name], [stor_address], [city], [state], [zip]
INTO [Stores]
FROM Pubs.dbo.stores;
GO

SELECT DISTINCT [ord_num], [ord_date], [stor_id]
INTO SalesHeaders
FROM Pubs.dbo.sales;
GO

SELECT [ord_num], [t].[title_id], [qty], [price]
INTO SalesDetails
FROM Pubs.dbo.sales AS s
INNER JOIN Pubs.dbo.titles AS t
	ON s.[title_id] = t.[title_id];
GO

ALTER TABLE Stores ADD CONSTRAINT pkStores PRIMARY KEY ([stor_id]);
GO

ALTER TABLE SalesHeaders ADD CONSTRAINT pkSalesHeaders PRIMARY KEY ([ord_num]);
GO

ALTER TABLE SalesDetails ADD CONSTRAINT pkSalesDetails PRIMARY KEY ([ord_num], [title_id]);
GO

ALTER TABLE Titles ADD CONSTRAINT pkTitles PRIMARY KEY ([title_id]);
GO

ALTER TABLE TitleAuthors ADD CONSTRAINT pkTitleAuthors PRIMARY KEY ([au_id], [title_id]);
GO

ALTER TABLE Authors ADD CONSTRAINT pkAuthors PRIMARY KEY ([au_id]);
GO

ALTER TABLE SalesHeaders ADD CONSTRAINT fkSalesHeadersToStores FOREIGN KEY ([stor_id]) REFERENCES Stores ([stor_id]);
GO

ALTER TABLE SalesDetails ADD CONSTRAINT fkSalesDetailsToSales FOREIGN KEY ([ord_num]) REFERENCES SalesHeaders ([ord_num]);
GO

ALTER TABLE SalesDetails ADD CONSTRAINT fkSalesDetailsToTitles FOREIGN KEY ([title_id]) REFERENCES Titles ([title_id]);
GO

ALTER TABLE TitleAuthors ADD CONSTRAINT fkTitleAuthorsToTitles FOREIGN KEY ([title_id]) REFERENCES Titles ([title_id]);
GO

ALTER TABLE TitleAuthors ADD CONSTRAINT fkTitleAuthorsToAuthors FOREIGN KEY ([au_id]) REFERENCES Authors ([au_id]);
GO

SELECT SourceObjectName = TABLE_CATALOG + '.' + TABLE_SCHEMA + '.' + TABLE_NAME + '.' + COLUMN_NAME
	, DataType = DATA_TYPE + IIF(CHARACTER_MAXIMUM_LENGTH IS NULL, '', '(' + Cast(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(10)) + ')')
	, Nullable = IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS;
GO

SELECT *
FROM dbo.Authors;

SELECT *
FROM dbo.TitleAuthors;

SELECT *
FROM dbo.Titles;

SELECT *
FROM dbo.Stores;

SELECT *
FROM dbo.SalesHeaders;

SELECT *
FROM dbo.SalesDetails;
GO
