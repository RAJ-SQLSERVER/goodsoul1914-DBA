RAISERROR(N'Oops! No, don''t just hit F5. Run these demos one at a time.', 20, 1) WITH LOG;
GO

/* ----------------------------------------------------------------------------
 A DMV a Day - Day 1 (sys.dm_os_buffer_descriptors)

 Returns information about all the data pages that are currently in the SQL 
 Server buffer pool. The output of this view can be used to determine the 
 distribution of database pages in the buffer pool according to database, 
 object, or type
---------------------------------------------------------------------------- */

-- Breaks down buffers by object (table, index) in the buffer pool
SELECT     OBJECT_NAME(p.object_id) AS ObjectName,
           p.object_id,
           p.index_id,
           COUNT(*) / 128.0 AS [Buffer size(MB)],
           COUNT(*) AS Buffer_count
FROM       sys.allocation_units AS a
INNER JOIN sys.dm_os_buffer_descriptors AS b ON a.allocation_unit_id = b.allocation_unit_id
INNER JOIN sys.partitions AS p ON a.container_id = p.hobt_id
WHERE      b.database_id = DB_ID()
GROUP BY   p.object_id,
           p.index_id
ORDER BY   Buffer_count DESC;
GO

-- Separate between dirty and clean pages
SELECT ObjectName,
       ISNULL(Clean, 0) AS CleanPages,
       ISNULL(Dirty, 0) AS DirtyPages,
       STR(ISNULL(Clean, 0) / 128.0, 12, 2) AS CleanPagesMB,
       STR(ISNULL(Dirty, 0 / 128.0), 12, 2) AS DirtyPagesMB
FROM   (
    SELECT     CASE
                   WHEN GROUPING(t.object_id) = 1 THEN
                       '=> Sum'
                   ELSE
                       QUOTENAME(OBJECT_SCHEMA_NAME(t.object_id)) + '.' + QUOTENAME(OBJECT_NAME(t.object_id))
               END AS ObjectName,
               CASE
                   WHEN bd.is_modified = 1 THEN
                       'Dirty'
                   ELSE
                       'Clean'
               END AS PageState,
               COUNT(*) AS PageCount
    FROM       sys.dm_os_buffer_descriptors AS bd
    INNER JOIN sys.allocation_units AS allc ON allc.allocation_unit_id = bd.allocation_unit_id
    INNER JOIN sys.partitions AS part ON allc.container_id = part.partition_id
    INNER JOIN sys.tables AS t ON part.object_id = t.object_id
    WHERE      bd.database_id = DB_ID()
    GROUP BY   GROUPING SETS((t.object_id, bd.is_modified), (bd.is_modified))
) AS pgs
PIVOT (
    SUM(PageCount)
    FOR PageState IN (Clean, Dirty)
) AS pvt;
GO


/* ----------------------------------------------------------------------------
 A DMV a Day – Day 2 (sys.dm_exec_sessions)

 Returns one row per authenticated session on SQL Server. sys.dm_exec_sessions 
 is a server-scope view that shows information about all active user 
 connections and internal tasks. This information includes client version, 
 client program name, client login time, login user, current session setting, 
 and more.
---------------------------------------------------------------------------- */

--  Get SQL users that are connected and how many sessions they have 
SELECT   login_name,
         COUNT(session_id) AS session_count
FROM     sys.dm_exec_sessions
GROUP BY login_name
ORDER BY COUNT(session_id) DESC;
GO


/* ----------------------------------------------------------------------------
 A DMV a Day – Day 3 (sys.dm_os_sys_info)

 Returns a miscellaneous set of useful information about the computer, and 
 about the resources available to and consumed by SQL Server.
---------------------------------------------------------------------------- */

-- Hardware information from SQL Server 2008 
-- (Cannot distinguish between HT and multi-core)
SELECT cpu_count AS [Logical CPU Count],
       hyperthread_ratio AS [Hyperthread Ratio],
       cpu_count / hyperthread_ratio AS [Physical CPU Count],
       physical_memory_kb / 1024 AS [Physical Memory (MB)],
       sqlserver_start_time
FROM   sys.dm_os_sys_info;
GO


/* ----------------------------------------------------------------------------
 A DMV a Day – Day 4 (sys.dm_os_sys_memory)

 Returns memory information from the operating system. SQL Server is bounded 
 by, and responds to, external memory conditions at the operating system level 
 and the physical limits of the underlying hardware. Determining the overall 
 system state is an important part of evaluating SQL Server memory usage.
---------------------------------------------------------------------------- */

-- Good basic information about memory amounts and state
SELECT total_physical_memory_kb, available_physical_memory_kb, 
       total_page_file_kb, available_page_file_kb, 
       system_memory_state_desc
FROM sys.dm_os_sys_memory;
GO


/* ----------------------------------------------------------------------------
 A DMV a Day – Day 5 (sys.dm_db_mirroring_auto_page_repair)

 Returns a row for every automatic page-repair attempt on any mirrored database 
 on the server instance. This view contains rows for the latest automatic 
 page-repair attempts on a given mirrored database, with a maximum of 100 rows 
 per database. As soon as a database reaches the maximum, the row for its next 
 automatic page-repair attempt replaces one of the existing entries.
---------------------------------------------------------------------------- */

-- Check auto page repair history (New in SQL 2008)
SELECT DB_NAME(database_id) AS database_name,
       database_id,
       file_id,
       page_id,
       error_type,
       page_status,
       modification_time
FROM   sys.dm_db_mirroring_auto_page_repair;
GO


/* ----------------------------------------------------------------------------
 A DMV a Day – Day 6 (sys.dm_db_index_usage_stats)

 Returns counts of different types of index operations and the time each type 
 of operation was last performed. Every individual seek, scan, lookup, or 
 update on the specified index by one query execution is counted as a use of 
 that index and increments the corresponding counter in this view. Information 
 is reported both for operations caused by user-submitted queries, and for 
 operations caused by internally generated queries, such as scans for gathering 
 statistics.
---------------------------------------------------------------------------- */

-- Possible Bad NC Indexes (writes > reads)
SELECT     OBJECT_NAME(s.object_id) AS [Table Name],
           i.name AS [Index Name],
           i.index_id,
           s.user_updates AS [Total Writes],
           s.user_seeks + s.user_scans + s.user_lookups AS [Total Reads],
           s.user_updates - (s.user_seeks + s.user_scans + s.user_lookups) AS Difference
FROM       sys.dm_db_index_usage_stats AS s WITH (NOLOCK)
INNER JOIN sys.indexes AS i WITH (NOLOCK) ON s.object_id = i.object_id
                                             AND i.index_id = s.index_id
WHERE      OBJECTPROPERTY(s.object_id, 'IsUserTable') = 1
           AND s.database_id = DB_ID()
           AND s.user_updates > (s.user_seeks + s.user_scans + s.user_lookups)
           AND i.index_id > 1
ORDER BY   Difference DESC,
           [Total Writes] DESC,
           [Total Reads] ASC;
GO

/*

I look for any indexes that have large numbers of writes with zero reads. 
Any index that falls into that category is a pretty good candidate for 
deletion (after some further investigation). You want to make sure that your 
SQL Server instance has been running long enough that you have your complete, 
typical workload included. Don’t forget about periodic, reporting workloads 
that might not show up in your day-to-day workload.

Next, I look at rows where there are large numbers of writes and a small 
number of reads. Dropping these indexes will be more of a judgment call, 
depending on the table and how familiar you are with your workload. 
Finding the correct balance between too many indexes and too few indexes, and 
having the “proper” set of indexes in place is extremely important for a DBA 
that wants to get the best performance from SQL Server.

*/


/* ----------------------------------------------------------------------------
 A DMV a Day – Day 7

 sys.dm_db_missing_index_group_stats
 -----------------------------------
 Returns summary information about groups of missing indexes, excluding spatial 
 indexes. Information returned by sys.dm_db_missing_index_group_stats is 
 updated by every query execution, not by every query compilation or 
 recompilation. Usage statistics are not persisted and are kept only until 
 SQL Server is restarted. Database administrators should periodically make 
 backup copies of the missing index information if they want to keep the usage 
 statistics after server recycling.

 sys.dm_db_missing_index_groups
 ------------------------------
 Returns information about what missing indexes are contained in a specific 
 missing index group, excluding spatial indexes.
---------------------------------------------------------------------------- */

-- Missing Indexes current database by Index Advantage
SELECT     migs.user_seeks * migs.avg_total_user_cost * (migs.avg_user_impact * 0.01) AS index_advantage,
           migs.last_user_seek,
           mid.statement AS [Database.Schema.Table],
           mid.equality_columns,
           mid.inequality_columns,
           mid.included_columns,
           migs.unique_compiles,
           migs.user_seeks,
           migs.avg_total_user_cost,
           migs.avg_user_impact
FROM       sys.dm_db_missing_index_group_stats AS migs WITH (NOLOCK)
INNER JOIN sys.dm_db_missing_index_groups AS mig WITH (NOLOCK) ON migs.group_handle = mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details AS mid WITH (NOLOCK) ON mig.index_handle = mid.index_handle
WHERE      mid.database_id = DB_ID()
ORDER BY   index_advantage DESC;
GO

/*

If there are multiple columns listed under “equality_columns” or 
“inequality_columns”, you will want to look at the selectivity of each of those 
columns within the equality and inequality results to determine the best column 
order for the prospective new index.

Remember, a more volatile table should generally have fewer indexes that a more 
static table. I generally start to get very hesitant to add a new index to a 
table (for an OLTP workload) if the table already has more than about five or 
six effective indexes.

*/


/* ----------------------------------------------------------------------------
 A DMV a Day – Day 8

 sys.dm_fts_active_catalogs
 --------------------------
 Returns information on the full-text catalogs that have some population 
 activity in progress on the server.

 sys.dm_fts_index_population
 ---------------------------
 Returns information about the full-text index populations currently in 
 progress.
---------------------------------------------------------------------------- */

-- Get population status for all FT catalogs in the current database
SELECT     c.name,
           c.status,
           c.status_description,
           OBJECT_NAME(p.table_id) AS table_name,
           p.population_type_description,
           p.is_clustered_index_scan,
           p.status_description,
           p.completion_type_description,
           p.queued_population_type_description,
           p.start_time,
           p.range_count
FROM       sys.dm_fts_active_catalogs AS c
INNER JOIN sys.dm_fts_index_population AS p ON c.database_id = p.database_id
                                               AND c.catalog_id = p.catalog_id
WHERE      c.database_id = DB_ID()
ORDER BY   c.name;
GO


/* ----------------------------------------------------------------------------
 A DMV a Day – Day 9 (sys.dm_os_schedulers)

 Returns one row per scheduler in SQL Server where each scheduler is mapped to 
 an individual processor. Use this view to monitor the condition of a scheduler 
 or to identify runaway tasks.
---------------------------------------------------------------------------- */

-- Get Avg task count and Avg runnable task count
SELECT AVG(current_tasks_count) AS [Avg Task Count],
       AVG(runnable_tasks_count) AS [Avg Runnable Task Count]
FROM   sys.dm_os_schedulers
WHERE  scheduler_id < 255
       AND status = 'VISIBLE ONLINE';
GO

/*

This query will help detect blocking and can help detect and confirm CPU pressure. 
High, sustained values for current_tasks_count usually indicates you are seeing 
lots of blocking. I have also seen it be a secondary indicator of I/O pressure. 
High, sustained values for runnable_tasks_count is usually a very good indicator 
of CPU pressure.  By “high, sustained values”, I mean anything above about 10-20 
for most systems.

*/

-- Is NUMA enabled
SELECT CASE COUNT(DISTINCT parent_node_id)
           WHEN 1 THEN
               'NUMA disabled'
           ELSE
               'NUMA enabled'
       END
FROM   sys.dm_os_schedulers
WHERE  parent_node_id <> 32;
GO

/*

The second query will tell you whether Non-uniform memory access (NUMA) is 
enabled on your SQL Server instance. AMD based servers have supported hardware 
based NUMA for several years, while Intel based Xeon servers, have added hardware 
based NUMA with the Xeon 5500, 5600, and 7500 series. 
There is also software based NUMA.

*/


/* ----------------------------------------------------------------------------
 A DMV a Day – Day 10 (sys.dm_exec_procedure_stats)

 Returns aggregate performance statistics for cached stored procedures. 
 The view contains one row per stored procedure, and the lifetime of the row is 
 as long as the stored procedure remains cached. When a stored procedure is 
 removed from the cache, the corresponding row is eliminated from this view. 
 At that time, a Performance Statistics SQL trace event is raised similar to 
 sys.dm_exec_query_stats.
---------------------------------------------------------------------------- */

-- Top Cached SPs By Total Physical Reads (SQL 2008 only) 
-- Physical reads relate to disk I/O pressure
SELECT     TOP (25)
           p.name AS [SP Name],
           qs.total_physical_reads AS TotalPhysicalReads,
           qs.total_physical_reads / qs.execution_count AS AvgPhysicalReads,
           qs.execution_count,
           ISNULL(qs.execution_count / DATEDIFF(SECOND, qs.cached_time, GETDATE()), 0) AS [Calls/Second],
           qs.total_elapsed_time,
           qs.total_elapsed_time / qs.execution_count AS avg_elapsed_time,
           qs.cached_time
FROM       sys.procedures AS p
INNER JOIN sys.dm_exec_procedure_stats AS qs ON p.object_id = qs.object_id
WHERE      qs.database_id = DB_ID()
ORDER BY   qs.total_physical_reads DESC;
GO

/*

This query will help detect the most expensive, cached stored procedures from 
a physical reads perspective, which relates to read, disk I/O pressure. 

First, you need to look at the cached_time column to make sure that it is 
similar for the top offenders. One way to ensure that the cached_time is nearly 
the same for most of your stored procedures is to periodically run DBCC 
FREEPROCCACHE on your instance with a SQL Agent job.

The second caveat is that only cached stored procedures will show up in the 
query. If you are using WITH RECOMPILE or OPTION(RECOMPILE), (which is usually 
not a good idea anyway) those plans won’t be cached.

If you see lots of stored procedures with high total physical reads or high 
average physical reads, it could mean that you are under severe memory pressure, 
and SQL Server is having to go to the disk I/O subsystem for data too often. 
It could also mean that you have lots of missing indexes or that you have “bad” 
queries (with no WHERE clauses for example) that are causing lots of clustered 
index or table scans on large tables.

*/


/* ----------------------------------------------------------------------------
 A DMV a Day – Day 11 (sys.dm_db_index_usage_stats)

 Returns counts of different types of index operations and the time each type 
 of operation was last performed. Every individual seek, scan, lookup, or 
 update on the specified index by one query execution is counted as a use of 
 that index and increments the corresponding counter in this view. Information 
 is reported both for operations caused by user-submitted queries, and for 
 operations caused by internally generated queries, such as scans for gathering 
 statistics.
---------------------------------------------------------------------------- */

-- List unused indexes
SELECT     OBJECT_NAME(i.object_id) AS [Table Name],
           i.name
FROM       sys.indexes AS i
INNER JOIN sys.objects AS o ON i.object_id = o.object_id
WHERE      i.index_id NOT IN (
               SELECT s.index_id
               FROM   sys.dm_db_index_usage_stats AS s
               WHERE  s.object_id = i.object_id
                      AND i.index_id = s.index_id
                      AND s.database_id = DB_ID()
           )
           AND o.type = 'U'
ORDER BY   OBJECT_NAME(i.object_id) ASC;
GO


/* ----------------------------------------------------------------------------
 A DMV a Day – Day 12

 Returns page and row-count information for every partition in the current 
 database.
---------------------------------------------------------------------------- */

-- Table and row count information   
SELECT     OBJECT_NAME(ps.object_id) AS TableName,
           i.name AS IndexName,
           SUM(ps.row_count) AS [RowCount]
FROM       sys.dm_db_partition_stats AS ps
INNER JOIN sys.indexes AS i ON i.object_id = ps.object_id
                               AND i.index_id = ps.index_id
WHERE      i.type_desc IN ( 'CLUSTERED', 'HEAP' )
           AND i.object_id > 100
           AND OBJECT_SCHEMA_NAME(ps.object_id) <> 'sys'
GROUP BY   ps.object_id,
           i.name
ORDER BY   SUM(ps.row_count) DESC;
GO


/* ----------------------------------------------------------------------------
 A DMV a Day – Day 13 (sys.dm_io_virtual_file_stats)

 Returns I/O statistics for data and log files. This dynamic management view 
 replaces the fn_virtualfilestats function.
---------------------------------------------------------------------------- */

-- Calculates average stalls per read, per write, and per total input/output 
-- for each database file. 
SELECT   DB_NAME(database_id) AS [Database Name],
         file_id,
         io_stall_read_ms,
         num_of_reads,
         CAST(io_stall_read_ms / (1.0 + num_of_reads) AS NUMERIC(10, 1)) AS avg_read_stall_ms,
         io_stall_write_ms,
         num_of_writes,
         CAST(io_stall_write_ms / (1.0 + num_of_writes) AS NUMERIC(10, 1)) AS avg_write_stall_ms,
         io_stall_read_ms + io_stall_write_ms AS io_stalls,
         num_of_reads + num_of_writes AS total_io,
         CAST((io_stall_read_ms + io_stall_write_ms) / (1.0 + num_of_reads + num_of_writes) AS NUMERIC(10, 1)) AS avg_io_stall_ms
FROM     sys.dm_io_virtual_file_stats(NULL, NULL)
ORDER BY avg_io_stall_ms DESC;
GO


/* ----------------------------------------------------------------------------
 A DMV a Day – Day 14 (sys.dm_os_wait_stats)

 Returns information about all the waits encountered by threads that executed. 
 You can use this aggregated view to diagnose performance issues with SQL 
 Server and also with specific queries and batches.
---------------------------------------------------------------------------- */

-- Total waits are wait_time_ms (high signal waits indicates CPU pressure)
SELECT CAST(100.0 * SUM(signal_wait_time_ms) / SUM(wait_time_ms) AS NUMERIC(20, 2)) AS [%signal (cpu) waits],
       CAST(100.0 * SUM(wait_time_ms - signal_wait_time_ms) / SUM(wait_time_ms) AS NUMERIC(20, 2)) AS [%resource waits]
FROM   sys.dm_os_wait_stats;
GO

/*

This query is useful to help confirm CPU pressure. Signal waits are time 
waiting for a CPU to service a thread. Seeing total signal waits above roughly 
10-15% is a pretty good indicator of CPU pressure, although you should be aware 
of what your baseline value for signal waits is, and watch the trend over time. 

You should also remember that these wait stats are cumulative since SQL Server 
was last restarted or since the wait statistics were cleared with this command:

*/

-- Clear Wait Stats 
DBCC SQLPERF('sys.dm_os_wait_stats', CLEAR);
GO

/*

If your SQL Server instance has been running for quite a while, and you make 
a significant change (such as adding an important new index), you should think 
about clearing the old wait stats with the DBCC SQLPERF command shown above. 
Otherwise, the old cumulative wait stats will mask what is currently going on 
since your change.

*/


/* ----------------------------------------------------------------------------
 A DMV a Day – Day 15 (sys.dm_os_performance_counters)

 Returns a row per performance counter maintained by the server. 
 For information about each performance counter, see Using SQL Server Objects.
---------------------------------------------------------------------------- */

-- Recovery model, log reuse wait description, log file size, log usage size 
-- and compatibility level for all databases on instance
SELECT     db.name AS [Database Name],
           db.recovery_model_desc AS [Recovery Model],
           db.log_reuse_wait_desc AS [Log Reuse Wait Description],
           ls.cntr_value AS [Log Size (KB)],
           lu.cntr_value AS [Log Used (KB)],
           CAST(CAST(lu.cntr_value AS FLOAT) / CAST(ls.cntr_value AS FLOAT) AS DECIMAL(18, 2)) * 100 AS [Log Used %],
           db.compatibility_level AS [DB Compatibility Level],
           db.page_verify_option_desc AS [Page Verify Option]
FROM       sys.databases AS db
INNER JOIN sys.dm_os_performance_counters AS lu ON db.name = lu.instance_name
INNER JOIN sys.dm_os_performance_counters AS ls ON db.name = ls.instance_name
WHERE      lu.counter_name LIKE 'Log File(s) Used Size (KB)%'
           AND ls.counter_name LIKE 'Log File(s) Size (KB)%';
GO

/*

This is all very valuable information that I like to gather when I am evaluating 
an unfamiliar database server. It it also useful from a monitoring perspective. 

For example, if your log reuse wait description is something unusual 
(such as ACTIVE_TRANSACTION), and your transaction log is 85% full, 
I would want some alarm bells to be going off…

*/


/* ----------------------------------------------------------------------------
 A DMV a Day – Day 16

 sys.dm_exec_cached_plans
 ------------------------
 Returns a row for each query plan that is cached by SQL Server for faster 
 query execution. You can use this dynamic management view to find cached query 
 plans, cached query text, the amount of memory taken by cached plans, and the 
 reuse count of the cached plans.

 sys.dm_exec_sql_text
 --------------------
 Returns the text of the SQL batch that is identified by the specified 
 sql_handle. This table-valued function replaces the system function fn_get_sql
---------------------------------------------------------------------------- */

-- Find single-use, ad-hoc queries that are bloating the plan cache
SELECT      TOP (100)
            est.text,
            cp.size_in_bytes
FROM        sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) est
WHERE       cp.cacheobjtype = 'Compiled Plan'
            AND cp.objtype = 'Adhoc'
            AND cp.usecounts = 1
ORDER BY    cp.size_in_bytes DESC;
GO

/*

This query will identify ad-hoc queries that have a use count of 1, ordered by 
the size of the plan. It gives you the text and size of single-use ad-hoc queries 
that waste space in plan cache. 

*/


/* ----------------------------------------------------------------------------
 A DMV a Day – Day 17 (sys.dm_db_index_usage_stats)

 Returns counts of different types of index operations and the time each type 
 of operation was last performed.
---------------------------------------------------------------------------- */

--- Index Read/Write stats (all tables in current DB)
SELECT     OBJECT_NAME(s.object_id) AS ObjectName,
           i.name AS IndexName,
           i.index_id,
           s.user_seeks + s.user_scans + s.user_lookups AS Reads,
           s.user_updates AS Writes,
           i.type_desc AS IndexType,
           i.fill_factor AS [FillFactor]
FROM       sys.dm_db_index_usage_stats AS s
INNER JOIN sys.indexes AS i ON s.object_id = i.object_id
WHERE      OBJECTPROPERTY(s.object_id, 'IsUserTable') = 1
           AND i.index_id = s.index_id
           AND s.database_id = DB_ID()
ORDER BY   OBJECT_NAME(s.object_id),
           Writes DESC,
           Reads DESC;
GO

/*

It is very useful for better understanding your workload. 
You can use it to help determine how volatile a particular index is, and the 
ratio of reads to writes. This can help you better tune your indexing 
strategy. For example, if you had a table that was pretty static (very few 
writes on any of the indexes), you could feel more confident about adding more 
indexes that were are listed in your missing index queries.

*/


/* ----------------------------------------------------------------------------
 A DMV a Day – Day 18 (sys.dm_clr_tasks)

 Returns a row for all common language runtime (CLR) tasks that are currently 
 running. A Transact-SQL batch that contains a reference to a CLR routine 
 creates a separate task for execution of all the managed code in that batch. 
 Multiple statements in the batch that require managed code execution use the 
 same CLR task. The CLR task is responsible for maintaining objects and state 
 pertaining to managed code execution, as well as the transitions between the 
 instance of SQL Server and the common language runtime.
---------------------------------------------------------------------------- */

-- Find long running SQL/CLR tasks
SELECT     os.task_address,
           os.state,
           os.last_wait_type,
           clr.state,
           clr.forced_yield_count
FROM       sys.dm_os_workers AS os
INNER JOIN sys.dm_clr_tasks AS clr ON (os.task_address = clr.sos_task_address)
WHERE      clr.type = 'E_TYPE_USER';
GO

/*

You want to be on the lookout for any rows that have a forced_yield_count above 
zero or that have a last_wait_type of SQLCLR_QUANTUM_PUNISHMENT, which indicates 
that the task previously exceeded its allowed quantum, causing the SQL OS 
scheduler to intervene and reschedule it at the end of the queue while 
forced_yield_count shows the number of times that this has happened. 
If you see either of these, you would want to be talking to your developers 
about their CLR assemblies, which are misbehaving, thereby causing SQL Server 
to put them in the “penalty box”.

*/


/* ----------------------------------------------------------------------------
 A DMV a Day – Day 19 (sys.dm_os_wait_stats)

 Returns information about all the waits encountered by threads that executed. 
 You can use this aggregated view to diagnose performance issues with SQL 
 Server and also with specific queries and batches.
---------------------------------------------------------------------------- */

-- Isolate top waits for server instance since last restart or statistics clear
WITH Waits
AS
(
    SELECT wait_type,
           wait_time_ms / 1000. AS wait_time_s,
           100. * wait_time_ms / SUM(wait_time_ms) OVER () AS pct,
           ROW_NUMBER() OVER (ORDER BY wait_time_ms DESC) AS rn
    FROM   sys.dm_os_wait_stats
    WHERE  wait_type NOT IN ( 'CLR_SEMAPHORE', 'LAZYWRITER_SLEEP', 'RESOURCE_QUEUE', 'SLEEP_TASK', 'SLEEP_SYSTEMTASK',
                              'SQLTRACE_BUFFER_FLUSH', 'WAITFOR', 'LOGMGR_QUEUE', 'CHECKPOINT_QUEUE',
                              'REQUEST_FOR_DEADLOCK_SEARCH', 'XE_TIMER_EVENT', 'BROKER_TO_FLUSH', 'BROKER_TASK_STOP',
                              'CLR_MANUAL_EVENT', 'CLR_AUTO_EVENT', 'DISPATCHER_QUEUE_SEMAPHORE',
                              'FT_IFTS_SCHEDULER_IDLE_WAIT', 'XE_DISPATCHER_WAIT', 'XE_DISPATCHER_JOIN'
)
)
SELECT     W1.wait_type,
           CAST(W1.wait_time_s AS DECIMAL(12, 2)) AS wait_time_s,
           CAST(W1.pct AS DECIMAL(12, 2)) AS pct,
           CAST(SUM(W2.pct) AS DECIMAL(12, 2)) AS running_pct
FROM       Waits AS W1
INNER JOIN Waits AS W2 ON W2.rn <= W1.rn
GROUP BY   W1.rn,
           W1.wait_type,
           W1.wait_time_s,
           W1.pct
HAVING     SUM(W2.pct) - W1.pct < 95; -- percentage threshold
GO

/*

This query is used to help determine what type of resource that SQL Server 
is spending the most time waiting on. This can help you figure out what the 
biggest bottleneck is at the instance level, which will then guide your 
efforts to focus on a particular type of problem.

You should also remember that these wait stats are cumulative since SQL 
Server was last restarted or since the wait statistics were cleared with 
this command:

*/

-- Clear Wait Stats 
DBCC SQLPERF('sys.dm_os_wait_stats', CLEAR);
GO


/* ----------------------------------------------------------------------------
 A DMV a Day – Day 20 (sys.dm_exec_cached_plans)

 Returns a row for each query plan that is cached by SQL Server for faster 
 query execution. You can use this dynamic management view to find cached 
 query plans, cached query text, the amount of memory taken by cached plans, 
 and the reuse count of the cached plans.
---------------------------------------------------------------------------- */

-- Use Counts and # of plans for compiled plans
SELECT   objtype,
         usecounts,
         COUNT(*) AS no_of_plans
FROM     sys.dm_exec_cached_plans
WHERE    cacheobjtype = 'Compiled Plan'
GROUP BY objtype,
         usecounts
ORDER BY objtype,
         usecounts;
GO


/* ----------------------------------------------------------------------------
 A DMV a Day – Day 21 (sys.dm_os_ring_buffers)

 The following SQL Server Operating System–related dynamic management views 
 are Identified for informational purposes only. Not supported. 
 Future compatibility is not guaranteed.
---------------------------------------------------------------------------- */

-- Get CPU Utilization History for last 30 minutes (in one minute intervals)
-- This version works with SQL Server 2008 and SQL Server 2008 R2 only
DECLARE @ts_now BIGINT = (
            SELECT cpu_ticks / (cpu_ticks / ms_ticks) FROM sys.dm_os_sys_info
        );

SELECT   TOP (30)
         y.SQLProcessUtilization AS [SQL Server Process CPU Utilization],
         y.SystemIdle AS [System Idle Process],
         100 - y.SystemIdle - y.SQLProcessUtilization AS [Other Process CPU Utilization],
         DATEADD(ms, -1 * (@ts_now - y.timestamp), GETDATE()) AS [Event Time]
FROM     (
    SELECT x.record.value('(./Record/@id)[1]', 'int') AS record_id,
           x.record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS SystemIdle,
           x.record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS SQLProcessUtilization,
           x.timestamp
    FROM   (
        SELECT timestamp,
               CONVERT(XML, record) AS record
        FROM   sys.dm_os_ring_buffers
        WHERE  ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
               AND record LIKE '%<SystemHealth>%'
    ) AS x
) AS y
ORDER BY y.record_id DESC;
GO


/* ----------------------------------------------------------------------------
 A DMV a Day – Day 22 (sys.dm_exec_query_memory_grants)

 Returns information about the queries that have acquired a memory grant or 
 that still require a memory grant to execute. Queries that do not have to 
 wait on a memory grant will not appear in this view.
---------------------------------------------------------------------------- */

-- Shows the memory required by both running (non-null grant_time) 
-- and waiting queries (null grant_time)
-- SQL Server 2008 version
SELECT      DB_NAME(st.dbid) AS DatabaseName,
            mg.requested_memory_kb,
            mg.ideal_memory_kb,
            mg.request_time,
            mg.grant_time,
            mg.query_cost,
            mg.dop,
            st.text
FROM        sys.dm_exec_query_memory_grants AS mg
CROSS APPLY sys.dm_exec_sql_text(mg.plan_handle) AS st
WHERE       mg.request_time < COALESCE(mg.grant_time, '99991231')
ORDER BY    mg.requested_memory_kb DESC;
GO


-- Shows the memory required by both running (non-null grant_time) 
-- and waiting queries (null grant_time)
-- SQL Server 2005 version
SELECT      DB_NAME(st.dbid) AS DatabaseName,
            mg.requested_memory_kb,
            mg.request_time,
            mg.grant_time,
            mg.query_cost,
            mg.dop,
            st.text
FROM        sys.dm_exec_query_memory_grants AS mg
CROSS APPLY sys.dm_exec_sql_text(mg.plan_handle) AS st
WHERE       mg.request_time < COALESCE(mg.grant_time, '99991231')
ORDER BY    mg.requested_memory_kb DESC;
GO

/*

Ideally, you would want to see few, if any rows returning from this query. 
If you do see many rows return as you run the query multiple times, that 
would be an indication of internal memory pressure. 

*/


/* ----------------------------------------------------------------------------
 A DMV a Day – Day 23 (sys.dm_os_process_memory)

 Most memory allocations that are attributed to the SQL Server process space 
 are controlled through interfaces that allow for tracking and accounting of 
 those allocations. However, memory allocations might be performed in the SQL 
 Server address space that bypasses internal memory management routines. 
 Values are obtained through calls to the base operating system. They are not 
 manipulated by methods internal to SQL Server, except when it adjusts for 
 locked or large page allocations. All returned values that indicate memory 
 sizes are shown in kilobytes (KB). 
 The column total_virtual_address_space_reserved_kb is a duplicate of 
 virtual_memory_in_bytes from sys.dm_os_sys_info.
---------------------------------------------------------------------------- */

-- SQL Server Process Address space info (SQL 2008 and 2008 R2 only)
--(shows whether locked pages is enabled, among other things)
SELECT physical_memory_in_use_kb,
       locked_page_allocations_kb,
       page_fault_count,
       memory_utilization_percentage,
       available_commit_limit_kb,
       process_physical_memory_low,
       process_virtual_memory_low
FROM   sys.dm_os_process_memory;
GO

/*

This query shows how much physical memory is in use by SQL Server 
(which is nice, since you cannot believe Task Manager in most cases). 
It also shows whether you have “Locked Pages in Memory” enabled 
(which is true if locked_page_allocations_kb is higher than zero). 
It also shows whether the SQL Server process has been notified by the 
operating system that physical or virtual memory is low (at the OS level), 
meaning that SQL Server should try to trim its working set.

DBCC MEMORYSTATUS shows a superset of similar information, but it is more 
difficult to work with programmatically

*/

DBCC MEMORYSTATUS
GO


/* ----------------------------------------------------------------------------
 A DMV a Day – Day 24 (sys.dm_exec_requests)

 Returns information about each request that is executing within SQL Server.
---------------------------------------------------------------------------- */

-- Look at currently executing requests, status and wait type
SELECT      r.session_id,
            r.status,
            r.wait_type,
            r.scheduler_id,
            SUBSTRING(qt.text,
                      r.statement_start_offset / 2,
                      (CASE
                           WHEN r.statement_end_offset = -1 THEN
                               LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2
                           ELSE
                               r.statement_end_offset
                       END - r.statement_start_offset
                      ) / 2
            ) AS statement_executing,
            DB_NAME(qt.dbid) AS DatabaseName,
            OBJECT_NAME(qt.objectid) AS ObjectName,
            r.cpu_time,
            r.total_elapsed_time,
            r.reads,
            r.writes,
            r.logical_reads,
            r.plan_handle
FROM        sys.dm_exec_requests AS r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS qt
WHERE       r.session_id > 50 AND r.session_id <> @@SPID
ORDER BY    r.scheduler_id,
            r.status,
            r.session_id;
GO


/* ----------------------------------------------------------------------------
 A DMV a Day – Day 25 (sys.dm_os_memory_cache_counters)

 Returns a snapshot of the health of a cache. sys.dm_os_memory_cache_counters 
 provides run-time information about the cache entries allocated, their use, 
 and the source of memory for the cache entries.
---------------------------------------------------------------------------- */

-- Look at the number of items in different parts of the cache
SELECT   name,
         type,
         entries_count,
         pages_kb,
         pages_in_use_kb,
         entries_count,
         entries_in_use_count
FROM     sys.dm_os_memory_cache_counters
WHERE    type = 'CACHESTORE_SQLCP'
         OR type = 'CACHESTORE_OBJCP'
ORDER BY pages_in_use_kb DESC;
GO


/* ----------------------------------------------------------------------------
 A DMV a Day – Day 26 (sys.dm_exec_procedure_stats)

 Returns aggregate performance statistics for cached stored procedures. 
 The view contains one row per stored procedure, and the lifetime of the row 
 is as long as the stored procedure remains cached. When a stored procedure 
 is removed from the cache, the corresponding row is eliminated from this 
 view. At that time, a Performance Statistics SQL trace event is raised 
 similar to sys.dm_exec_query_stats.
---------------------------------------------------------------------------- */

-- Top Cached SPs By Total Logical Reads (SQL 2008). 
-- Logical reads relate to memory pressure
SELECT     TOP (25)
           p.name AS [SP Name],
           qs.total_logical_reads AS TotalLogicalReads,
           qs.total_logical_reads / qs.execution_count AS AvgLogicalReads,
           qs.execution_count,
           ISNULL(qs.execution_count / DATEDIFF(SECOND, qs.cached_time, GETDATE()), 0) AS [Calls/Second],
           qs.total_elapsed_time,
           qs.total_elapsed_time / qs.execution_count AS avg_elapsed_time,
           qs.cached_time
FROM       sys.procedures AS p
INNER JOIN sys.dm_exec_procedure_stats AS qs ON p.object_id = qs.object_id
WHERE      qs.database_id = DB_ID()
ORDER BY   qs.total_logical_reads DESC;
GO


/* ----------------------------------------------------------------------------
 A DMV a Day – Day 27 (sys.dm_tran_locks)

 Returns information about currently active lock manager resources. 
 Each row represents a currently active request to the lock manager for a lock 
 that has been granted or is waiting to be granted. The columns in the result 
 set are divided into two main groups: resource and request. The resource 
 group describes the resource on which the lock request is being made, and the 
 request group describes the lock request.
---------------------------------------------------------------------------- */

-- Look at active Lock Manager resources for current database
SELECT   request_session_id,
         DB_NAME(resource_database_id) AS [Database],
         resource_type,
         resource_subtype,
         request_type,
         request_mode,
         resource_description,
         request_mode,
         request_owner_type
FROM     sys.dm_tran_locks
WHERE    request_session_id > 50
         AND resource_database_id = DB_ID()
         AND request_session_id <> @@SPID
ORDER BY request_session_id;
GO

-- Look for blocking
SELECT     tl.resource_type,
           tl.resource_database_id,
           tl.resource_associated_entity_id,
           tl.request_mode,
           tl.request_session_id,
           wt.blocking_session_id,
           wt.wait_type,
           wt.wait_duration_ms
FROM       sys.dm_tran_locks AS tl
INNER JOIN sys.dm_os_waiting_tasks AS wt ON tl.lock_owner_address = wt.resource_address
ORDER BY   wt.wait_duration_ms DESC;
GO


/* ----------------------------------------------------------------------------
 A DMV a Day – Day 28 (sys.dm_io_pending_io_requests)

 Returns a row for each pending I/O request in SQL Server.
---------------------------------------------------------------------------- */

-- Look at pending I/O requests by file
SELECT     DB_NAME(mf.database_id) AS [Database],
           mf.physical_name,
           r.io_pending,
           r.io_pending_ms_ticks,
           r.io_type,
           fs.num_of_reads,
           fs.num_of_writes
FROM       sys.dm_io_pending_io_requests AS r
INNER JOIN sys.dm_io_virtual_file_stats(NULL, NULL) AS fs ON r.io_handle = fs.file_handle
INNER JOIN sys.master_files AS mf ON fs.database_id = mf.database_id
                                     AND fs.file_id = mf.file_id
ORDER BY   r.io_pending,
           r.io_pending_ms_ticks DESC;
GO


/* ----------------------------------------------------------------------------
 A DMV a Day – Day 29 (sys.dm_exec_connections)

 Returns information about the connections established to this instance of 
 SQL Server and the details of each connection.
---------------------------------------------------------------------------- */

-- Get a count of SQL connections by IP address
SELECT     ec.client_net_address,
           es.program_name,
           es.host_name,
           es.login_name,
           COUNT(ec.session_id) AS [connection count]
FROM       sys.dm_exec_sessions AS es
INNER JOIN sys.dm_exec_connections AS ec ON es.session_id = ec.session_id
GROUP BY   ec.client_net_address,
           es.program_name,
           es.host_name,
           es.login_name
ORDER BY   ec.client_net_address,
           es.program_name;
GO


/* ----------------------------------------------------------------------------
 – A DMV A Day – Day 30 (sys.dm_os_buffer_descriptors)

 Returns information about all the data pages that are currently in the SQL 
 Server buffer pool. The output of this view can be used to determine the 
 distribution of database pages in the buffer pool according to database, 
 object, or type.

 When a data page is read from disk, the page is copied into the SQL Server 
 buffer pool and cached for reuse. Each cached data page has one buffer 
 descriptor. Buffer descriptors uniquely identify each data page that is 
 currently cached in an instance of SQL Server. sys.dm_os_buffer_descriptors 
 returns cached pages for all user and system databases. This includes pages 
 that are associated with the Resource database.
---------------------------------------------------------------------------- */

-- Get total buffer usage by database
SELECT   DB_NAME(database_id) AS [Database Name],
         COUNT(*) * 8 / 1024.0 AS [Cached Size (MB)]
FROM     sys.dm_os_buffer_descriptors
WHERE    database_id > 4 -- exclude system databases
         AND database_id <> 32767 -- exclude ResourceDB
GROUP BY DB_NAME(database_id)
ORDER BY [Cached Size (MB)] DESC;
GO


-- Breaks down buffers used by current database by object (table, index) 
-- in the buffer cache
SELECT     OBJECT_NAME(p.object_id) AS ObjectName,
           p.index_id,
           COUNT(*) / 128 AS [buffer size(MB)],
           COUNT(*) AS buffer_count
FROM       sys.allocation_units AS a
INNER JOIN sys.dm_os_buffer_descriptors AS b ON a.allocation_unit_id = b.allocation_unit_id
INNER JOIN sys.partitions AS p ON a.container_id = p.hobt_id
WHERE      b.database_id = DB_ID()
           AND p.object_id > 100
GROUP BY   p.object_id,
           p.index_id
ORDER BY   buffer_count DESC;
GO
