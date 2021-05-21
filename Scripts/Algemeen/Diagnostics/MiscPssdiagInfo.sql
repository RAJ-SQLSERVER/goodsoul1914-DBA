SET NOCOUNT ON;
GO
PRINT '';
RAISERROR('-- DiagInfo --', 0, 1) WITH NOWAIT;
SELECT 1001 AS 'DiagVersion',
       '2015-01-09' AS 'DiagDate';
PRINT '';
GO
PRINT 'Script Version = 1001';
PRINT '';
GO
SET LANGUAGE us_english;
PRINT '-- Script and Environment Details --';
PRINT 'Name                     Value';
PRINT '------------------------ ---------------------------------------------------';
PRINT 'Script Name              Misc Pssdiag Info';
PRINT 'Script File Name         $File: MiscPssdiagInfo.sql $';
PRINT 'Revision                 $Revision: 1 $ ($Change: ? $)';
PRINT 'Last Modified            $Date: 2015/01/26 12:04:00 EST $';
PRINT 'Script Begin Time        ' + CONVERT(VARCHAR(30), GETDATE(), 126);
PRINT 'Current Database         ' + DB_NAME();
PRINT '';
GO
CREATE TABLE #summary
(
    PropertyName NVARCHAR(50) PRIMARY KEY,
    PropertyValue NVARCHAR(256)
);
INSERT INTO #summary
VALUES
('ProductVersion', CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(MAX)));
INSERT INTO #summary
VALUES
('MajorVersion',
 LEFT(CONVERT(sysname, SERVERPROPERTY('ProductVersion')), CHARINDEX(
                                                                       '.',
                                                                       CONVERT(
                                                                                  sysname,
                                                                                  SERVERPROPERTY('ProductVersion')
                                                                              ),
                                                                       0
                                                                   ) - 1));
INSERT INTO #summary
VALUES
('IsClustered', CAST(SERVERPROPERTY('IsClustered') AS NVARCHAR(MAX)));
INSERT INTO #summary
VALUES
('Edition', CAST(SERVERPROPERTY('Edition') AS NVARCHAR(MAX)));
INSERT INTO #summary
VALUES
('InstanceName', CAST(SERVERPROPERTY('InstanceName') AS NVARCHAR(MAX)));
INSERT INTO #summary
VALUES
('SQLServerName', @@SERVERNAME);
INSERT INTO #summary
VALUES
('MachineName', CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(MAX)));
INSERT INTO #summary
VALUES
('ProcessID', CAST(SERVERPROPERTY('ProcessID') AS NVARCHAR(MAX)));
INSERT INTO #summary
VALUES
('ResourceVersion', CAST(SERVERPROPERTY('ResourceVersion') AS NVARCHAR(MAX)));
INSERT INTO #summary
VALUES
('ServerName', CAST(SERVERPROPERTY('ServerName') AS NVARCHAR(MAX)));
INSERT INTO #summary
VALUES
('ComputerNamePhysicalNetBIOS', CAST(SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS NVARCHAR(MAX)));
INSERT INTO #summary
VALUES
('BuildClrVersion', CAST(SERVERPROPERTY('BuildClrVersion') AS NVARCHAR(MAX)));
INSERT INTO #summary
VALUES
('IsFullTextInstalled', CAST(SERVERPROPERTY('IsFullTextInstalled') AS NVARCHAR(MAX)));
INSERT INTO #summary
VALUES
('IsIntegratedSecurityOnly', CAST(SERVERPROPERTY('IsIntegratedSecurityOnly') AS NVARCHAR(MAX)));
INSERT INTO #summary
VALUES
('ProductLevel', CAST(SERVERPROPERTY('ProductLevel') AS NVARCHAR(MAX)));
INSERT INTO #summary
VALUES
('suser_name()', CAST(SUSER_NAME() AS NVARCHAR(MAX)));

INSERT INTO #summary
SELECT 'number of visible schedulers',
       COUNT(*) 'cnt'
FROM sys.dm_os_schedulers
WHERE status = 'VISIBLE ONLINE';
INSERT INTO #summary
SELECT 'number of visible numa nodes',
       COUNT(DISTINCT parent_node_id) 'cnt'
FROM sys.dm_os_schedulers
WHERE status = 'VISIBLE ONLINE';
INSERT INTO #summary
SELECT 'cpu_count',
       cpu_count
FROM sys.dm_os_sys_info;
INSERT INTO #summary
SELECT 'hyperthread_ratio',
       hyperthread_ratio
FROM sys.dm_os_sys_info;
INSERT INTO #summary
SELECT 'machine start time',
       CONVERT(VARCHAR(23), DATEADD(SECOND, -ms_ticks / 1000, GETDATE()), 121)
FROM sys.dm_os_sys_info;
INSERT INTO #summary
SELECT 'number of tempdb data files',
       COUNT(*) 'cnt'
FROM master.sys.master_files
WHERE database_id = 2
      AND [type] = 0;
INSERT INTO #summary
SELECT 'number of active profiler traces',
       COUNT(*) 'cnt'
FROM::fn_trace_getinfo(0)
WHERE property = 5
      AND CONVERT(TINYINT, value) = 1;
INSERT INTO #summary
SELECT 'suser_name() default database name',
       default_database_name
FROM sys.server_principals
WHERE name = SUSER_NAME();

INSERT INTO #summary
SELECT 'VISIBLEONLINE_SCHEDULER_COUNT' PropertyName,
       COUNT(*) PropertValue
FROM sys.dm_os_schedulers
WHERE status = 'VISIBLE ONLINE';

DECLARE @cpu_ticks BIGINT;
SELECT @cpu_ticks = cpu_ticks
FROM sys.dm_os_sys_info;
WAITFOR DELAY '0:0:2';
SELECT @cpu_ticks = cpu_ticks - @cpu_ticks
FROM sys.dm_os_sys_info;

INSERT INTO #summary
VALUES
('cpu_ticks_per_sec', @cpu_ticks / 2);

PRINT '';
PRINT '';
RAISERROR('--ServerProperty--', 0, 1) WITH NOWAIT;

SELECT *
FROM #summary
ORDER BY PropertyName;

TRUNCATE TABLE #summary;

GO

PRINT '';

GO



--we need to get this into a different rowset because it may fail

DECLARE @osversion NVARCHAR(256);
DECLARE @regvalue NVARCHAR(256);
DECLARE @regvalueint INT;
DECLARE @myhive NVARCHAR(256);
DECLARE @mykey NVARCHAR(1000);
DECLARE @pos INT;
DECLARE @osmajorversion INT;
DECLARE @fWinVista BIT;
SET @myhive = N'HKEY_LOCAL_MACHINE';
SET @mykey = N'Software\Microsoft\Windows NT\CurrentVersion';
--get windows info from registry
EXEC xp_instance_regread @rootkey = @myhive,
                         @key = @mykey,
                         @value_name = 'CurrentVersion',
                         @value = @regvalue OUTPUT;


SET @pos = CHARINDEX(N'.', @regvalue);
IF @pos != 0
BEGIN
    INSERT INTO #summary
    VALUES
    ('operating system version major', SUBSTRING(@regvalue, 1, @pos - 1));
    INSERT INTO #summary
    VALUES
    ('operating system version minor', SUBSTRING(@regvalue, @pos + 1, LEN(@regvalue)));

    SET @osmajorversion = SUBSTRING(@regvalue, 1, @pos - 1);
    IF @osmajorversion >= 6
    BEGIN
        SET @fWinVista = 1;
    END;
    ELSE
    BEGIN
        SET @fWinVista = 0;
    END;

    EXEC xp_instance_regread @rootkey = @myhive,
                             @key = @mykey,
                             @value_name = 'CurrentBuildNumber',
                             @value = @regvalue OUTPUT;

    INSERT INTO #summary
    VALUES
    ('operating system version build', @regvalue);

    EXEC xp_instance_regread @rootkey = @myhive,
                             @key = @mykey,
                             @value_name = 'ProductName',
                             @value = @osversion OUTPUT;
    EXEC xp_instance_regread @rootkey = @myhive,
                             @key = @mykey,
                             @value_name = 'CSDVersion',
                             @value = @regvalue OUTPUT;

    INSERT INTO #summary
    VALUES
    ('operating system', @osversion + N' ' + @regvalue);

    EXEC xp_instance_regread @rootkey = @myhive,
                             @key = @mykey,
                             @value_name = 'InstallDate',
                             @value = @regvalueint OUTPUT;

    INSERT INTO #summary
    VALUES
    ('operating system install date', CONVERT(VARCHAR(23), DATEADD(SECOND, @regvalueint, '1970-01-01'), 121));

/*
	other possible values of interest
	CurrentType
	InstallationType
	EditionID
	SoftwareType
	*/
END;

IF @fWinVista = 1
BEGIN
    SET @mykey = N'SYSTEM\CurrentControlSet\Control\SystemInformation';
    --get system info from registry
    EXEC xp_instance_regread @rootkey = @myhive,
                             @key = @mykey,
                             @value_name = 'SystemManufacturer',
                             @value = @regvalue OUTPUT;
    INSERT INTO #summary
    VALUES
    ('registry SystemManufacturer', @regvalue);
    EXEC xp_instance_regread @rootkey = @myhive,
                             @key = @mykey,
                             @value_name = 'SystemProductName',
                             @value = @regvalue OUTPUT;
    INSERT INTO #summary
    VALUES
    ('registry SystemProductName', @regvalue);

    --get powerplan from registry
    SET @mykey = N'SYSTEM\CurrentControlSet\Control\Power\User\Default\PowerSchemes';

    EXEC xp_instance_regread @rootkey = @myhive,
                             @key = @mykey,
                             @value_name = 'ActivePowerScheme',
                             @value = @regvalue OUTPUT;

    SET @mykey = @mykey + N'\' + @regvalue;

    EXEC xp_instance_regread @rootkey = @myhive,
                             @key = @mykey,
                             @value_name = 'FriendlyName',
                             @value = @regvalue OUTPUT;

    DECLARE @string NVARCHAR(100);
    SET @string = N'@%SystemRoot%\system32\powrprof.dll,';
    SET @pos = CHARINDEX(@string, @regvalue);
    IF @pos != 0
    BEGIN
        DECLARE @len INT;
        SET @len = LEN(@string) + 1;
        SET @pos = CHARINDEX(N',', @regvalue, @len);
        IF @pos != 0
        BEGIN
            SET @regvalue = SUBSTRING(@regvalue, @pos + 1, LEN(@regvalue));
        END;
    END;

    INSERT INTO #summary
    VALUES
    ('registry ActivePowerScheme (default)', @regvalue);

    SET @mykey = N'SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes';

    EXEC xp_instance_regread @rootkey = 'HKEY_LOCAL_MACHINE',
                             @key = @mykey,
                             @value_name = 'ActivePowerScheme',
                             @value = @regvalue OUTPUT;

    SET @mykey = @mykey + N'\' + @regvalue;

    EXEC xp_instance_regread @rootkey = @myhive,
                             @key = @mykey,
                             @value_name = 'FriendlyName',
                             @value = @regvalue OUTPUT;

    INSERT INTO #summary
    VALUES
    ('registry ActivePowerScheme', @regvalue);
END;

IF (@@MICROSOFTVERSION >= 167773760) --10.0.1600
BEGIN
    EXEC sp_executesql N'insert into #summary select ''sqlserver_start_time'', convert(varchar(23),sqlserver_start_time,121) from sys.dm_os_sys_info';
    EXEC sp_executesql N'insert into #summary select ''resource governor enabled'', is_enabled from sys.resource_governor_configuration';
    INSERT INTO #summary
    VALUES
    ('FilestreamShareName', CAST(SERVERPROPERTY('FilestreamShareName') AS NVARCHAR(MAX)));
    INSERT INTO #summary
    VALUES
    ('FilestreamConfiguredLevel', CAST(SERVERPROPERTY('FilestreamConfiguredLevel') AS NVARCHAR(MAX)));
    INSERT INTO #summary
    VALUES
    ('FilestreamEffectiveLevel', CAST(SERVERPROPERTY('FilestreamEffectiveLevel') AS NVARCHAR(MAX)));
    INSERT INTO #summary
    SELECT 'number of active extended event traces',
           COUNT(*) AS 'cnt'
    FROM sys.dm_xe_sessions;
END;

IF (@@MICROSOFTVERSION >= 171050560) --10.50.1600
BEGIN
    EXEC sp_executesql N'insert into #summary select ''possibly running in virtual machine'', virtual_machine_type from sys.dm_os_sys_info';
END;

IF (@@MICROSOFTVERSION >= 184551476) --11.0.2100
BEGIN
    EXEC sp_executesql N'insert into #summary select ''physical_memory_kb'', physical_memory_kb from sys.dm_os_sys_info';
    INSERT INTO #summary
    VALUES
    ('HadrManagerStatus', CAST(SERVERPROPERTY('HadrManagerStatus') AS NVARCHAR(MAX)));
    INSERT INTO #summary
    VALUES
    ('IsHadrEnabled', CAST(SERVERPROPERTY('IsHadrEnabled') AS NVARCHAR(MAX)));
END;

IF (@@MICROSOFTVERSION >= 201328592) --12.0.2000
BEGIN
    INSERT INTO #summary
    VALUES
    ('IsLocalDB', CAST(SERVERPROPERTY('IsLocalDB') AS NVARCHAR(MAX)));
    INSERT INTO #summary
    VALUES
    ('IsXTPSupported', CAST(SERVERPROPERTY('IsXTPSupported') AS NVARCHAR(MAX)));
END;

RAISERROR('', 0, 1) WITH NOWAIT;
RAISERROR('--ServerProperty--', 0, 1) WITH NOWAIT;

SELECT *
FROM #summary
ORDER BY PropertyName;
DROP TABLE #summary;
GO

DECLARE @startup TABLE
(
    ArgsName NVARCHAR(10),
    ArgsValue NVARCHAR(MAX)
);
INSERT INTO @startup
EXEC master..xp_instance_regenumvalues 'HKEY_LOCAL_MACHINE',
                                       'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer\Parameters';
PRINT '';
RAISERROR('--Startup Parameters--', 0, 1) WITH NOWAIT;
SELECT *
FROM @startup;
GO

CREATE TABLE #traceflg
(
    TraceFlag INT,
    Status INT,
    Global INT,
    Session INT
);
INSERT INTO #traceflg
EXEC ('dbcc tracestatus (-1)');
PRINT '';
RAISERROR('--traceflags--', 0, 1) WITH NOWAIT;
SELECT *
FROM #traceflg;
DROP TABLE #traceflg;
GO

PRINT '';
RAISERROR('--sys.dm_os_schedulers--', 0, 1) WITH NOWAIT;
SELECT *
FROM sys.dm_os_schedulers;
GO

IF (
       @@MICROSOFTVERSION >= 167773760 --10.0.1600
       AND @@MICROSOFTVERSION < 171048960
   ) --10.50.0.0
BEGIN
    PRINT '';
    RAISERROR('--sys.dm_os_nodes--', 0, 1) WITH NOWAIT;
    EXEC sp_executesql N'select node_id, memory_object_address, memory_clerk_address, io_completion_worker_address, memory_node_id, cpu_affinity_mask, online_scheduler_count, idle_scheduler_count active_worker_count, avg_load_balance, timer_task_affinity_mask, permanent_task_affinity_mask, resource_monitor_state, node_state_desc from sys.dm_os_nodes';
END;
GO

IF (@@MICROSOFTVERSION >= 171048960) --10.50.0.0
BEGIN
    PRINT '';
    RAISERROR('--sys.dm_os_nodes--', 0, 1) WITH NOWAIT;
    EXEC sp_executesql N'select node_id, memory_object_address, memory_clerk_address, io_completion_worker_address, memory_node_id, cpu_affinity_mask, online_scheduler_count, idle_scheduler_count active_worker_count, avg_load_balance, timer_task_affinity_mask, permanent_task_affinity_mask, resource_monitor_state, online_scheduler_mask, processor_group, node_state_desc from sys.dm_os_nodes';
END;
GO

PRINT '';
RAISERROR('--dm_os_sys_info--', 0, 1) WITH NOWAIT;
SELECT *
FROM sys.dm_os_sys_info;
GO

IF CAST(SERVERPROPERTY('IsClustered') AS INT) = 1
BEGIN
    PRINT '';
    RAISERROR('--fn_virtualservernodes--', 0, 1) WITH NOWAIT;
    SELECT *
    FROM fn_virtualservernodes();
END;
GO


PRINT '';
RAISERROR('--sys.configurations--', 0, 1) WITH NOWAIT;
SELECT configuration_id,
       CONVERT(INT, value) AS 'value',
       CONVERT(INT, value_in_use) AS 'value_in_use',
       CONVERT(INT, minimum) AS 'minimum',
       CONVERT(INT, maximum) AS 'maximum',
       CONVERT(INT, is_dynamic) AS 'is_dynamic',
       CONVERT(INT, is_advanced) AS 'is_advanced',
       name
FROM sys.configurations
ORDER BY name;
GO


PRINT '';
RAISERROR('--database files--', 0, 1) WITH NOWAIT;
SELECT database_id,
       [file_id],
       file_guid,
       [type],
       LEFT(type_desc, 10) AS 'type_desc',
       data_space_id,
       [state],
       LEFT(state_desc, 16) AS 'state_desc',
       size,
       max_size,
       growth,
       is_media_read_only,
       is_read_only,
       is_sparse,
       is_percent_growth,
       is_name_reserved,
       create_lsn,
       drop_lsn,
       read_only_lsn,
       read_write_lsn,
       differential_base_lsn,
       differential_base_guid,
       differential_base_time,
       redo_start_lsn,
       redo_start_fork_guid,
       redo_target_lsn,
       redo_target_fork_guid,
       backup_lsn,
       DB_NAME(database_id) AS 'Database_name',
       name,
       physical_name
FROM master.sys.master_files
ORDER BY database_id,
         type,
         file_id;
PRINT '';

GO

PRINT '';
RAISERROR('--sys.databases_ex--', 0, 1) WITH NOWAIT;
SELECT CAST(DATABASEPROPERTYEX(name, 'IsAutoCreateStatistics') AS INT) 'IsAutoCreateStatistics',
       CAST(DATABASEPROPERTYEX(name, 'IsAutoUpdateStatistics') AS INT) 'IsAutoUpdateStatistics',
       CAST(DATABASEPROPERTYEX(name, 'IsAutoCreateStatisticsIncremental') AS INT) 'IsAutoCreateStatisticsIncremental',
       *
FROM sys.databases;
GO

PRINT '';
RAISERROR('-- Windows Group Default Databases other than master --', 0, 1) WITH NOWAIT;
SELECT name,
       default_database_name
FROM sys.server_principals
WHERE [type] = 'G'
      AND is_disabled = 0
      AND default_database_name != 'master';
GO

PRINT '';
RAISERROR('-- sys.database_mirroring --', 0, 1) WITH NOWAIT;
IF (@@MICROSOFTVERSION >= 167772160) --10.0.0
BEGIN
    EXEC sp_executesql N'select database_id, mirroring_guid, mirroring_state, mirroring_role, mirroring_role_sequence, mirroring_safety_level, mirroring_safety_sequence, 
			mirroring_witness_state, mirroring_failover_lsn, mirroring_end_of_log_lsn, mirroring_replication_lsn, mirroring_connection_timeout, mirroring_redo_queue,
			db_name(database_id) as ''database_name'', mirroring_partner_name, mirroring_partner_instance, mirroring_witness_name 
		from sys.database_mirroring where mirroring_guid IS NOT NULL';
END;
ELSE
BEGIN
    SELECT database_id,
           mirroring_guid,
           mirroring_state,
           mirroring_role,
           mirroring_role_sequence,
           mirroring_safety_level,
           mirroring_safety_sequence,
           mirroring_witness_state,
           mirroring_failover_lsn,
           mirroring_connection_timeout,
           mirroring_redo_queue,
           DB_NAME(database_id) AS 'database_name',
           mirroring_partner_name,
           mirroring_partner_instance,
           mirroring_witness_name
    FROM sys.database_mirroring
    WHERE mirroring_guid IS NOT NULL;
END;
GO

IF @@MICROSOFTVERSION >= 184551476 --11.0.2100
BEGIN
    PRINT '';
    RAISERROR('--Hadron Configuration--', 0, 1) WITH NOWAIT;
    SELECT ag.name AS ag_name,
           ar.replica_server_name,
           ar_state.is_local AS is_ag_replica_local,
           ag_replica_role_desc = CASE
                                      WHEN ar_state.role_desc IS NULL THEN
                                          N'<unknown>'
                                      ELSE
                                          ar_state.role_desc
                                  END,
           ag_replica_operational_state_desc = CASE
                                                   WHEN ar_state.operational_state_desc IS NULL THEN
                                                       N'<unknown>'
                                                   ELSE
                                                       ar_state.operational_state_desc
                                               END,
           ag_replica_connected_state_desc = CASE
                                                 WHEN ar_state.connected_state_desc IS NULL THEN
                                                     CASE
                                                         WHEN ar_state.is_local = 1 THEN
                                                             N'CONNECTED'
                                                         ELSE
                                                             N'<unknown>'
                                                     END
                                                 ELSE
                                                     ar_state.connected_state_desc
                                             END
    --ar.secondary_role_allow_read_desc
    FROM sys.availability_groups AS ag
        JOIN sys.availability_replicas AS ar
            ON ag.group_id = ar.group_id
        JOIN sys.dm_hadr_availability_replica_states AS ar_state
            ON ar.replica_id = ar_state.replica_id;

    PRINT '';
    RAISERROR('--sys.availability_groups--', 0, 1) WITH NOWAIT;
    SELECT *
    FROM sys.availability_groups;


    PRINT '';
    RAISERROR('--sys.dm_hadr_availability_group_states--', 0, 1) WITH NOWAIT;
    SELECT *
    FROM sys.dm_hadr_availability_group_states;

    PRINT '';
    RAISERROR('--sys.dm_hadr_availability_replica_states--', 0, 1) WITH NOWAIT;
    SELECT *
    FROM sys.dm_hadr_availability_replica_states;

    PRINT '';
    RAISERROR('--sys.availability_replicas--', 0, 1) WITH NOWAIT;
    SELECT *
    FROM sys.availability_replicas;

    PRINT '';
    RAISERROR('--sys.dm_hadr_database_replica_cluster_states--', 0, 1) WITH NOWAIT;
    SELECT *
    FROM sys.dm_hadr_database_replica_cluster_states;

    PRINT '';
    RAISERROR('--sys.availability_group_listeners--', 0, 1) WITH NOWAIT;
    SELECT *
    FROM sys.availability_group_listeners;

    PRINT '';
    RAISERROR('--sys.dm_hadr_cluster_members--', 0, 1) WITH NOWAIT;
    SELECT *
    FROM sys.dm_hadr_cluster_members;
END;
GO

PRINT '-- sys.change_tracking_databases --';
SELECT *
FROM sys.change_tracking_databases;
PRINT '';


PRINT '-- sys.dm_database_encryption_keys --';
SELECT database_id,
       encryption_state
FROM sys.dm_database_encryption_keys;
PRINT '';

GO
/*
--windows version from @@version
declare @pos int
set @pos = CHARINDEX(N' on ',@@VERSION)
print substring(@@VERSION, @pos + 4, LEN(@@VERSION))
*/


PRINT '--profiler trace summary--';
SELECT traceid,
       property,
       CONVERT(VARCHAR(1024), value) AS value
FROM::fn_trace_getinfo(DEFAULT);

GO
--we need the space for import
PRINT '';
PRINT '--trace event details--';
SELECT trace_id,
       status,
       CASE
           WHEN row_number = 1 THEN
               path
           ELSE
               NULL
       END AS path,
       CASE
           WHEN row_number = 1 THEN
               max_size
           ELSE
               NULL
       END AS max_size,
       CASE
           WHEN row_number = 1 THEN
               start_time
           ELSE
               NULL
       END AS start_time,
       CASE
           WHEN row_number = 1 THEN
               stop_time
           ELSE
               NULL
       END AS stop_time,
       max_files,
       is_rowset,
       is_rollover,
       is_shutdown,
       is_default,
       buffer_count,
       buffer_size,
       last_event_time,
       event_count,
       trace_event_id,
       trace_event_name,
       trace_column_id,
       trace_column_name,
       expensive_event
FROM
(
    SELECT t.id AS trace_id,
           ROW_NUMBER() OVER (PARTITION BY t.id ORDER BY te.trace_event_id, tc.trace_column_id) AS row_number,
           t.status,
           t.path,
           t.max_size,
           t.start_time,
           t.stop_time,
           t.max_files,
           t.is_rowset,
           t.is_rollover,
           t.is_shutdown,
           t.is_default,
           t.buffer_count,
           t.buffer_size,
           t.last_event_time,
           t.event_count,
           te.trace_event_id,
           te.name AS trace_event_name,
           tc.trace_column_id,
           tc.name AS trace_column_name,
           CASE
               WHEN te.trace_event_id IN ( 23, 24, 40, 41, 44, 45, 51, 52, 54, 68, 96, 97, 98, 113, 114, 122, 146, 180 ) THEN
                   CAST(1 AS BIT)
               ELSE
                   CAST(0 AS BIT)
           END AS expensive_event
    FROM sys.traces t
        CROSS APPLY::fn_trace_geteventinfo(t.id) AS e
        JOIN sys.trace_events te
            ON te.trace_event_id = e.eventid
        JOIN sys.trace_columns tc
            ON e.columnid = trace_column_id
) AS x;

GO


PRINT '';
PRINT '--XEvent Session Details--';
SELECT sess.name 'session_name',
       event_name
FROM sys.dm_xe_sessions sess
    JOIN sys.dm_xe_session_events evt
        ON sess.address = evt.event_session_address;
PRINT '';