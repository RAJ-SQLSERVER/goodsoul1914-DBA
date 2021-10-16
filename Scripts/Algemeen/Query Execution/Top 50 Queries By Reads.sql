-- Top 50 Logical I/O queries
-- ------------------------------------------------------------------------------------------------

SELECT TOP (50) DB_NAME (t.dbid) AS "Database Name",
                REPLACE (REPLACE (LEFT(t.text, 255), CHAR (10), ''), CHAR (13), '') AS "Short Query Text",
                qs.total_logical_reads AS "Total Logical Reads",
                qs.min_logical_reads AS "Min Logical Reads",
                qs.total_logical_reads / qs.execution_count AS "Avg Logical Reads",
                qs.max_logical_reads AS "Max Logical Reads",
                qs.min_worker_time AS "Min Worker Time",
                qs.total_worker_time / qs.execution_count AS "Avg Worker Time",
                qs.max_worker_time AS "Max Worker Time",
                qs.min_elapsed_time AS "Min Elapsed Time",
                qs.total_elapsed_time / qs.execution_count AS "Avg Elapsed Time",
                qs.max_elapsed_time AS "Max Elapsed Time",
                qs.execution_count AS "Execution Count",
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
ORDER BY qs.total_logical_reads DESC
OPTION (RECOMPILE);
GO

-- Top 50 Fysical I/O queries
-- ------------------------------------------------------------------------------------------------

SELECT TOP 50 q.query_hash,
              SUBSTRING (t.text,
                         q.statement_start_offset / 2 + 1,
                         (CASE q.statement_end_offset
                              WHEN -1 THEN DATALENGTH (t.text)
                              ELSE q.statement_end_offset
                          END - q.statement_start_offset
                         ) / 2 + 1
              ),
              SUM (q.total_physical_reads) AS "total_physical_reads"
FROM sys.dm_exec_query_stats AS q
CROSS APPLY sys.dm_exec_sql_text (q.sql_handle) AS t
GROUP BY q.query_hash,
         SUBSTRING (t.text,
                    q.statement_start_offset / 2 + 1,
                    (CASE q.statement_end_offset
                         WHEN -1 THEN DATALENGTH (t.text)
                         ELSE q.statement_end_offset
                     END - q.statement_start_offset
                    ) / 2 + 1
         )
ORDER BY SUM (q.total_physical_reads) DESC;
GO

-- By Average Logical I/O
---------------------------------------------------------------------------------------------------

DECLARE @MinExecutions INT = 5;

SELECT EQS.total_worker_time AS "TotalWorkerTime",
       EQS.total_logical_reads + EQS.total_logical_writes AS "TotalLogicalIO",
       EQS.execution_count AS "ExeCnt",
       EQS.last_execution_time AS "LastUsage",
       EQS.total_worker_time / EQS.execution_count AS "AvgCPUTime(ms)",
       (EQS.total_logical_reads + EQS.total_logical_writes) / EQS.execution_count AS "AvgLogicalIO",
       DB.name AS "DatabaseName",
       SUBSTRING (
           EST.text,
           1 + EQS.statement_start_offset / 2,
           (CASE
                WHEN EQS.statement_end_offset = -1 THEN LEN (CONVERT (NVARCHAR(MAX), EST.text)) * 2
                ELSE EQS.statement_end_offset
            END - EQS.statement_start_offset
           ) / 2
       ) AS "SqlStatement",
       EQP.query_plan AS "QueryPlan" -- Optional with Query plan; remove comment to show, but then the query takes !!much longer time!! 
FROM sys.dm_exec_query_stats AS EQS
CROSS APPLY sys.dm_exec_sql_text (EQS.sql_handle) AS EST
CROSS APPLY sys.dm_exec_query_plan (EQS.plan_handle) AS EQP
LEFT JOIN sys.databases AS DB
    ON EST.dbid = DB.database_id
WHERE EQS.execution_count > @MinExecutions
      AND EQS.last_execution_time > DATEDIFF (MONTH, -1, GETDATE ())
ORDER BY AvgLogicalIO DESC,
         [AvgCPUTime(ms)] DESC;
GO

-- Query Execution Statistics By Average Physical Reads
---------------------------------------------------------------------------------------------------

SELECT TOP 10 execution_count,
              statement_start_offset AS "stmt_start_offset",
              sql_handle,
              plan_handle,
              total_logical_reads / execution_count AS "avg_logical_reads",
              total_logical_writes / execution_count AS "avg_logical_writes",
              total_physical_reads / execution_count AS "avg_physical_reads",
              t.text
FROM sys.dm_exec_query_stats AS s
CROSS APPLY sys.dm_exec_sql_text (s.sql_handle) AS t
ORDER BY avg_physical_reads DESC;
GO