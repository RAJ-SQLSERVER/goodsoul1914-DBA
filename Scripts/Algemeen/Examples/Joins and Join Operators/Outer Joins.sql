USE AdventureWorks2017;
GO

-- ==========================================
-- Demonstrates the semantics of Outer Joins
-- ==========================================
/***************************************************
		Inner		Outer			1st phase		2nd phase		3rd phase
		-------		-------			---------		---------		---------
		1			1				1	1		->	1	1		->	1	1
		2			2				1	2
		3							2	1
									2	2		->	2	2		->	2	2
									3	1						->	3	NULL
									3	2							
***************************************************/
-- Execute the query with an Outer Join.
-- Now we are also getting back customers that haven't placed orders.
-- The left table is the preserving one, and missing rows from the right table are added
-- SQL Server performs a Merge Join (Left Outer Join) in the execution plan.
SELECT c.CustomerID,
	soh.SalesOrderID
FROM Sales.Customer AS c
LEFT JOIN Sales.SalesOrderHeader AS soh ON soh.CustomerID = c.CustomerID;
GO

-- You can rewrite the query above with a Right Outer Join when you swap the order
-- of the tables. This time you get back the same result.
SELECT c.CustomerID,
	soh.SalesOrderID
FROM Sales.SalesOrderHeader AS soh
RIGHT JOIN Sales.Customer AS c ON c.CustomerID = soh.CustomerID;
GO

-- If you eliminate the NULL extended rows, the Query Optimizer transforms the
-- Outer Join to an Inner Join.
SELECT c.CustomerID,
	soh.SalesOrderID
FROM Sales.SalesOrderHeader AS soh
LEFT JOIN Sales.Customer AS c ON c.CustomerID = soh.CustomerID
WHERE c.CustomerID IS NOT NULL;
GO


