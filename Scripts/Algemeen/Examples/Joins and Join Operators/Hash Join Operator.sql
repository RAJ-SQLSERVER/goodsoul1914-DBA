-- =====================================================
-- Demonstrates the semantics of Hash Joins
--
-- Used when joining big unindexed tables together (DWH)
-- Memory Grant is required
-- When memory grant is too small (because of bad 
-- 	  statistics) the hash join will spill to tempdb
-- =====================================================
/****************************************
												
	A:	1, 3, 5, 2, 1, 6, 8, 7				
		
	B:	3, 1, 2, 5, 3, 7, 1, 4

	
	#1 Build phase		#2 Probe phase
	
	Hash buckets:		
	------|-------
	1, 1	2			3, 1, 2, 5, 3, 7  -> upstream operator
	3		6
	5		8
	7

****************************************/
SELECT p1.FirstName,
	p1.LastName,
	p2.PhoneNumber
FROM Person.Person AS p1
INNER JOIN Person.PersonPhone AS p2 ON p1.BusinessEntityID = p2.BusinessEntityID;
GO

-- Hash Spill
USE Playground
GO

CREATE TABLE Table1 (
	Column1 INT identity PRIMARY KEY,
	Column2 INT,
	Column3 CHAR(2000),
	Column4 CHAR(2000)
	)
GO

CREATE NONCLUSTERED INDEX idxTable1_Column2 ON Table1 (Column2)
GO

SELECT TOP 1500 IDENTITY(INT, 1, 1) AS n
INTO #Nums
FROM master.dbo.syscolumns sc1

INSERT INTO Table1 (
	Column2,
	Column3
	)
SELECT n,
	REPLICATE('x', 2000)
FROM #Nums

DROP TABLE #Nums
GO

SELECT *
FROM Table1
GO

CREATE TABLE Table2 (
	Column1 INT identity PRIMARY KEY,
	Column2 INT,
	Column3 CHAR(2000)
	)
GO

CREATE NONCLUSTERED INDEX idxTable2_Column2 ON Table1 (Column2)
GO

SELECT TOP 1500 IDENTITY(INT, 1, 1) AS n
INTO #Nums
FROM master.dbo.syscolumns sc1

INSERT INTO Table2 (
	Column2,
	Column3
	)
SELECT n,
	REPLICATE('x', 2000)
FROM #Nums

DROP TABLE #Nums
GO

SELECT *
FROM Table2
GO

-- Execute our problematic SQL statement in the 1st step
-- Therefore SQL server is able to produce and cache a suboptimal
-- execution plan, which will be reused afterwards
SELECT *
FROM Table1 t1
INNER HASH JOIN Table2 t2 ON t2.Column2 = t1.Column2
WHERE t1.Column2 = 2
GO

-- insert 799 additional rows into the 1st table
-- statistics will not be updated (800 data changes!)
SELECT TOP 799 IDENTITY(INT, 1, 1) AS n
INTO #Nums
FROM master.dbo.syscolumns sc1

INSERT INTO Table1 (
	Column2,
	Column3
	)
SELECT 2,
	REPLICATE('x', 2000)
FROM #Nums

DROP TABLE #Nums
GO

-- insert 799 additional rows into the 2nd table
-- statistics will not be updated (800 data changes!)
SELECT TOP 799 IDENTITY(INT, 1, 1) AS n
INTO #Nums
FROM master.dbo.syscolumns sc1

INSERT INTO Table2 (
	Column2,
	Column3
	)
SELECT 2,
	REPLICATE('x', 2000)
FROM #Nums

DROP TABLE #Nums
GO

-- This query will produce a hash spill because of inaccurate statistics
-- SQL Server estimates 1 row for the hash join and requests a memory grant of 1 MB
SELECT *
FROM Table1 t1
INNER HASH JOIN Table2 t2 ON t2.Column2 = t1.Column2
WHERE t1.Column2 = 2
GO

-- Update statistics to fix it
UPDATE STATISTICS Table1
WITH fullscan

UPDATE STATISTICS Table2
WITH fullscan
GO


