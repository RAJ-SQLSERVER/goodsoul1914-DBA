--Code for Chapter 1
USE StockAnalysisDemo;
GO

--1-1.1 Using a subquery    
SELECT TickerSymbol,
       TradeDate,
       ClosePrice,
       (
           SELECT TOP (1) ClosePrice
           FROM dbo.StockHistory AS SQ
           WHERE SQ.TickerSymbol = OQ.TickerSymbol
                 AND SQ.TradeDate < OQ.TradeDate
           ORDER BY TradeDate DESC
       ) AS "PrevClosePrice"
FROM dbo.StockHistory AS OQ
ORDER BY TickerSymbol,
         TradeDate;
GO

--1-1.2 Using LAG    
SELECT TickerSymbol,
       TradeDate,
       ClosePrice,
       LAG (ClosePrice) OVER (PARTITION BY TickerSymbol ORDER BY TradeDate) AS "PrevClosePrice"
FROM dbo.StockHistory
ORDER BY TickerSymbol,
         TradeDate;
GO


USE AdventureWorks;
GO

--1-2.1 Row numbers applied by CustomerID    
SELECT CustomerID,
       SalesOrderID,
       ROW_NUMBER () OVER (ORDER BY CustomerID) AS "RowNumber"
FROM Sales.SalesOrderHeader;
GO

--1-2.2 Row numbers applied by SalesOrderID    
SELECT CustomerID,
       SalesOrderID,
       ROW_NUMBER () OVER (ORDER BY SalesOrderID) AS "RowNumber"
FROM Sales.SalesOrderHeader;
GO

--1-3.1 Row number with a different ORDER BY    
SELECT CustomerID,
       SalesOrderID,
       ROW_NUMBER () OVER (ORDER BY CustomerID) AS "RowNumber"
FROM Sales.SalesOrderHeader
ORDER BY SalesOrderID;
GO

--1-4.1 Row number with a descending ORDER BY    
SELECT CustomerID,
       SalesOrderID,
       ROW_NUMBER () OVER (ORDER BY CustomerID DESC) AS "RowNumber"
FROM Sales.SalesOrderHeader;
GO

--1-5.1 Row number with a random ORDER BY    
SELECT CustomerID,
       SalesOrderID,
       ROW_NUMBER () OVER (ORDER BY NEWID ()) AS "RowNumber"
FROM Sales.SalesOrderHeader;
GO

--1-6.1 Use a constant for an ORDER BY    
SELECT CustomerID,
       SalesOrderID,
       ROW_NUMBER () OVER (ORDER BY (SELECT 1)) AS "RowNumber"
FROM Sales.SalesOrderHeader;
GO

--1-6.2 Apply an ORDER BY to the query    
SELECT CustomerID,
       SalesOrderID,
       ROW_NUMBER () OVER (ORDER BY (SELECT 1)) AS "RowNumber"
FROM Sales.SalesOrderHeader
ORDER BY SalesOrderID;
GO

--1-6.3 No ROW_NUMBER and no ORDER BY    
SELECT CustomerID,
       SalesOrderID
FROM Sales.SalesOrderHeader;
GO

--1-7.1 Use an expression in the ORDER BY    
SELECT CustomerID,
       SalesOrderID,
       OrderDate,
       ROW_NUMBER () OVER (ORDER BY CASE
                                        WHEN OrderDate > '2013/12/31' THEN 0
                                        ELSE 1
                                    END,
                                    SalesOrderID
                     ) AS "RowNumber"
FROM Sales.SalesOrderHeader;
GO

--1-8.1 Use ROW_NUMBER with PARTITION BY    
SELECT CustomerID,
       SalesOrderID,
       ROW_NUMBER () OVER (PARTITION BY CustomerID
ORDER BY SalesOrderID
                     ) AS "RowNumber"
FROM Sales.SalesOrderHeader;
GO

--1-9.1 Using DISTINCT    
SELECT DISTINCT OrderDate,
                ROW_NUMBER () OVER (ORDER BY OrderDate) AS "RowNumber"
FROM Sales.SalesOrderHeader
ORDER BY RowNumber;
GO

--1-9.2 Separate logic with CTE    
WITH OrderDates AS (SELECT DISTINCT OrderDate FROM Sales.SalesOrderHeader)
SELECT OrderDate,
       ROW_NUMBER () OVER (ORDER BY OrderDate) AS "RowNumber"
FROM OrderDates
ORDER BY RowNumber;
GO

--1-10.1 Using TOP with ROW_NUMBER    
SELECT TOP (6) CustomerID,
               SalesOrderID,
               ROW_NUMBER () OVER (ORDER BY SalesOrderID) AS "RowNumber"
FROM Sales.SalesOrderHeader
ORDER BY NEWID ();
GO

--1-10.2 Separate the logic with a CTE    
WITH Orders AS
(
    SELECT TOP (6) CustomerID,
                   SalesOrderID
    FROM Sales.SalesOrderHeader
    ORDER BY NEWID ()
)
SELECT CustomerID,
       SalesOrderID,
       ROW_NUMBER () OVER (ORDER BY SalesOrderID) AS "RowNumber"
FROM Orders;
GO
