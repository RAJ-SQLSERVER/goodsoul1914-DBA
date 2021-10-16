-- Query to find top 50 high CPU queries and it's details
-- Author: Saleem Hakani (http://sqlcommunity.com)
-- ------------------------------------------------------------------------------------------------

SELECT TOP 50 CONVERT (VARCHAR, qs.creation_time, 109) AS "Plan_Compiled_On",
              qs.execution_count AS "Total Executions",
              qs.total_worker_time AS "Overall CPU Time Since Compiled",
              CONVERT (VARCHAR, qs.last_execution_time, 109) AS "Last Execution Date/Time",
              CAST(qs.last_worker_time AS VARCHAR) + '   (' + CAST(qs.max_worker_time AS VARCHAR) + ' Highest ever)' AS "CPU Time for Last Execution (Milliseconds)",
              CONVERT (VARCHAR, (qs.last_worker_time / 1000) / (60 * 60)) + ' Hrs (i.e. '
              + CONVERT (VARCHAR, (qs.last_worker_time / 1000) / 60) + ' Mins & '
              + CONVERT (VARCHAR, (qs.last_worker_time / 1000) % 60) + ' Seconds)' AS "Last Execution Duration",
              qs.last_rows AS "Rows returned",
              qs.total_logical_reads / 128 AS "Overall Logical Reads (MB)",
              qs.max_logical_reads / 128 AS "Highest Logical Reads (MB)",
              qs.last_logical_reads / 128 AS "Logical Reads from Last Execution (MB)",
              qs.total_physical_reads / 128 AS "Total Physical Reads Since Compiled (MB)",
              qs.last_dop AS "Last DOP used",
              qs.last_physical_reads / 128 AS "Physical Reads from Last Execution (MB)",
              t.text AS "Query Text",
              qp.query_plan AS "Query Execution Plan",
              DB_NAME (t.dbid) AS "Database Name",
              t.objectid AS "Object ID",
              t.encrypted AS "Is Query Encrypted",
              qs.plan_handle --Uncomment this if you want query plan handle
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text (plan_handle) AS t
CROSS APPLY sys.dm_exec_query_plan (plan_handle) AS qp
ORDER BY qs.last_worker_time DESC;
GO

-- Statements with highest average CPU time
-- ------------------------------------------------------------------------------------------------

SELECT TOP 50 qs.total_worker_time / qs.execution_count AS "Avg CPU Time",
              SUBSTRING (
                  qt.text,
                  qs.statement_start_offset / 2,
                  (CASE
                       WHEN qs.statement_end_offset = -1 THEN LEN (CONVERT (NVARCHAR(MAX), qt.text)) * 2
                       ELSE qs.statement_end_offset
                   END - qs.statement_start_offset
                  ) / 2
              ) AS "query_text",
              qt.dbid,
              DB_NAME (qt.dbid) AS "dbname",
              qt.objectid
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text (qs.sql_handle) AS qt
ORDER BY [Avg CPU Time] DESC;
GO

-- Finding Top 10 CPU-consuming Queries
---------------------------------------------------------------------------------------------------

SELECT TOP (10) SUBSTRING (st.text,
                           qs.statement_start_offset / 2 + 1,
                           (CASE statement_end_offset
                                WHEN -1 THEN DATALENGTH (st.text)
                                ELSE qs.statement_end_offset
                            END - qs.statement_start_offset
                           ) / 2 + 1
                ) AS "statement_text",
                execution_count,
                total_worker_time / 1000 AS "total_worker_time_ms",
                (total_worker_time / 1000) / execution_count AS "avg_worker_time_ms",
                total_logical_reads,
                total_logical_reads / execution_count AS "avg_logical_reads",
                total_elapsed_time / 1000 AS "total_elapsed_time_ms",
                (total_elapsed_time / 1000) / execution_count AS "avg_elapsed_time_ms",
                qp.query_plan
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text (qs.sql_handle) AS st
CROSS APPLY sys.dm_exec_query_plan (qs.plan_handle) AS qp
ORDER BY total_worker_time DESC;
GO