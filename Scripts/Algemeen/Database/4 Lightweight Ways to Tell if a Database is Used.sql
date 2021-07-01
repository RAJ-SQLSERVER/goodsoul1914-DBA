-------------------------------------------------------------------------------
-- 4 Lightweight Ways to Tell if a Database is Used
-------------------------------------------------------------------------------

/* Is a Login Using the database? */
EXEC dbo.sp_whoisactive @show_sleeping_spids = 2,
                        @filter_type = 'database',
                        @filter = 'AdventureWorks2019';
GO


/* Are Reads and Writes Happening on Tables in the Database? */
EXEC dbo.sp_BlitzIndex @DatabaseName = 'AdventureWorks2019', @Mode = 2;
GO


/* Is the Transaction Counter Going Up for the Database? */
SELECT object_name,
       counter_name,
       instance_name,
       cntr_value,
       cntr_type
FROM sys.dm_os_performance_counters
WHERE counter_name LIKE 'Transactions/sec%'
      AND instance_name LIKE 'AdventureWorks2019%';
GO


/* Are there user Execution Plans in the Cache for the Database? */
SELECT SUBSTRING (
           tx.text,
           (qs.statement_start_offset / 2) + 1,
           (CASE
                WHEN qs.statement_end_offset = -1 THEN DATALENGTH (tx.text)
                ELSE qs.statement_end_offset
            END - qs.statement_start_offset
           ) / 2 + 1
       ) AS QueryText,
       CASE WHEN pl.query_plan LIKE '%<MissingIndexes>%' THEN 1 ELSE 0 END AS [Missing Indexes?],
       qs.execution_count,
       qs.total_worker_time / qs.execution_count AS avg_cpu_time,
       qs.total_worker_time AS total_cpu_time,
       qs.total_logical_reads / qs.execution_count AS avg_logical_reads,
       qs.total_logical_reads,
       qs.creation_time AS [plan creation time],
       qs.last_execution_time AS [last execution time],
       CAST(pl.query_plan AS XML) AS sqlplan
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_text_query_plan (qs.plan_handle, qs.statement_start_offset, qs.statement_end_offset) AS pl
CROSS APPLY sys.dm_exec_sql_text (qs.sql_handle) AS tx
WHERE pl.query_plan LIKE '%[AdventureWorks2019]%'
ORDER BY qs.execution_count DESC
OPTION (RECOMPILE);
GO