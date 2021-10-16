-- Execution counts
-- ------------------------------------------------------------------------------------------------

SELECT TOP (50) LEFT(t.text, 50) AS "Short Query Text",
                qs.execution_count AS "Execution Count",
                qs.total_logical_reads AS "Total Logical Reads",
                qs.total_logical_reads / qs.execution_count AS "Avg Logical Reads",
                qs.total_worker_time AS "Total Worker Time",
                qs.total_worker_time / qs.execution_count AS "Avg Worker Time",
                qs.total_elapsed_time AS "Total Elapsed Time",
                qs.total_elapsed_time / qs.execution_count AS "Avg Elapsed Time",
                CASE
                    WHEN CONVERT (NVARCHAR(MAX), qp.query_plan) LIKE N'%<MissingIndexes>%' THEN 1
                    ELSE 0
                END AS "Has Missing Index",
                qs.creation_time AS "Creation Time",
                t.text AS "Complete Query Text",
                qp.query_plan AS "Query Plan"
FROM sys.dm_exec_query_stats AS qs WITH (NOLOCK)
CROSS APPLY sys.dm_exec_sql_text (plan_handle) AS t
CROSS APPLY sys.dm_exec_query_plan (plan_handle) AS qp
WHERE t.dbid = DB_ID ()
ORDER BY qs.execution_count DESC
OPTION (RECOMPILE);
GO

-- Most frequently run queries
---------------------------------------------------------------------------------------------------

SELECT TOP (5) qsp.query_id,
               qsrt.count_executions,
               qsqt.query_sql_text
FROM sys.query_store_query AS qsq
INNER JOIN sys.query_store_query_text AS qsqt
    ON qsqt.query_text_id = qsq.query_text_id
INNER JOIN sys.query_store_plan AS qsp
    ON qsp.query_id = qsq.query_id
INNER JOIN sys.query_store_runtime_stats AS qsrt
    ON qsrt.plan_id = qsp.plan_id
INNER JOIN sys.query_store_runtime_stats_interval AS qsrsi
    ON qsrsi.runtime_stats_interval_id = qsrt.runtime_stats_interval_id
WHERE qsrsi.start_time >= '2020-01-01 00:00:00'
      AND qsrsi.start_time < '2020-01-01 19:00:00'
GROUP BY qsp.query_id,
         qsqt.query_sql_text,
         qsrt.count_executions
ORDER BY SUM (qsrt.count_executions) DESC;
GO