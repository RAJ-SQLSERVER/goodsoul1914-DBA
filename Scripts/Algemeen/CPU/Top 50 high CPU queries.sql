--Author: Saleem Hakani (http://sqlcommunity.com)
--Query to find top 50 high CPU queries and it's details
SELECT TOP (50)
       CONVERT(VARCHAR, qs.creation_time, 109) AS Plan_Compiled_On,
       qs.execution_count AS 'Total Executions',
       qs.total_worker_time AS 'Overall CPU Time Since Compiled',
       CONVERT(VARCHAR, qs.last_execution_time, 109) AS 'Last Execution Date/Time',
       CAST(qs.last_worker_time AS VARCHAR) + '   (' + CAST(qs.max_worker_time AS VARCHAR) + ' Highest ever)' AS 'CPU Time for Last Execution (Milliseconds)',
       CONVERT(VARCHAR, (qs.last_worker_time / 1000) / (60 * 60)) + ' Hrs (i.e. '
       + CONVERT(VARCHAR, (qs.last_worker_time / 1000) / 60) + ' Mins & '
       + CONVERT(VARCHAR, (qs.last_worker_time / 1000) % 60) + ' Seconds)' AS 'Last Execution Duration',
       qs.last_rows AS 'Rows returned',
       qs.total_logical_reads / 128 AS 'Overall Logical Reads (MB)',
       qs.max_logical_reads / 128 AS 'Highest Logical Reads (MB)',
       qs.last_logical_reads / 128 AS 'Logical Reads from Last Execution (MB)',
       qs.total_physical_reads / 128 AS 'Total Physical Reads Since Compiled (MB)',
       qs.last_dop AS 'Last DOP used',
       qs.last_physical_reads / 128 AS 'Physical Reads from Last Execution (MB)',
       t.[text] AS 'Query Text',
       qp.query_plan AS 'Query Execution Plan',
       DB_NAME(t.dbid) AS 'Database Name',
       t.objectid AS 'Object ID',
       t.encrypted AS 'Is Query Encrypted'
--qs.plan_handle --Uncomment this if you want query plan handle
FROM sys.dm_exec_query_stats AS qs
    CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS t
    CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp
ORDER BY qs.last_worker_time DESC;
GO