-- Get Top Average Elapsed Time Queries For Entire Instance
--
-- Helps you find the highest average elapsed time queries across the entire instance
-- Can also help track down parameter sniffing issues
---------------------------------------------------------------------------------------------------

SELECT TOP (50) DB_NAME (t.dbid) AS "Database Name",
                qs.total_elapsed_time / qs.execution_count AS "Avg Elapsed Time",
                qs.min_elapsed_time,
                qs.max_elapsed_time,
                qs.last_elapsed_time,
                qs.execution_count AS "Execution Count",
                qs.total_logical_reads / qs.execution_count AS "Avg Logical Reads",
                qs.total_physical_reads / qs.execution_count AS "Avg Physical Reads",
                qs.total_worker_time / qs.execution_count AS "Avg Worker Time",
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
ORDER BY qs.total_elapsed_time / qs.execution_count DESC
OPTION (RECOMPILE);
GO

-- Finding the most expensive statements in your database
-- ------------------------------------------------------------------------------------------------

SELECT TOP 20 DB_NAME (CONVERT (INT, epa.value)) AS "DatabaseName",
              qs.execution_count AS "Execution count",
              total_worker_time / qs.execution_count AS "CpuPerExecution",
              total_worker_time AS "TotalCPU",
              (total_logical_reads + total_logical_writes) / qs.execution_count AS "IOPerExecution",
              total_logical_reads + total_logical_writes AS "TotalIO",
              total_elapsed_time / qs.execution_count AS "AverageElapsedTime",
              (total_elapsed_time - total_worker_time) / qs.execution_count AS "AverageTimeBlocked",
              total_rows / qs.execution_count AS "AverageRowsReturned",
              SUBSTRING (
                  qt.text,
                  qs.statement_start_offset / 2 + 1,
                  (CASE
                       WHEN qs.statement_end_offset = -1 THEN LEN (CONVERT (NVARCHAR(MAX), qt.text)) * 2
                       ELSE qs.statement_end_offset
                   END - qs.statement_start_offset
                  ) / 2
              ) AS "Query Text",
              qt.text AS "Parent Query",
              p.query_plan AS "Execution Plan",
              qs.creation_time AS "Creation Time",
              qs.last_execution_time AS "Last Execution Time"
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text (qs.sql_handle) AS qt
OUTER APPLY sys.dm_exec_query_plan (qs.plan_handle) AS p
OUTER APPLY sys.dm_exec_plan_attributes (plan_handle) AS epa
WHERE epa.attribute = 'dbid'
      AND epa.value = DB_ID ()
ORDER BY AverageElapsedTime DESC;
GO