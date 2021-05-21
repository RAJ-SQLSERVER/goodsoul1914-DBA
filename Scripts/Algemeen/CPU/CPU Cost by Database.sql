SELECT DB_NAME(pa.database_id) AS [database_name],
       SUM(qs.total_worker_time / qs.execution_count) AS cpu_cost
FROM sys.dm_exec_query_stats qs
    CROSS APPLY
(
    SELECT CONVERT(INT, value) AS database_id
    FROM sys.dm_exec_plan_attributes(qs.plan_handle)
    WHERE attribute = N'dbid'
) pa
GROUP BY pa.database_id
ORDER BY cpu_cost DESC;
GO
