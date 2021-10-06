
-- http://msdn.microsoft.com/en-us/library/ms187731.aspx

/* http://msdn.microsoft.com/en-us/library/ms187731.aspx
A. Using SELECT to retrieve rows and columns 
The following example shows three code examples. This first code 
example returns all rows (no WHERE clause is specified) and all
columns (using the *) from the Product table in the 
AdventureWorks2012 database.
*/

USE AdventureWorks2012;
GO
SELECT *
FROM Production.Product
ORDER BY Name ASC;
-- Alternate way.
USE AdventureWorks2012;
GO
SELECT p.*
FROM Production.Product AS p
ORDER BY Name ASC;
GO

/*
This example returns all rows (no WHERE clause is specified), and 
only a subset of the columns (Name, ProductNumber, ListPrice) from 
the Product table in the AdventureWorks2012 database. Additionally, 
a column heading is added.
*/

USE AdventureWorks2012;
GO
SELECT Name, ProductNumber, ListPrice AS Price
FROM Production.Product 
ORDER BY Name ASC;
GO


/*
This example returns only the rows for Product that have a product 
line of R and that have days to manufacture that is less than 4.
*/

USE AdventureWorks2012;
GO
SELECT Name, ProductNumber, ListPrice AS Price
FROM Production.Product 
WHERE ProductLine = 'R' 
AND DaysToManufacture < 4
ORDER BY Name ASC;
GO

------

/* http://msdn.microsoft.com/en-us/library/ms187731.aspx
B. Using SELECT with column headings and calculations 
The following examples return all rows from the Product table. The 
first example returns total sales and the discounts for each product. 
In the second example, the total revenue is calculated for each 
product.
*/

--USE AdventureWorks2012;
--GO
--SELECT p.Name AS ProductName, 
--NonDiscountSales = (OrderQty * UnitPrice),
--Discounts = ((OrderQty * UnitPrice) * UnitPriceDiscount)
--FROM Production.Product AS p 
--INNER JOIN Sales.SalesOrderDetail AS sod
--ON p.ProductID = sod.ProductID 
--ORDER BY ProductName DESC;
--GO


/*
This is the query that calculates the revenue for each product in 
each sales order.
*/

--USE AdventureWorks2012;
--GO
--SELECT 'Total income is', ((OrderQty * UnitPrice) * (1.0 - UnitPriceDiscount)), ' for ',
--p.Name AS ProductName 
--FROM Production.Product AS p 
--INNER JOIN Sales.SalesOrderDetail AS sod
--ON p.ProductID = sod.ProductID 
--ORDER BY ProductName ASC;
--GO

------

/* http://msdn.microsoft.com/en-us/library/ms187731.aspx
C. Using DISTINCT with SELECT 
The following example uses DISTINCT to prevent the retrieval 
of duplicate titles.
*/

USE AdventureWorks2012;
GO
SELECT DISTINCT JobTitle
FROM HumanResources.Employee
ORDER BY JobTitle;
GO


------

/* http://msdn.microsoft.com/en-us/library/ms187731.aspx
T. Using the INDEX optimizer hint 
The following example shows two ways to use the INDEX 
optimizer hint. The first example shows how to force the 
optimizer to use a nonclustered index to retrieve rows from 
a table, and the second example forces a table scan by using 
an index of 0.
*/

USE AdventureWorks2012;
GO
SELECT pp.FirstName, pp.LastName, e.NationalIDNumber
FROM HumanResources.Employee AS e WITH (INDEX(AK_Employee_NationalIDNumber))
JOIN Person.Person AS pp on e.BusinessEntityID = pp.BusinessEntityID
WHERE LastName = 'Johnson';
GO

-- Force a table scan by using INDEX = 0.
USE AdventureWorks2012;
GO
SELECT pp.LastName, pp.FirstName, e.JobTitle
FROM HumanResources.Employee AS e WITH (INDEX = 0) JOIN Person.Person AS pp
ON e.BusinessEntityID = pp.BusinessEntityID
WHERE LastName = 'Johnson';
GO

------

/* http://msdn.microsoft.com/en-us/library/ms187731.aspx
U. Using OPTION and the GROUP hints 
The following example shows how the OPTION (GROUP) clause
is used with a GROUP BY clause.
*/

USE AdventureWorks2012;
GO
SELECT ProductID, OrderQty, SUM(LineTotal) AS Total
FROM Sales.SalesOrderDetail
WHERE UnitPrice < $5.00
GROUP BY ProductID, OrderQty
ORDER BY ProductID, OrderQty
OPTION (HASH GROUP, FAST 10);
GO

------

/* http://msdn.microsoft.com/en-us/library/ms187731.aspx
V. Using the UNION query hint 
The following example uses the MERGE UNION query hint.
*/

USE AdventureWorks2012;
GO
SELECT *
FROM HumanResources.Employee AS e1
UNION
SELECT *
FROM HumanResources.Employee AS e2
OPTION (MERGE UNION);
GO



------

SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'AR-5381'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BA-8327'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BB-7421'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BB-8107'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BB-9108'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BC-M005'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BC-R205'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BE-2349'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BE-2908'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-M18B-40'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-M18B-42'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-M18B-44'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-M18B-48'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-M18B-52'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-M18S-40'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-M18S-42'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-M18S-44'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-M18S-48'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-M18S-52'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-M38S-38'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-M38S-40'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-M38S-42'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-M38S-46'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-M47B-38'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-M47B-40'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-M47B-44'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-M47B-48'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-M68B-38'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-M68B-42'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-M68B-46'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-M68S-38'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-M68S-42'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-M68S-46'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-M82B-38'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-M82B-42'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-M82B-44'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-M82B-48'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-M82S-38'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-M82S-42'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-M82S-44'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-M82S-48'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R19B-44'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R19B-48'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R19B-52'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R19B-58'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R50B-44'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R50B-48'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R50B-52'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R50B-58'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R50B-60'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R50B-62'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R50R-44'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R50R-48'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R50R-52'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R50R-58'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R50R-60'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R50R-62'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R64Y-38'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R64Y-40'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R64Y-42'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R64Y-44'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R64Y-48'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R68R-44'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R68R-48'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R68R-52'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R68R-58'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R68R-60'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R79Y-40'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R79Y-42'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R79Y-44'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R79Y-48'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R89B-44'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R89B-48'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R89B-52'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R89B-58'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R89R-44'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R89R-48'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R89R-52'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R89R-58'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R93R-44'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R93R-48'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R93R-52'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R93R-56'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-R93R-62'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-T18U-44'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-T18U-50'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-T18U-54'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-T18U-58'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-T18U-62'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-T18Y-44'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-T18Y-50'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-T18Y-54'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-T18Y-58'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-T18Y-62'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-T44U-46'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-T44U-50'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-T44U-54'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-T44U-60'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-T79U-46'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-T79U-50'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-T79U-54'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-T79U-60'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-T79Y-46'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-T79Y-50'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-T79Y-54'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BK-T79Y-60'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'BL-2036'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'CA-1098'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'CA-5965'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'CA-6738'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'CA-7457'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'CB-2903'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'CH-0234'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'CL-9009'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'CN-6137'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'CR-7833'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'CR-9981'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'CS-2812'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'CS-4759'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'CS-6583'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'CS-9183'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'DC-8732'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'DC-9824'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'DT-2377'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'EC-M092'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'EC-R098'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'EC-T209'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FB-9873'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FC-3654'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FC-3982'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FD-2342'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FE-3760'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FE-6654'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FH-2981'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FK-1639'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FK-5136'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FK-9939'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FL-2301'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-M21B-40'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-M21B-42'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-M21B-44'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-M21B-48'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-M21B-52'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-M21S-40'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-M21S-42'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-M21S-44'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-M21S-48'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-M21S-52'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-M63B-38'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-M63B-40'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-M63B-44'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-M63B-48'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-M63S-38'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-M63S-40'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-M63S-42'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-M63S-46'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-M94B-38'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-M94B-42'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-M94B-44'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-M94B-46'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-M94B-48'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-M94S-38'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-M94S-42'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-M94S-44'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-M94S-46'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-M94S-52'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-R38B-44'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-R38B-48'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-R38B-52'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-R38B-58'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-R38B-60'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-R38B-62'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-R38R-44'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-R38R-48'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-R38R-52'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-R38R-58'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-R38R-60'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-R38R-62'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-R72R-44'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-R72R-48'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-R72R-52'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-R72R-58'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-R72R-60'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-R72Y-38'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-R72Y-40'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-R72Y-42'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-R72Y-44'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-R72Y-48'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-R92B-44'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-R92B-48'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-R92B-52'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-R92B-58'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-R92B-62'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-R92R-44'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-R92R-48'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-R92R-52'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-R92R-56'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-R92R-58'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-R92R-62'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-T67U-44'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-T67U-50'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-T67U-54'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-T67U-58'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-T67U-62'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-T67Y-44'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-T67Y-50'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-T67Y-54'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-T67Y-58'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-T67Y-62'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-T98U-46'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-T98U-50'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-T98U-54'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-T98U-60'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-T98Y-46'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-T98Y-50'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-T98Y-54'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FR-T98Y-60'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FW-1000'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FW-1200'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FW-1400'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FW-3400'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FW-3800'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FW-5160'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FW-5800'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FW-7160'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FW-9160'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FW-M423'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FW-M762'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FW-M928'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FW-R623'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FW-R762'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FW-R820'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'FW-T905'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'GL-F110-L'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'GL-F110-M'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'GL-F110-S'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'GL-H102-L'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'GL-H102-M'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'GL-H102-S'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'GP-0982'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'GT-0820'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'GT-1209'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'GT-2908'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HB-M243'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HB-M763'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HB-M918'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HB-R504'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HB-R720'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HB-R956'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HB-T721'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HB-T928'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HJ-1213'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HJ-1220'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HJ-1420'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HJ-1428'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HJ-3410'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HJ-3416'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HJ-3816'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HJ-3824'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HJ-5161'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HJ-5162'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HJ-5811'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HJ-5818'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HJ-7161'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HJ-7162'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HJ-9080'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HJ-9161'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HL-U509'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HL-U509-B'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HL-U509-R'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HN-1024'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HN-1032'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HN-1213'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HN-1220'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HN-1224'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HN-1420'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HN-1428'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HN-3410'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HN-3416'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HN-3816'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HN-3824'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HN-4402'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HN-5161'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HN-5162'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HN-5400'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HN-5811'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HN-5818'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HN-6320'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HN-7161'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HN-7162'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HN-8320'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HN-9161'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HN-9168'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HS-0296'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HS-2451'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HS-3479'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HT-2981'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HT-8019'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HU-6280'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HU-8998'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'HY-1023-70'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'KW-4091'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LE-1000'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LE-1200'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LE-1201'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LE-1400'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LE-3800'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LE-5160'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LE-6000'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LE-7160'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LE-8000'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LI-1000'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LI-1200'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LI-1201'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LI-1400'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LI-3800'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LI-5160'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LI-5800'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LI-6000'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LI-7160'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LI-8000'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LJ-0192-L'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LJ-0192-M'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LJ-0192-S'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LJ-0192-X'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LJ-1213'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LJ-1220'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LJ-1420'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LJ-1428'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LJ-3410'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LJ-3416'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LJ-3816'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LJ-3824'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LJ-5161'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LJ-5162'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LJ-5811'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LJ-5818'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LJ-7161'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LJ-7162'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LJ-9080'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LJ-9161'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LN-1024'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LN-1032'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LN-1213'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LN-1220'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LN-1224'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LN-1420'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LN-1428'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LN-3410'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LN-3416'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LN-3816'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LN-3824'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LN-4400'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LN-5161'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LN-5162'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LN-5400'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LN-5811'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LN-5818'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LN-6320'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LN-7161'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LN-7162'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LN-8320'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LN-9080'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LN-9161'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LO-C100'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LR-2398'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LR-8520'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LT-H902'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LT-H903'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LT-T990'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LW-1000'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LW-1200'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LW-1201'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LW-1400'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LW-3400'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LW-3800'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LW-4000'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LW-5160'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LW-5800'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LW-6000'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LW-7160'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LW-8000'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'LW-9160'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'MA-7075'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'MB-2024'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'MB-6061'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'MP-2066'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'MP-2503'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'MP-4960'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'MS-0253'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'MS-1256'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'MS-1981'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'MS-2259'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'MS-2341'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'MS-2348'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'MS-6061'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'MT-1000'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'NI-4127'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'NI-9522'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'PA-187B'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'PA-361R'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'PA-529S'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'PA-632U'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'PA-823Y'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'PA-T100'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'PB-6109'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'PD-M282'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'PD-M340'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'PD-M562'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'PD-R347'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'PD-R563'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'PD-R853'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'PD-T852'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'PK-7098'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'PU-0452'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'PU-M044'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'RA-2345'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'RA-7490'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'RA-H123'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'RB-9231'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'RC-0291'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'RD-2308'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'RF-9198'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'RM-M464'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'RM-M692'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'RM-M823'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'RM-R436'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'RM-R600'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'RM-R800'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'RM-T801'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'RW-M423'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'RW-M762'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'RW-M928'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'RW-R623'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'RW-R762'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'RW-R820'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'RW-T905'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SA-M198'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SA-M237'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SA-M687'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SA-R127'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SA-R430'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SA-R522'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SA-T467'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SA-T612'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SA-T872'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SB-M891-L'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SB-M891-M'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SB-M891-S'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SD-2342'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SD-9872'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SE-M236'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SE-M798'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SE-M940'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SE-R581'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SE-R908'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SE-R995'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SE-T312'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SE-T762'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SE-T924'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SH-4562'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SH-9312'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SH-M897-L'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SH-M897-M'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SH-M897-S'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SH-M897-X'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SH-W890-L'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SH-W890-M'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SH-W890-S'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SJ-0194-L'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SJ-0194-M'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SJ-0194-S'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SJ-0194-X'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SK-9283'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SL-0931'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SM-9087'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SO-B909-L'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SO-B909-M'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SO-R809-L'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SO-R809-M'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SP-2981'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SR-2098'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'SS-2985'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'ST-1401'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'ST-9828'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'TG-W091-L'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'TG-W091-M'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'TG-W091-S'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'TI-M267'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'TI-M602'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'TI-M823'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'TI-R092'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'TI-R628'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'TI-R982'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'TI-T723'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'TO-2301'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'TP-0923'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'TT-M928'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'TT-R982'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'TT-T092'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'VE-C304-L'
GO------
SELECT soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'VE-C304-M'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'VE-C304-S'
GO------
SELECT 
	soh.SalesOrderID,
	soh.SalesOrderNumber,
	soh.OrderDate,
	sod.OrderQty
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
WHERE ProductNumber = N'WB-H098'
GO