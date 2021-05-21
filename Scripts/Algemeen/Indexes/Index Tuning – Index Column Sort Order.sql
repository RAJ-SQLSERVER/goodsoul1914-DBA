USE AdventureWorks;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT SalesOrderID,
       OrderDate,
       CustomerID,
       SalesPersonID
FROM Sales.SalesOrderHeader;

EXEC sp_helpindex @objname = [Sales.SalesOrderHeader];

SELECT CustomerID,
       SalesPersonID
FROM Sales.SalesOrderHeader;

SELECT CustomerID,
       SalesPersonID
FROM Sales.SalesOrderHeader
WHERE CustomerID = 29984;

SELECT CustomerID,
       SalesPersonID
FROM Sales.SalesOrderHeader
WHERE CustomerID > 29984;

CREATE NONCLUSTERED INDEX Covering1
ON Sales.SalesOrderHeader (CustomerID)
INCLUDE (SalesPersonID);

SELECT CustomerID,
       SalesPersonID
FROM Sales.SalesOrderHeader
WHERE CustomerID > 29984;

SELECT CustomerID,
       SalesPersonID
FROM Sales.SalesOrderHeader
WHERE CustomerID > 29984
      AND SalesPersonID > 290;

CREATE NONCLUSTERED INDEX Covering2
ON Sales.SalesOrderHeader (
                              CustomerID,
                              SalesPersonID
                          );

DBCC FREEPROCCACHE;

SELECT CustomerID,
       SalesPersonID
FROM Sales.SalesOrderHeader
WHERE CustomerID > 29984
      AND SalesPersonID > 290; -- Still uses Covering1

SELECT CustomerID,
       SalesPersonID
FROM Sales.SalesOrderHeader
WHERE CustomerID = 29984
      AND SalesPersonID = 290; -- Covering2 index is used, no residual predicates!

SELECT CustomerID,
       SalesPersonID
FROM Sales.SalesOrderHeader
WHERE CustomerID = 29984
      AND SalesPersonID = 290 -- Covering2 index is used, no residual predicates!
ORDER BY CustomerID;

SELECT CustomerID,
       SalesPersonID
FROM Sales.SalesOrderHeader
WHERE CustomerID = 29984
      AND SalesPersonID = 290 -- Covering2 index is used, no residual predicates!
ORDER BY SalesPersonID;

SELECT CustomerID,
       SalesPersonID
FROM Sales.SalesOrderHeader
WHERE CustomerID = 29984
      AND SalesPersonID IN ( 290, 285, 283 )
ORDER BY SalesPersonID;

SELECT CustomerID,
       SalesPersonID
FROM Sales.SalesOrderHeader
WHERE CustomerID IN ( 29984, 30015, 30031 )
      AND SalesPersonID IN ( 290, 285, 284 )
ORDER BY SalesPersonID; -- Now a SORT operator is added, which is expensive!

CREATE NONCLUSTERED INDEX Covering3
ON Sales.SalesOrderHeader (
                              SalesPersonID,
                              CustomerID
                          );

SELECT CustomerID,
       SalesPersonID
FROM Sales.SalesOrderHeader
WHERE CustomerID IN ( 29984, 30015, 30031 )
      AND SalesPersonID IN ( 290, 285, 284 )
ORDER BY SalesPersonID; -- SORT operator is gone now!

-- Clean up

DROP INDEX Covering1 ON Sales.SalesOrderHeader;
DROP INDEX Covering2 ON Sales.SalesOrderHeader;
DROP INDEX Covering3 ON Sales.SalesOrderHeader;
