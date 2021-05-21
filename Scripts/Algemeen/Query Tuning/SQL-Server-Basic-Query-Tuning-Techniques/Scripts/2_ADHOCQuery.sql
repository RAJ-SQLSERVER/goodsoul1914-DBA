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
-- Exercise 2: Ad Hoc Query Optimization
-------------------------------------------------------------

-- Step 1: Execute the following statements to select AdventureWorks2012 database
USE AdventureWorks2017;
SET NOCOUNT ON;
SET STATISTICS IO ON;
DBCC FREEPROCCACHE;
GO

--------------------
-- Begin: Step 2
--------------------
-- Execute the following select statement(s)

SELECT P.Name,
       THA.TransactionDate,
       THA.TransactionType,
       THA.Quantity,
       THA.ActualCost
FROM Production.TransactionHistoryArchive AS THA
    JOIN Production.Product AS P
        ON THA.ProductID = P.ProductID
WHERE P.ProductID = 461;

SELECT P.Name,
       THA.TransactionDate,
       THA.TransactionType,
       THA.Quantity,
       THA.ActualCost
FROM Production.TransactionHistoryArchive AS THA
    JOIN Production.Product AS P
        ON THA.ProductID = P.ProductID
WHERE P.ProductID = 712;

SELECT P.Name,
       THA.TransactionDate,
       THA.TransactionType,
       THA.Quantity,
       THA.ActualCost
FROM Production.TransactionHistoryArchive AS THA
    JOIN Production.Product AS P
        ON THA.ProductID = P.ProductID
WHERE P.ProductID = 888;

--------------------
-- End: Step 2
--------------------

-- Step 3: View plan cache details for the above three query
SELECT DEQS.execution_count,
       DEQS.query_hash,
       DEQS.query_plan_hash,
       DEST.text,
       DEQP.query_plan
FROM sys.dm_exec_query_stats AS DEQS
    CROSS APPLY sys.dm_exec_sql_text(DEQS.plan_handle) AS DEST
    CROSS APPLY sys.dm_exec_query_plan(DEQS.plan_handle) AS DEQP
WHERE DEST.text LIKE 'SELECT P.Name%';

-- Step 4: View plan cache details
SELECT objtype AS [CacheType],
       COUNT_BIG(*) AS [Total Plans],
       SUM(CAST(size_in_bytes AS DECIMAL(18, 2))) / 1024 / 1024 AS [Total MBs],
       AVG(usecounts) AS [Avg Use Count],
       SUM(   CAST((CASE
                        WHEN usecounts = 1 THEN
                            size_in_bytes
                        ELSE
                            0
                    END
                   ) AS DECIMAL(18, 2))
          ) / 1024 / 1024 AS [Total MBs - USE Count 1],
       SUM(   CASE
                  WHEN usecounts = 1 THEN
                      1
                  ELSE
                      0
              END
          ) AS [Total Plans - USE Count 1]
FROM sys.dm_exec_cached_plans
GROUP BY objtype
ORDER BY [Total MBs - USE Count 1] DESC;
GO

-- Step 5: Clear processes cache
DBCC FREEPROCCACHE;
GO


-- Step 6: Create a stored procedure usp_GETPRODETAILS
CREATE PROCEDURE usp_GETPRODETAILS
(@PID INT)
AS
SELECT P.Name,
       THA.TransactionDate,
       THA.TransactionType,
       THA.Quantity,
       THA.ActualCost
FROM Production.TransactionHistoryArchive AS THA
    JOIN Production.Product AS P
        ON THA.ProductID = P.ProductID
WHERE P.ProductID = @PID;

------------------
-- Begin: Step 7
------------------
-- Execute stored procedure usp_GETPRODETAILS with different parameter list
EXEC usp_GETPRODETAILS @PID = 461;
GO
EXEC usp_GETPRODETAILS @PID = 712;
GO
EXEC usp_GETPRODETAILS @PID = 888;
GO

------------------
-- End: Step 7
------------------

-- Step 8: View query deatils using DMV
SELECT DEQS.execution_count,
       DEQS.query_hash,
       DEQS.query_plan_hash,
       DEST.text,
       DEQP.query_plan
FROM sys.dm_exec_query_stats AS DEQS
    CROSS APPLY sys.dm_exec_sql_text(DEQS.plan_handle) AS DEST
    CROSS APPLY sys.dm_exec_query_plan(DEQS.plan_handle) AS DEQP
WHERE DEST.text LIKE 'CREATE PROCEDURE usp_GETPRODETAILS%';

--But then there can be problem of parameter sniffing!!

-- Step 9: Clear processes cache
DBCC FREEPROCCACHE;
GO

-- Step 10: Enable optimize for ad hoc workloads server setting
EXEC sys.sp_configure N'show advanced options', N'1';
GO
RECONFIGURE WITH OVERRIDE;
GO
EXEC sys.sp_configure N'optimize for ad hoc workloads', N'1';
GO
RECONFIGURE WITH OVERRIDE;
GO


--------------------
-- Begin: Step 11
--------------------
-- Execute the following select statement(s)

SELECT P.Name,
       THA.TransactionDate,
       THA.TransactionType,
       THA.Quantity,
       THA.ActualCost
FROM Production.TransactionHistoryArchive AS THA
    JOIN Production.Product AS P
        ON THA.ProductID = P.ProductID
WHERE P.ProductID = 461;

SELECT P.Name,
       THA.TransactionDate,
       THA.TransactionType,
       THA.Quantity,
       THA.ActualCost
FROM Production.TransactionHistoryArchive AS THA
    JOIN Production.Product AS P
        ON THA.ProductID = P.ProductID
WHERE P.ProductID = 712;

SELECT P.Name,
       THA.TransactionDate,
       THA.TransactionType,
       THA.Quantity,
       THA.ActualCost
FROM Production.TransactionHistoryArchive AS THA
    JOIN Production.Product AS P
        ON THA.ProductID = P.ProductID
WHERE P.ProductID = 888;

--------------------
-- End: Step 11
--------------------

-- Step 12: View query deatils using DMV
SELECT DEQS.execution_count,
       DEQS.query_hash,
       DEQS.query_plan_hash,
       DEST.text,
       DEQP.query_plan
FROM sys.dm_exec_query_stats AS DEQS
    CROSS APPLY sys.dm_exec_sql_text(DEQS.plan_handle) AS DEST
    CROSS APPLY sys.dm_exec_query_plan(DEQS.plan_handle) AS DEQP
WHERE DEST.text LIKE 'SELECT P.Name%';


-- Step 13: Execute the following select statement
SELECT P.Name,
       THA.TransactionDate,
       THA.TransactionType,
       THA.Quantity,
       THA.ActualCost
FROM Production.TransactionHistoryArchive AS THA
    JOIN Production.Product AS P
        ON THA.ProductID = P.ProductID
WHERE P.ProductID = 461;

-- Step 14: View query deatils using DMV
SELECT DEQS.execution_count,
       DEQS.query_hash,
       DEQS.query_plan_hash,
       DEST.text,
       DEQP.query_plan
FROM sys.dm_exec_query_stats AS DEQS
    CROSS APPLY sys.dm_exec_sql_text(DEQS.plan_handle) AS DEST
    CROSS APPLY sys.dm_exec_query_plan(DEQS.plan_handle) AS DEQP
WHERE DEST.text LIKE 'SELECT P.Name%';

------------------
-- Begin: Cleanup
------------------
-- Execute the following statement to drop usp_GETPRODETAILS stored procedure
DROP PROCEDURE usp_GETPRODETAILS;

-- Disable optimize for ad hoc workloads server setting
EXEC sys.sp_configure N'show advanced options', N'1';
GO
RECONFIGURE WITH OVERRIDE;
GO
EXEC sys.sp_configure N'optimize for ad hoc workloads', N'0';
GO
RECONFIGURE WITH OVERRIDE;
GO
------------------
-- End: Cleanup
------------------


/*===================================================================================================
For Hands-On-Labs feedback, write to us at holfeedback@SQLMaestros.com
For Hands-On-Labs support, write to us at holsupport@SQLMaestros.com
Do you wish to subscribe to HOLs for your team? Email holsales@SQLMaestros.com
For SQLMaestros Master Classes & Videos, visit www.SQLMaestros.com
====================================================================================================*/