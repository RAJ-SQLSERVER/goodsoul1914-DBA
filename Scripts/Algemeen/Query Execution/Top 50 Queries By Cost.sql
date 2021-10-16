-- Show Top 50 Most Expensive Queries
-- ------------------------------------------------------------------------------------------------

SELECT TOP 50 SUBSTRING (qt.text,
                         qs.statement_start_offset / 2 + 1,
                         (CASE qs.statement_end_offset
                              WHEN -1 THEN DATALENGTH (qt.text)
                              ELSE qs.statement_end_offset
                          END - qs.statement_start_offset
                         ) / 2 + 1
              ) AS "Sql",
              qs.execution_count AS "Exec Cnt",
              (qs.total_logical_reads + qs.total_logical_writes) / qs.execution_count AS "Avg IO",
              qp.query_plan AS "Plan",
              qs.total_logical_reads AS "Total Reads",
              qs.last_logical_reads AS "Last Reads",
              qs.total_logical_writes AS "Total Writes",
              qs.last_logical_writes AS "Last Writes",
              qs.total_worker_time AS "Total Worker Time",
              qs.last_worker_time AS "Last Worker Time",
              qs.total_elapsed_time / 1000 AS "Total Elps Time",
              qs.last_elapsed_time / 1000 AS "Last Elps Time",
              qs.creation_time AS "Compile Time",
              qs.last_execution_time AS "Last Exec Time"
FROM sys.dm_exec_query_stats AS qs WITH (NOLOCK)
CROSS APPLY sys.dm_exec_sql_text (qs.sql_handle) AS qt
CROSS APPLY sys.dm_exec_query_plan (qs.plan_handle) AS qp
ORDER BY [Avg IO] DESC
OPTION (RECOMPILE);
GO


-- Expensive Queries using cursor
-- ------------------------------------------------------------------------------------------------

WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
SELECT TOP 1000 DB_NAME (qt.dbid) AS "DbName",
                SUBSTRING (qt.text,
                           qs.statement_start_offset / 2 + 1,
                           (CASE qs.statement_end_offset
                                WHEN -1 THEN DATALENGTH (qt.text)
                                ELSE qs.statement_end_offset
                            END - qs.statement_start_offset
                           ) / 2 + 1
                ) AS "SQLStatement",
                qt.text AS "BatchStatement",
                qs.execution_count,
                qs.total_logical_reads,
                qs.last_logical_reads,
                qs.total_logical_writes,
                qs.last_logical_writes,
                qs.total_worker_time,
                qs.last_worker_time,
                qs.total_elapsed_time / 1000000 AS "total_elapsed_time_in_S",
                qs.last_elapsed_time / 1000000 AS "last_elapsed_time_in_S",
                qs.last_execution_time,
                qp.query_plan,
                c.value ('@StatementText', 'varchar(255)') AS "StatementText",
                c.value ('@StatementType', 'varchar(255)') AS "StatementType",
                c.value ('CursorPlan[1]/@CursorName', 'varchar(255)') AS "CursorName",
                c.value ('CursorPlan[1]/@CursorActualType', 'varchar(255)') AS "CursorActualType",
                c.value ('CursorPlan[1]/@CursorRequestedType', 'varchar(255)') AS "CursorRequestedType",
                c.value ('CursorPlan[1]/@CursorConcurrency', 'varchar(255)') AS "CursorConcurrency",
                c.value ('CursorPlan[1]/@ForwardOnly', 'varchar(255)') AS "ForwardOnly"
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text (qs.sql_handle) AS qt
CROSS APPLY sys.dm_exec_query_plan (qs.plan_handle) AS qp
INNER JOIN sys.dm_exec_cached_plans AS cp
    ON cp.plan_handle = qs.plan_handle
CROSS APPLY qp.query_plan.nodes ('//StmtCursor') AS t(c)
WHERE qp.query_plan.exist ('//StmtCursor') = 1
      --and DB_NAME(qt.dbid) not in ('uhtdba', 'msdb')
      AND (qt.dbid IS NULL OR DB_NAME (qt.dbid) NOT IN ( 'uhtdba', 'msdb' ))
--order by qs.total_logical_reads desc; -- logical reads
--order by qs.total_logical_writes desc; -- logical writes
ORDER BY qs.total_worker_time DESC; -- CPU time