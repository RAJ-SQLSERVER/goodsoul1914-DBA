USE tempdb;
GO
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET QUOTED_IDENTIFIER ON;
SET NUMERIC_ROUNDABORT OFF;
GO

/*******************************************************************
perf stats snapshot
********************************************************************/
USE tempdb;
GO

IF OBJECT_ID ('sp_perf_stats_snapshot', 'P') IS NOT NULL
    DROP PROCEDURE sp_perf_stats_snapshot;
GO

CREATE PROCEDURE sp_perf_stats_snapshot
AS
BEGIN
    PRINT 'Starting SQL Server Perf Stats Snapshot Script...';
    PRINT 'SQL Version (SP)         ' + CONVERT (VARCHAR, SERVERPROPERTY ('ProductVersion')) + ' ('
          + CONVERT (VARCHAR, SERVERPROPERTY ('ProductLevel')) + ')';
    DECLARE @runtime DATETIME;
    DECLARE @cpu_time_start     BIGINT,
            @cpu_time           BIGINT,
            @elapsed_time_start BIGINT,
            @rowcount           BIGINT;
    DECLARE @queryduration            INT,
            @qrydurationwarnthreshold INT;
    DECLARE @querystarttime DATETIME;
    SET @runtime = GETDATE ();
    SET @qrydurationwarnthreshold = 5000;

    PRINT '';
    PRINT 'Start time: ' + CONVERT (VARCHAR(30), @runtime, 126);
    PRINT '';
    PRINT '-- Top N Query Plan Statistics --';
    SELECT @cpu_time_start = cpu_time
    FROM sys.dm_exec_sessions
    WHERE session_id = @@SPID;
    SET @querystarttime = GETDATE ();
    SELECT CONVERT (VARCHAR(30), @runtime, 126) AS runtime,
           LEFT(p.cacheobjtype + ' (' + p.objtype + ')', 35) AS cacheobjtype,
           p.usecounts,
           p.size_in_bytes / 1024 AS size_in_kb,
           PlanStats.total_worker_time / 1000 AS tot_cpu_ms,
           PlanStats.total_elapsed_time / 1000 AS tot_duration_ms,
           PlanStats.total_physical_reads,
           PlanStats.total_logical_writes,
           PlanStats.total_logical_reads,
           PlanStats.CpuRank,
           PlanStats.PhysicalReadsRank,
           PlanStats.DurationRank,
           LEFT(CASE
                    WHEN pa.value = 32767 THEN 'ResourceDb'
                    ELSE ISNULL (DB_NAME (CONVERT (sysname, pa.value)), CONVERT (sysname, pa.value))
                END, 40) AS dbname,
           sql.objectid,
           CONVERT (NVARCHAR(50),
                    CASE
                        WHEN sql.objectid IS NULL THEN NULL
                        ELSE REPLACE (REPLACE (sql.text, CHAR (13), ' '), CHAR (10), ' ')
                    END
           ) AS procname,
           REPLACE (
               REPLACE (
                   SUBSTRING (
                       sql.text,
                       PlanStats.statement_start_offset / 2 + 1,
                       CASE
                           WHEN PlanStats.statement_end_offset = -1 THEN LEN (CONVERT (NVARCHAR(MAX), sql.text))
                           ELSE PlanStats.statement_end_offset / 2 - PlanStats.statement_start_offset / 2 + 1
                       END
                   ),
                   CHAR (13),
                   ' '
               ),
               CHAR (10),
               ' '
           ) AS stmt_text,
           PlanStats.query_hash,
           PlanStats.query_plan_hash,
           PlanStats.creation_time,
           PlanStats.statement_start_offset,
           PlanStats.statement_end_offset,
           PlanStats.plan_generation_num,
           PlanStats.min_worker_time,
           PlanStats.last_worker_time,
           PlanStats.max_worker_time,
           PlanStats.min_elapsed_time,
           PlanStats.last_elapsed_time,
           PlanStats.max_elapsed_time,
           PlanStats.min_physical_reads,
           PlanStats.last_physical_reads,
           PlanStats.max_physical_reads,
           PlanStats.min_logical_writes,
           PlanStats.last_logical_writes,
           PlanStats.max_logical_writes,
           PlanStats.min_logical_reads,
           PlanStats.last_logical_reads,
           PlanStats.max_logical_reads,
           PlanStats.plan_handle
    FROM (
        SELECT stat.plan_handle,
               statement_start_offset,
               statement_end_offset,
               stat.total_worker_time,
               stat.total_elapsed_time,
               stat.total_physical_reads,
               stat.total_logical_writes,
               stat.total_logical_reads,
               stat.query_hash,
               stat.query_plan_hash,
               stat.plan_generation_num,
               stat.creation_time,
               stat.last_worker_time,
               stat.min_worker_time,
               stat.max_worker_time,
               stat.last_elapsed_time,
               stat.min_elapsed_time,
               stat.max_elapsed_time,
               stat.last_physical_reads,
               stat.min_physical_reads,
               stat.max_physical_reads,
               stat.last_logical_writes,
               stat.min_logical_writes,
               stat.max_logical_writes,
               stat.last_logical_reads,
               stat.min_logical_reads,
               stat.max_logical_reads,
               ROW_NUMBER () OVER (ORDER BY stat.total_worker_time DESC) AS CpuRank,
               ROW_NUMBER () OVER (ORDER BY stat.total_physical_reads DESC) AS PhysicalReadsRank,
               ROW_NUMBER () OVER (ORDER BY stat.total_elapsed_time DESC) AS DurationRank
        FROM sys.dm_exec_query_stats AS stat
    ) AS PlanStats
    INNER JOIN sys.dm_exec_cached_plans AS p
        ON p.plan_handle = PlanStats.plan_handle
    OUTER APPLY sys.dm_exec_plan_attributes (p.plan_handle) AS pa
    OUTER APPLY sys.dm_exec_sql_text (p.plan_handle) AS sql
    WHERE (
        PlanStats.CpuRank < 50
        OR PlanStats.PhysicalReadsRank < 50
        OR PlanStats.DurationRank < 50
    )
          AND pa.attribute = 'dbid'
    ORDER BY tot_cpu_ms DESC;

    SET @rowcount = @@ROWCOUNT;
    SET @queryduration = DATEDIFF (ms, @querystarttime, GETDATE ());
    IF @queryduration > @qrydurationwarnthreshold
    BEGIN
        SELECT @cpu_time = cpu_time - @cpu_time_start
        FROM sys.dm_exec_sessions
        WHERE session_id = @@SPID;
        PRINT '';
        PRINT 'DebugPrint: perfstats_snapshot_querystats - ' + CONVERT (VARCHAR, @queryduration) + 'ms, '
              + CONVERT (VARCHAR, @cpu_time) + 'ms cpu, ' + 'rowcount=' + CONVERT (VARCHAR, @rowcount);
        PRINT '';
    END;

    PRINT '';
    PRINT '===============================================================================================';
    PRINT 'Missing Indexes: ';
    PRINT 'The "improvement_measure" column is an indicator of the (estimated) improvement that might ';
    PRINT 'be seen if the index was created.  This is a unitless number, and has meaning only relative ';
    PRINT 'the same number for other indexes.  The measure is a combination of the avg_total_user_cost, ';
    PRINT 'avg_user_impact, user_seeks, and user_scans columns in sys.dm_db_missing_index_group_stats.';
    PRINT '';
    PRINT '-- Missing Indexes --';
    SELECT CONVERT (VARCHAR(30), @runtime, 126) AS runtime,
           mig.index_group_handle,
           mid.index_handle,
           CONVERT (
               DECIMAL(28, 1), migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans)
           ) AS improvement_measure,
           'CREATE INDEX missing_index_' + CONVERT (VARCHAR, mig.index_group_handle) + '_'
           + CONVERT (VARCHAR, mid.index_handle) + ' ON ' + mid.statement + ' (' + ISNULL (mid.equality_columns, '')
           + CASE
                 WHEN mid.equality_columns IS NOT NULL
                      AND mid.inequality_columns IS NOT NULL THEN ','
                 ELSE ''
             END + ISNULL (mid.inequality_columns, '') + ')' + ISNULL (' INCLUDE (' + mid.included_columns + ')', '') AS create_index_statement,
           migs.*,
           mid.database_id,
           mid.object_id
    FROM sys.dm_db_missing_index_groups AS mig
    INNER JOIN sys.dm_db_missing_index_group_stats AS migs
        ON migs.group_handle = mig.index_group_handle
    INNER JOIN sys.dm_db_missing_index_details AS mid
        ON mig.index_handle = mid.index_handle
    WHERE CONVERT (
              DECIMAL(28, 1), migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans)
          ) > 10
    ORDER BY migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) DESC;
    PRINT '';

    PRINT '';
    PRINT '-- Current database options --';
    SELECT LEFT(name, 128) AS name,
           dbid,
           cmptlevel,
           CONVERT (INT,
           (
               SELECT SUM (CONVERT (BIGINT, size)) * 8192 / 1024 / 1024
               FROM master.dbo.sysaltfiles AS f
               WHERE f.dbid = d.dbid
           )
           ) AS db_size_in_mb,
           LEFT('Status=' + CONVERT (sysname, DATABASEPROPERTYEX (name, 'Status')) + ', Updateability='
                + CONVERT (sysname, DATABASEPROPERTYEX (name, 'Updateability')) + ', UserAccess='
                + CONVERT (VARCHAR(40), DATABASEPROPERTYEX (name, 'UserAccess')) + ', Recovery='
                + CONVERT (VARCHAR(40), DATABASEPROPERTYEX (name, 'Recovery')) + ', Version='
                + CONVERT (VARCHAR(40), DATABASEPROPERTYEX (name, 'Version'))
                + CASE
                      WHEN DATABASEPROPERTYEX (name, 'IsAutoCreateStatistics') = 1 THEN ', IsAutoCreateStatistics'
                      ELSE ''
                  END
                + CASE
                      WHEN DATABASEPROPERTYEX (name, 'IsAutoUpdateStatistics') = 1 THEN ', IsAutoUpdateStatistics'
                      ELSE ''
                  END + CASE
                            WHEN DATABASEPROPERTYEX (name, 'IsShutdown') = 1 THEN ''
                            ELSE ', Collation=' + CONVERT (VARCHAR(40), DATABASEPROPERTYEX (name, 'Collation'))
                        END + CASE
                                  WHEN DATABASEPROPERTYEX (name, 'IsAutoClose') = 1 THEN ', IsAutoClose'
                                  ELSE ''
                              END + CASE
                                        WHEN DATABASEPROPERTYEX (name, 'IsAutoShrink') = 1 THEN ', IsAutoShrink'
                                        ELSE ''
                                    END + CASE
                                              WHEN DATABASEPROPERTYEX (name, 'IsInStandby') = 1 THEN ', IsInStandby'
                                              ELSE ''
                                          END
                + CASE
                      WHEN DATABASEPROPERTYEX (name, 'IsTornPageDetectionEnabled') = 1 THEN
                          ', IsTornPageDetectionEnabled'
                      ELSE ''
                  END + CASE
                            WHEN DATABASEPROPERTYEX (name, 'IsAnsiNullDefault') = 1 THEN ', IsAnsiNullDefault'
                            ELSE ''
                        END + CASE
                                  WHEN DATABASEPROPERTYEX (name, 'IsAnsiNullsEnabled') = 1 THEN ', IsAnsiNullsEnabled'
                                  ELSE ''
                              END
                + CASE
                      WHEN DATABASEPROPERTYEX (name, 'IsAnsiPaddingEnabled') = 1 THEN ', IsAnsiPaddingEnabled'
                      ELSE ''
                  END + CASE
                            WHEN DATABASEPROPERTYEX (name, 'IsAnsiWarningsEnabled') = 1 THEN ', IsAnsiWarningsEnabled'
                            ELSE ''
                        END
                + CASE
                      WHEN DATABASEPROPERTYEX (name, 'IsArithmeticAbortEnabled') = 1 THEN ', IsArithmeticAbortEnabled'
                      ELSE ''
                  END
                + CASE
                      WHEN DATABASEPROPERTYEX (name, 'IsCloseCursorsOnCommitEnabled') = 1 THEN
                          ', IsCloseCursorsOnCommitEnabled'
                      ELSE ''
                  END + CASE
                            WHEN DATABASEPROPERTYEX (name, 'IsFullTextEnabled') = 1 THEN ', IsFullTextEnabled'
                            ELSE ''
                        END
                + CASE
                      WHEN DATABASEPROPERTYEX (name, 'IsLocalCursorsDefault') = 1 THEN ', IsLocalCursorsDefault'
                      ELSE ''
                  END
                + CASE
                      WHEN DATABASEPROPERTYEX (name, 'IsNumericRoundAbortEnabled') = 1 THEN
                          ', IsNumericRoundAbortEnabled'
                      ELSE ''
                  END
                + CASE
                      WHEN DATABASEPROPERTYEX (name, 'IsQuotedIdentifiersEnabled') = 1 THEN
                          ', IsQuotedIdentifiersEnabled'
                      ELSE ''
                  END
                + CASE
                      WHEN DATABASEPROPERTYEX (name, 'IsRecursiveTriggersEnabled') = 1 THEN
                          ', IsRecursiveTriggersEnabled'
                      ELSE ''
                  END + CASE
                            WHEN DATABASEPROPERTYEX (name, 'IsMergePublished') = 1 THEN ', IsMergePublished'
                            ELSE ''
                        END + CASE
                                  WHEN DATABASEPROPERTYEX (name, 'IsPublished') = 1 THEN ', IsPublished'
                                  ELSE ''
                              END + CASE
                                        WHEN DATABASEPROPERTYEX (name, 'IsSubscribed') = 1 THEN ', IsSubscribed'
                                        ELSE ''
                                    END
                + CASE
                      WHEN DATABASEPROPERTYEX (name, 'IsSyncWithBackup') = 1 THEN ', IsSyncWithBackup'
                      ELSE ''
                  END, 512) AS status
    FROM master.dbo.sysdatabases AS d;



    PRINT ' ';

    PRINT '--sys.dm_database_encryption_keys  Transparent Database Encryption (TDE) information';
    SELECT DB_NAME (database_id) AS database_name,
           *
    FROM sys.dm_database_encryption_keys;

    PRINT '';
    PRINT '-- sys.dm_os_loaded_modules --';
    SELECT * FROM sys.dm_os_loaded_modules;
    PRINT '';

    PRINT '';
    PRINT '--sys.dm_server_audit_status';
    SELECT * FROM sys.dm_server_audit_status;

    PRINT '';
    PRINT '--top 10 CPU consuming procedures ';
    SELECT TOP 10
           d.object_id,
           d.database_id,
           DB_NAME (database_id) AS [db name],
           OBJECT_NAME (object_id, database_id) AS [proc name],
           d.cached_time,
           d.last_execution_time,
           d.total_elapsed_time,
           d.total_elapsed_time / d.execution_count AS avg_elapsed_time,
           d.last_elapsed_time,
           d.execution_count
    FROM sys.dm_exec_procedure_stats AS d
    ORDER BY total_worker_time DESC;

    PRINT '';
    PRINT '--top 10 CPU consuming triggers ';
    SELECT TOP 10
           d.object_id,
           d.database_id,
           DB_NAME (database_id) AS [db name],
           OBJECT_NAME (object_id, database_id) AS [proc name],
           d.cached_time,
           d.last_execution_time,
           d.total_elapsed_time,
           d.total_elapsed_time / d.execution_count AS avg_elapsed_time,
           d.last_elapsed_time,
           d.execution_count
    FROM sys.dm_exec_trigger_stats AS d
    ORDER BY total_worker_time DESC;
    PRINT '';

    --new stats DMV
    SET NOCOUNT ON;
    DECLARE @dbname sysname,
            @dbid   INT;
    DECLARE dbCursor CURSOR FOR
        SELECT name,
               database_id
        FROM sys.databases
        WHERE state_desc = 'ONLINE'
              AND database_id > 4
        ORDER BY name;
    OPEN dbCursor;

    FETCH NEXT FROM dbCursor
    INTO @dbname,
         @dbid;
    SELECT @dbid AS Database_Id,
           @dbname AS Database_Name,
           OBJECT_NAME (st.object_id) AS Object_Name,
           st.*
    INTO #tmpStats
    FROM sys.dm_db_index_usage_stats AS usg
    CROSS APPLY sys.dm_db_stats_properties (usg.object_id, index_id) AS st
    WHERE Database_Id IS NULL;
    WHILE @@FETCH_STATUS = 0
    BEGIN

        DECLARE @sql NVARCHAR(512);
        SET @sql = N'USE [' + @dbname + N']';

        SET @sql
            = @sql + N'	insert into #tmpStats	select '    + CAST(@dbid AS NVARCHAR(20)) + N' ''Database_Id'''
              + N',''' + @dbname
              + N''' Database_Name,  Object_name(st.object_id) ''Object_Name'',  st.* from sys.dm_db_index_usage_stats usg cross apply sys.dm_db_stats_properties (usg.object_id, index_id) st where database_id  = '
              + CAST(@dbid AS NVARCHAR(20));

        EXEC (@sql);
        --print @sql
        FETCH NEXT FROM dbCursor
        INTO @dbname,
             @dbid;

    END;
    CLOSE dbCursor;
    DEALLOCATE dbCursor;
    PRINT '';
    PRINT '--sys.dm_db_stats_properties--';
    SELECT * FROM #tmpStats ORDER BY Database_Name;
    DROP TABLE #tmpStats;
    PRINT '';


    --disable indexes

    SET NOCOUNT ON;
    DECLARE @dbname_index sysname,
            @dbid_index   INT;
    DECLARE dbCursor_Index CURSOR FOR
        SELECT name,
               database_id
        FROM sys.databases
        WHERE state_desc = 'ONLINE'
              AND database_id > 4
        ORDER BY name;
    OPEN dbCursor_Index;

    FETCH NEXT FROM dbCursor_Index
    INTO @dbname_index,
         @dbid_index;
    SELECT DB_ID () AS database_id,
           DB_NAME () AS database_name,
           OBJECT_NAME (object_id) AS object_name,
           *
    INTO #tblDisabledIndex
    FROM sys.indexes
    WHERE is_disabled = 1
          AND 1 = 0;

    WHILE @@FETCH_STATUS = 0
    BEGIN

        DECLARE @sql_index NVARCHAR(512);
        SET @sql_index = N'USE ' + @dbname_index;

        SET @sql_index
            = @sql_index
              + N'	insert into #tblDisabledIndex	select  db_id()  database_id, db_name() database_name, object_name(object_id) object_name, *  from sys.indexes where is_disabled = 1'  ;

        EXEC (@sql_index);
        --print @sql
        FETCH NEXT FROM dbCursor_Index
        INTO @dbname_index,
             @dbid_index;

    END;
    CLOSE dbCursor_Index;
    DEALLOCATE dbCursor_Index;
    PRINT '';
    PRINT '--disabled indexes--';
    SELECT * FROM #tblDisabledIndex ORDER BY database_name;
    DROP TABLE #tblDisabledIndex;
    PRINT '';



    /*
	this takes too long for large machines
		PRINT '-- High Compile Queries --';
	 WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS sp)  
	 select   
	 stmt.stmt_details.value ('(./sp:QueryPlan/@CompileTime)[1]', 'int') 'CompileTime',
	 stmt.stmt_details.value ('(./sp:QueryPlan/@CompileCPU)[1]', 'int') 'CompileCPU',
	 SUBSTRING(replace(replace(stmt.stmt_details.value ('@StatementText', 'nvarchar(max)'), char(13), ' '), char(10), ' '), 1, 8000) 'Statement'
	  from (   SELECT  query_plan as sqlplan FROM sys.dm_exec_cached_plans AS qs CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle))
	   as p       cross apply sqlplan.nodes('//sp:StmtSimple') as stmt (stmt_details)
	 order by 1 desc;
	 */
    RAISERROR ('', 0, 1) WITH NOWAIT;

END;

GO


IF OBJECT_ID ('sp_perf_stats_snapshot9', 'P') IS NOT NULL
    DROP PROCEDURE sp_perf_stats_snapshot9;
GO

CREATE PROCEDURE sp_perf_stats_snapshot9
AS
BEGIN
    EXEC sp_perf_stats_snapshot;
END;

GO

IF OBJECT_ID ('sp_perf_stats_snapshot10', 'P') IS NOT NULL
    DROP PROCEDURE sp_perf_stats_snapshot10;
GO

CREATE PROCEDURE sp_perf_stats_snapshot10
AS
BEGIN
    EXEC sp_perf_stats_snapshot9;

    PRINT 'getting resource governor info';
    PRINT '==========================================';

    PRINT 'sys.resource_governor_configuration';
    SELECT * FROM sys.resource_governor_configuration;

    PRINT 'sys.resource_governor_resource_pools';
    SELECT * FROM sys.resource_governor_resource_pools;

    PRINT 'sys.resource_governor_workload_groups';
    SELECT * FROM sys.resource_governor_workload_groups;

    PRINT '-- query and plan hash capture --';
    PRINT '-- query and plan hash capture --';
    PRINT '-- top 10 CPU by query_hash --';
    SELECT GETDATE () AS runtime,
           * --into tbl_QueryHashByCPU
    FROM (
        SELECT TOP 10
               query_hash,
               COUNT (DISTINCT query_plan_hash) AS [distinct query_plan_hash count],
               SUM (execution_count) AS execution_count,
               SUM (total_worker_time) AS total_worker_time,
               SUM (total_elapsed_time) AS total_elapsed_time,
               SUM (total_logical_reads) AS total_logical_reads,
               MAX (
                   REPLACE (
                       REPLACE (
                           SUBSTRING (
                               st.text,
                               qs.statement_start_offset / 2 + 1,
                               CASE
                                   WHEN qs.statement_end_offset = -1 THEN LEN (CONVERT (NVARCHAR(MAX), st.text))
                                   ELSE qs.statement_end_offset / 2 - qs.statement_start_offset / 2 + 1
                               END
                           ),
                           CHAR (13),
                           ' '
                       ),
                       CHAR (10),
                       ' '
                   )
               ) AS sample_statement_text
        FROM sys.dm_exec_query_stats AS qs
        CROSS APPLY sys.dm_exec_sql_text (qs.sql_handle) AS st
        GROUP BY query_hash
        ORDER BY SUM (total_worker_time) DESC
    ) AS t;




    PRINT '-- top 10 logical reads by query_hash --';
    SELECT GETDATE () AS runtime,
           * --into tbl_QueryHashByLogicalReads
    FROM (
        SELECT TOP 10
               query_hash,
               COUNT (DISTINCT query_plan_hash) AS [distinct query_plan_hash count],
               SUM (execution_count) AS execution_count,
               SUM (total_worker_time) AS total_worker_time,
               SUM (total_elapsed_time) AS total_elapsed_time,
               SUM (total_logical_reads) AS total_logical_reads,
               MAX (
                   REPLACE (
                       REPLACE (
                           SUBSTRING (
                               st.text,
                               qs.statement_start_offset / 2 + 1,
                               CASE
                                   WHEN qs.statement_end_offset = -1 THEN LEN (CONVERT (NVARCHAR(MAX), st.text))
                                   ELSE qs.statement_end_offset / 2 - qs.statement_start_offset / 2 + 1
                               END
                           ),
                           CHAR (13),
                           ' '
                       ),
                       CHAR (10),
                       ' '
                   )
               ) AS sample_statement_text
        FROM sys.dm_exec_query_stats AS qs
        CROSS APPLY sys.dm_exec_sql_text (qs.sql_handle) AS st
        GROUP BY query_hash
        ORDER BY SUM (total_logical_reads) DESC
    ) AS t;


    PRINT '-- top 10 elapsed time by query_hash --';
    SELECT GETDATE () AS runtime,
           * -- into tbl_QueryHashByElapsedTime
    FROM (
        SELECT TOP 10
               query_hash,
               SUM (execution_count) AS execution_count,
               COUNT (DISTINCT query_plan_hash) AS [distinct query_plan_hash count],
               SUM (total_worker_time) AS total_worker_time,
               SUM (total_elapsed_time) AS total_elapsed_time,
               SUM (total_logical_reads) AS total_logical_reads,
               MAX (
                   REPLACE (
                       REPLACE (
                           SUBSTRING (
                               st.text,
                               qs.statement_start_offset / 2 + 1,
                               CASE
                                   WHEN qs.statement_end_offset = -1 THEN LEN (CONVERT (NVARCHAR(MAX), st.text))
                                   ELSE qs.statement_end_offset / 2 - qs.statement_start_offset / 2 + 1
                               END
                           ),
                           CHAR (13),
                           ' '
                       ),
                       CHAR (10),
                       ' '
                   )
               ) AS sample_statement_text
        FROM sys.dm_exec_query_stats AS qs
        CROSS APPLY sys.dm_exec_sql_text (qs.sql_handle) AS st
        GROUP BY query_hash
        ORDER BY SUM (total_elapsed_time) DESC
    ) AS t;



    PRINT '-- top 10 CPU by query_plan_hash and query_hash --';
    SELECT TOP 10
           query_plan_hash,
           query_hash,
           COUNT (DISTINCT query_plan_hash) AS [distinct query_plan_hash count],
           SUM (execution_count) AS execution_count,
           SUM (total_worker_time) AS total_worker_time,
           SUM (total_elapsed_time) AS total_elapsed_time,
           SUM (total_logical_reads) AS total_logical_reads,
           MAX (
               REPLACE (
                   REPLACE (
                       SUBSTRING (
                           st.text,
                           qs.statement_start_offset / 2 + 1,
                           CASE
                               WHEN qs.statement_end_offset = -1 THEN LEN (CONVERT (NVARCHAR(MAX), st.text))
                               ELSE qs.statement_end_offset / 2 - qs.statement_start_offset / 2 + 1
                           END
                       ),
                       CHAR (13),
                       ' '
                   ),
                   CHAR (10),
                   ' '
               )
           ) AS sample_statement_text
    FROM sys.dm_exec_query_stats AS qs
    CROSS APPLY sys.dm_exec_sql_text (qs.sql_handle) AS st
    GROUP BY query_plan_hash,
             query_hash
    ORDER BY SUM (total_worker_time) DESC;




    PRINT '-- top 10 logical reads by query_plan_hash and query_hash --';
    SELECT TOP 10
           query_plan_hash,
           query_hash,
           SUM (execution_count) AS execution_count,
           SUM (total_worker_time) AS total_worker_time,
           SUM (total_elapsed_time) AS total_elapsed_time,
           SUM (total_logical_reads) AS total_logical_reads,
           MAX (
               REPLACE (
                   REPLACE (
                       SUBSTRING (
                           st.text,
                           qs.statement_start_offset / 2 + 1,
                           CASE
                               WHEN qs.statement_end_offset = -1 THEN LEN (CONVERT (NVARCHAR(MAX), st.text))
                               ELSE qs.statement_end_offset / 2 - qs.statement_start_offset / 2 + 1
                           END
                       ),
                       CHAR (13),
                       ' '
                   ),
                   CHAR (10),
                   ' '
               )
           ) AS sample_statement_text
    FROM sys.dm_exec_query_stats AS qs
    CROSS APPLY sys.dm_exec_sql_text (qs.sql_handle) AS st
    GROUP BY query_plan_hash,
             query_hash
    ORDER BY SUM (total_logical_reads) DESC;




    PRINT '-- top 10 elapsed time  by query_plan_hash and query_hash --';
    SELECT TOP 10
           query_plan_hash,
           query_hash,
           SUM (execution_count) AS execution_count,
           SUM (total_worker_time) AS total_worker_time,
           SUM (total_elapsed_time) AS total_elapsed_time,
           SUM (total_logical_reads) AS total_logical_reads,
           MAX (
               REPLACE (
                   REPLACE (
                       SUBSTRING (
                           st.text,
                           qs.statement_start_offset / 2 + 1,
                           CASE
                               WHEN qs.statement_end_offset = -1 THEN LEN (CONVERT (NVARCHAR(MAX), st.text))
                               ELSE qs.statement_end_offset / 2 - qs.statement_start_offset / 2 + 1
                           END
                       ),
                       CHAR (13),
                       ' '
                   ),
                   CHAR (10),
                   ' '
               )
           ) AS sample_statement_text
    FROM sys.dm_exec_query_stats AS qs
    CROSS APPLY sys.dm_exec_sql_text (qs.sql_handle) AS st
    GROUP BY query_plan_hash,
             query_hash
    ORDER BY SUM (total_elapsed_time) DESC;



    PRINT '';
    RAISERROR ('-- new row modification counter --', 0, 1) WITH NOWAIT;
    --this only is available after SQL 2008 R2 SP2 and SQL 2012 SP1 and SQL 2014
    IF (@@MICROSOFTVERSION >= 171052960 AND @@MICROSOFTVERSION < 184551476)
       OR (@@MICROSOFTVERSION >= 184551476)
    BEGIN

        EXEC master..sp_MSforeachdb @command1 = '
		PRINT ''''
		PRINT ''-- sys.dm_db_stats_properties for database name [?]  database id: '' + cast (db_id (''?'') as varchar(20))  + '' --''',
                                    @command2 = '
		use [?]
		SELECT db_name() ''database_name'', 
		object_name (stat.object_id) ''Object_Name'', stat.object_id,
			sp.stats_id, name, filter_definition, cast(last_updated as datetime) ''last_updated'', rows, rows_sampled, steps, unfiltered_rows, modification_counter 
		FROM sys.stats AS stat 
		CROSS APPLY sys.dm_db_stats_properties(stat.object_id, stat.stats_id) AS sp
		';

    END;

END;



GO

IF OBJECT_ID ('sp_perf_stats_snapshot11', 'P') IS NOT NULL
    DROP PROCEDURE sp_perf_stats_snapshot11;
GO

CREATE PROCEDURE sp_perf_stats_snapshot11
AS
BEGIN
    EXEC sp_perf_stats_snapshot10;

    PRINT '--hadron replica info--';
    SELECT ag.name AS ag_name,
           ar.replica_server_name,
           ar_state.is_local AS is_ag_replica_local,
           CASE
               WHEN ar_state.role_desc IS NULL THEN N'<unknown>'
               ELSE ar_state.role_desc
           END AS ag_replica_role_desc,
           CASE
               WHEN ar_state.operational_state_desc IS NULL THEN N'<unknown>'
               ELSE ar_state.operational_state_desc
           END AS ag_replica_operational_state_desc,
           CASE
               WHEN ar_state.connected_state_desc IS NULL THEN
                   CASE WHEN ar_state.is_local = 1 THEN N'CONNECTED' ELSE N'<unknown>' END
               ELSE ar_state.connected_state_desc
           END AS ag_replica_connected_state_desc
    FROM sys.availability_groups AS ag
    JOIN sys.availability_replicas AS ar
        ON ag.group_id = ar.group_id
    JOIN sys.dm_hadr_availability_replica_states AS ar_state
        ON ar.replica_id = ar_state.replica_id;


    PRINT '-- sys.availability_groups --';
    SELECT * FROM sys.availability_groups;


    PRINT '-- sys.dm_hadr_cluster --';
    SELECT * FROM sys.dm_hadr_cluster;


    PRINT '-- sys.dm_hadr_cluster_members --';
    SELECT * FROM sys.dm_hadr_cluster_members;


    PRINT '-- sys.dm_hadr_cluster_networks --';
    SELECT * FROM sys.dm_hadr_cluster_networks;

    PRINT '-- sys.availability_replicas --';
    SELECT * FROM sys.availability_replicas;

END;
GO



IF OBJECT_ID ('sp_perf_stats_snapshot12', 'P') IS NOT NULL
    DROP PROCEDURE sp_perf_stats_snapshot12;
GO

CREATE PROCEDURE sp_perf_stats_snapshot12
AS
BEGIN
    EXEC sp_perf_stats_snapshot11;
END;
GO

IF OBJECT_ID ('sp_perf_stats_snapshot13', 'P') IS NOT NULL
    DROP PROCEDURE sp_perf_stats_snapshot13;
GO

CREATE PROCEDURE sp_perf_stats_snapshot13
AS
BEGIN
    EXEC sp_perf_stats_snapshot12;
END;


GO

IF OBJECT_ID ('sp_perf_stats_snapshot14', 'P') IS NOT NULL
    DROP PROCEDURE sp_perf_stats_snapshot14;
GO

CREATE PROCEDURE sp_perf_stats_snapshot14
AS
BEGIN
    EXEC sp_perf_stats_snapshot13;
END;

GO

IF OBJECT_ID ('sp_perf_stats_snapshot15', 'P') IS NOT NULL
    DROP PROCEDURE sp_perf_stats_snapshot15;
GO

CREATE PROCEDURE sp_perf_stats_snapshot15
AS
BEGIN
    EXEC sp_perf_stats_snapshot14;
END;

GO

/*****************************************************************
*                   main loop   perf statssnapshot               *
******************************************************************/


IF OBJECT_ID ('sp_Run_PerfStats_Snapshot', 'P') IS NOT NULL
    DROP PROCEDURE sp_Run_PerfStats_Snapshot;
GO
CREATE PROCEDURE sp_Run_PerfStats_Snapshot @IsLite BIT = 0
AS
    DECLARE @servermajorversion NVARCHAR(2);
    SET @servermajorversion = REPLACE (LEFT(CONVERT (VARCHAR, SERVERPROPERTY ('ProductVersion')), 2), '.', '');
    DECLARE @sp_perf_stats_snapshot_ver sysname;
    SET @sp_perf_stats_snapshot_ver = 'sp_perf_stats_snapshot' + @servermajorversion;
    PRINT 'executing procedure ' + @sp_perf_stats_snapshot_ver;
    EXEC @sp_perf_stats_snapshot_ver;

GO


EXEC sp_Run_PerfStats_Snapshot;