/*
Optimize for Ad Hoc Workloads is one of those server level settings that are not 
changed very often, but is still good to know about. Before we get into the details 
let’s talk about what it is. When using SQL Server, it reserves a portion of memory 
for Plan Cache. The Optimize for Ad Hoc Workloads setting controls what SQL Server 
places into this plan cache for single use queries. When it is turned off, all single 
use queries will have the entire plan cached, therefore consuming more space. 
By turning this on, you are asking SQL Server to not store the entire plan when the 
query is executed the first time, SQL Server will now only store a plan stub instead. 
Which consumes less memory than the full plan would. Something to keep in mind, 
the next time that the query is executed, it will flush the stub from the cache and 
replace it with the full plan.
*/


-- Determine if "Optimize for Ad Hoc Workloads" is enabled

SELECT name,
       value,
       description
FROM sys.configurations
WHERE name = 'optimize for ad hoc workloads';
GO


-- How to determine if there are a lot of Single use Queries in Cache?
-- Enable "Optimize for Ad Hoc Workloads" when between 20 and 30%

SELECT AdHoc_Plan_MB,
       Total_Cache_MB,
       AdHoc_Plan_MB * 100.0 / Total_Cache_MB AS 'AdHoc %'
FROM
(
    SELECT SUM(   CASE
                      WHEN objtype = 'adhoc' THEN
                          CONVERT(BIGINT, size_in_bytes)
                      ELSE
                          0
                  END
              ) / 1048576.0 AdHoc_Plan_MB,
           SUM(CONVERT(BIGINT, size_in_bytes)) / 1048576.0 Total_Cache_MB
    FROM sys.dm_exec_cached_plans
) T;


-- Determine the number of ad hoc queries in the cache

SELECT SUM(c.usecounts),
       c.objtype
FROM sys.dm_exec_cached_plans AS c
    CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS t
    CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS q
GROUP BY c.objtype;
GO


-- How do I get the Query Plan

SELECT cplan.usecounts,
       cplan.objtype,
       qtext.text,
       qplan.query_plan
FROM sys.dm_exec_cached_plans AS cplan
    CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS qtext
    CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qplan
ORDER BY cplan.usecounts DESC;
GO


-- Clear Cache
USE AdventureWorks2014
GO

DBCC FREEPROCCACHE

--SELECT database_id
--FROM sys.databases
--WHERE name = 'AdventureWorks2014'

-- Confirm there are no plans in the cache
SELECT c.usecounts,
       c.objtype,
       t.text,
       q.query_plan
FROM sys.dm_exec_cached_plans AS c
    CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS t
    CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS q
WHERE t.text LIKE '%select% *%'
      AND q.dbid = 5
ORDER BY c.usecounts DESC;
GO

-- Run this query the first time
SELECT * 
FROM Production.Product

-- Confirm there are no plans in the cache for it
SELECT c.usecounts,
       c.objtype,
       t.text,
       q.query_plan
FROM sys.dm_exec_cached_plans AS c
    CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS t
    CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS q
WHERE t.text LIKE '%select% *%'
      AND q.dbid = 5
ORDER BY c.usecounts DESC;
GO

-- Run this query the second time
SELECT * 
FROM Production.Product

-- Confirm there is a plan in the cache for it
SELECT c.usecounts,
       c.objtype,
       t.text,
       q.query_plan
FROM sys.dm_exec_cached_plans AS c
    CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS t
    CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS q
WHERE t.text LIKE '%select% *%'
      AND q.dbid = 5
ORDER BY c.usecounts DESC;
GO

