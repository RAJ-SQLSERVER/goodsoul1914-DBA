-------------------------------------------------------------------------------
-- Recent Execution of Stored Procedures
-------------------------------------------------------------------------------

SELECT DB_NAME(eps.database_id) AS "database_name",
       SCHEMA_NAME(o.schema_id) AS "schema_name",
       OBJECT_NAME(eps.object_id) AS "stored_procedure",
       eps.type_desc,
       eps.cached_time,
       eps.last_execution_time,
       eps.execution_count,
       (eps.total_worker_time / eps.execution_count) / 1000 AS "avg_worker_time_ms",
       (eps.total_elapsed_time / eps.execution_count) / 1000 AS "avg_elapsed_time_ms",
       (eps.total_logical_reads / eps.execution_count) AS "avg_logical_reads",
       (eps.total_logical_writes / eps.execution_count) AS "avg_logical_writes",
       (eps.total_physical_reads / eps.execution_count) AS "avg_physical_reads",
       (eps.total_spills / eps.execution_count) AS "avg_page_spills"
FROM sys.dm_exec_procedure_stats eps
    INNER JOIN sys.objects o
        ON o.object_id = eps.object_id
WHERE o.type = 'P'
ORDER BY eps.last_execution_time DESC;
GO

-------------------------------------------------------------------------------
-- Recent Execution of Functions
-------------------------------------------------------------------------------

SELECT DB_NAME(efs.database_id) AS "database_name",
       SCHEMA_NAME(o.schema_id) AS "schema_name",
       OBJECT_NAME(efs.object_id) AS "function_name",
       efs.type_desc,
       efs.cached_time,
       efs.last_execution_time,
       efs.execution_count,
       (efs.total_worker_time / efs.execution_count) / 1000 AS "avg_worker_time_ms",
       (efs.total_elapsed_time / efs.execution_count) / 1000 AS "avg_elapsed_time_ms",
       (efs.total_logical_reads / efs.execution_count) AS "avg_logical_reads",
       (efs.total_logical_writes / efs.execution_count) AS "avg_logical_writes",
       (efs.total_physical_reads / efs.execution_count) AS "avg_physical_reads"
FROM sys.dm_exec_function_stats efs
    INNER JOIN sys.objects o
        ON o.object_id = efs.object_id
ORDER BY efs.last_execution_time DESC;
GO

