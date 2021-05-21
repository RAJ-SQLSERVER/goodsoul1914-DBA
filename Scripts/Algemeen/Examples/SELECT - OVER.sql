
/***
 *       _____ ______ _      ______ _____ _______             ______      ________ _____  
 *      / ____|  ____| |    |  ____/ ____|__   __|           / __ \ \    / /  ____|  __ \ 
 *     | (___ | |__  | |    | |__ | |       | |     ______  | |  | \ \  / /| |__  | |__) |
 *      \___ \|  __| | |    |  __|| |       | |    |______| | |  | |\ \/ / |  __| |  _  / 
 *      ____) | |____| |____| |___| |____   | |             | |__| | \  /  | |____| | \ \ 
 *     |_____/|______|______|______\_____|  |_|              \____/   \/   |______|_|  \_\
 *                                                                                        
 *                                                                                        
 */
                                                                                                 
USE AdventureWorks2014;
GO

/*
 The following example shows using the OVER clause with ROW_NUMBER function 
 to display a row number for each row within a partition. The ORDER BY clause 
 specified in the OVER clause orders the rows in each partition by the column SalesYTD. 
 The ORDER BY clause in the SELECT statement determines the order in which the entire 
 query result set is returned
*/
SELECT ROW_NUMBER() OVER (PARTITION BY PostalCode ORDER BY SalesYTD DESC) AS "Row Number",
       p.LastName,
       s.SalesYTD,
       a.PostalCode
FROM Sales.SalesPerson AS s
    INNER JOIN Person.Person AS p
        ON s.BusinessEntityID = p.BusinessEntityID
    INNER JOIN Person.Address AS a
        ON a.AddressID = p.BusinessEntityID
WHERE TerritoryID IS NOT NULL
      AND SalesYTD <> 0
ORDER BY PostalCode;
GO

/*
 The following example uses the OVER clause with aggregate functions over all rows 
 returned by the query. In this example, using the OVER clause is more efficient than 
 using subqueries to derive the aggregate values.
*/
SELECT SalesOrderID,
       ProductID,
       OrderQty,
       SUM(OrderQty) OVER (PARTITION BY SalesOrderID) AS Total,
       AVG(OrderQty) OVER (PARTITION BY SalesOrderID) AS "Avg",
       COUNT(OrderQty) OVER (PARTITION BY SalesOrderID) AS "Count",
       MIN(OrderQty) OVER (PARTITION BY SalesOrderID) AS "Min",
       MAX(OrderQty) OVER (PARTITION BY SalesOrderID) AS "Max"
FROM Sales.SalesOrderDetail
WHERE SalesOrderID IN ( 43659, 43664 );
GO

/*
 The following example shows using the OVER clause with an aggregate function 
 in a calculated value.
*/
SELECT SalesOrderID,
       ProductID,
       OrderQty,
       SUM(OrderQty) OVER (PARTITION BY SalesOrderID) AS Total,
       CAST(1. * OrderQty / SUM(OrderQty) OVER (PARTITION BY SalesOrderID) * 100 AS DECIMAL(5, 2)) AS "Percent by ProductID"
FROM Sales.SalesOrderDetail
WHERE SalesOrderID IN ( 43659, 43664 );
GO

/*
 The following example uses the AVG and SUM functions with the OVER clause to 
 provide a moving average and cumulative total of yearly sales for each territory 
 in the Sales.SalesPerson table. The data is partitioned by TerritoryID and 
 logically ordered by SalesYTD. This means that the AVG function is computed for 
 each territory based on the sales year. Notice that for TerritoryID 1, there are 
 two rows for sales year 2005 representing the two sales people with sales that year. 
 The average sales for these two rows is computed and then the third row representing 
 sales for the year 2006 is included in the computation.
*/
SELECT BusinessEntityID,
       TerritoryID,
       DATEPART(yy, ModifiedDate) AS SalesYear,
       CONVERT(VARCHAR(20), SalesYTD, 1) AS SalesYTD,
       CONVERT(VARCHAR(20), AVG(SalesYTD) OVER (PARTITION BY TerritoryID ORDER BY DATEPART(yy, ModifiedDate)), 1) AS MovingAvg,
       CONVERT(VARCHAR(20), SUM(SalesYTD) OVER (PARTITION BY TerritoryID ORDER BY DATEPART(yy, ModifiedDate)), 1) AS CumulativeTotal
FROM Sales.SalesPerson
WHERE TerritoryID IS NULL
      OR TerritoryID < 5
ORDER BY TerritoryID,
         SalesYear;
GO

/*
 In this example, the OVER clause does not include PARTITION BY. 
 This means that the function will be applied to all rows returned by the query. 
 The ORDER BY clause specified in the OVER clause determines the logical order 
 to which the AVG function is applied. The query returns a moving average of 
 sales by year for all sales territories specified in the WHERE clause. 
 The ORDER BY clause specified in the SELECT statement determines the order in 
 which the rows of the query are displayed.
*/
SELECT BusinessEntityID,
       TerritoryID,
       DATEPART(yy, ModifiedDate) AS SalesYear,
       CONVERT(VARCHAR(20), SalesYTD, 1) AS SalesYTD,
       CONVERT(VARCHAR(20), AVG(SalesYTD) OVER (ORDER BY DATEPART(yy, ModifiedDate)), 1) AS MovingAvg,
       CONVERT(VARCHAR(20), SUM(SalesYTD) OVER (ORDER BY DATEPART(yy, ModifiedDate)), 1) AS CumulativeTotal
FROM Sales.SalesPerson
WHERE TerritoryID IS NULL
      OR TerritoryID < 5
ORDER BY SalesYear;
GO

/*
 The following example uses the ROWS clause to define a window over which 
 the rows are computed as the current row and the N number of rows that 
 follow (1 row in this example).
*/
SELECT BusinessEntityID,
       TerritoryID,
       CONVERT(VARCHAR(20), SalesYTD, 1) AS SalesYTD,
       DATEPART(yy, ModifiedDate) AS SalesYear,
       CONVERT(   VARCHAR(20),
                  SUM(SalesYTD) OVER (PARTITION BY TerritoryID
                                      ORDER BY DATEPART(yy, ModifiedDate)
                                      ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING
                                     ),
                  1
              ) AS CumulativeTotal
FROM Sales.SalesPerson
WHERE TerritoryID IS NULL
      OR TerritoryID < 5;
GO

/*
 In the following example, the ROWS clause is specified with UNBOUNDED PRECEDING. 
 The result is that the window starts at the first row of the partition.
*/
SELECT BusinessEntityID,
       TerritoryID,
       CONVERT(VARCHAR(20), SalesYTD, 1) AS SalesYTD,
       DATEPART(yy, ModifiedDate) AS SalesYear,
       CONVERT(   VARCHAR(20),
                  SUM(SalesYTD) OVER (PARTITION BY TerritoryID
                                      ORDER BY DATEPART(yy, ModifiedDate)
                                      ROWS UNBOUNDED PRECEDING
                                     ),
                  1
              ) AS CumulativeTotal
FROM Sales.SalesPerson
WHERE TerritoryID IS NULL
      OR TerritoryID < 5;
GO


USE AdventureWorksDW2014
GO

/*
 The following example returns the ROW_NUMBER for sales representatives based 
 on their assigned sales quota.
*/
SELECT ROW_NUMBER() OVER (ORDER BY SUM(SalesAmountQuota) DESC) AS RowNumber,
       FirstName,
       LastName,
       CONVERT(VARCHAR(13), SUM(SalesAmountQuota), 1) AS SalesQuota
FROM dbo.DimEmployee AS e
    INNER JOIN dbo.FactSalesQuota AS sq
        ON e.EmployeeKey = sq.EmployeeKey
WHERE e.SalesPersonFlag = 1
GROUP BY LastName,
         FirstName;
GO

/*
 The following examples show using the OVER clause with aggregate functions. 
 In this example, using the OVER clause is more efficient than using subqueries.
*/
SELECT SalesOrderNumber AS OrderNumber,
       ProductKey,
       OrderQuantity AS Qty,
       SUM(OrderQuantity) OVER (PARTITION BY SalesOrderNumber) AS Total,
       AVG(OrderQuantity) OVER (PARTITION BY SalesOrderNumber) AS Avg,
       COUNT(OrderQuantity) OVER (PARTITION BY SalesOrderNumber) AS Count,
       MIN(OrderQuantity) OVER (PARTITION BY SalesOrderNumber) AS Min,
       MAX(OrderQuantity) OVER (PARTITION BY SalesOrderNumber) AS Max
FROM dbo.FactResellerSales
WHERE SalesOrderNumber IN ( N'SO43659', N'SO43664' )
      AND ProductKey LIKE '2%'
ORDER BY SalesOrderNumber,
         ProductKey;
GO

/*
 The following example shows using the OVER clause with an aggregate function 
 in a calculated value. Notice that the aggregates are calculated by 
 SalesOrderNumber and the percentage of the total sales order is calculated 
 for each line of each SalesOrderNumber.
*/
SELECT SalesOrderNumber AS OrderNumber,
       ProductKey AS Product,
       OrderQuantity AS Qty,
       SUM(OrderQuantity) OVER (PARTITION BY SalesOrderNumber) AS Total,
       CAST(1. * OrderQuantity / SUM(OrderQuantity) OVER (PARTITION BY SalesOrderNumber) * 100 AS DECIMAL(5, 2)) AS PctByProduct
FROM dbo.FactResellerSales
WHERE SalesOrderNumber IN ( N'SO43659', N'SO43664' )
      AND ProductKey LIKE '2%'
ORDER BY SalesOrderNumber,
         ProductKey;
GO
