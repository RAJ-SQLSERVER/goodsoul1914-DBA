-- Top 50 Stored Procs by Logical Writes
---------------------------------------------------------------------------------------------------

SELECT TOP (50) p.name AS "SP Name",
                qs.total_logical_writes AS "TotalLogicalWrites",
                qs.total_logical_writes / qs.execution_count AS "AvgLogicalWrites",
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
      AND qs.total_logical_writes > 0
      AND DATEDIFF (MINUTE, qs.cached_time, GETDATE ()) > 0
ORDER BY qs.total_logical_writes DESC
OPTION (RECOMPILE);
GO

-- Top 50 Stored Procs by Physical Writes
---------------------------------------------------------------------------------------------------

SELECT TOP (50) p.name AS "SP Name",
                qs.total_physical_reads AS "TotalPhysicalReads",
                qs.total_physical_reads / qs.execution_count AS "AvgPhysicalReads",
                qs.execution_count,
                qs.total_logical_reads,
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
      AND qs.total_physical_reads > 0
ORDER BY qs.total_physical_reads DESC,
         qs.total_logical_reads DESC
OPTION (RECOMPILE);
GO

-- Top 50 Stored Procedures by Average I/O
---------------------------------------------------------------------------------------------------

SELECT TOP 50 s.name + '.' + p.name AS "Procedure",
              qp.query_plan AS "Plan",
              (ps.total_logical_reads + ps.total_logical_writes) / ps.execution_count AS "Avg IO",
              ps.execution_count AS "Exec Cnt",
              ps.cached_time AS "Cached",
              ps.last_execution_time AS "Last Exec Time",
              ps.total_logical_reads AS "Total Reads",
              ps.last_logical_reads AS "Last Reads",
              ps.total_logical_writes AS "Total Writes",
              ps.last_logical_writes AS "Last Writes",
              ps.total_worker_time AS "Total Worker Time",
              ps.last_worker_time AS "Last Worker Time",
              ps.total_elapsed_time AS "Total Elapsed Time",
              ps.last_elapsed_time AS "Last Elapsed Time"
FROM sys.procedures AS p WITH (NOLOCK)
JOIN sys.schemas AS s WITH (NOLOCK)
    ON p.schema_id = s.schema_id
JOIN sys.dm_exec_procedure_stats AS ps WITH (NOLOCK)
    ON p.object_id = ps.object_id
OUTER APPLY sys.dm_exec_query_plan (ps.plan_handle) AS qp
ORDER BY [Avg IO] DESC
OPTION (RECOMPILE);
GO