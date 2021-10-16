-- Worker Time
---------------------------------------------------------------------------------------------------

SELECT TOP (25) p.name AS "SP Name",
                qs.total_worker_time AS "TotalWorkerTime",
                qs.total_worker_time / qs.execution_count AS "AvgWorkerTime",
                qs.execution_count,
                ISNULL (qs.execution_count / DATEDIFF (MINUTE, qs.cached_time, GETDATE ()), 0) AS "Calls/Minute",
                qs.total_elapsed_time,
                qs.total_elapsed_time / qs.execution_count AS "avg_elapsed_time",
                CASE
                    WHEN CONVERT (NVARCHAR(MAX), qp.query_plan) LIKE N'%<MissingIndexes>%' THEN 1
                    ELSE 0
                END AS "Has Missing Index",
                FORMAT (qs.last_execution_time, 'yyyy-MM-dd HH:mm:ss', 'en-US') AS "Last Execution Time",
                FORMAT (qs.cached_time, 'yyyy-MM-dd HH:mm:ss', 'en-US') AS "Plan Cached Time"
FROM sys.procedures AS p WITH (NOLOCK)
INNER JOIN sys.dm_exec_procedure_stats AS qs WITH (NOLOCK)
    ON p.object_id = qs.object_id
CROSS APPLY sys.dm_exec_query_plan (qs.plan_handle) AS qp
WHERE qs.database_id = DB_ID ()
      AND DATEDIFF (MINUTE, qs.cached_time, GETDATE ()) > 0
ORDER BY qs.total_worker_time DESC
OPTION (RECOMPILE);
GO