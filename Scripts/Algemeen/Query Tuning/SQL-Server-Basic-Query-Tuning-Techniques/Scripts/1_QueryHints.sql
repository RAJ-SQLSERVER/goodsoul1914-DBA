/*============================================================================================
  Copyright (C) 2016 SQLMaestros.com | eDominer Systems P Ltd.
  All rights reserved.
    
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.

=============================================================================================*/

-------------------------------------------------------------
-- Lab: SQL Server Basic Query Tuning Techniques
-- Exercise 1: Query Hints
-------------------------------------------------------------

-- Step 1: Execute the following statements to select AdventureWorks2012 database
USE AdventureWorks2017;
SET NOCOUNT ON;
SET STATISTICS IO ON;
GO

-------------------
-- Begin: Step 2
-------------------
-- Execute below select statement with actual execution plan (Ctrl + M)
SELECT ProductID, OrderQty, SUM(LineTotal) AS Total
FROM Sales.SalesOrderDetail
WHERE ProductID = 870
GROUP BY ProductID, OrderQty
ORDER BY ProductID, OrderQty
OPTION (HASH GROUP);
GO

-- Execute below select statement with actual execution plan (Ctrl + M)
SELECT ProductID, OrderQty, SUM(LineTotal) AS Total
FROM Sales.SalesOrderDetail
WHERE ProductID = 870
GROUP BY ProductID, OrderQty
ORDER BY ProductID, OrderQty
OPTION (ORDER GROUP);
GO
-------------------
-- End: Step 2
-------------------

-------------------
-- Begin: Step 3
-------------------
-- Execute below select statement with actual execution plan (Ctrl + M)
SELECT SOD.SalesOrderID, SOD.OrderQty, SOD.ProductID, SOH.CustomerID, SOH.TotalDue 
FROM Sales.SalesOrderDetail AS SOD
INNER JOIN Sales.SalesOrderHeader AS SOH
ON SOD.SalesOrderID = SOH.SalesOrderID
WHERE SOD.SalesOrderID = 49999
OPTION(MERGE JOIN);

-- Execute below select statement with actual execution plan (Ctrl + M)
SELECT SOD.SalesOrderID, SOD.OrderQty, SOD.ProductID, SOH.CustomerID, SOH.TotalDue 
FROM Sales.SalesOrderDetail AS SOD
INNER JOIN Sales.SalesOrderHeader AS SOH
ON SOD.SalesOrderID = SOH.SalesOrderID
WHERE SOD.SalesOrderID = 49999
OPTION(LOOP JOIN);

-- Execute below select statement with actual execution plan (Ctrl + M)
SELECT SOD.SalesOrderID, SOD.OrderQty, SOD.ProductID, SOH.CustomerID, SOH.TotalDue 
FROM Sales.SalesOrderDetail AS SOD
INNER JOIN Sales.SalesOrderHeader AS SOH
ON SOD.SalesOrderID = SOH.SalesOrderID
WHERE SOD.SalesOrderID = 49999
OPTION(HASH JOIN);
-------------------
-- End: Step 3
-------------------

-------------------
-- Begin: Step 4
-------------------
-- Execute below select statement with actual execution plan (Ctrl + M)
SELECT TOP 10 * FROM Sales.SalesOrderDetail
UNION
SELECT TOP 10 * FROM Sales.SalesOrderDetail
OPTION(MERGE UNION);

-- Execute below select statement with actual execution plan (Ctrl + M)
SELECT TOP 10 * FROM Sales.SalesOrderDetail
UNION
SELECT TOP 10 * FROM Sales.SalesOrderDetail
OPTION(HASH UNION);

-- Execute below select statement with actual execution plan (Ctrl + M)
SELECT TOP 10 * FROM Sales.SalesOrderDetail
UNION
SELECT TOP 10 * FROM Sales.SalesOrderDetail
OPTION(CONCAT UNION);
-------------------
-- End: Step 4
-------------------

-------------------
-- Begin: Step 5
-------------------
-- Execute below select statement with actual execution plan (Ctrl + M)
SELECT BusinessEntityID, FirstName, LastName 
FROM Person.Person WITH(INDEX(0)) WHERE BusinessEntityID = 100;

-- Execute below select statement with actual execution plan (Ctrl + M)
SELECT BusinessEntityID, FirstName, LastName 
FROM Person.Person WITH(INDEX(1)) WHERE BusinessEntityID = 100;

-- Execute below select statement with actual execution plan (Ctrl + M)
SELECT BusinessEntityID, FirstName, LastName 
FROM Person.Person WITH(INDEX(2)) WHERE BusinessEntityID = 100;
-------------------
-- End: Step 5
-------------------

-------------------
-- Begin: Step 6
-------------------
-- Execute below select statement with actual execution plan (Ctrl + M)
SELECT BusinessEntityID, FirstName, LastName 
FROM Person.Person  WHERE BusinessEntityID > 100;

-- Execute below select statement with actual execution plan (Ctrl + M)
SELECT BusinessEntityID, FirstName, LastName 
FROM Person.Person WITH(FORCESEEK) WHERE BusinessEntityID > 100;
-------------------
-- End: Step 6
-------------------

-------------------
-- Begin: Step 7
-------------------
-- Execute below select statement with actual execution plan (Ctrl + M)
SELECT * FROM Sales.SalesOrderDetail AS SOD
INNER JOIN Sales.SalesOrderHeader AS SOH
ON SOD.SalesOrderID = SOH.SalesOrderID
WHERE SOH.SalesOrderID = 50000;

-- Execute below select statement with actual execution plan (Ctrl + M)
SELECT * FROM Sales.SalesOrderDetail AS SOD 
INNER JOIN Sales.SalesOrderHeader AS SOH WITH (FORCESCAN)
ON SOD.SalesOrderID = SOH.SalesOrderID
WHERE SOH.SalesOrderID = 50000;
-------------------
-- End: Step 7
-------------------

-------------------
-- Begin: Step 8
-------------------
-- Execute below select statement with actual execution plan (Ctrl + M)
SELECT 
PP.BusinessEntityID,PP.FirstName,PP.LastName,
PBEA.AddressID,PA.AddressLine1,PA.AddressLine2,
PA.City,PA.PostalCode,PEA.EmailAddress
FROM Person.Person AS PP
INNER JOIN Person.BusinessEntityAddress AS PBEA
ON PP.BusinessEntityID = PBEA.BusinessEntityID
INNER JOIN Person.Address AS PA
ON PA.AddressID = PBEA.AddressID
INNER JOIN Person.EmailAddress AS PEA
ON PEA.BusinessEntityID = PP.BusinessEntityID
WHERE PP.BusinessEntityID = 100;

-- Execute below select statement with actual execution plan (Ctrl + M)
SELECT 
PP.BusinessEntityID,PP.FirstName,PP.LastName,
PBEA.AddressID,PA.AddressLine1,PA.AddressLine2,
PA.City,PA.PostalCode,PEA.EmailAddress
FROM Person.Person AS PP
INNER JOIN Person.BusinessEntityAddress AS PBEA
ON PP.BusinessEntityID = PBEA.BusinessEntityID
INNER JOIN Person.Address AS PA
ON PA.AddressID = PBEA.AddressID
INNER JOIN Person.EmailAddress AS PEA
ON PEA.BusinessEntityID = PP.BusinessEntityID
WHERE PP.BusinessEntityID = 100
OPTION(FORCE ORDER);
-------------------
-- End: Step 8
-------------------
/*===================================================================================================
For Hands-On-Labs feedback, write to us at holfeedback@SQLMaestros.com
For Hands-On-Labs support, write to us at holsupport@SQLMaestros.com
Do you wish to subscribe to HOLs for your team? Email holsales@SQLMaestros.com
For SQLMaestros Master Classes & Videos, visit www.SQLMaestros.com
====================================================================================================*/