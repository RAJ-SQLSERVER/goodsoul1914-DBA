USE StackOverflow2010
GO

-------------------------------------------------------------------------------
-- You can verify the configuration of the Query Store on a given database 
-- by checking a new view:
-------------------------------------------------------------------------------
SELECT desired_state,
       desired_state_desc,
       actual_state,
       actual_state_desc,
       readonly_reason,
       current_storage_size_mb,
       flush_interval_seconds,
       interval_length_minutes,
       max_storage_size_mb,
       stale_query_threshold_days,
       max_plans_per_query,
       query_capture_mode,
       query_capture_mode_desc,
       size_based_cleanup_mode,
       size_based_cleanup_mode_desc,
       wait_stats_capture_mode,
       wait_stats_capture_mode_desc,
       actual_state_additional_info
FROM sys.database_query_store_options;
GO

-------------------------------------------------------------------------------
-- This query returns useful info on queries, their text, execution plans, 
-- and some historical statistics on their resource consumption
-------------------------------------------------------------------------------
SELECT TOP (50)
       qsqt.query_sql_text,
       CAST(qsp.query_plan AS XML) AS query_plan_xml,
       qsrs.first_execution_time,
       qsrs.last_execution_time,
       qsrs.count_executions,
       qsrs.avg_duration / 1000 AS avg_duration_ms,
       qsrs.last_duration / 1000 AS last_duration_ms,
       qsrs.avg_cpu_time / 1000 AS avg_cpu_time_ms,
       qsrs.last_cpu_time / 1000 AS last_cpu_time_ms,
       qsrs.avg_logical_io_reads,
       qsrs.last_logical_io_reads,
       qsrs.avg_query_max_used_memory AS avg_query_max_used_memory_8k_pages,
       qsrs.last_query_max_used_memory AS last_query_max_used_memory_8k_pages,
       qsrs.avg_rowcount,
       qsrs.last_rowcount,
       qsrsi.start_time AS interval_start_time,
       qsrsi.end_time AS interval_end_time,
       qsq.query_id,
       qsqt.query_text_id,
       qsp.plan_id
FROM sys.query_store_query qsq
    LEFT JOIN sys.query_store_query_text qsqt
        ON qsq.query_text_id = qsqt.query_text_id
    LEFT JOIN sys.query_store_plan qsp
        ON qsq.query_id = qsp.query_id
    LEFT JOIN sys.query_store_runtime_stats qsrs
        ON qsp.plan_id = qsrs.plan_id
    LEFT JOIN sys.query_store_runtime_stats_interval qsrsi
        ON qsrs.runtime_stats_interval_id = qsrsi.runtime_stats_interval_id
WHERE qsrsi.start_time > DATEADD(DAY, -2, CURRENT_TIMESTAMP)
ORDER BY qsrs.avg_cpu_time DESC;
-- ORDER BY query_store_runtime_stats.avg_duration DESC
-- ORDER BY query_store_runtime_stats.count_executions DESC
-- ORDER BY query_store_runtime_stats.avg_logical_io_reads DESC
-- ORDER BY query_store_runtime_stats.avg_rowcount DESC
GO

-------------------------------------------------------------------------------
-- Tracking queries
-------------------------------------------------------------------------------

SELECT * FROM dbo.Users
GO

SELECT TOP (50)
       qsq.query_id,
       qsqt.query_sql_text,
       CAST(qsp.query_plan AS XML) AS query_plan_xml,
       qsrs.first_execution_time,
       qsrs.last_execution_time,
       qsrs.count_executions,
       qsrs.avg_duration AS avg_duration_microseconds,
       qsrs.last_duration AS last_duration_microseconds,
       qsrs.avg_cpu_time AS avg_cpu_time_microseconds,
       qsrs.last_cpu_time AS last_cpu_time_microseconds,
       qsrs.avg_logical_io_reads,
       qsrs.last_logical_io_reads,
       qsrs.avg_query_max_used_memory AS avg_query_max_used_memory_8k_pages,
       qsrs.last_query_max_used_memory AS last_query_max_used_memory_8k_pages,
       qsrs.avg_rowcount,
       qsrs.last_rowcount
FROM sys.query_store_query qsq
    LEFT JOIN sys.query_store_query_text qsqt
        ON qsq.query_text_id = qsqt.query_text_id
    LEFT JOIN sys.query_store_plan qsp
        ON qsq.query_id = qsp.query_id
    LEFT JOIN sys.query_store_runtime_stats qsrs
        ON qsp.plan_id = qsrs.plan_id
    LEFT JOIN sys.query_store_runtime_stats_interval qsrsi
        ON qsrs.runtime_stats_interval_id = qsrsi.runtime_stats_interval_id
WHERE qsrsi.start_time > DATEADD(DAY, -7, CURRENT_TIMESTAMP)
      AND qsqt.query_sql_text LIKE '%SELECT * FROM dbo.Users%'
ORDER BY qsrs.last_execution_time DESC;
GO

-------------------------------------------------------------------------------
-- Queries from the past week that used a specific index
-------------------------------------------------------------------------------
SELECT TOP (50)
       qsq.query_id,
       qsqt.query_sql_text,
       CAST(qsp.query_plan AS XML) AS query_plan_xml,
       qsrs.avg_logical_io_reads
FROM sys.query_store_query qsq
    LEFT JOIN sys.query_store_query_text qsqt
        ON qsq.query_text_id = qsqt.query_text_id
    LEFT JOIN sys.query_store_plan qsp
        ON qsq.query_id = qsp.query_id
    LEFT JOIN sys.query_store_runtime_stats qsrs
        ON qsp.plan_id = qsrs.plan_id
    LEFT JOIN sys.query_store_runtime_stats_interval qsrsi
        ON qsrs.runtime_stats_interval_id = qsrsi.runtime_stats_interval_id
WHERE qsrsi.start_time > DATEADD(DAY, -7, CURRENT_TIMESTAMP)
      AND qsp.query_plan LIKE '%PK_Users_Id%'
ORDER BY qsrs.avg_logical_io_reads DESC;
GO

-------------------------------------------------------------------------------
-- Queries from the past day with CONVERSION_IMPLICIT
-------------------------------------------------------------------------------
SELECT TOP (50)
       qsq.query_id,
       qsqt.query_sql_text,
       qsp.query_plan AS query_plan_text,
       CAST(qsp.query_plan AS XML) AS query_plan_xml,
       qsrs.last_execution_time
FROM sys.query_store_query qsq
    LEFT JOIN sys.query_store_query_text qsqt
        ON qsq.query_text_id = qsqt.query_text_id
    LEFT JOIN sys.query_store_plan qsp
        ON qsq.query_id = qsp.query_id
    LEFT JOIN sys.query_store_runtime_stats qsrs
        ON qsp.plan_id = qsrs.plan_id
    LEFT JOIN sys.query_store_runtime_stats_interval qsrsi
        ON qsrs.runtime_stats_interval_id = qsrsi.runtime_stats_interval_id
WHERE qsrsi.start_time > DATEADD(DAY, -1, CURRENT_TIMESTAMP)
      AND qsp.query_plan LIKE '%convert_implicit%'
ORDER BY qsrs.last_execution_time DESC;
GO

-------------------------------------------------------------------------------
-- Regressed Queries
--
-- Any queries in the past week where the CPU doubled between one execution 
-- and another future execution.
-------------------------------------------------------------------------------
SELECT qsqt.query_sql_text,
       stats_interval_1.start_time AS interval_1,
       stats_interval_2.start_time AS interval_2,
       query_plan_1.plan_id AS plan_id_1,
       query_plan_2.plan_id AS plan_id_2,
       runtime_stats_1.avg_duration AS avg_duration_1,
       runtime_stats_2.avg_duration AS avg_duration_2,
       runtime_stats_1.avg_cpu_time AS avg_cpu_1,
       runtime_stats_2.avg_cpu_time AS avg_cpu_2,
       runtime_stats_1.avg_logical_io_reads AS avg_reads_1,
       runtime_stats_2.avg_logical_io_reads AS avg_reads_2
FROM sys.query_store_query_text qsqt
    INNER JOIN sys.query_store_query qsq
        ON qsqt.query_text_id = qsq.query_text_id
    INNER JOIN sys.query_store_plan AS query_plan_1
        ON qsq.query_id = query_plan_1.query_id
    INNER JOIN sys.query_store_runtime_stats AS runtime_stats_1
        ON query_plan_1.plan_id = runtime_stats_1.plan_id
    INNER JOIN sys.query_store_runtime_stats_interval AS stats_interval_1
        ON stats_interval_1.runtime_stats_interval_id = runtime_stats_1.runtime_stats_interval_id
    INNER JOIN sys.query_store_plan AS query_plan_2
        ON qsq.query_id = query_plan_2.query_id
    INNER JOIN sys.query_store_runtime_stats AS runtime_stats_2
        ON query_plan_2.plan_id = runtime_stats_2.plan_id
    INNER JOIN sys.query_store_runtime_stats_interval AS stats_interval_2
        ON stats_interval_2.runtime_stats_interval_id = runtime_stats_2.runtime_stats_interval_id
WHERE stats_interval_1.start_time > DATEADD(DAY, -7, CURRENT_TIMESTAMP)
      AND stats_interval_2.start_time > stats_interval_1.start_time
      AND query_plan_1.plan_id <> query_plan_2.plan_id
      -- AND runtime_stats_2.avg_duration > 2 * runtime_stats_1.avg_duration
      -- AND runtime_stats_2.avg_logical_io_reads > 2 * runtime_stats_1.avg_logical_io_reads
      AND runtime_stats_2.avg_cpu_time > 2 * runtime_stats_1.avg_cpu_time
ORDER BY qsq.query_id,
         stats_interval_1.start_time,
         stats_interval_2.start_time;
GO

