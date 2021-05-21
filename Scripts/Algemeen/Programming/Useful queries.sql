/******************************************************************************
 Number of connections and connected clients
	
 Possible errors when max number of connections is reached:

 - Client unable to establish connection because an error was encountered 
   during handshakes before login. Common causes include client attempting to 
   connect to an unsupported version of SQL Server, server too busy to accept 
   new connections or a resource limitation (memory or maximum allowed 
   connections) on the server.
 - A connection was successfully established with the server, but then an 
   error occurred during the pre-login handshake. (provider: TCP Provider, 
   error: 0 – An existing connection was forcibly closed by the remote host.)
 - A network-related or instance-specific error occurred while establishing a 
   connection to SQL Server. The server was not found or was not accessible. 
   Verify that the instance name is correct and that SQL Server is configured 
   to allow remote connections. (provider: TCP Provider, error: 40 – Could not 
   open a connection to SQL Server)
******************************************************************************/
SELECT @@MAX_CONNECTIONS AS MaxConnections;

SELECT   ISNULL(DB_NAME(database_id), 'Total On Server') AS DatabaseName,
         COUNT(*) AS Connections,
         COUNT(DISTINCT host_name) AS ClientMachines
FROM     sys.dm_exec_sessions
WHERE    host_name IS NOT NULL
GROUP BY ROLLUP(database_id);


-------------------------------------------------------------------------------
-- Finding connection leaks
-------------------------------------------------------------------------------
SELECT   COUNT(*) AS sessions,
         s.host_name,
         s.host_process_id,
         s.program_name,
         DB_NAME(s.database_id) AS database_name
FROM     sys.dm_exec_sessions AS s
WHERE    s.is_user_process = 1
GROUP BY s.host_name,
         s.host_process_id,
         s.program_name,
         s.database_id
ORDER BY COUNT(*) DESC;

-- More details about one of the connection
DECLARE @host_process_id INT = 10312;
DECLARE @host_name sysname = N'LT-RSD-01';
DECLARE @database_name sysname = N'msdb';

SELECT      DATEDIFF(MINUTE, s.last_request_end_time, GETDATE()) AS minutes_asleep,
            s.session_id,
            DB_NAME(s.database_id) AS database_name,
            s.host_name,
            s.host_process_id,
            t.text AS last_sql,
            s.program_name
FROM        sys.dm_exec_connections AS c
JOIN        sys.dm_exec_sessions AS s ON c.session_id = s.session_id
CROSS APPLY sys.dm_exec_sql_text(c.most_recent_sql_handle) AS t
WHERE       s.is_user_process = 1
            AND s.status = 'sleeping'
            AND DB_NAME(s.database_id) = @database_name
            AND s.host_process_id = @host_process_id
            AND s.host_name = @host_name
            AND DATEDIFF(SECOND, s.last_request_end_time, GETDATE()) > 60
ORDER BY    s.last_request_end_time;


-------------------------------------------------------------------------------
-- Top 20 Executed Queries (Michael J. Swart)
-------------------------------------------------------------------------------
;WITH frequent_queries
AS
(
    SELECT   TOP (20)
             query_hash,
             SUM(execution_count) AS executions
    FROM     sys.dm_exec_query_stats
    WHERE    query_hash <> 0x0
    GROUP BY query_hash
    ORDER BY SUM(execution_count) DESC
)
SELECT      @@servername AS server_name,
            COALESCE(DB_NAME(st.dbid), DB_NAME(CAST(pa.value AS INT)), 'Resource') AS DatabaseName,
            COALESCE(OBJECT_NAME(st.objectid, st.dbid), '<none>') AS object_name,
            qs.query_hash,
            qs.execution_count,
            fq.executions AS total_executions_for_query,
            SUBSTRING(st.text,
                      (qs.statement_start_offset + 2) / 2,
                      (CASE
                           WHEN qs.statement_end_offset = -1 THEN
                               LEN(CONVERT(NVARCHAR(MAX), st.text)) * 2
                           ELSE
                               qs.statement_end_offset + 2
                       END - qs.statement_start_offset
                      ) / 2
            ) AS sql_text,
            qp.query_plan
FROM        sys.dm_exec_query_stats AS qs
JOIN        frequent_queries AS fq ON fq.query_hash = qs.query_hash
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
OUTER APPLY sys.dm_exec_plan_attributes(qs.plan_handle) AS pa
WHERE       pa.attribute = 'dbid'
ORDER BY    fq.executions DESC,
            fq.query_hash,
            qs.execution_count DESC
OPTION (RECOMPILE);


-------------------------------------------------------------------------------
-- Top 20 I/O Consumers (Michael J. Swart)
-------------------------------------------------------------------------------
;WITH high_io_queries
AS
(
    SELECT   TOP (20)
             query_hash,
             SUM(total_logical_reads + total_logical_writes) AS io
    FROM     sys.dm_exec_query_stats
    WHERE    query_hash <> 0x0
    GROUP BY query_hash
    ORDER BY SUM(total_logical_reads + total_logical_writes) DESC
)
SELECT      @@servername AS servername,
            COALESCE(DB_NAME(st.dbid), DB_NAME(CAST(pa.value AS INT)), 'Resource') AS DatabaseName,
            COALESCE(OBJECT_NAME(st.objectid, st.dbid), '<none>') AS object_name,
            qs.query_hash,
            qs.total_logical_reads + qs.total_logical_writes AS total_io,
            qs.execution_count,
            CAST((qs.total_logical_reads + qs.total_logical_writes) / (qs.execution_count + 0.0) AS MONEY) AS average_io,
            fq.io AS total_io_for_query,
            SUBSTRING(st.text,
                      (qs.statement_start_offset + 2) / 2,
                      (CASE
                           WHEN qs.statement_end_offset = -1 THEN
                               LEN(CONVERT(NVARCHAR(MAX), st.text)) * 2
                           ELSE
                               qs.statement_end_offset + 2
                       END - qs.statement_start_offset
                      ) / 2
            ) AS sql_text,
            qp.query_plan
FROM        sys.dm_exec_query_stats AS qs
JOIN        high_io_queries AS fq ON fq.query_hash = qs.query_hash
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
OUTER APPLY sys.dm_exec_plan_attributes(qs.plan_handle) AS pa
WHERE       pa.attribute = 'dbid'
ORDER BY    fq.io DESC,
            fq.query_hash,
            qs.total_logical_reads + qs.total_logical_writes DESC
OPTION (RECOMPILE);


-------------------------------------------------------------------------------
-- Top 20 CPU Consumers (Michael J. Swart)
-------------------------------------------------------------------------------
;WITH high_cpu_queries
AS
(
    SELECT   TOP (20)
             query_hash,
             SUM(total_worker_time) AS cpuTime
    FROM     sys.dm_exec_query_stats
    WHERE    query_hash <> 0x0
    GROUP BY query_hash
    ORDER BY SUM(total_worker_time) DESC
)
SELECT      @@servername AS server_name,
            COALESCE(DB_NAME(st.dbid), DB_NAME(CAST(pa.value AS INT)), 'Resource') AS DatabaseName,
            COALESCE(OBJECT_NAME(st.objectid, st.dbid), '<none>') AS object_name,
            qs.query_hash,
            qs.total_worker_time AS cpu_time,
            qs.execution_count,
            CAST(qs.total_worker_time / (qs.execution_count + 0.0) AS MONEY) AS average_CPU_in_microseconds,
            hcq.cpuTime AS total_cpu_for_query,
            SUBSTRING(st.text,
                      (qs.statement_start_offset + 2) / 2,
                      (CASE
                           WHEN qs.statement_end_offset = -1 THEN
                               LEN(CONVERT(NVARCHAR(MAX), st.text)) * 2
                           ELSE
                               qs.statement_end_offset + 2
                       END - qs.statement_start_offset
                      ) / 2
            ) AS sql_text,
            qp.query_plan
FROM        sys.dm_exec_query_stats AS qs
JOIN        high_cpu_queries AS hcq ON hcq.query_hash = qs.query_hash
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
OUTER APPLY sys.dm_exec_plan_attributes(qs.plan_handle) AS pa
WHERE       pa.attribute = 'dbid'
ORDER BY    hcq.cpuTime DESC,
            hcq.query_hash,
            qs.total_worker_time DESC
OPTION (RECOMPILE);


-------------------------------------------------------------------------------
-- Top 20 Queries By Elapsed Time (Michael J. Swart)
-------------------------------------------------------------------------------
;WITH long_queries
AS
(
    SELECT   TOP (20)
             query_hash,
             SUM(total_elapsed_time) AS elapsed_time
    FROM     sys.dm_exec_query_stats
    WHERE    query_hash <> 0x0
    GROUP BY query_hash
    ORDER BY SUM(total_elapsed_time) DESC
)
SELECT      @@servername AS server_name,
            COALESCE(DB_NAME(st.dbid), DB_NAME(CAST(pa.value AS INT)), 'Resource') AS DatabaseName,
            COALESCE(OBJECT_NAME(st.objectid, st.dbid), '<none>') AS object_name,
            qs.query_hash,
            qs.total_elapsed_time,
            qs.execution_count,
            CAST(qs.total_elapsed_time / (qs.execution_count + 0.0) AS MONEY) AS average_duration_in_microseconds,
            lq.elapsed_time AS total_elapsed_time_for_query,
            SUBSTRING(st.text,
                      (qs.statement_start_offset + 2) / 2,
                      (CASE
                           WHEN qs.statement_end_offset = -1 THEN
                               LEN(CONVERT(NVARCHAR(MAX), st.text)) * 2
                           ELSE
                               qs.statement_end_offset + 2
                       END - qs.statement_start_offset
                      ) / 2
            ) AS sql_text,
            qp.query_plan
FROM        sys.dm_exec_query_stats AS qs
JOIN        long_queries AS lq ON lq.query_hash = qs.query_hash
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
OUTER APPLY sys.dm_exec_plan_attributes(qs.plan_handle) AS pa
WHERE       pa.attribute = 'dbid'
ORDER BY    lq.elapsed_time DESC,
            lq.query_hash,
            qs.total_elapsed_time DESC
OPTION (RECOMPILE);

-------------------------------------------------------------------------------
-- DMV/DMF overview
-------------------------------------------------------------------------------
SELECT   name,
         type_desc
FROM     sys.system_objects
WHERE    name LIKE 'dm%'
ORDER BY name;
GO


SELECT   UPPER(SUBSTRING(name, 4, CHARINDEX('_', name, 4) - 4)) AS Type,
		 COUNT(*) AS DMVCount
FROM     sys.system_objects
WHERE    name LIKE 'dm%'
GROUP BY SUBSTRING(name, 4, CHARINDEX('_', name, 4) - 4)
ORDER BY DMVCount DESC, SUBSTRING(name, 4, CHARINDEX('_', name, 4) - 4);
GO


-------------------------------------------------------------------------------
-- All databases CPU resources
-------------------------------------------------------------------------------
WITH DB_CPU_STATS_ON_INSTANCE
AS
(
    SELECT      F_DB.DatabaseID,
                DB_NAME(F_DB.DatabaseID) AS DatabaseName,
                SUM(qs.total_worker_time) AS CPU_Time_Ms
    FROM        sys.dm_exec_query_stats AS qs
    CROSS APPLY (
        SELECT CONVERT(INT, value) AS DatabaseID
        FROM   sys.dm_exec_plan_attributes(qs.plan_handle)
        WHERE  attribute = N'dbid'
    ) AS F_DB
    GROUP BY    F_DB.DatabaseID
)
SELECT   ROW_NUMBER() OVER (ORDER BY DB_CPU_STATS_ON_INSTANCE.CPU_Time_Ms DESC) AS row_num,
         DB_CPU_STATS_ON_INSTANCE.DatabaseName,
         DB_CPU_STATS_ON_INSTANCE.CPU_Time_Ms,
         CAST(DB_CPU_STATS_ON_INSTANCE.CPU_Time_Ms * 1.0 / SUM(DB_CPU_STATS_ON_INSTANCE.CPU_Time_Ms) OVER () * 100.0 AS DECIMAL(5, 2)) AS CPUPercent
FROM     DB_CPU_STATS_ON_INSTANCE
WHERE    DB_CPU_STATS_ON_INSTANCE.DatabaseID > 4
         AND DB_CPU_STATS_ON_INSTANCE.DatabaseID <> 32767
ORDER BY row_num
OPTION (RECOMPILE);
GO


-------------------------------------------------------------------------------
-- TOP 50 CPU queries
-------------------------------------------------------------------------------
SELECT      TOP (50)
            OBJECT_SCHEMA_NAME(qt.objectid, qt.dbid) + '.' + OBJECT_NAME(qt.objectid, qt.dbid) AS ObjectName,
            qt.text AS TextData,
            qs.total_physical_reads AS DiskReads,  -- The worst reads, disk reads
            qs.total_logical_reads AS MemoryReads, --Logical Reads are memory reads
            qs.execution_count AS Executions,
            qs.total_worker_time AS TotalCPUTime,
            qs.total_worker_time / qs.execution_count AS AverageCPUTime,
            qs.total_elapsed_time AS DiskWaitAndCPUTime,
            qs.max_logical_writes AS MemoryWrites,
            qs.creation_time AS DateCached,
            DB_NAME(qt.dbid) AS DatabaseName,
            qs.last_execution_time AS LastExecutionTime
FROM        sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
ORDER BY    qs.total_worker_time DESC;
GO


-------------------------------------------------------------------------------
-- TOP 50 CPU queries
-------------------------------------------------------------------------------
SELECT   TOP (50)
         query_stats.query_hash,
         SUM(query_stats.total_worker_time) / SUM(query_stats.execution_count) AS avgCPU_USAGE,
         MIN(query_stats.statement_text) AS QUERY
FROM     (
    SELECT      qs.*,
                SUBSTRING(st.text,
                          (qs.statement_start_offset / 2) + 1,
                          ((CASE qs.statement_end_offset
                                WHEN -1 THEN
                                    DATALENGTH(st.text)
                                ELSE
                                    qs.statement_end_offset
                            END - qs.statement_start_offset
                           ) / 2
                          ) + 1
                ) AS statement_text
    FROM        sys.dm_exec_query_stats AS qs
    CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
) AS query_stats
GROUP BY query_stats.query_hash
ORDER BY 2 DESC;
GO


-------------------------------------------------------------------------------
-- TOP 50 IO queries
-------------------------------------------------------------------------------
SELECT      q.text,
            SUBSTRING(
                q.text,
                (highest_cpu_queries.statement_start_offset / 2) + 1,
                ((CASE highest_cpu_queries.statement_end_offset
                      WHEN -1 THEN
                          DATALENGTH(q.text)
                      ELSE
                          highest_cpu_queries.statement_end_offset
                  END - highest_cpu_queries.statement_start_offset
                 ) / 2
                ) + 1
            ) AS statement_text,
            highest_cpu_queries.total_worker_time,
            highest_cpu_queries.total_logical_reads,
            highest_cpu_queries.last_execution_time,
            highest_cpu_queries.execution_count,
            q.dbid,
            q.objectid,
            q.number,
            q.encrypted,
            highest_cpu_queries.plan_handle
FROM        (
    SELECT   TOP (50)
             qs.last_execution_time,
             qs.execution_count,
             qs.plan_handle,
             qs.total_worker_time,
             qs.statement_start_offset,
             qs.statement_end_offset,
             qs.total_logical_reads
    FROM     sys.dm_exec_query_stats AS qs
    ORDER BY qs.total_worker_time DESC
) AS highest_cpu_queries
CROSS APPLY sys.dm_exec_sql_text(highest_cpu_queries.plan_handle) AS q
ORDER BY    highest_cpu_queries.total_logical_reads DESC;
GO


-------------------------------------------------------------------------------
-- TOP IO queries
-------------------------------------------------------------------------------
SELECT      SUBSTRING(st.text,
                      (qs.statement_start_offset / 2) + 1,
                      ((CASE qs.statement_end_offset
                            WHEN -1 THEN
                                DATALENGTH(st.text)
                            ELSE
                                qs.statement_end_offset
                        END - qs.statement_start_offset
                       ) / 2
                      ) + 1
            ) AS statement_text,
            qs.total_logical_reads,
            qs.total_physical_reads,
            qs.execution_count
FROM        sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
ORDER BY    qs.total_logical_reads DESC,
            qs.execution_count DESC;
GO


-------------------------------------------------------------------------------
-- IO stats
-------------------------------------------------------------------------------
SELECT          SERVERPROPERTY('MachineName') AS machine_name,
                ISNULL(SERVERPROPERTY('InstanceName'), 'mssqlserver') AS instance_name,
                @@SERVERNAME AS sql_server_name,
                DB_NAME(mf.database_id) AS database_name,
                mf.name AS logical_name,
                mf.physical_name AS physical_name,
                LEFT(mf.physical_name, 1) AS disk_drive,
                mf.type_desc AS file_type,
                mf.state_desc AS state,
                CASE mf.is_read_only
                    WHEN 0 THEN
                        'no'
                    WHEN 1 THEN
                        'yes'
                END AS read_only,
                CONVERT(NUMERIC(18, 2), CONVERT(NUMERIC, mf.size) * 8 / 1024) AS size_mb,
                divfs.size_on_disk_bytes / 1024 / 1024 AS size_on_disk_mb,
                CASE mf.is_percent_growth
                    WHEN 0 THEN
                        CAST(CONVERT(INT, CONVERT(NUMERIC, mf.growth) * 8 / 1024) AS VARCHAR) + ' MB'
                    WHEN 1 THEN
                        CAST(mf.growth AS VARCHAR) + '%'
                END AS growth,
                CASE mf.is_percent_growth
                    WHEN 0 THEN
                        CONVERT(NUMERIC(18, 2), CONVERT(NUMERIC, mf.growth) * 8 / 1024)
                    WHEN 1 THEN
                        CONVERT(NUMERIC(18, 2), (CONVERT(NUMERIC, mf.size) * mf.growth / 100) * 8 / 1024)
                END AS next_growth_mb,
                CASE mf.max_size
                    WHEN 0 THEN
                        'NO-growth'
                    WHEN -1 THEN
                (CASE mf.growth
                     WHEN 0 THEN
                         'NO-growth'
                     ELSE
                         'unlimited'
                 END
                )
                    ELSE
                        CAST(CONVERT(INT, CONVERT(NUMERIC, mf.max_size) * 8 / 1024) AS VARCHAR) + ' MB'
                END AS max_size,
                divfs.num_of_reads,
                divfs.num_of_bytes_read / 1024 / 1024 AS read_mb,
                divfs.io_stall_read_ms,
                divfs.num_of_writes,
                divfs.num_of_bytes_written / 1024 / 1024 AS write_mb,
                divfs.io_stall_write_ms
FROM            sys.master_files AS mf
LEFT OUTER JOIN sys.dm_io_virtual_file_stats(NULL, NULL) AS divfs ON mf.database_id = divfs.database_id
                                                                     AND mf.file_id = divfs.file_id;
GO


-------------------------------------------------------------------------------
-- Monitor running queries
-------------------------------------------------------------------------------
SELECT      st.text,
            SUBSTRING(st.text,
                      (qs.statement_start_offset / 2) + 1,
                      ((CASE qs.statement_end_offset
                            WHEN -1 THEN
                                DATALENGTH(st.text)
                            ELSE
                                qs.statement_end_offset
                        END - qs.statement_start_offset
                       ) / 2
                      ) + 1
            ) AS statement_text,
            *
FROM        sys.dm_exec_requests AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle);
GO


-------------------------------------------------------------------------------
-- To find blocking sessions or queries
-------------------------------------------------------------------------------
SELECT      db.name AS DBName,
            tl.request_session_id,
            wt.blocking_session_id,
            OBJECT_NAME(p.object_id) AS BlockedObjectName,
            tl.resource_type,
            h1.text AS RequestingText,
            h2.text AS BlockingTest,
            tl.request_mode
FROM        sys.dm_tran_locks AS tl
INNER JOIN  sys.databases AS db ON db.database_id = tl.resource_database_id
INNER JOIN  sys.dm_os_waiting_tasks AS wt ON tl.lock_owner_address = wt.resource_address
INNER JOIN  sys.partitions AS p ON p.hobt_id = tl.resource_associated_entity_id
INNER JOIN  sys.dm_exec_connections AS ec1 ON ec1.session_id = tl.request_session_id
INNER JOIN  sys.dm_exec_connections AS ec2 ON ec2.session_id = wt.blocking_session_id
CROSS APPLY sys.dm_exec_sql_text(ec1.most_recent_sql_handle) AS h1
CROSS APPLY sys.dm_exec_sql_text(ec2.most_recent_sql_handle) AS h2;
GO


-------------------------------------------------------------------------------
-- Backup Check
-------------------------------------------------------------------------------
SELECT    DB.name AS Database_Name,
          MAX(DB.recovery_model_desc) AS Recovery_Model,
          MAX(BS.backup_start_date) AS Last_Backup,
          MAX(CASE
                  WHEN BS.type = 'D' THEN
                      BS.backup_start_date
              END
          ) AS Last_Full_backup,
          SUM(CASE
                  WHEN BS.type = 'D' THEN
                      1
              END
          ) AS Count_Full_backup,
          MAX(CASE
                  WHEN BS.type = 'L' THEN
                      BS.backup_start_date
              END
          ) AS Last_Log_backup,
          SUM(CASE
                  WHEN BS.type = 'L' THEN
                      1
              END
          ) AS Count_Log_backup,
          MAX(CASE
                  WHEN BS.type = 'I' THEN
                      BS.backup_start_date
              END
          ) AS Last_Differential_backup,
          SUM(CASE
                  WHEN BS.type = 'I' THEN
                      1
              END
          ) AS Count_Differential_backup,
          MAX(CASE
                  WHEN BS.type = 'F' THEN
                      BS.backup_start_date
              END
          ) AS LastFile,
          SUM(CASE
                  WHEN BS.type = 'F' THEN
                      1
              END
          ) AS CountFile,
          MAX(CASE
                  WHEN BS.type = 'G' THEN
                      BS.backup_start_date
              END
          ) AS LastFileDiff,
          SUM(CASE
                  WHEN BS.type = 'G' THEN
                      1
              END
          ) AS CountFileDiff,
          MAX(CASE
                  WHEN BS.type = 'P' THEN
                      BS.backup_start_date
              END
          ) AS LastPart,
          SUM(CASE
                  WHEN BS.type = 'P' THEN
                      1
              END
          ) AS CountPart,
          MAX(CASE
                  WHEN BS.type = 'Q' THEN
                      BS.backup_start_date
              END
          ) AS LastPartDiff,
          SUM(CASE
                  WHEN BS.type = 'Q' THEN
                      1
              END
          ) AS CountPartDiff
FROM      sys.databases AS DB
LEFT JOIN msdb.dbo.backupset AS BS ON BS.database_name = DB.name
WHERE     ISNULL(BS.is_damaged, 0) = 0 -- exclude damaged backups 
GROUP BY  DB.name
ORDER BY  Last_Backup DESC;
GO


-------------------------------------------------------------------------------
-- Check for fragmented indexes
-------------------------------------------------------------------------------
DECLARE @db INT;
SELECT  @db = DB_ID();
SELECT   OBJECT_NAME(s.object_id) AS objname,
         s.object_id,
         i.name AS index_name,
         s.index_type_desc,
         s.avg_fragmentation_in_percent,
		 'ALTER INDEX [' + i.name + '] on ' + OBJECT_NAME(s.object_id) + ' REBUILD WITH (ONLINE = ON)' AS sql_command
FROM     sys.dm_db_index_physical_stats(@db, NULL, NULL, NULL, NULL) AS s
JOIN     sys.indexes AS i ON i.object_id = s.object_id
                             AND i.index_id = s.index_id
WHERE    s.avg_fragmentation_in_percent > 10
ORDER BY s.avg_fragmentation_in_percent DESC,
         s.page_count DESC;
GO


-------------------------------------------------------------------------------
-- All indexes usage statistic for current database
-------------------------------------------------------------------------------
SELECT   OBJECT_NAME(s.object_id) AS objname,
         s.object_id,
         i.name AS index_name,
         i.index_id AS index_id,
         s.user_seeks,
         s.user_scans,
         s.user_lookups
FROM     sys.dm_db_index_usage_stats AS s
JOIN     sys.indexes AS i ON i.object_id = s.object_id
                             AND i.index_id = s.index_id
WHERE    s.database_id = DB_ID()
         AND OBJECTPROPERTY(s.object_id, 'IsUserTable') = 1
ORDER BY (s.user_seeks + s.user_scans + s.user_lookups) DESC;
GO


-------------------------------------------------------------------------------
-- Check all objects stats for current database
-------------------------------------------------------------------------------
SELECT   OBJECT_NAME(si.object_id) AS TableName,
         CASE
             WHEN si.stats_id = 0 THEN
                 'Heap'
             WHEN si.stats_id = 1 THEN
                 'CL'
             WHEN INDEXPROPERTY(si.object_id, si.name, 'IsAutoStatistics') = 1 THEN
                 'Stats-Auto'
             WHEN INDEXPROPERTY(si.object_id, si.name, 'IsHypothetical') = 1 THEN
                 'Stats-HIND'
             WHEN INDEXPROPERTY(si.object_id, si.name, 'IsStatistics') = 1 THEN
                 'Stats-User'
             WHEN si.stats_id
                  BETWEEN 2 AND 1004 THEN
                 'NC ' + RIGHT('00' + CONVERT(VARCHAR, si.stats_id), 3)
             ELSE
                 'Text/Image'
         END AS IndexType,
         si.name AS IndexName,
         si.stats_id AS IndexID,
         CASE
             WHEN si.stats_id
                  BETWEEN 1 AND 250
                  AND STATS_DATE(si.object_id, si.stats_id) < DATEADD(m, -1, GETDATE()) THEN
                 '!! More than a month OLD !!'
             WHEN si.stats_id
                  BETWEEN 1 AND 250
                  AND STATS_DATE(si.object_id, si.stats_id) < DATEADD(wk, -1, GETDATE()) THEN
                 '! Within the past month !'
             WHEN si.stats_id
                  BETWEEN 1 AND 250 THEN
                 'Stats recent'
             ELSE
                 ''
         END AS Warning,
         STATS_DATE(si.object_id, si.stats_id) AS [Last Stats Update],
         si.no_recompute
FROM     sys.stats AS si
WHERE    OBJECTPROPERTY(si.object_id, 'IsUserTable') = 1
         AND STATS_DATE(si.object_id, si.stats_id) IS NOT NULL
         AND (
             INDEXPROPERTY(si.object_id, si.name, 'IsAutoStatistics') = 1
             OR INDEXPROPERTY(si.object_id, si.name, 'IsHypothetical') = 1
             OR INDEXPROPERTY(si.object_id, si.name, 'IsStatistics') = 1
         )
ORDER BY [Last Stats Update];
GO


-------------------------------------------------------------------------------
--  Monitoring all sessions status (so_whoisactive replacement)
-------------------------------------------------------------------------------
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT      er.session_id AS SPID,
            er.blocking_session_id AS BlkBy,
            er.total_elapsed_time AS ElapsedMS,
            er.cpu_time AS CPU,
            er.logical_reads + er.reads AS IOReads,
            er.writes AS IOWrites,
            ec.execution_count AS Executions,
            er.command AS CommandType,
            OBJECT_SCHEMA_NAME(qt.objectid, qt.dbid) + '.' + OBJECT_NAME(qt.objectid, qt.dbid) AS ObjectName,
            SUBSTRING(qt.text,
                      er.statement_start_offset / 2,
                      (CASE
                           WHEN er.statement_end_offset = -1 THEN
                               LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2
                           ELSE
                               er.statement_end_offset
                       END - er.statement_start_offset
                      ) / 2
            ) AS SQLStatement,
            ses.status AS Status,
            ses.login_name AS Login,
            ses.host_name AS Host,
            DB_NAME(er.database_id) AS DBName,
            er.last_wait_type AS LastWaitType,
            er.start_time AS StartTime,
            con.net_transport AS Protocol,
            CASE ses.transaction_isolation_level
                WHEN 0 THEN
                    'Unspecified'
                WHEN 1 THEN
                    'Read Uncommitted'
                WHEN 2 THEN
                    'Read Committed'
                WHEN 3 THEN
                    'Repeatable'
                WHEN 4 THEN
                    'Serializable'
                WHEN 5 THEN
                    'Snapshot'
            END AS transaction_isolation,
            con.num_writes AS ConnectionWrites,
            con.num_reads AS ConnectionReads,
            con.client_net_address AS ClientAddress,
            con.auth_scheme AS Authentication
FROM        sys.dm_exec_requests AS er
LEFT JOIN   sys.dm_exec_sessions AS ses ON ses.session_id = er.session_id
LEFT JOIN   sys.dm_exec_connections AS con ON con.session_id = ses.session_id
CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) AS qt
OUTER APPLY (
    SELECT MAX(cp.usecounts) AS execution_count
    FROM   sys.dm_exec_cached_plans AS cp
    WHERE  cp.plan_handle = er.plan_handle
) AS ec
ORDER BY    er.blocking_session_id DESC,
            er.logical_reads + er.reads DESC,
            er.session_id;
GO


-------------------------------------------------------------------------------
-- List and status of currently waiting tasks
-------------------------------------------------------------------------------
SELECT      wt.session_id,
            wt.exec_context_id,
            wt.wait_duration_ms,
            wt.wait_type,
            wt.blocking_session_id,
            wt.resource_address,
            wt.resource_description,
            s.program_name,
            st.text,
            sp.query_plan,
            s.cpu_time AS cpu_time_ms,
            s.memory_usage * 8 AS memory_usage_kb
FROM        sys.dm_os_waiting_tasks AS wt
JOIN        sys.dm_exec_sessions AS s ON s.session_id = wt.session_id
JOIN        sys.dm_exec_requests AS r ON r.session_id = s.session_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) AS st
OUTER APPLY sys.dm_exec_query_plan(r.plan_handle) AS sp
WHERE       s.is_user_process = 1
ORDER BY    wt.session_id,
            wt.exec_context_id;
GO


-------------------------------------------------------------------------------
-- Wait events of current database
-------------------------------------------------------------------------------
SELECT   GETDATE() AS Run_Time,                                                        
         wait_type,                                                                     
         waiting_tasks_count,
         CAST(wait_time_ms / 1000. AS DECIMAL(12, 2)) AS wait_time_s,                   
         CAST(100. * wait_time_ms / SUM(wait_time_ms) OVER () AS DECIMAL(12, 2)) AS pct 
FROM     sys.dm_os_wait_stats
WHERE    wait_type NOT IN ( 'BROKER_TASK_STOP', 'Total', 'SLEEP', 'BROKER_EVENTHANDLER', 'BROKER_RECEIVE_WAITFOR',
                            'BROKER_TRANSMITTER', 'CHECKPOINT_QUEUE', 'CHKPT,CLR_AUTO_EVENT', 'CLR_MANUAL_EVENT',
                            'KSOURCE_WAKEUP', 'LAZYWRITER_SLEEP', 'LOGMGR_QUEUE', 'ONDEMAND_TASK_QUEUE',
                            'REQUEST_FOR_DEADLOCK_SEARCH', 'RESOURCE_QUEUE', 'SERVER_IDLE_CHECK', 'SLEEP_BPOOL_FLUSH',
                            'SLEEP_DBSTARTUP', 'SLEEP_DCOMSTARTUP', 'SLEEP_MSDBSTARTUP', 'SLEEP_SYSTEMTASK', 'SLEEP_TASK',
                            'SLEEP_TEMPDBSTARTUP', 'SNI_HTTP_ACCEPT', 'SQLTRACE_BUFFER_FLUSH', 'TRACEWRITE',
                            'WAIT_FOR_RESULTS', 'WAITFOR_TASKSHUTDOWN', 'XE_DISPATCHER_WAIT', 'XE_TIMER_EVENT', 'WAITFOR'
)
ORDER BY wait_time_s DESC;
GO


-------------------------------------------------------------------------------
-- Wait events of current database
-------------------------------------------------------------------------------
WITH waits
AS
(
    SELECT wait_type,
           wait_time_ms / 1000.0 AS waits,
           (wait_time_ms - signal_wait_time_ms) / 1000.0 AS resources,
           signal_wait_time_ms / 1000.0 AS signals,
           waiting_tasks_count AS waitcount,
           100.0 * wait_time_ms / SUM(wait_time_ms) OVER () AS percentage,
           ROW_NUMBER() OVER (ORDER BY wait_time_ms DESC) AS rownum
    FROM   sys.dm_os_wait_stats
    WHERE  wait_type NOT IN ( N'CLR_SEMAPHORE', N'LAZYWRITER_SLEEP', N'RESOURCE_QUEUE', N'SQLTRACE_BUFFER_FLUSH',
                              N'SLEEP_TASK', N'SLEEP_SYSTEMTASK', N'WAITFOR', N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
                              N'CHECKPOINT_QUEUE', N'REQUEST_FOR_DEADLOCK_SEARCH', N'XE_TIMER_EVENT',
                              N'XE_DISPATCHER_JOIN', N'LOGMGR_QUEUE', N'FT_IFTS_SCHEDULER_IDLE_WAIT',
                              N'BROKER_TASK_STOP', N'CLR_MANUAL_EVENT', N'CLR_AUTO_EVENT',
                              N'DISPATCHER_QUEUE_SEMAPHORE', N'TRACEWRITE', N'XE_DISPATCHER_WAIT', N'BROKER_TO_FLUSH',
                              N'BROKER_EVENTHANDLER', N'FT_IFTSHC_MUTEX', N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
                              N'DIRTY_PAGE_POLL', N'SP_SERVER_DIAGNOSTICS_SLEEP'
)
)
SELECT     w1.wait_type AS waittype,
           CAST(w1.waits AS DECIMAL(14, 2)) AS wait_s,
           CAST(w1.resources AS DECIMAL(14, 2)) AS resource_s,
           CAST(w1.signals AS DECIMAL(14, 2)) AS signal_s,
           w1.waitcount AS wait_count,
           CAST(w1.percentage AS DECIMAL(4, 2)) AS percentage,
           CAST((w1.waits / w1.waitcount) AS DECIMAL(14, 4)) AS avgWait_s,
           CAST((w1.resources / w1.waitcount) AS DECIMAL(14, 4)) AS avgResource_s,
           CAST((w1.signals / w1.waitcount) AS DECIMAL(14, 4)) AS avgSignal_s
FROM       waits AS w1
INNER JOIN waits AS w2 ON w2.rownum <= w1.rownum
GROUP BY   w1.rownum,
           w1.wait_type,
           w1.waits,
           w1.resources,
           w1.signals,
           w1.waitcount,
           w1.percentage
HAVING     SUM(w2.percentage) - w1.percentage < 95; -- percentage threshold
GO


-------------------------------------------------------------------------------
-- Analyse database size growth using backup history
-------------------------------------------------------------------------------
DECLARE @startDate DATETIME;
SET @startDate = GETDATE();

SELECT   PVT.DatabaseName,
         PVT.[0],
         PVT.[-1],
         PVT.[-2],
         PVT.[-3],
         PVT.[-4],
         PVT.[-5],
         PVT.[-6],
         PVT.[-7],
         PVT.[-8],
         PVT.[-9],
         PVT.[-10],
         PVT.[-11],
         PVT.[-12]
FROM     (
    SELECT     BS.database_name AS DatabaseName,
               DATEDIFF(mm, @startDate, BS.backup_start_date) AS MonthsAgo,
               CONVERT(NUMERIC(10, 1), AVG(BF.file_size / 1048576.0)) AS AvgSizeMB
    FROM       msdb.dbo.backupset AS BS
    INNER JOIN msdb.dbo.backupfile AS BF ON BS.backup_set_id = BF.backup_set_id
    WHERE      NOT BS.database_name IN ( 'master', 'msdb', 'model', 'tempdb' )
               AND BF.file_type = 'D'
               AND BS.backup_start_date
               BETWEEN DATEADD(yy, -1, @startDate) AND @startDate
    GROUP BY   BS.database_name,
               DATEDIFF(mm, @startDate, BS.backup_start_date)
) AS BCKSTAT
PIVOT (
    SUM(AvgSizeMB)
    FOR MonthsAgo IN ([0], [-1], [-2], [-3], [-4], [-5], [-6], [-7], [-8], [-9], [-10], [-11], [-12])
) AS PVT
ORDER BY PVT.DatabaseName;
GO


-------------------------------------------------------------------------------
-- Check if table is partitioned in SQL Server
-------------------------------------------------------------------------------
SELECT     DISTINCT
           pp.object_id,
           OBJECT_NAME(pp.object_id) AS TbName,
           i.name AS index_name,
           i.type_desc AS index_type_desc,
           ps.name AS partition_scheme,
           ps.data_space_id AS data_space_id,
           pf.name AS function_name,
           ps.function_id AS function_id
FROM       sys.partitions AS pp
INNER JOIN sys.indexes AS i ON pp.object_id = i.object_id
                               AND pp.index_id = i.index_id
INNER JOIN sys.data_spaces AS ds ON i.data_space_id = ds.data_space_id
INNER JOIN sys.partition_schemes AS ps ON ds.data_space_id = ps.data_space_id
INNER JOIN sys.partition_functions AS pf ON ps.function_id = pf.function_id
ORDER BY   TbName,
           index_name;
GO


-------------------------------------------------------------------------------
-- Inventory Collection Script
-------------------------------------------------------------------------------
SELECT          GETDATE() AS Date_Collected,
                SERVERPROPERTY('MachineName') AS Machine_Name,
                ISNULL(SERVERPROPERTY('InstanceName'), 'mssqlserver') AS Instance_Name,
                @@SERVERNAME AS Sql_Server_Name,
                SERVERPROPERTY('productversion') AS Product_Version,
                SERVERPROPERTY('productlevel') AS Product_Level,
                SERVERPROPERTY('edition') AS Edition,
                d.name AS database_name,
                SUSER_SNAME(d.owner_sid) AS owner,
                ls.cntr_value AS log_size_kb,
                lu.cntr_value AS log_used_kb,
                lp.cntr_value AS percent_log_used,
                ds.cntr_value AS data_files_size_kb
FROM            sys.databases AS d
LEFT OUTER JOIN sys.dm_os_performance_counters AS lu ON lu.instance_name = d.name
                                                        AND lu.counter_name LIKE N'Log File(s) Used Size (KB)%'
LEFT OUTER JOIN sys.dm_os_performance_counters AS ls ON ls.instance_name = d.name
                                                        AND ls.counter_name LIKE N'Log File(s) Size (KB)%'
                                                        AND ls.cntr_value > 0
LEFT OUTER JOIN sys.dm_os_performance_counters AS lp ON lp.instance_name = d.name
                                                        AND lp.counter_name LIKE N'Percent Log Used%'
LEFT OUTER JOIN sys.dm_os_performance_counters AS ds ON ds.instance_name = d.name
                                                        AND ds.counter_name LIKE N'Data File(s) Size (KB)%'
ORDER BY        d.name;
GO


-------------------------------------------------------------------------------
-- Inventory Collection Script
-------------------------------------------------------------------------------
SELECT     SERVERPROPERTY('MachineName') AS machine_name,
           ISNULL(SERVERPROPERTY('InstanceName'), 'mssqlserver') AS instance_name,
           @@SERVERNAME AS sql_server_name,
           d.name AS database_name,
           SUSER_SNAME(d.owner_sid) AS owner,
           d.compatibility_level,
           d.collation_name,
           d.is_auto_close_on,
           d.is_auto_shrink_on,
           d.state_desc,
           d.snapshot_isolation_state,
           d.is_read_committed_snapshot_on,
           d.recovery_model_desc,
           d.is_auto_create_stats_on,
           d.is_auto_update_stats_on,
           d.is_auto_update_stats_async_on,
           d.is_in_standby,
           d.page_verify_option_desc,
           d.log_reuse_wait_desc,
           ls.cntr_value AS [log size (kb)],
           lu.cntr_value AS [log used (kb)],
           lp.cntr_value AS [percent log used],
           ds.cntr_value AS [data file(s) size (kb)]
FROM       sys.databases AS d
INNER JOIN sys.dm_os_performance_counters AS lu ON lu.instance_name = d.name
                                                   AND lu.counter_name LIKE N'Log File(s) Used Size (KB)%'
INNER JOIN sys.dm_os_performance_counters AS ls ON ls.instance_name = d.name
                                                   AND ls.counter_name LIKE N'Log File(s) Size (KB)%'
                                                   AND ls.cntr_value > 0
INNER JOIN sys.dm_os_performance_counters AS lp ON lp.instance_name = d.name
                                                   AND lp.counter_name LIKE N'Percent Log Used%'
INNER JOIN sys.dm_os_performance_counters AS ds ON ds.instance_name = d.name
                                                   AND ds.counter_name LIKE N'Data File(s) Size (KB)%'
ORDER BY   d.name;
GO


-------------------------------------------------------------------------------
-- Top 10 CPU intensive queries
-------------------------------------------------------------------------------
SELECT      TOP (10)
            CASE
                WHEN qs.sql_handle IS NULL THEN
                    ''
                ELSE
				(SUBSTRING(st.text,
						   (qs.statement_start_offset + 2) / 2,
						   (CASE
								WHEN qs.statement_end_offset = -1 THEN
									LEN(CONVERT(NVARCHAR(MAX), st.text)) * 2
								ELSE
									qs.statement_end_offset
							END - qs.statement_start_offset
						   ) / 2
				 )
				)
            END AS query_text,
            qp.query_plan,
            (qs.total_worker_time + 0.0) / 1000 AS total_worker_time,
            (qs.total_worker_time + 0.0) / (qs.execution_count * 1000) AS AvgCPUTime,
            qs.total_logical_reads AS LogicalReads,
            qs.total_logical_writes AS logicalWrites,
            qs.execution_count,
            qs.creation_time,
            qs.last_execution_time,
            qs.total_logical_reads + qs.total_logical_writes AS AggIO,
            (qs.total_logical_reads + qs.total_logical_writes) / (qs.execution_count + 0.0) AS AvgIO,
            DB_NAME(st.dbid) AS database_name,
            st.objectid AS object_id
FROM        sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
WHERE       total_worker_time > 0
ORDER BY    total_worker_time DESC;