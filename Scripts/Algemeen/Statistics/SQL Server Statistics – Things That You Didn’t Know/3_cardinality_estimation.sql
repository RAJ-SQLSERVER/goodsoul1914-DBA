USE AdventureWorks2017;
GO

-- Turn on actual execution plan

SELECT *
FROM Sales.SalesOrderHeader
WHERE TotalDue = 1457.3288;
GO -- 1.7 estimated rows

SELECT *
FROM Sales.SalesOrderHeader
WHERE TotalDue = 472.3108;
GO -- 1.95 estimated rows


DECLARE @td FLOAT;
SET @td = 1457.3288;
SELECT *
FROM Sales.SalesOrderHeader
WHERE TotalDue = @td;
GO -- 6.87 estimated rows

DECLARE @td FLOAT;
SET @td = 53623; -- will be available at runtime so SQL Server has to guess the estimates
SELECT *
FROM Sales.SalesOrderHeader
WHERE TotalDue = @td;
GO -- 6.87 estimated rows


-- Total Rows * Density (where density is 1/number of distinct values)

SELECT COUNT(*)
FROM Sales.SalesOrderHeader; -- 31465
GO

SELECT COUNT(DISTINCT TotalDue)
FROM Sales.SalesOrderHeader; -- 4754
GO

SELECT COUNT(*) * CAST((1. * 1 / COUNT(DISTINCT TotalDue)) AS DECIMAL(18, 17))
FROM Sales.SalesOrderHeader; -- 6.61863663405000000
GO
