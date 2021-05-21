
/* ----------------------------------------------------------------------------
 – To count the amount of data files in tempdb
---------------------------------------------------------------------------- */
SELECT file_id,
       name,
       physical_name
FROM tempdb.sys.database_files
WHERE type = 0; -- data files
GO


SELECT GETDATE() AS runtime,
       SUM(user_object_reserved_page_count) * 8 AS usr_obj_kb,
       SUM(internal_object_reserved_page_count) * 8 AS internal_obj_kb,
       SUM(version_store_reserved_page_count) * 8 AS version_store_kb,
       SUM(unallocated_extent_page_count) * 8 AS freespace_kb,
       SUM(mixed_extent_page_count) * 8 AS mixedextent_kb
FROM sys.dm_db_file_space_usage;
GO


SELECT name AS [Logical Name],
       size / 128.0 AS [Total Size in MB],
       size / 128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT) / 128.0 AS [Available Space in MB]
FROM sys.database_files;
GO


/* ----------------------------------------------------------------------------
 – If you need to remove some of the data files in tempdb
---------------------------------------------------------------------------- */
DBCC SHRINKFILE(tempdev2, EMPTYFILE);
GO
ALTER DATABASE tempdb REMOVE FILE tempdev2;
GO


SELECT name AS FileName,
       size * 1.0 / 128 AS FileSizeinMB,
       CASE max_size
           WHEN 0 THEN 'Autogrowth is off.'
           WHEN -1 THEN 'Autogrowth is on.'
           ELSE 'Log file will grow to a maximum size of 2 TB.'
       END,
       growth AS GrowthValue,
       CASE
           WHEN growth = 0 THEN 'Size is fixed and will not grow.'
           WHEN growth > 0
                AND is_percent_growth = 0 THEN 'Growth value is in 8-KB pages.'
           ELSE 'Growth value is a percentage.'
       END AS GrowthIncrement
FROM tempdb.sys.database_files;
GO


/* ----------------------------------------------------------------------------
 – An overview of tempdb utilization
---------------------------------------------------------------------------- */
SELECT mf.physical_name,
       mf.size AS entire_file_page_count,
       dfsu.version_store_reserved_page_count,
       dfsu.unallocated_extent_page_count,
       dfsu.user_object_reserved_page_count,
       dfsu.internal_object_reserved_page_count,
       dfsu.mixed_extent_page_count
FROM sys.dm_db_file_space_usage AS dfsu
JOIN sys.master_files AS mf
    ON mf.database_id = dfsu.database_id
       AND mf.file_id = dfsu.file_id;
GO


/* ----------------------------------------------------------------------------
 – An overview of tempdb utilization
   Modified from 
   http://blogs.msdn.com/sqlserverstorageengine/archive/2009/01/12/tempdb-monitoring-and-troubleshooting-out-of-space.aspx
   https://dba.stackexchange.com/questions/19870/how-to-identify-which-query-is-filling-up-the-tempdb-transaction-log
---------------------------------------------------------------------------- */
SELECT t1.session_id,
       t1.request_id,
       CAST(t1.task_alloc_pages * 8. / 1024. / 1024. AS NUMERIC(10, 1)) AS task_alloc_GB,
       CAST(t1.task_dealloc_pages * 8. / 1024. / 1024. AS NUMERIC(10, 1)) AS task_dealloc_GB,
       CASE
           WHEN t1.session_id <= 50 THEN 'SYS'
           ELSE s1.host_name
       END AS host,
       s1.login_name,
       s1.status,
       s1.last_request_start_time,
       s1.last_request_end_time,
       s1.row_count,
       s1.transaction_isolation_level,
       COALESCE((
           SELECT SUBSTRING(text,
                            t2.statement_start_offset / 2 + 1,
                            (CASE
                                 WHEN statement_end_offset = -1 THEN
                                     LEN(CONVERT(NVARCHAR(MAX), text)) * 2
                                 ELSE
                                     statement_end_offset
                             END - t2.statement_start_offset
                            ) / 2
                  )
           FROM sys.dm_exec_sql_text(t2.sql_handle)
       ),
                'Not currently executing'
       ) AS query_text,
       (
           SELECT query_plan FROM sys.dm_exec_query_plan(t2.plan_handle)
       ) AS query_plan
FROM (
    SELECT session_id,
           request_id,
           SUM(internal_objects_alloc_page_count + user_objects_alloc_page_count) AS task_alloc_pages,
           SUM(internal_objects_dealloc_page_count + user_objects_dealloc_page_count) AS task_dealloc_pages
    FROM sys.dm_db_task_space_usage
    GROUP BY session_id,
             request_id
) AS t1
LEFT JOIN sys.dm_exec_requests AS t2
    ON t1.session_id = t2.session_id
       AND t1.request_id = t2.request_id
LEFT JOIN sys.dm_exec_sessions AS s1
    ON t1.session_id = s1.session_id
WHERE t1.session_id > 50 -- ignore system unless you suspect there's a problem there
      AND t1.session_id <> @@SPID -- ignore this request itself
ORDER BY t1.task_alloc_pages DESC;
GO


/* ----------------------------------------------------------------------------
 – Determining the Amount of Free Space in tempdb
---------------------------------------------------------------------------- */
SELECT SUM(unallocated_extent_page_count) AS [free pages],
       (SUM(unallocated_extent_page_count) * 1.0 / 128) AS [free space in MB]
FROM sys.dm_db_file_space_usage;
GO


/* ----------------------------------------------------------------------------
 – Determining the Amount Space Used by the Version Store
---------------------------------------------------------------------------- */
SELECT SUM(version_store_reserved_page_count) AS [version store pages used],
       (SUM(version_store_reserved_page_count) * 1.0 / 128) AS [version store space in MB]
FROM sys.dm_db_file_space_usage;
GO

SELECT SUM(dfsu.version_store_reserved_page_count) AS version_store_reserved_page_count,
	   SUM(mf.size) AS entire_page_count
FROM sys.dm_db_file_space_usage AS dfsu
JOIN sys.master_files AS mf
    ON mf.database_id = dfsu.database_id
       AND mf.file_id = dfsu.file_id;
GO

-- Get tempdb version store space usage by database
select DB_NAME(database_id) as [Database Name], 
	   reserved_page_count as [Version Store Reserved Page Count], 
	   reserved_space_kb / 1024 as [Version Store Reserved Space (MB)]
from sys.dm_tran_version_store_space_usage with(nolock)
order by reserved_space_kb / 1024 desc option(recompile);
go


/* ----------------------------------------------------------------------------
 – Determining the Longest Running Transaction
---------------------------------------------------------------------------- */
SELECT transaction_id
FROM sys.dm_tran_active_snapshot_database_transactions
ORDER BY elapsed_time_seconds DESC;
GO


/* ----------------------------------------------------------------------------
 – Determining the Amount of Space Used by Internal Objects
---------------------------------------------------------------------------- */
SELECT SUM(internal_object_reserved_page_count) AS [internal object pages used],
       (SUM(internal_object_reserved_page_count) * 1.0 / 128) AS [internal object space in MB]
FROM sys.dm_db_file_space_usage;
GO


/* ----------------------------------------------------------------------------
 – Determining the Amount of Space Used by User Objects
---------------------------------------------------------------------------- */
SELECT SUM(user_object_reserved_page_count) AS [user object pages used],
       (SUM(user_object_reserved_page_count) * 1.0 / 128) AS [user object space in MB]
FROM sys.dm_db_file_space_usage;
GO


/* ----------------------------------------------------------------------------
 – Determining the Total Amount of Space (Free and Used)
---------------------------------------------------------------------------- */
SELECT SUM(size) * 1.0 / 128 AS [size in MB]
FROM tempdb.sys.database_files;
GO


/* ----------------------------------------------------------------------------
 – run [DBCC INPUTBUFFER] (https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2008-r2/ms187730(v=sql.105)) once every three minutes for all the 
   sessions
---------------------------------------------------------------------------- */
DECLARE @max INT;
DECLARE @i INT;

SELECT @max = MAX(session_id)
FROM sys.dm_exec_sessions;

SET @i = 51;
WHILE @i <= @max
BEGIN
    IF EXISTS (
        SELECT session_id
        FROM sys.dm_exec_sessions
        WHERE session_id = @i
    )
        DBCC INPUTBUFFER(@i);

    SET @i = @i + 1;
END;
GO


/* ----------------------------------------------------------------------------
 – Returns the total space used by internal objects in all currently running 
   tasks in tempdb
---------------------------------------------------------------------------- */
CREATE VIEW dbo.all_task_usage
AS
SELECT session_id,
       SUM(internal_objects_alloc_page_count) AS task_internal_objects_alloc_page_count,
       SUM(internal_objects_dealloc_page_count) AS task_internal_objects_dealloc_page_count
FROM sys.dm_db_task_space_usage
GROUP BY session_id;
GO

/* ----------------------------------------------------------------------------
 – Returns the space used by all internal objects running and completed 
   tasks in tempdb
---------------------------------------------------------------------------- */
CREATE VIEW dbo.all_session_usage
AS
SELECT R1.session_id,
       R1.internal_objects_alloc_page_count + R2.task_internal_objects_alloc_page_count AS session_internal_objects_alloc_page_count,
       R1.internal_objects_dealloc_page_count + R2.task_internal_objects_dealloc_page_count AS session_internal_objects_dealloc_page_count
FROM sys.dm_db_session_space_usage AS R1
INNER JOIN all_task_usage AS R2
    ON R1.session_id = R2.session_id;
GO


CREATE VIEW dbo.all_request_usage
AS
SELECT session_id,
       request_id,
       SUM(internal_objects_alloc_page_count) AS request_internal_objects_alloc_page_count,
       SUM(internal_objects_dealloc_page_count) AS request_internal_objects_dealloc_page_count
FROM sys.dm_db_task_space_usage
GROUP BY session_id,
         request_id;
GO


CREATE VIEW dbo.all_query_usage
AS
SELECT R1.session_id,
       R1.request_id,
       R1.request_internal_objects_alloc_page_count,
       R1.request_internal_objects_dealloc_page_count,
       R2.sql_handle,
       R2.statement_start_offset,
       R2.statement_end_offset,
       R2.plan_handle
FROM all_request_usage AS R1
INNER JOIN sys.dm_exec_requests AS R2
    ON R1.session_id = R2.session_id
       AND R1.request_id = R2.request_id;
GO


-- Obtain the query text
SELECT R1.sql_handle,
       R2.text
FROM dbo.all_query_usage AS R1
OUTER APPLY sys.dm_exec_sql_text(R1.sql_handle) AS R2;
GO


-- Save the plan handle and XML plan
SELECT R1.plan_handle,
       R2.query_plan
FROM dbo.all_query_usage AS R1
OUTER APPLY sys.dm_exec_query_plan(R1.plan_handle) AS R2;
GO


/* ----------------------------------------------------------------------------
 – Stress tempdb database

   ostress.exe -E -d"tempdb" -Q"exec dbo.tempdbstress" -n5 -r300 -b -q -Uostress -Postress
---------------------------------------------------------------------------- */
USE tempdb;
GO
CREATE PROCEDURE dbo.tempdbstress
AS
BEGIN
	SET NOCOUNT ON;
	SELECT TOP (5000)
	       a.name,
	       REPLICATE(a.status, 4000) AS col2
	INTO #t1
	FROM master..spt_values AS a
	CROSS JOIN master..spt_values AS b
	OPTION (MAXDOP 1);
END
GO


/* ----------------------------------------------------------------------------
 – Finding GAM and PFS contention in tempdb with sp_BlitzFirst and Wait Stats
---------------------------------------------------------------------------- */
USE DBA
GO
EXEC dbo.sp_BlitzFirst @ExpertMode = 1, @Seconds = 10;
GO


/* ----------------------------------------------------------------------------
 – Finding GAM and PFS contention in tempdb with sp_whoisactive
---------------------------------------------------------------------------- */
EXEC dbo.sp_WhoIsActive;
GO


/* ----------------------------------------------------------------------------
 – Moving TempDB to its own drive (restart SQL Server service afterwards)
---------------------------------------------------------------------------- */
USE master;
GO
ALTER DATABASE tempdb
MODIFY FILE (
    NAME = 'tempdev',
    FILENAME = 'T:\tempdb\tempdb.MDF',
    SIZE = 1MB
);
GO
ALTER DATABASE tempdb
MODIFY FILE (
    NAME = 'templog',
    FILENAME = 'L:\MSSQL\LOGS\templog.LDF',
    SIZE = 1MB
);
GO


/* ----------------------------------------------------------------------------
 – Create one additional TempDB data file
---------------------------------------------------------------------------- */
USE master;
GO
ALTER DATABASE tempdb
ADD FILE (
    NAME = N'tempdev2',
    FILENAME = N'T:\tempdb\tempdev2.ndf',
    SIZE = 10GB,
    FILEGROWTH = 0
);
GO


/* ----------------------------------------------------------------------------
 – Snippet is nuts and bolts for creating/moving to an isolated tempdb drive.
   After you run this, SQL Server must be restarted for it to take effect
---------------------------------------------------------------------------- */
DECLARE @DriveSizeGB INT          = 40,
        @FileCount   INT          = 9,
        @RowID       INT,
        @FileSize    VARCHAR(10),
        @DrivePath   VARCHAR(100) = 'T:\tempdb\';

/* Converts GB to MB */
SELECT @DriveSizeGB = @DriveSizeGB * 1024;

/* Splits size by @FileCount files */
SELECT @FileSize = @DriveSizeGB / @FileCount;

/* 
Table to house requisite SQL statements that will modify the files to the 
standardized name, and size 
*/
DECLARE @Command TABLE
(
    RowID INT IDENTITY(1, 1),
    Command NVARCHAR(MAX)
);
INSERT INTO @Command (Command)
SELECT 'ALTER DATABASE tempdb MODIFY FILE (NAME = [' + f.name + '],' + ' FILENAME = ''' + @DrivePath + f.name
       + CASE
             WHEN f.type = 1 THEN '.ldf'
             ELSE '.mdf'
         END + ''', SIZE = ' + @FileSize + ');'
FROM sys.master_files AS f
WHERE f.database_id = DB_ID(N'tempdb ');
SET @RowID = @@ROWCOUNT;

/* 
If there are less files than indicated in @FileCount, add missing lines 
as ADD FILE commands 
*/
WHILE @RowID < @FileCount
BEGIN
    INSERT INTO @Command (Command)
    SELECT 'ALTER DATABASE tempdb ADD FILE (NAME = [temp' + CAST(@RowID AS VARCHAR) + '],' + ' FILENAME = '''
           + @DrivePath + 'temp' + CAST(@RowID AS VARCHAR) + '.mdf''' + ', SIZE=' + @FileSize + ');';
    SET @RowID = @RowID + 1;
END;

/* Execute each line to process */
WHILE @RowID > 0
BEGIN
    DECLARE @WorkingSQL NVARCHAR(MAX);

    SELECT @WorkingSQL = Command
    FROM @Command
    WHERE RowID = @RowID;

    EXEC (@WorkingSQL);
    SET @RowID = @RowID - 1;
END;
GO


/* ----------------------------------------------------------------------------
 – If Size of Log file is greator than 200GB, then try to truncate it
---------------------------------------------------------------------------- */
USE tempdb;
WHILE EXISTS (
          SELECT mf.name,
                 mf.physical_name,
                 mf.size * 8.0 / 1024 / 1024 AS size_gb
          FROM sys.master_files AS mf
          WHERE mf.database_id = DB_ID('tempdb')
                AND mf.type_desc = 'LOG'
                AND mf.size * 8.0 / 1024 / 1024 > 200.0
      )
BEGIN
    DBCC SHRINKFILE(N'templog', 0, TRUNCATEONLY);
    WAITFOR DELAY '00:05';
END;
GO


/* ----------------------------------------------------------------------------
 – Currently executing tasks and tempdb space usage
---------------------------------------------------------------------------- */
SELECT TOP (10)
       t1.session_id,
       t1.request_id,
       t1.task_alloc,
       t1.task_dealloc,
       (
           SELECT SUBSTRING(text,
                            t2.statement_start_offset / 2 + 1,
                            (CASE
                                 WHEN statement_end_offset = -1 THEN
                                     LEN(CONVERT(NVARCHAR(MAX), text)) * 2
                                 ELSE
                                     statement_end_offset
                             END - t2.statement_start_offset
                            ) / 2
                  )
           FROM sys.dm_exec_sql_text(sql_handle)
       ) AS query_text,
       (
           SELECT query_plan FROM sys.dm_exec_query_plan(t2.plan_handle)
       ) AS query_plan
FROM (
    SELECT session_id,
           request_id,
           SUM(internal_objects_alloc_page_count) AS task_alloc,
           SUM(internal_objects_dealloc_page_count) AS task_dealloc
    FROM sys.dm_db_task_space_usage
    GROUP BY session_id,
             request_id
) AS t1 ,
     sys.dm_exec_requests AS t2
WHERE t1.session_id = t2.session_id
      AND t1.request_id = t2.request_id
      AND t1.session_id > 50
ORDER BY t1.task_alloc DESC;
GO


/* ----------------------------------------------------------------------------
 – Peek into the allocation and deallocation of page process in tempdb
   dbcc traceon(1106, -1)
---------------------------------------------------------------------------- */
DECLARE @ts_now BIGINT;
SELECT @ts_now = cpu_ticks / (cpu_ticks / ms_ticks)
FROM sys.dm_os_sys_info;

SELECT ring_buffer_record.record_id,
       DATEADD(ms, -1 * (@ts_now - ring_buffer_record.timestamp), GETDATE()) AS EventTime,
       CASE
           WHEN ring_buffer_record.event = 0 THEN
               'Allocation Cache Init'
           WHEN ring_buffer_record.event = 1 THEN
               'Allocation Cache Add Entry'
           WHEN ring_buffer_record.event = 2 THEN
               'Allocation Cache RMV Entry'
           WHEN ring_buffer_record.event = 3 THEN
               'Allocation Cache ReInit'
           WHEN ring_buffer_record.event = 4 THEN
               'Allocation Cache Free'
           WHEN ring_buffer_record.event = 5 THEN
               'Truncate Allocation Unit'
           WHEN ring_buffer_record.event = 10 THEN
               'PFS Alloc Page'
           WHEN ring_buffer_record.event = 11 THEN
               'PFS Dealloc Page'
           WHEN ring_buffer_record.event = 20 THEN
               'IAM Set Bit'
           WHEN ring_buffer_record.event = 21 THEN
               'IAM Clear Bit'
           WHEN ring_buffer_record.event = 22 THEN
               'GAM Set Bit'
           WHEN ring_buffer_record.event = 23 THEN
               'GAM Clear Bit'
           WHEN ring_buffer_record.event = 24 THEN
               'SGAM Set Bit'
           WHEN ring_buffer_record.event = 25 THEN
               'SGAM Clear Bit'
           WHEN ring_buffer_record.event = 26 THEN
               'SGAM Set Bit NX'
           WHEN ring_buffer_record.event = 27 THEN
               'SGAM Clear Bit NX'
           WHEN ring_buffer_record.event = 28 THEN
               'GAM_ZAP_EXENT'
           WHEN ring_buffer_record.event = 40 THEN
               'FORMAT_IAM_PAGE'
           WHEN ring_buffer_record.event = 41 THEN
               'FORMAT_PAGE'
           WHEN ring_buffer_record.event = 42 THEN
               'REASSIGN IAM PAGE'
           WHEN ring_buffer_record.event = 50 THEN
               'Worktable Cache Add IAM'
           WHEN ring_buffer_record.event = 51 THEN
               'Worktable Cache Add Page'
           WHEN ring_buffer_record.event = 52 THEN
               'Worktable Cache RMV IAM'
           WHEN ring_buffer_record.event = 53 THEN
               'Worktable Cache RMV Page'
           WHEN ring_buffer_record.event = 61 THEN
               'IAM Cache Destroy'
           WHEN ring_buffer_record.event = 62 THEN
               'IAM Cache Add Page'
           WHEN ring_buffer_record.event = 63 THEN
               'IAM Cache Refresh Requested'
           ELSE
               'Unknown Event'
       END AS EventName,
       ring_buffer_record.session_id AS s_id,
       ring_buffer_record.page_id,
       ring_buffer_record.allocation_unit_id
FROM (
    SELECT the_record.xml_record.value('(./Record/@id)[1]', 'int') AS record_id,
           the_record.xml_record.value('(./Record/SpaceMgr/Event)[1]', 'int') AS event,
           the_record.xml_record.value('(./Record/SpaceMgr/SpId)[1]', 'int') AS session_id,
           the_record.xml_record.value('(./Record/SpaceMgr/PageId)[1]', 'varchar(100)') AS page_id,
           the_record.xml_record.value('(./Record/SpaceMgr/AuId)[1]', 'varchar(100)') AS allocation_unit_id,
           the_record.timestamp
    FROM (
        SELECT timestamp,
               CONVERT(XML, record) AS xml_record
        FROM sys.dm_os_ring_buffers
        WHERE ring_buffer_type = N'RING_BUFFER_SPACEMGR_TRACE'
    ) AS the_record
) AS ring_buffer_record
WHERE ring_buffer_record.session_id = @@SPID
ORDER BY ring_buffer_record.record_id;
GO


/* ----------------------------------------------------------------------------
 – Check for allocation page contention in tempdb
---------------------------------------------------------------------------- */
SELECT session_id,
       wait_type,
       wait_duration_ms,
       blocking_session_id,
       resource_description,
       CASE
           WHEN CAST(RIGHT(resource_description, LEN(resource_description) - CHARINDEX(':', resource_description, 3)) AS INT)
                - 1 % 8088 = 0 THEN 'Is PFS Page'
           WHEN CAST(RIGHT(resource_description, LEN(resource_description) - CHARINDEX(':', resource_description, 3)) AS INT)
                - 2 % 511232 = 0 THEN 'Is GAM Page'
           WHEN CAST(RIGHT(resource_description, LEN(resource_description) - CHARINDEX(':', resource_description, 3)) AS INT)
                - 3 % 511232 = 0 THEN 'Is SGAM Page'
           ELSE 'Is Not PFS, GAM, or SGAM page'
       END AS ResourceType
FROM sys.dm_os_waiting_tasks
WHERE wait_type LIKE 'PAGE%LATCH_%'
      AND resource_description LIKE '2:%';
GO


/* ----------------------------------------------------------------------------
 – XEvent Session to track tempdb file growths
---------------------------------------------------------------------------- */
CREATE EVENT SESSION TempDBFileGrowth
ON SERVER
    ADD EVENT sqlserver.database_file_size_change
    (SET collect_database_name = (0)
     ACTION (
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.database_id,
         sqlserver.session_nt_username,
         sqlserver.sql_text
     )
     WHERE (database_id = (2))
    )
    ADD TARGET package0.event_file
    (SET filename = N'TempDBFileGrowth.xel', max_file_size = (10), max_rollover_files = (5))
WITH (
    MAX_MEMORY = 16384KB,
    EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,
    MAX_DISPATCH_LATENCY = 1 SECONDS,
    MEMORY_PARTITION_MODE = PER_NODE,
    TRACK_CAUSALITY = OFF,
    STARTUP_STATE = ON
);
GO
ALTER EVENT SESSION TempDBFileGrowth ON SERVER STATE = START;
GO


/* ----------------------------------------------------------------------------
 – Wait type information
---------------------------------------------------------------------------- */
SELECT owt.session_id,
       owt.exec_context_id,
       owt.wait_duration_ms,
       owt.wait_type,
       owt.blocking_session_id,
       owt.resource_description,
       CASE owt.wait_type
           WHEN N'CXPACKET' THEN
               RIGHT(owt.resource_description, CHARINDEX(N'=', REVERSE(owt.resource_description)) - 1)
           ELSE NULL
       END AS [Node ID],
       es.program_name,
       est.text,
       er.database_id,
       eqp.query_plan,
       er.cpu_time
FROM sys.dm_os_waiting_tasks AS owt
INNER JOIN sys.dm_exec_sessions AS es
    ON owt.session_id = es.session_id
INNER JOIN sys.dm_exec_requests AS er
    ON es.session_id = er.session_id
OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) AS est
OUTER APPLY sys.dm_exec_query_plan(er.plan_handle) AS eqp
WHERE es.is_user_process = 1
ORDER BY owt.session_id,
         owt.exec_context_id;
GO


/* ----------------------------------------------------------------------------
 – View all the sessions that are waiting for page-related wait types and 
   get information about the objects that the pages belong to
---------------------------------------------------------------------------- */
USE master;
GO
SELECT er.session_id,
       er.wait_type,
       er.wait_resource,
       OBJECT_NAME(page_info.object_id, page_info.database_id) AS object_name,
       er.blocking_session_id,
       er.command,
       SUBSTRING(st.text,
                 (er.statement_start_offset / 2) + 1,
                 ((CASE er.statement_end_offset
                       WHEN -1 THEN
                           DATALENGTH(st.text)
                       ELSE
                           er.statement_end_offset
                   END - er.statement_start_offset
                  ) / 2
                 ) + 1
       ) AS statement_text,
       page_info.database_id,
       page_info.file_id,
       page_info.page_id,
       page_info.object_id,
       page_info.index_id,
       page_info.page_type_desc
FROM sys.dm_exec_requests AS er
CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) AS st
CROSS APPLY sys.fn_PageResCracker(er.page_resource) AS r
CROSS APPLY sys.dm_db_page_info(r.db_id, r.file_id, r.page_id, 'DETAILED') AS page_info
WHERE er.wait_type LIKE '%page%';
GO

