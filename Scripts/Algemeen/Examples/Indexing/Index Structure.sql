-- Demo script for Index Structure demo
USE [master];
GO

IF DATABASEPROPERTYEX(N'Company', N'Version') > 0
BEGIN
	ALTER DATABASE [Company]

	SET SINGLE_USER
	WITH

	ROLLBACK IMMEDIATE;

	DROP DATABASE [Company];
END
GO

CREATE DATABASE [Company];
GO

USE [Company];
GO

-- Create a simple test table to use
CREATE TABLE [Random] (
	[intCol] INT,
	[charCol] CHAR(4000)
	);

INSERT INTO [Random]
VALUES (
	1,
	REPLICATE('Row1', 1000)
	);
GO

INSERT INTO [Random]
VALUES (
	3,
	REPLICATE('Row3', 1000)
	);
GO

INSERT INTO [Random]
VALUES (
	5,
	REPLICATE('Row5', 1000)
	);
GO

INSERT INTO [Random]
VALUES (
	7,
	REPLICATE('Row7', 1000)
	);
GO

INSERT INTO [Random]
VALUES (
	9,
	REPLICATE('Row9', 1000)
	);
GO

INSERT INTO [Random]
VALUES (
	11,
	REPLICATE('Row11', 800)
	);
GO

INSERT INTO [Random]
VALUES (
	13,
	REPLICATE('Row13', 800)
	);
GO

INSERT INTO [Random]
VALUES (
	15,
	REPLICATE('Row15', 800)
	);
GO

INSERT INTO [Random]
VALUES (
	17,
	REPLICATE('Row17', 800)
	);
GO

INSERT INTO [Random]
VALUES (
	19,
	REPLICATE('Row19', 800)
	);
GO

INSERT INTO [Random]
VALUES (
	21,
	REPLICATE('Row21', 800)
	);
GO

INSERT INTO [Random]
VALUES (
	23,
	REPLICATE('Row23', 800)
	);
GO

-- And a clustered index
CREATE CLUSTERED INDEX [Random_CL] ON [Random] ([intCol]);
GO

-- Trace flag is required for undocumented DBCC output
DBCC TRACEON (3604);
GO

-- Undocumented command to list interesting pages
DBCC SEMETADATA(N'Random');
GO

-- Dump the root page
DBCC PAGE(N'Company', 1, xx, 3);
GO

-- Explain the non-contiguous first few pages
-- Pick a page with a contiguous next page
DBCC PAGE(N'Company', 1, xx, 3);
GO

-- Follow the left-to-right linkage
DBCC PAGE(N'Company', 1, xx, 3);
GO


