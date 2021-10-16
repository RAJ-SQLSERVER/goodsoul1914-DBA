USE AdventureWorks;
GO

-- Searching for all queries run against the SalesOrderHeader table

SELECT TOP (10) d.name,
                est.text AS "TSQL_Text",
                eqs.creation_time,
                eqs.execution_count,
                eqs.total_worker_time AS "total_cpu_time",
                eqs.total_elapsed_time,
                eqs.total_logical_reads,
                eqs.total_physical_reads,
                eqp.query_plan
FROM sys.dm_exec_query_stats AS eqs
CROSS APPLY sys.dm_exec_sql_text (eqs.plan_handle) AS est
CROSS APPLY sys.dm_exec_query_plan (eqs.plan_handle) AS eqp
INNER JOIN sys.databases AS d
    ON est.dbid = d.database_id
WHERE est.text LIKE '%SalesOrderHeader%'
ORDER BY eqs.total_elapsed_time DESC;
GO


-- Which queries on our server are the most expensive?

SELECT TOP (25) d.name,
                est.text AS "TSQL_Text",
                CAST(CAST(eqs.total_worker_time AS DECIMAL) / CAST(eqs.execution_count AS DECIMAL) AS INT) AS "cpu_per_execution",
                CAST(CAST(eqs.total_logical_reads AS DECIMAL) / CAST(eqs.execution_count AS DECIMAL) AS INT) AS "logical_reads_per_execution",
                CAST(CAST(eqs.total_elapsed_time AS DECIMAL) / CAST(eqs.execution_count AS DECIMAL) AS INT) AS "elapsed_time_per_execution",
                eqs.creation_time,
                eqs.execution_count,
                eqs.total_worker_time AS "total_cpu_time",
                eqs.max_worker_time AS "max_cpu_time",
                eqs.total_elapsed_time,
                eqs.max_elapsed_time,
                eqs.total_logical_reads,
                eqs.max_logical_reads,
                eqs.total_physical_reads,
                eqs.max_physical_reads,
                eqp.query_plan,
                ecp.cacheobjtype,
                ecp.objtype,
                ecp.size_in_bytes
FROM sys.dm_exec_query_stats AS eqs
CROSS APPLY sys.dm_exec_sql_text (eqs.plan_handle) AS est
CROSS APPLY sys.dm_exec_query_plan (eqs.plan_handle) AS eqp
INNER JOIN sys.databases AS d
    ON est.dbid = d.database_id
INNER JOIN sys.dm_exec_cached_plans AS ecp
    ON ecp.plan_handle = eqs.plan_handle
WHERE d.name = 'AdventureWorks'
ORDER BY eqs.max_logical_reads DESC;
GO


-- To make a query easier to find, add a tag

-- 01232016 Open Order Query by EHP
SELECT TOP (100) soh.SalesOrderID,
                 sod.SalesOrderDetailID,
                 soh.OrderDate,
                 soh.DueDate,
                 soh.PurchaseOrderNumber,
                 sod.ProductID,
                 sod.LineTotal
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
    ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.Status <> 5
ORDER BY soh.OrderDate DESC;
GO


-- And then search for that tag

SELECT d.name,
       est.text AS "TSQL_Text",
       CAST(CAST(eqs.total_worker_time AS DECIMAL) / CAST(eqs.execution_count AS DECIMAL) AS INT) AS "cpu_per_execution",
       CAST(CAST(eqs.total_logical_reads AS DECIMAL) / CAST(eqs.execution_count AS DECIMAL) AS INT) AS "logical_reads_per_execution",
       CAST(CAST(eqs.total_elapsed_time AS DECIMAL) / CAST(eqs.execution_count AS DECIMAL) AS INT) AS "elapsed_time_per_execution",
       eqs.creation_time,
       eqs.execution_count,
       eqs.total_worker_time AS "total_cpu_time",
       eqs.max_worker_time AS "max_cpu_time",
       eqs.total_elapsed_time,
       eqs.max_elapsed_time,
       eqs.total_logical_reads,
       eqs.max_logical_reads,
       eqs.total_physical_reads,
       eqs.max_physical_reads,
       eqp.query_plan,
       ecp.cacheobjtype,
       ecp.objtype,
       ecp.size_in_bytes,
       CAST(CAST(eqs.execution_count AS DECIMAL)
            / CAST((CASE
                        WHEN DATEDIFF (HOUR, eqs.creation_time, CURRENT_TIMESTAMP) = 0 THEN 1
                        ELSE DATEDIFF (HOUR, eqs.creation_time, CURRENT_TIMESTAMP)
                    END
                   ) AS DECIMAL) AS INT) AS "executions_per_hour"
FROM sys.dm_exec_query_stats AS eqs
CROSS APPLY sys.dm_exec_sql_text (eqs.plan_handle) AS est
CROSS APPLY sys.dm_exec_query_plan (eqs.plan_handle) AS eqp
INNER JOIN sys.databases AS d
    ON est.dbid = d.database_id
INNER JOIN sys.dm_exec_cached_plans AS ecp
    ON ecp.plan_handle = eqs.plan_handle
WHERE est.text LIKE '-- 01232016 Open Order Query by EHP%';
GO


-- The following query will return only instances where a specific index is used

DECLARE @index_name AS NVARCHAR(128) = N'[PK_SalesOrderHeader_SalesOrderID]';

;WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
SELECT stmt.value ('(@StatementText)[1]', 'varchar(max)') AS "sql_text",
       obj.value ('(@Database)[1]', 'varchar(128)') AS "database_name",
       obj.value ('(@Schema)[1]', 'varchar(128)') AS "schema_name",
       obj.value ('(@Table)[1]', 'varchar(128)') AS "table_name",
       obj.value ('(@Index)[1]', 'varchar(128)') AS "index_name",
       obj.value ('(@IndexKind)[1]', 'varchar(128)') AS "index_type",
       eqp.query_plan,
       ecp.usecounts AS "execution_count"
FROM sys.dm_exec_cached_plans AS ecp
CROSS APPLY sys.dm_exec_query_plan (ecp.plan_handle) AS eqp
CROSS APPLY query_plan.nodes ('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS nodes(stmt)
CROSS APPLY stmt.nodes ('.//IndexScan/Object[@Index=sql:variable("@index_name")]') AS index_object(obj);
GO


-- Look for implicit conversion in the plan cache

;WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
SELECT est.text AS "sql_text",
       CAST(CAST(eqs.execution_count AS DECIMAL)
            / CAST((CASE
                        WHEN DATEDIFF (HOUR, eqs.creation_time, CURRENT_TIMESTAMP) = 0 THEN 1
                        ELSE DATEDIFF (HOUR, eqs.creation_time, CURRENT_TIMESTAMP)
                    END
                   ) AS DECIMAL) AS INT) AS "executions_per_hour",
       eqs.creation_time,
       eqs.execution_count,
       CAST(CAST(eqs.total_worker_time AS DECIMAL) / CAST(eqs.execution_count AS DECIMAL) AS INT) AS "cpu_per_execution",
       CAST(CAST(eqs.total_logical_reads AS DECIMAL) / CAST(eqs.execution_count AS DECIMAL) AS INT) AS "logical_reads_per_execution",
       CAST(CAST(eqs.total_elapsed_time AS DECIMAL) / CAST(eqs.execution_count AS DECIMAL) AS INT) AS "elapsed_time_per_execution",
       eqs.total_worker_time AS "total_cpu_time",
       eqs.max_worker_time AS "max_cpu_time",
       eqs.total_elapsed_time,
       eqs.max_elapsed_time,
       eqs.total_logical_reads,
       eqs.max_logical_reads,
       eqs.total_physical_reads,
       eqs.max_physical_reads,
       eqp.query_plan
FROM sys.dm_exec_query_stats AS eqs
CROSS APPLY sys.dm_exec_sql_text (eqs.sql_handle) AS est
CROSS APPLY sys.dm_exec_query_plan (eqs.plan_handle) AS eqp
WHERE query_plan.exist ('//PlanAffectingConvert') = 1
      AND query_plan.exist ('//ColumnReference[@Database = "[AdventureWorks]"]') = 1
ORDER BY eqs.total_worker_time DESC;
GO


-- Look for TempDB spills in the plan cache

;WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
SELECT est.text AS "sql_text",
       CAST(CAST(eqs.execution_count AS DECIMAL)
            / CAST((CASE
                        WHEN DATEDIFF (HOUR, eqs.creation_time, CURRENT_TIMESTAMP) = 0 THEN 1
                        ELSE DATEDIFF (HOUR, eqs.creation_time, CURRENT_TIMESTAMP)
                    END
                   ) AS DECIMAL) AS INT) AS "executions_per_hour",
       eqs.creation_time,
       eqs.execution_count,
       CAST(CAST(eqs.total_worker_time AS DECIMAL) / CAST(eqs.execution_count AS DECIMAL) AS INT) AS "cpu_per_execution",
       CAST(CAST(eqs.total_logical_reads AS DECIMAL) / CAST(eqs.execution_count AS DECIMAL) AS INT) AS "logical_reads_per_execution",
       CAST(CAST(eqs.total_elapsed_time AS DECIMAL) / CAST(eqs.execution_count AS DECIMAL) AS INT) AS "elapsed_time_per_execution",
       eqs.total_worker_time AS "total_cpu_time",
       eqs.max_worker_time AS "max_cpu_time",
       eqs.total_elapsed_time,
       eqs.max_elapsed_time,
       eqs.total_logical_reads,
       eqs.max_logical_reads,
       eqs.total_physical_reads,
       eqs.max_physical_reads,
       eqp.query_plan
FROM sys.dm_exec_query_stats AS eqs
CROSS APPLY sys.dm_exec_sql_text (eqs.sql_handle) AS est
CROSS APPLY sys.dm_exec_query_plan (eqs.plan_handle) AS eqp
WHERE query_plan.exist ('//Warnings') = 1
      AND query_plan.exist ('//ColumnReference[@Database = "[AdventureWorks]"]') = 1
ORDER BY eqs.total_worker_time DESC;
GO


-- Identify queries that resulted in a table scan or clustered index scan:

;WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
SELECT est.text AS "sql_text",
       CAST(CAST(eqs.execution_count AS DECIMAL)
            / CAST((CASE
                        WHEN DATEDIFF (HOUR, eqs.creation_time, CURRENT_TIMESTAMP) = 0 THEN 1
                        ELSE DATEDIFF (HOUR, eqs.creation_time, CURRENT_TIMESTAMP)
                    END
                   ) AS DECIMAL) AS INT) AS "executions_per_hour",
       eqs.creation_time,
       eqs.execution_count,
       CAST(CAST(eqs.total_worker_time AS DECIMAL) / CAST(eqs.execution_count AS DECIMAL) AS INT) AS "cpu_per_execution",
       CAST(CAST(eqs.total_logical_reads AS DECIMAL) / CAST(eqs.execution_count AS DECIMAL) AS INT) AS "logical_reads_per_execution",
       CAST(CAST(eqs.total_elapsed_time AS DECIMAL) / CAST(eqs.execution_count AS DECIMAL) AS INT) AS "elapsed_time_per_execution",
       eqs.total_worker_time AS "total_cpu_time",
       eqs.max_worker_time AS "max_cpu_time",
       eqs.total_elapsed_time,
       eqs.max_elapsed_time,
       eqs.total_logical_reads,
       eqs.max_logical_reads,
       eqs.total_physical_reads,
       eqs.max_physical_reads,
       eqp.query_plan
FROM sys.dm_exec_query_stats AS eqs
CROSS APPLY sys.dm_exec_sql_text (eqs.sql_handle) AS est
CROSS APPLY sys.dm_exec_query_plan (eqs.plan_handle) AS eqp
WHERE (
    query_plan.exist ('//RelOp[@PhysicalOp = "Index Scan"]') = 1
    OR query_plan.exist ('//RelOp[@PhysicalOp = "Clustered Index Scan"]') = 1
)
      AND query_plan.exist ('//ColumnReference[@Database = "[AdventureWorks]"]') = 1
ORDER BY eqs.total_worker_time DESC;
GO


-- Find largest plans in the plan cache

SELECT est.text,
       ecp.objtype,
       ecp.size_in_bytes,
       eqp.query_plan
FROM sys.dm_exec_cached_plans AS ecp
CROSS APPLY sys.dm_exec_sql_text (ecp.plan_handle) AS est
CROSS APPLY sys.dm_exec_query_plan (ecp.plan_handle) AS eqp
WHERE ecp.cacheobjtype = N'Compiled Plan'
      AND ecp.objtype IN ( N'Adhoc', N'Prepared' )
      AND ecp.usecounts = 1
ORDER BY ecp.size_in_bytes DESC;
GO


-- Get the total plan cache size

SELECT SUM (CAST(ecp.size_in_bytes AS BIGINT)) / 1024 AS "size_in_KB"
FROM sys.dm_exec_cached_plans AS ecp
WHERE ecp.cacheobjtype = N'Compiled Plan'
      AND ecp.objtype IN ( N'Adhoc', N'Prepared' )
      AND ecp.usecounts = 1;
GO


-- Determine average age of an execution plan

SELECT AVG (DATEDIFF (HOUR, eqs.creation_time, CURRENT_TIMESTAMP)) AS "average_creation_time_in_hours"
FROM sys.dm_exec_query_stats AS eqs
CROSS APPLY sys.dm_exec_sql_text (eqs.plan_handle) AS est
CROSS APPLY sys.dm_exec_query_plan (eqs.plan_handle) AS eqp
INNER JOIN sys.databases AS d
    ON est.dbid = d.database_id
WHERE d.name = 'StackOverflow2010';
GO


-- Breakdown of plan cache usage by database

SELECT d.name,
       SUM (CAST(ecp.size_in_bytes AS BIGINT)) AS "plan_cache_size_in_bytes",
       COUNT (*) AS "number_of_plans"
FROM sys.dm_exec_query_stats AS eqs
CROSS APPLY sys.dm_exec_query_plan (eqs.plan_handle) AS eqp
INNER JOIN sys.databases AS d
    ON d.database_id = eqp.dbid
INNER JOIN sys.dm_exec_cached_plans AS ecp
    ON ecp.plan_handle = eqs.plan_handle
GROUP BY d.name;
GO


-- Collect the number of plans (and total space used) for any given index

DECLARE @index_name AS NVARCHAR(128) = N'[PK_SalesOrderHeader_SalesOrderID]';

;WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
SELECT SUM (CAST(ecp.size_in_bytes AS BIGINT)) AS "plan_cache_size_in_bytes",
       COUNT (*) AS "number_of_plans"
FROM sys.dm_exec_cached_plans AS ecp
CROSS APPLY sys.dm_exec_query_plan (ecp.plan_handle) AS eqp
CROSS APPLY query_plan.nodes ('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS nodes(stmt)
CROSS APPLY stmt.nodes ('.//IndexScan/Object[@Index=sql:variable("@index_name")]') AS index_object(obj);
GO
