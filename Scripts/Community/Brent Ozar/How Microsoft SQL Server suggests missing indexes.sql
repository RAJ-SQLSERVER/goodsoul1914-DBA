/*
 How are missing index hints built?

 - How SQL Server picks missing index column order
 - What SQL Server doesn't consider: selectivity or statistics

 - EQUALITY searches go first (order by the column they are in the table)
 - INEQUALITY searches go second (order by the column they are in the table)

 */

USE Playground;
GO

--DROP TABLE dbo.DiningRoom;

-- A statistic is 1 8KB page of index metadata
-- Microsoft Fast Track Data Warehouse Reference Architecture

CREATE TABLE dbo.DiningRoom (
    FirstColumn  INT NULL,
    SecondColumn INT NULL,
    ThirdColumn  INT NULL,
    FourthColumn INT NULL,
    FifthColumn  INT NULL,
    SixthColumn  INT NULL
);

INSERT INTO dbo.DiningRoom (FirstColumn, SecondColumn, ThirdColumn, FourthColumn, FifthColumn, SixthColumn)
SELECT TOP (10000000) 1,
                      1,
                      1,
                      1,
                      1,
                      1
FROM sys.all_columns AS ac1
CROSS JOIN sys.all_columns AS ac2
CROSS JOIN sys.all_columns AS ac3;
GO

SELECT TOP (100) *
FROM dbo.DiningRoom;

SET STATISTICS TIME, IO ON;

-------------------------------------------------------------------------------
-- EQUALITY
-------------------------------------------------------------------------------

SELECT 'Hi Mom!'
FROM dbo.DiningRoom
WHERE FirstColumn = 0;
GO

SELECT 'Hi Mom!'
FROM dbo.DiningRoom
WHERE SecondColumn = 0;
GO

SELECT 'Hi Mom!'
FROM dbo.DiningRoom
WHERE FirstColumn = 0
      AND SecondColumn = 0;
GO

SELECT 'Hi Mom!'
FROM dbo.DiningRoom
WHERE SecondColumn = 0
      AND FirstColumn = 0;
GO

-------------------------------------------------------------------------------
-- SELECTIVITY
--
-- If our where clause looks for one thing that doesn't exist and one thing  that 
-- does, will SQL Server put the thing that doesn't exist first
-------------------------------------------------------------------------------

SELECT 'Hi Mom!'
FROM dbo.DiningRoom
WHERE FirstColumn = 1 -- unselective
      AND SecondColumn = 0; -- selective
GO

SELECT 'Hi Mom!'
FROM dbo.DiningRoom
WHERE FirstColumn = 0 -- selective
      AND SecondColumn = 1; -- unselective
GO

-------------------------------------------------------------------------------
-- INEQUALITY
-------------------------------------------------------------------------------

SELECT 'Hi Mom!'
FROM dbo.DiningRoom
WHERE FirstColumn <> 1
      AND SecondColumn <> 1;
GO

SELECT 'Hi Mom!'
FROM dbo.DiningRoom
WHERE FirstColumn = 1
      AND SecondColumn <> 1;
GO

SELECT 'Hi Mom!'
FROM dbo.DiningRoom
WHERE FirstColumn <> 1
      AND SecondColumn = 1;
GO

SELECT 'Hi Mom!'
FROM dbo.DiningRoom
WHERE FirstColumn IS NULL -- EQUALITY
      AND SecondColumn IS NOT NULL; -- INEQUALITY
GO

SELECT 'Hi Mom!'
FROM dbo.DiningRoom
WHERE ThirdColumn = 0
      AND FourthColumn <> 1;
GO

SELECT 'Hi Mom!'
FROM dbo.DiningRoom
WHERE FourthColumn <> 1
      AND SecondColumn = 0;
GO

SELECT 'Hi Mom!'
FROM dbo.DiningRoom
WHERE FirstColumn <> SecondColumn;
GO
-- Cannot be seeked into, because ALL rows have to be read
-- So no index recommendations!


SELECT 'Hi Mom!'
FROM dbo.DiningRoom
WHERE FourthColumn = 0
      AND FirstColumn <> 0
      AND ThirdColumn = 0;
GO

SELECT 'Hi Mom!'
FROM dbo.DiningRoom
WHERE FirstColumn <> 0
      AND SecondColumn = 0
      AND FirstColumn IS NOT NULL
      AND ThirdColumn = 1;
GO
