-- Top Cached Stored Procedures By Execution Count
--
-- Tells you which cached stored procedures are called most often
-- This helps you characterize and baseline your workload
---------------------------------------------------------------------------------------------------

SELECT TOP (50) p.name AS "SP Name",
                qs.execution_count AS "Execution Count",
                ISNULL (qs.execution_count / DATEDIFF (MINUTE, qs.cached_time, GETDATE ()), 0) AS "Calls/Minute",
                qs.total_elapsed_time / qs.execution_count AS "Avg Elapsed Time",
                qs.total_worker_time / qs.execution_count AS "Avg Worker Time",
                qs.total_logical_reads / qs.execution_count AS "Avg Logical Reads",
                CASE
                    WHEN CONVERT (NVARCHAR(MAX), qp.query_plan) LIKE N'%<MissingIndexes>%' THEN 1
                    ELSE 0
                END AS "Has Missing Index",
                FORMAT (qs.last_execution_time, 'yyyy-MM-dd HH:mm:ss', 'en-US') AS "Last Execution Time",
                FORMAT (qs.cached_time, 'yyyy-MM-dd HH:mm:ss', 'en-US') AS "Plan Cached Time",
                qp.query_plan AS "Query Plan"
FROM sys.procedures AS p WITH (NOLOCK)
INNER JOIN sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
    ON p.object_id = qs.object_id
CROSS APPLY sys.dm_exec_query_plan (qs.plan_handle) AS qp
WHERE qs.database_id = DB_ID ()
      AND DATEDIFF (MINUTE, qs.cached_time, GETDATE ()) > 0
ORDER BY qs.execution_count DESC
OPTION (RECOMPILE);
GO
