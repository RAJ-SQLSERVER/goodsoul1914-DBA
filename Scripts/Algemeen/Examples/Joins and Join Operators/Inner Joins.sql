USE AdventureWorks2017;
GO

-- ==========================================
-- Demonstrates the semantics of Inner Joins
-- ==========================================
/****************************************
		Table 1		Table 2			1st phase		2nd phase
		-------		-------			---------		---------
		1			1				1	1		->	1	1	
		2			2				1	2
		3							2	1
									2	2		->	2	2	
									3	1					
									3	2							
****************************************/
-- Returns 121.317 rows
-- Returns for each SalesOrderHeader record all associated SalesOrderDetail records.
-- SQL Server performs a Merge Join, because both tables are physically sorted
-- by the column "SalesOrderID".
SELECT soh.SalesOrderID,
	soh.CustomerID,
	sod.SalesOrderDetailID,
	sod.ProductID,
	sod.LineTotal
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod ON sod.SalesOrderID = soh.SalesOrderID;
GO

-- The logical ordering of the tables during an Inner Join
-- does not matter. It is up to the Query Optimizer to arrange
-- the tables in the best order.
-- This query produces the same execution plan as the previous one.
SELECT soh.SalesOrderID,
	soh.CustomerID,
	sod.SalesOrderDetailID,
	sod.ProductID,
	sod.LineTotal
FROM Sales.SalesOrderDetail AS sod
INNER JOIN Sales.SalesOrderHeader AS soh ON soh.SalesOrderID = sod.SalesOrderID
ORDER BY SalesOrderID;
GO

--	We have only 13976 rows with a non-NULL value in the column "CurrencyRateID"
-- Count(*) also counts NULL values
SELECT COUNT(CurrencyRateID),
	COUNT(*)
FROM Sales.SalesOrderHeader;
GO

-- When we perform an Inner Join where the Join Predicate column has NULL value
-- the rows with the NULL values are not returned.
-- If you want to preserve these rows, you need an Outer Join.
-- This query returns only the 13976 non-NULL rows.
SELECT cr.CurrencyRateID
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.CurrencyRate AS cr ON cr.CurrencyRateID = soh.CurrencyRateID;
GO


