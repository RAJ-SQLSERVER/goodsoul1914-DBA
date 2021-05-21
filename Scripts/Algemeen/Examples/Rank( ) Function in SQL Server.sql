/*
 RANK () is one of the four Ranking Functions that are available in SQL Server.

	1. ROW_NUMBER()
	2. RANK()
	3. DENSE_RANK()
	4. NTILE(N)

 Values returned by RANK() function are of BIG INT datatype.
 */

SET NOCOUNT ON;
GO

USE AdventureWorks2014;
GO

-- Example 1: assign rank to each product based on the available quantity in each location
SELECT ProductID,
       LocationID,
       Quantity
FROM Production.ProductInventory
WHERE ProductID = 1;
GO

SELECT ProductID, Name
FROM Production.Product 
WHERE ProductID = 1
GO

SELECT LocationID, Name 
FROM Production.Location
WHERE LocationID IN (1, 6, 50)
GO

-- Join these 3 tables together
SELECT P.Name ProductName,
       L.Name LocationName,
       PIN.Quantity,
       L.LocationID
FROM Production.ProductInventory PIN
    INNER JOIN Production.Product P
        ON P.ProductID = PIN.ProductID
    INNER JOIN Production.Location L
        ON L.LocationID = PIN.LocationID
ORDER BY PIN.LocationID,
         PIN.Quantity;
GO

-- Rank the data
SELECT P.Name ProductName,
       L.Name LocationName,
       PIN.Quantity,
       L.LocationID,
	   RANK() OVER(PARTITION BY PIN.LocationID ORDER BY PIN.Quantity DESC) OrderQty_Rank
FROM Production.ProductInventory PIN
    INNER JOIN Production.Product P
        ON P.ProductID = PIN.ProductID
    INNER JOIN Production.Location L
        ON L.LocationID = PIN.LocationID
GO

-- Show most available product(s) per location
;WITH cte
AS (SELECT P.Name ProductName,
           L.Name LocationName,
           PIN.Quantity,
           L.LocationID,
           RANK() OVER (PARTITION BY PIN.LocationID ORDER BY PIN.Quantity DESC) OrderQty_Rank
    FROM Production.ProductInventory PIN
        INNER JOIN Production.Product P
            ON P.ProductID = PIN.ProductID
        INNER JOIN Production.Location L
            ON L.LocationID = PIN.LocationID)
SELECT cte.ProductName,
       cte.LocationName,
       cte.Quantity
FROM cte
WHERE cte.OrderQty_Rank = 1;
GO
