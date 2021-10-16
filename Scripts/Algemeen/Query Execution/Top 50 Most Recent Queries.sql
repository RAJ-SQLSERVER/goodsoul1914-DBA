-- Top 50 most recent queries
-- ------------------------------------------------------------------------------------------------

SELECT TOP 50 DB_NAME (ST.dbid) AS "database",
              execution_count,
              total_worker_time / execution_count AS "avg_cpu",
              total_elapsed_time / execution_count AS "avg_time",
              total_logical_reads / execution_count AS "avg_reads",
              total_logical_writes / execution_count AS "avg_writes",
              SUBSTRING (ST.text,
                         QS.statement_start_offset / 2 + 1,
                         (CASE QS.statement_end_offset
                              WHEN -1 THEN DATALENGTH (ST.text)
                              ELSE QS.statement_end_offset
                          END - QS.statement_start_offset
                         ) / 2 + 1
              ) AS "request",
              query_plan
FROM sys.dm_exec_query_stats AS QS
CROSS APPLY sys.dm_exec_sql_text (QS.sql_handle) AS ST
CROSS APPLY sys.dm_exec_query_plan (QS.plan_handle) AS QP
--WHERE	DB_NAME(ST.[dbid]) = 'Credit'
ORDER BY total_elapsed_time DESC;
GO