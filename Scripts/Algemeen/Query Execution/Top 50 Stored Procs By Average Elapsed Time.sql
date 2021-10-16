-- Top 50 Cached Stored Procedures By Avg Elapsed Time
--
-- This helps you find high average elapsed time cached stored procedures that
-- may be easy to optimize with standard query tuning techniques
---------------------------------------------------------------------------------------------------

SELECT TOP (25) p.name AS "SP Name",
                qs.total_elapsed_time / qs.execution_count AS "avg_elapsed_time",
                qs.min_elapsed_time,
                qs.max_elapsed_time,
                qs.last_elapsed_time,
                qs.total_elapsed_time,
                qs.execution_count,
                ISNULL (qs.execution_count / DATEDIFF (MINUTE, qs.cached_time, GETDATE ()), 0) AS "Calls/Minute",
                qs.total_worker_time / qs.execution_count AS "AvgWorkerTime",
                qs.total_worker_time AS "TotalWorkerTime",
                CASE
                    WHEN CONVERT (NVARCHAR(MAX), qp.query_plan) LIKE N'%<MissingIndexes>%' THEN 1
                    ELSE 0
                END AS "Has Missing Index",
                FORMAT (qs.last_execution_time, 'yyyy-MM-dd HH:mm:ss', 'en-US') AS "Last Execution Time",
                FORMAT (qs.cached_time, 'yyyy-MM-dd HH:mm:ss', 'en-US') AS "Plan Cached Time",
                qp.query_plan AS "Query Plan" -- Uncomment if you want the Query Plan
FROM sys.procedures AS p WITH (NOLOCK)
INNER JOIN sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
    ON p.object_id = qs.object_id
CROSS APPLY sys.dm_exec_query_plan (qs.plan_handle) AS qp
WHERE qs.database_id = DB_ID ()
      AND DATEDIFF (MINUTE, qs.cached_time, GETDATE ()) > 0
ORDER BY avg_elapsed_time DESC
OPTION (RECOMPILE);
GO

--

SELECT TOP 10 t.text AS "ProcedureName",
              s.execution_count AS "ExecutionCount",
              ISNULL (s.total_elapsed_time / s.execution_count, 0) AS "AvgExecutionTime",
              s.total_worker_time / s.execution_count AS "AvgWorkerTime",
              s.total_worker_time AS "TotalWorkerTime",
              s.max_logical_reads AS "MaxLogicalReads",
              s.max_logical_writes AS "MaxLogicalWrites",
              s.creation_time AS "CreationDateTime",
              ISNULL (s.execution_count / DATEDIFF (SECOND, s.creation_time, GETDATE ()), 0) AS "CallsPerSecond"
FROM sys.dm_exec_query_stats AS s
CROSS APPLY sys.dm_exec_sql_text (s.sql_handle) AS t
-- WHERE ...
ORDER BY s.total_elapsed_time DESC;