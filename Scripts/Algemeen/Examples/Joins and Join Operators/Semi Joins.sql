USE AdventureWorks2017;
GO

-- ==========================================
-- Demonstrates the semantics of Semi Joins
-- ==========================================
/***************************
		Table 1		Table 2			Result
		-------		-------			-------
		1			1				1
		2			3				3
		3		
***************************/
-- Returns all customers from Sales.Territory 3 who have placed orders.
-- SQL Server uses a "Nested Loop" (Left Semi Join) in the execution plan.
-- With a semi join, SQL Server just probes if there are matching records,
-- without returning the records themselves.
-- The NCI Seek was performed 132 times, and 69 times a matching
-- record in the table "Sales.SalesOrderHeader" was found.
SELECT *
FROM Sales.Customer AS c
WHERE c.TerritoryID = 3
	AND EXISTS (
		SELECT 1
		FROM Sales.SalesOrderHeader AS h
		WHERE h.CustomerID = c.CustomerID
		);
GO

-- Returns all customers from Sales.Territory 3 who have not placed any orders.
-- SQL Server uses a "Nested Loop" (Left Anti Semi Join) in the execution plan.
-- With an Anti Semi Join, SQL Server just probes if there are no matching records,
-- without returning the records themselves.
-- The NCI Seek was performed 132 times, and 69 times a matching
-- record in the table "Sales.SalesOrderHeader" was found.
SELECT *
FROM Sales.Customer AS c
WHERE c.TerritoryID = 3
	AND NOT EXISTS (
		SELECT 1
		FROM Sales.SalesOrderHeader AS h
		WHERE h.CustomerID = c.CustomerID
		);
GO


