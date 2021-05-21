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
-- Exercise 3: Parameter Sniffing
-------------------------------------------------------------

-- Step 1: Execute the following statements to select AdventureWorks2012 database
USE AdventureWorks2012;
SET NOCOUNT ON;
SET STATISTICS IO ON;
DBCC FREEPROCCACHE;
GO

-- Step 2: Create a stored procedure named uspAddressByCity
IF(SELECT OBJECT_ID('uspAddressByCity'))
IS NOT NULL
DROP PROCEDURE dbo.uspAddressByCity;
GO
CREATE PROCEDURE dbo.uspAddressByCity @City NVARCHAR(30)
AS
SELECT A.AddressID,
	A.AddressLine1,
	A.AddressLine2,
	A.City,
	SP.Name AS StateProvinceName,
	A.PostalCode
FROM Person.Address AS A
	JOIN Person.StateProvince AS SP
	ON A.StateProvinceID = SP.StateProvinceID
WHERE A.City = @City

---------------------
-- Begin: Step 3
---------------------
-- Execute the stored procedure with actual execution plan (Ctrl + M)
EXEC uspAddressByCity @City = N'London';

-- Execute the stored procedure with actual execution plan (Ctrl + M)
EXEC uspAddressByCity @City = N'Mentor';
---------------------
-- End: Step 3
---------------------

-- Step 4: Execute the following statement to clear processes cache
DBCC FREEPROCCACHE;
GO

---------------------
-- Begin: Step 5
---------------------
-- Execute the stored procedure with actual execution plan (Ctrl + M)
EXEC uspAddressByCity @City = N'Mentor';

-- Execute the stored procedure with actual execution plan (Ctrl + M)
EXEC uspAddressByCity @City = N'London';
---------------------
-- End: Step 5
---------------------

-- Step 6: Alter stored procedure uspAddressByCity
ALTER PROCEDURE dbo.uspAddressByCity @City NVARCHAR(30)
AS

SELECT A.AddressID,
	A.AddressLine1,
	A.AddressLine2,
	A.City,
	SP.Name AS StateProvinceName,
	A.PostalCode
FROM Person.Address AS A
	JOIN Person.StateProvince AS SP
	ON A.StateProvinceID = SP.StateProvinceID
WHERE A.City = @City
OPTION (OPTIMIZE FOR (@City = 'London'));

-- Step 7: Execute the following statement to clear processes cache
DBCC FREEPROCCACHE;
GO

---------------------
-- Begin: Step 8
---------------------
-- Execute the stored procedure with actual execution plan (Ctrl + M)
EXEC uspAddressByCity @City = N'London';

-- Execute the stored procedure with actual execution plan (Ctrl + M)
EXEC uspAddressByCity @City = N'Mentor';
---------------------
-- End: Step 8
---------------------

-- Step 9: Alter stored procedure uspAddressByCity
ALTER PROCEDURE dbo.uspAddressByCity @City NVARCHAR(30)
AS

SELECT A.AddressID,
	A.AddressLine1,
	A.AddressLine2,
	A.City,
	SP.Name AS StateProvinceName,
	A.PostalCode
FROM Person.Address AS A
	JOIN Person.StateProvince AS SP
	ON A.StateProvinceID = SP.StateProvinceID
WHERE A.City = @City
OPTION (RECOMPILE);

-- Step 10: Execute the following statement to clear processes cache
DBCC FREEPROCCACHE;
GO

---------------------
-- Begin: Step 11
---------------------
-- Execute the stored procedure with actual execution plan (Ctrl + M)
EXEC uspAddressByCity @City = N'London';

-- Execute the stored procedure with actual execution plan (Ctrl + M)
EXEC uspAddressByCity @City = N'Mentor';
---------------------
-- End: Step 11
---------------------

-- Step 12: Execute the following statement to drop uspAddressByCity stored procedure
DROP PROCEDURE dbo.uspAddressByCity;
GO

/*===================================================================================================
For Hands-On-Labs feedback, write to us at holfeedback@SQLMaestros.com
For Hands-On-Labs support, write to us at holsupport@SQLMaestros.com
Do you wish to subscribe to HOLs for your team? Email holsales@SQLMaestros.com
For SQLMaestros Master Classes & Videos, visit www.SQLMaestros.com
====================================================================================================*/