USE AdventureWorks2017;
GO

SET STATISTICS IO ON;
GO

-- ==========================================
-- Demonstrates the semantics of Cross Joins
-- ==========================================
/*****************************
		Table 1		Table 2			1st phase
		-------		-------			---------
		1			1				1	1	
		2			2				1	2
		3							2	1
									2	2		
									3	1					
									3	2							
*****************************/
-- Cross Join (Carthesian Product)
-- Returns 10.920 (105 x 104) records.
-- The execution plan shows you a Nested Loop operator without a Join Predicate.
SELECT c.*,
	v.*
FROM Sales.Currency AS c -- 105 records
CROSS JOIN Purchasing.Vendor AS v;-- 104 records
GO

-- Self-Joining tables
-- Generates currency pairs (with mirror and self pairs).
SELECT c1.CurrencyCode + ' - ' + c2.CurrencyCode
FROM Sales.Currency AS c1
CROSS JOIN Sales.Currency AS c2;
GO

-- ============================================================================
-- Demonstrates how to create number sequences with cross joins
-- ============================================================================
USE Playground;
GO

CREATE TABLE Numbers (Num INT NOT NULL PRIMARY KEY);
GO

-- Insert all digits
INSERT INTO Numbers
VALUES (0),
	(1),
	(2),
	(3),
	(4),
	(5),
	(6),
	(7),
	(8),
	(9);
GO

-- Creates a table with 1000000 records - large enough to produce 
-- parallel execution plans
SELECT n6.Num * 100000 + n5.Num * 10000 + n4.Num * 1000 + n3.Num * 100 + n2.Num * 10 + n1.Num + 1 AS 'Number',
	CAST('Some Data....' AS CHAR(500)) AS 'SomeData'
INTO LargeTable
FROM Numbers AS n1
CROSS JOIN Numbers AS n2
CROSS JOIN Numbers AS n3
CROSS JOIN Numbers AS n4
CROSS JOIN Numbers AS n5
CROSS JOIN Numbers AS n6
ORDER BY Number;
GO
