/*
Author: Eitan Blumin (t: @EitanBlumin | b: eitanblumin.com)
Date: February, 2019
Description:
This is a condensed SQL Server Checkup of most common and impactful best practices.
Some of the checks are based on BP_Check.sql in Tiger Toolbox (by Pedro Lopez)
*/

DECLARE @NumOfMinutesBackToCheck      INT = 360,
        @MinutesBackToCheck           INT = 360,
        @DaysBackToCheck              INT = 10,
        @MinAdHocSizeInMB             INT = 200,
        @MinAdHocPercent              INT = 25,
        @FreespaceMinimumMB           INT = 1024,
        @FreespaceMinimumPercent      INT = 10,
        @UnsentLogThresholdKB         INT = 2048,
        @UnrestoredLogThresholdKB     INT = 2048,
        @TransactionDelayThresholdMil INT = 1000,
        @MaxSQLErrorLogSize           INT = 100;

SET NOCOUNT ON;
DECLARE @Alerts AS TABLE
(
    Category NVARCHAR(1000),
    SubCategory NVARCHAR(MAX),
    ObjectName NVARCHAR(MAX),
    Details NVARCHAR(MAX)
);


INSERT INTO @Alerts
SELECT 'Database Backup',
       'Database has never been backed up',
       QUOTENAME(name),
       'It''s recommended to have a backup plan for all databases, including user databases as well as the system databases MSDB and Master.'
FROM   sys.databases AS db
WHERE  database_id NOT IN ( 2, 32767 )
       AND state_desc = 'ONLINE'
       AND name NOT IN ( 'ReportServerTempDB', 'model' )
       AND NOT EXISTS
(
    SELECT NULL FROM msdb..backupset WHERE database_name = db.name
);


INSERT INTO @Alerts
SELECT     'Corruption',
           'Automatic Page Repair Was Used in AlwaysOn',
           'Database: ' + DB_NAME(rep.database_id) + ' File: ' + fil.name + ' PageID: ' + CONVERT(VARCHAR, rep.page_id),
           ' Error Type: ' + CASE rep.error_type
                                 WHEN -1 THEN
                                     'Hardware 823 Error'
                                 WHEN 1 THEN
                                     'General 824 Error'
                                 WHEN 2 THEN
                                     'Bad Checksum'
                                 WHEN 3 THEN
                                     'Torn Page'
                                 ELSE
                                     'Unknown - ' + CONVERT(VARCHAR, rep.error_type)
                             END + ' Page Status: ' + CASE rep.page_status
                                                          WHEN 2 THEN
                                                              'Queued for Request from Partner'
                                                          WHEN 3 THEN
                                                              'Request Sent to Partner'
                                                          WHEN 4 THEN
                                                              'Queued for Automatic Page Repair'
                                                          WHEN 5 THEN
                                                              'Automatic Page Repair Succeeded'
                                                          WHEN 6 THEN
                                                              'Unable to Repair'
                                                          ELSE
                                                              'Unknown - ' + CONVERT(VARCHAR, rep.page_status)
                                                      END + ' Modification Time: '
           + CONVERT(VARCHAR, rep.modification_time, 120)
FROM       sys.dm_hadr_auto_page_repair AS rep
INNER JOIN sys.master_files AS fil
    ON rep.database_id = fil.database_id
       AND rep.file_id = fil.file_id
WHERE      rep.modification_time >= DATEADD(MINUTE, -@NumOfMinutesBackToCheck, GETDATE())
UNION ALL
SELECT     'Corruption',
           'Automatic Page Repair Was Used in DB Mirroring',
           'Database: ' + DB_NAME(rep.database_id) + ' File: ' + fil.name + ' PageID: ' + CONVERT(VARCHAR, rep.page_id),
           ' Error Type: ' + CASE rep.error_type
                                 WHEN -1 THEN
                                     'Hardware 823 Error'
                                 WHEN 1 THEN
                                     'General 824 Error'
                                 WHEN 2 THEN
                                     'Bad Checksum'
                                 WHEN 3 THEN
                                     'Torn Page'
                                 ELSE
                                     'Unknown - ' + CONVERT(VARCHAR, rep.error_type)
                             END + ' Page Status: ' + CASE rep.page_status
                                                          WHEN 2 THEN
                                                              'Queued for Request from Partner'
                                                          WHEN 3 THEN
                                                              'Request Sent to Partner'
                                                          WHEN 4 THEN
                                                              'Queued for Automatic Page Repair'
                                                          WHEN 5 THEN
                                                              'Automatic Page Repair Succeeded'
                                                          WHEN 6 THEN
                                                              'Unable to Repair'
                                                          ELSE
                                                              'Unknown - ' + CONVERT(VARCHAR, rep.page_status)
                                                      END + ' Modification Time: '
           + CONVERT(VARCHAR, rep.modification_time, 120)
FROM       sys.dm_db_mirroring_auto_page_repair AS rep
INNER JOIN sys.master_files AS fil
    ON rep.database_id = fil.database_id
       AND rep.file_id = fil.file_id
WHERE      rep.modification_time >= DATEADD(MINUTE, -@NumOfMinutesBackToCheck, GETDATE());


INSERT INTO @Alerts
SELECT 'Performance',
       'Auto Create Statistics is OFF',
       name,
       'Recommended to turn Auto Create Statistics ON'
FROM   sys.databases
WHERE  state_desc = 'ONLINE'
       AND is_auto_create_stats_on = 0
UNION ALL
SELECT 'Performance',
       'Auto Update Statistics is OFF',
       name,
       'Recommended to turn Auto Update Statistics ON'
FROM   sys.databases
WHERE  state_desc = 'ONLINE'
       AND is_auto_update_stats_on = 0;


DECLARE @RecentBackups AS TABLE
(
    PhysicalPath NVARCHAR(4000),
    DeviceName NVARCHAR(4000)
);
DECLARE @CurrFile NVARCHAR(4000),
        @Exists   INT;

INSERT INTO @RecentBackups
SELECT     DISTINCT
           physical_device_name,
           UPPER(SUBSTRING(physical_device_name, 0, CHARINDEX('\', physical_device_name, 3)))
FROM       msdb.dbo.backupmediafamily AS bmf
INNER JOIN msdb.dbo.backupset AS bs
    ON bmf.media_set_id = bs.media_set_id
WHERE      bs.backup_start_date > DATEADD(dd, -@DaysBackToCheck, GETDATE())
           AND physical_device_name IS NOT NULL;

DECLARE Backups CURSOR LOCAL FAST_FORWARD FOR
SELECT PhysicalPath
FROM   @RecentBackups;

OPEN Backups;
FETCH NEXT FROM Backups
INTO @CurrFile;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @Exists = 1;
    EXEC master.dbo.xp_fileexist @CurrFile, @Exists OUT;

    IF @Exists = 0
        DELETE FROM @RecentBackups
        WHERE PhysicalPath = @CurrFile;

    FETCH NEXT FROM Backups
    INTO @CurrFile;
END;

CLOSE Backups;
DEALLOCATE Backups;

INSERT INTO @Alerts
SELECT     'Database Backup',
           N'Backups and database files in the same physical volume',
           DeviceName,
           N'The volumn Contains ' + CONVERT(NVARCHAR(4000), COUNT(DISTINCT bmf.PhysicalPath)) + N' backup file(s) and '
           + CONVERT(NVARCHAR(4000), COUNT(DISTINCT mf.physical_name)) + N' database file(s).'
FROM       @RecentBackups AS bmf
INNER JOIN sys.master_files AS mf
    ON UPPER(SUBSTRING(physical_name, 0, CHARINDEX('\', physical_name, 3))) = DeviceName
WHERE      (
               database_id > 3
               OR database_id = 2
           )
           AND database_id <> 32767
GROUP BY   DeviceName;

DECLARE @MasterCmpt INT;
SELECT @MasterCmpt = cmptlevel
FROM   sysdatabases
WHERE  dbid = 1;

INSERT INTO @Alerts
SELECT 'Database Compatibility Mismatch',
       'Database Compatibility: ' + CONVERT(NVARCHAR, cmptlevel) + N', Instance Compatibility: '
       + CONVERT(NVARCHAR, @MasterCmpt),
       QUOTENAME(name),
       'User Database Compatibility should be the same as Instance Compatibility'
FROM   sysdatabases
WHERE  cmptlevel <> @MasterCmpt;

INSERT INTO @Alerts
SELECT 'General',
       'Database Auto Close is ON',
       name,
       'Strongly recommended to set Database Auto Close to OFF'
FROM   sys.databases
WHERE  state_desc = 'ONLINE'
       AND is_auto_close_on = 1;


INSERT INTO @Alerts
SELECT 'General',
       'File Auto Growth is Disabled',
       'File ' + QUOTENAME(name) + ' in database ' + QUOTENAME(DB_NAME(database_id)) + ' has Auto Growth disabled',
       'File Auto Growth should be ON (with a max size limit)'
FROM   sys.master_files
WHERE  growth = 0
       AND type IN ( 0, 1 );


INSERT INTO @Alerts
SELECT 'Performance',
       'Database Auto Shrink is ON',
       name,
       'Strongly recommended to set Database Auto Shrink to OFF'
FROM   sys.databases
WHERE  state_desc = 'ONLINE'
       AND is_auto_shrink_on = 1;


INSERT INTO @Alerts
SELECT 'General',
       N'Database File(s) on Volume C',
       'Database ' + DB_NAME(database_id) + N': ' + physical_name,
       'Placing database files on the system volume puts the Operating System in danger when these files grow too much'
FROM   sys.master_files AS mf
WHERE  (
           database_id > 3
           OR database_id = 2
       )
       AND database_id <> 32767
       AND UPPER(SUBSTRING(physical_name, 0, CHARINDEX('\', physical_name, 3))) = 'C:';

-- Tiger Toolbox Recommendations:
-- backup compression default
-- clr enabled (only enable if needed)
-- lightweight pooling (should be zero)
-- max degree of parallelism
-- cost threshold for parallelism 
-- max server memory (MB) (set to an appropriate value)
-- priority boost (should be zero)
-- remote admin connections (should be enabled in a cluster configuration, to allow remote DAC)
-- scan for startup procs (should be disabled unless business requirement, like replication)
-- min memory per query (default is 1024KB)
-- allow updates (no effect in 2005 or above, but should be off)
-- max worker threads (should be zero in 2005 or above)
-- affinity mask and affinity I/O mask (must not overlap)

DECLARE @sqlmajorver        INT,
        @systemmem          INT,
        @systemfreemem      INT,
        @maxservermem       INT,
        @numa_nodes_afinned INT,
        @numa               INT;
DECLARE @mwthreads_count INT,
        @mwthreads       INT,
        @arch            SMALLINT,
        @sqlcmd          NVARCHAR(4000);
DECLARE @MinMBMemoryForOS    INT,
        @RecommendedMaxMemMB INT;
SET @sqlmajorver = CONVERT(INT, (@@microsoftversion / 0x1000000) & 0xff);
SET @arch = CASE
                WHEN @@VERSION LIKE '%<X64>%' THEN
                    64
                WHEN @@VERSION LIKE '%<IA64>%' THEN
                    128
                ELSE
                    32
            END;

SELECT @maxservermem = CONVERT(INT, value)
FROM   sys.configurations (NOLOCK)
WHERE  name = 'max server memory (MB)';
SELECT @numa_nodes_afinned = COUNT(DISTINCT parent_node_id)
FROM   sys.dm_os_schedulers
WHERE  scheduler_id < 255
       AND parent_node_id < 64
       AND is_online = 1;
SELECT @numa = COUNT(DISTINCT parent_node_id)
FROM   sys.dm_os_schedulers
WHERE  scheduler_id < 255
       AND parent_node_id < 64;
SELECT @mwthreads = CONVERT(INT, value)
FROM   sys.configurations
WHERE  name = 'max worker threads';
SELECT @mwthreads_count = max_workers_count
FROM   sys.dm_os_sys_info;

IF @sqlmajorver = 9
BEGIN
    SET @sqlcmd
        = N'SELECT @systemmemOUT = t1.record.value(''(./Record/MemoryRecord/TotalPhysicalMemory)[1]'', ''bigint'')/1024, 
	@systemfreememOUT = t1.record.value(''(./Record/MemoryRecord/AvailablePhysicalMemory)[1]'', ''bigint'')/1024
FROM (SELECT MAX([TIMESTAMP]) AS [TIMESTAMP], CONVERT(xml, record) AS record 
	FROM sys.dm_os_ring_buffers (NOLOCK)
	WHERE ring_buffer_type = N''RING_BUFFER_RESOURCE_MONITOR''
		AND record LIKE ''%RESOURCE_MEMPHYSICAL%''
	GROUP BY record) AS t1';
END;
ELSE
BEGIN
    SET @sqlcmd
        = N'SELECT @systemmemOUT = total_physical_memory_kb/1024, @systemfreememOUT = available_physical_memory_kb/1024 FROM sys.dm_os_sys_memory';
END;
EXECUTE sp_executesql @sqlcmd,
                      N'@systemmemOUT bigint OUTPUT, @systemfreememOUT bigint OUTPUT',
                      @systemmemOUT = @systemmem OUTPUT,
                      @systemfreememOUT = @systemfreemem OUTPUT;

SET @MinMBMemoryForOS = CASE
                            WHEN @systemmem <= 2048 THEN
                                512
                            WHEN @systemmem
                                 BETWEEN 2049 AND 4096 THEN
                                819
                            WHEN @systemmem
                                 BETWEEN 4097 AND 8192 THEN
                                1228
                            WHEN @systemmem
                                 BETWEEN 8193 AND 12288 THEN
                                2048
                            WHEN @systemmem
                                 BETWEEN 12289 AND 24576 THEN
                                2560
                            WHEN @systemmem
                                 BETWEEN 24577 AND 32768 THEN
                                3072
                            WHEN @systemmem > 32768 THEN
                                4096
                        END;

SET @RecommendedMaxMemMB = @systemmem - @MinMBMemoryForOS - (@mwthreads_count * (CASE
                                                                                     WHEN @arch = 64 THEN
                                                                                         2
                                                                                     WHEN @arch = 128 THEN
                                                                                         4
                                                                                     WHEN @arch = 32 THEN
                                                                                         0.5
                                                                                 END
                                                                                ) - 256
                                                            );

INSERT INTO @Alerts
SELECT 'Performance',
       'Not recommended instance configuration',
       'Optimize for ad hoc workloads',
       CASE
           WHEN CurrentConfig = 0 THEN
               'Optimize for ad hoc workloads is off, but recommended to be on'
           WHEN CurrentConfig = 1 THEN
               'Optimize for ad hoc workloads is on, but recommended to be off'
       END
FROM
       (
           SELECT SUM(   CAST((CASE
                                   WHEN usecounts = 1
                                        AND LOWER(objtype) = 'adhoc' THEN
                                       size_in_bytes
                                   ELSE
                                       0
                               END
                              ) AS DECIMAL(14, 2))
                     ) / 1048576 AS "AdHocSizeInMB",
                  SUM(CAST(size_in_bytes AS DECIMAL(14, 2))) / 1048576 AS "TotalSizeInMB",
                  (
                      SELECT CONVERT(BIT, value_in_use)
                      FROM   sys.configurations
                      WHERE  name = 'optimize for ad hoc workloads'
                  ) AS "CurrentConfig"
           FROM   sys.dm_exec_cached_plans
       ) AS D
WHERE  (
           CurrentConfig = 1
           AND
           (
               AdHocSizeInMB > @MinAdHocSizeInMB
               OR (AdHocSizeInMB / TotalSizeInMB) * 100 > @MinAdHocPercent
           )
       )
       OR
       (
           CurrentConfig = 0
           AND
           (
               AdHocSizeInMB < @MinAdHocSizeInMB
               AND (AdHocSizeInMB / TotalSizeInMB) * 100 < @MinAdHocPercent
           )
       )
UNION ALL
SELECT 'General',
       'Not recommended instance configuration',
       'SQL Server Max Memory',
       Report
FROM
       (
           SELECT 'MaxMem setting exceeds available system memory'
           WHERE  @maxservermem > @systemmem
           UNION ALL
           SELECT 'Current MaxMem setting will leverage node foreign memory. Maximum value for MaxMem setting on this configuration is '
                  +   CONVERT(NVARCHAR, (@systemmem / @numa) * @numa_nodes_afinned) + ' MB for a single instance'
           WHERE  @numa > 1
                  AND (@maxservermem / @numa) * @numa_nodes_afinned > (@systemmem / @numa) * @numa_nodes_afinned
           UNION ALL
           SELECT 'Current MaxMem setting is too high. Recommended maximum value for MaxMem setting on this configuration is '
                  +   CONVERT(NVARCHAR(1000), @RecommendedMaxMemMB) + N' MB for a single instance'
           WHERE  @numa <= 1
                  AND @maxservermem
                  BETWEEN @RecommendedMaxMemMB AND @systemmem
       ) AS V(Report)
UNION ALL
SELECT 'General',
       'Not recommended instance configuration',
       R.setting,
       R.errormsg + N' (current value: ' + CONVERT(NVARCHAR, c.value) + N', recommended value: '
       + CONVERT(NVARCHAR, R.recommendedvalue) + ')'
FROM   sys.configurations AS c
CROSS APPLY
       (
           SELECT 'allow updates',
                  0,
                  'Direct System Catalog Updates is enabled'
           UNION ALL
           SELECT 'automatic soft-NUMA disabled',
                  0,
                  'Auto Soft NUMA is disabled'
           UNION ALL
           SELECT 'awe enabled',
                  CASE
                      WHEN @sqlmajorver < 11
                           AND @@VERSION NOT LIKE '%<X64>%'
                           AND @@VERSION NOT LIKE '%<IA64>%'
                           AND @systemmem >= 4000 THEN
                          1
                      WHEN @sqlmajorver > 10 THEN
                          0
                  END,
                  'AWE setting is not optimal for this instance'
           UNION ALL
           SELECT 'backup compression default',
                  1,
                  'Backup Compression by default is not enabled'
           UNION ALL
           SELECT 'default trace enabled',
                  1,
                  'Default trace setting is NOT enabled'
           UNION ALL
           SELECT 'lightweight pooling',
                  0,
                  'Lightweight pooling setting is not the recommended value'
           UNION ALL
           SELECT 'network packet size (B)',
                  4096,
                  'Network packet size is not the default value'
       ) AS R(setting, recommendedvalue, errormsg)
WHERE  c.name = R.setting
       AND CONVERT(INT, c.value) <> R.recommendedvalue
UNION ALL
SELECT 'General',
       'Not recommended instance configuration',
       'Affinity Mask and Affinity I/O Mask',
       'Current Affinity Mask and Affinity I/O Mask are overlaping'
FROM
       (
           SELECT
               (
                   SELECT CONVERT(INT, value)
                   FROM   sys.configurations
                   WHERE  name = 'affinity mask'
               ) AS "affin",
               (
                   SELECT CONVERT(INT, value)
                   FROM   sys.configurations
                   WHERE  name = 'affinity I/O mask'
               ) AS "affinIO",
               (
                   SELECT CONVERT(INT, value)
                   FROM   sys.configurations
                   WHERE  name = 'affinity64 mask'
               ) AS "affin64",
               (
                   SELECT CONVERT(INT, value)
                   FROM   sys.configurations
                   WHERE  name = 'affinity64 I/O mask'
               ) AS "affin64IO"
       ) AS V
WHERE  (affin & affinIO <> 0)
       OR
       (
           affin & affinIO <> 0
           AND affin64 & affin64IO <> 0
       )
UNION ALL
SELECT 'General',
       'Not recommended instance configuration',
       'Blocked Process Threshold',
       'Setting is not the recommended value. If not disabled, value should be higher than 4'
FROM
       (
           SELECT CONVERT(INT, value) AS "block_threshold"
           FROM   sys.configurations
           WHERE  name = 'blocked process threshold (s)'
       ) AS V
WHERE  block_threshold > 0
       AND block_threshold < 5
UNION ALL
SELECT 'General',
       'Not recommended instance configuration',
       'min memory per query (KB) and index create memory (KB)',
       'Index create memory should not be less than Min memory per query'
FROM
       (
           SELECT
               (
                   SELECT CONVERT(INT, value)
                   FROM   sys.configurations
                   WHERE  name = 'min memory per query (KB)'
               ) AS "minmemqry",
               (
                   SELECT CONVERT(INT, value)
                   FROM   sys.configurations
                   WHERE  name = 'index create memory (KB)'
               ) AS "ixmem"
       ) AS V
WHERE  ixmem > 0
       AND ixmem < minmemqry
UNION ALL
SELECT 'Performance',
       'Not recommended instance configuration',
       'Max worker threads',
       R.errormsg
FROM
       (
           SELECT 'Max worker threads should not be larger than 2048 on a x64 system'
           WHERE  @mwthreads > 2048
                  AND @arch = 64
           UNION ALL
           SELECT 'Max worker threads should not be larger than 1024 on a x86 system'
           WHERE  @mwthreads > 1024
                  AND @arch = 32
       ) AS R(errormsg);

-- Check Failed Login Auditing

DECLARE @AuditLevel INT;
EXEC xp_instance_regread @rootkey = 'HKEY_LOCAL_MACHINE',
                         @key = 'Software\Microsoft\MSSQLServer\MSSQLServer',
                         @value_name = 'AuditLevel',
                         @value = @AuditLevel OUTPUT;

-- Check SQL Default Port Using system registry (dynamic port):

DECLARE @portNo NVARCHAR(10);
EXEC xp_instance_regread @rootkey = 'HKEY_LOCAL_MACHINE',
                         @key = 'Software\Microsoft\Microsoft SQL Server\MSSQLServer\SuperSocketNetLib\Tcp\IpAll',
                         @value_name = 'TcpDynamicPorts',
                         @value = @portNo OUTPUT;

-- Using system registry (static port):

IF @portNo IS NULL
    EXEC xp_instance_regread @rootkey = 'HKEY_LOCAL_MACHINE',
                             @key = 'Software\Microsoft\Microsoft SQL Server\MSSQLServer\SuperSocketNetLib\Tcp\IpAll',
                             @value_name = 'TcpPort',
                             @value = @portNo OUTPUT;

INSERT INTO @Alerts
SELECT 'Security',
       N'Not recommended instance security configuration',
       ObjectName,
       Report
FROM
       (
           SELECT N'TCPIP Port',
                  N'SQL Sever port should not be the default 1433'
           WHERE  @portNo = '1433'
           UNION ALL
           SELECT N'Failed Logins Auditing',
                  N'Failed Logins should be audited'
           WHERE  @AuditLevel NOT IN ( 2, 3 )
           UNION ALL
           SELECT N'SA login',
                  N'SA server login should be renamed and/or disabled'
           FROM   sys.server_principals
           WHERE  sid = 0x01
                  AND name = 'sa'
                  AND is_disabled = 0
           UNION ALL
           SELECT     QUOTENAME(a.name),
                      N'Security vulnerability detected in authentication settings of linked server (anyone can access it)'
           FROM       sys.servers AS a
           INNER JOIN sys.linked_logins AS b
               ON b.server_id = a.server_id
           WHERE      b.local_principal_id = 0
                      AND uses_self_credential = 0
                      AND a.server_id <> 0
       ) AS v(ObjectName, Report)
UNION ALL
SELECT 'Security',
       'Not recommended instance security configuration',
       R.setting,
       R.errormsg + N' (current value: ' + CONVERT(NVARCHAR, c.value) + N', recommended value: '
       + CONVERT(NVARCHAR, R.recommendedvalue) + ')'
FROM   sys.configurations AS c
CROSS APPLY
       (
           SELECT 'clr enabled',
                  0,
                  'CLR Integration recommended to be disabled'
           UNION ALL
           SELECT 'xp_cmdshell',
                  0,
                  'XP_CMDSHELL recommended to be disabled'
           UNION ALL
           SELECT 'Ole Automation Procedures',
                  0,
                  'Ole Automation Procedures setting is not the recommended value'
           UNION ALL
           SELECT 'remote admin connections',
                  1,
                  'DAC listener should be enabled on clustered servers'
           WHERE  CONVERT(BIT, SERVERPROPERTY('IsClustered')) = 1
           UNION ALL
           SELECT 'remote admin connections',
                  0,
                  'DAC listener should be disabled on non-clustered servers'
           WHERE  CONVERT(BIT, SERVERPROPERTY('IsClustered')) = 0
       ) AS R(setting, recommendedvalue, errormsg)
WHERE  c.name = R.setting
       AND CONVERT(INT, c.value) <> R.recommendedvalue;



DECLARE @DBCC AS TABLE
(
    RowId INT NOT NULL IDENTITY(1, 1),
    ParentObject VARCHAR(255),
    Object VARCHAR(255),
    Field VARCHAR(255),
    Value VARCHAR(255)
);

INSERT INTO @DBCC
EXEC sp_MSforeachdb 'IF EXISTS (SELECT [name] FROM master.sys.databases WITH (NOLOCK) WHERE database_id NOT IN (2,3) AND is_read_only = 0 AND [state] = 0 AND [name] = ''?'')
BEGIN
	USE [?];
	DBCC DBINFO WITH TABLERESULTS, NO_INFOMSGS;
	SELECT NULL, ''DBINFO STRUCTURE'', ''DatabaseName'', DB_NAME();
END';

INSERT INTO @Alerts
SELECT N'Integrity Checks',
       b.SubCategpry,
       b.ObjectName,
       ErrorDescription
FROM
       (
           SELECT *
           FROM
                  (
                      SELECT 'Database needs purity checks' AS "SubCategpry",
                             (
                                 SELECT   TOP 1
                                          c.Value
                                 FROM     @DBCC AS c
                                 WHERE    c.ParentObject IS NULL
                                          AND c.Field = 'DatabaseName'
                                          AND c.RowId > m.RowId
                                 ORDER BY c.RowId ASC
                             ) AS "ObjectName",
                             'Please run DBCC CHECKDB on this database' AS "ErrorDescription"
                      FROM   @DBCC AS m
                      WHERE  Field = 'dbi_DBCCFlags'
                             AND Value = 0
                  ) AS a
           WHERE  ObjectName NOT IN ( 'master', 'model' )
           UNION ALL
           SELECT 'Database integrity checks have not been performed' AS "SubCategpry",
                  (
                      SELECT   TOP 1
                               c.Value
                      FROM     @DBCC AS c
                      WHERE    c.ParentObject IS NULL
                               AND c.Field = 'DatabaseName'
                               AND c.RowId > m.RowId
                      ORDER BY c.RowId ASC
                  ) AS "ObjectName",
                  'Last known good DBCC CHECKDB: '
                  + ISNULL(NULLIF(CONVERT(VARCHAR(50), Value, 121), '1900-01-01 00:00:00.000'), 'never') AS "ErrorDescription"
           FROM   @DBCC AS m
           WHERE  Field LIKE 'dbi_dbccLastKnownGood%'
                  AND
                  (
                      Value IS NULL
                      OR CONVERT(DATETIME, Value) < DATEADD(dd, -7, GETDATE())
                  )
       ) AS b;


INSERT INTO @Alerts
SELECT    'General',
          'Invalid database owner',
          QUOTENAME(db.name),
          'Login may have been deleted, or the database was copied from another server. Please set a new valid owner for the database.'
FROM      sys.databases AS db
LEFT JOIN sys.server_principals AS sp
    ON db.owner_sid = sp.sid
WHERE     sp.sid IS NULL
          AND db.state = 0;


INSERT INTO @Alerts
SELECT    'Automation',
          'Missing Agent Alert(s)',
          'Missing Agent Alert(s) for Severity ' + CONVERT(VARCHAR(10), msgs.severity),
          'Error ' + CONVERT(VARCHAR(10), msgs.message_id) + ': ' + msgs.text
FROM
          (
              SELECT error AS "message_id",
                     severity,
                     description AS "text"
              FROM   sysmessages
              WHERE  msglangid = 1033 -- en-US
                     AND error IN ( 823, 824, 825, 832, 5180, 8966, 605, 610, 2511, 5228, 5229, 5242, 5243, 5250, 5572, 9100,
                                    28036
                                  )
          ) AS msgs
LEFT JOIN msdb.dbo.sysalerts AS a
    ON msgs.severity = a.severity
       OR msgs.message_id = a.message_id
WHERE     a.id IS NULL;



SET NOCOUNT ON;
DECLARE @db   sysname,
        @user NVARCHAR(MAX);
INSERT INTO @Alerts
EXEC sp_MSforeachdb '
IF EXISTS (SELECT * FROM sys.databases WHERE state_desc = ''ONLINE'' AND name = ''?'')
SELECT ''Security'', ''Orphaned User(s) in [?]'', dp.name
, CASE WHEN dp.name IN (SELECT name COLLATE database_default FROM sys.server_principals) THEN ''Login with same name already exists'' ELSE ''Login with same name was not found'' END
FROM [?].sys.database_principals AS dp 
LEFT JOIN sys.server_principals AS sp ON dp.SID = sp.SID 
WHERE sp.SID IS NULL 
AND authentication_type_desc = ''INSTANCE''
;';


INSERT INTO @Alerts
SELECT 'General',
       'DB Page Verification different from CHECKSUM',
       QUOTENAME(name),
       'Current setting: ' + page_verify_option_desc
FROM   sys.databases
WHERE  name NOT IN ( 'model', 'tempdb' )
       AND state = 0
       AND page_verify_option_desc <> 'CHECKSUM';


INSERT INTO @Alerts
EXEC sp_MSforeachdb '
IF EXISTS (SELECT * FROM sys.databases WHERE state_desc = ''ONLINE'' AND name = ''?'')
AND OBJECT_ID(''[?].sys.database_query_store_options'') IS NOT NULL
SELECT ''Automation'', N''Query Store'',''?'', N''Query Store Capture is on but Auto Cleanup is off!''
FROM [?].sys.database_query_store_options
WHERE 
	query_capture_mode <> 3 -- capture is on
AND size_based_cleanup_mode <> 1 -- cleanup is off
';


INSERT INTO @Alerts
SELECT 'General',
       N'@@SERVERNAME different from actual server name',
       N'@@SERVERNAME: ' + @@SERVERNAME,
       N'Actual server name: ' + CONVERT(NVARCHAR, SERVERPROPERTY('ServerName'))
WHERE  @@SERVERNAME <> CONVERT(NVARCHAR, SERVERPROPERTY('ServerName'));



INSERT INTO @Alerts
SELECT 'Corruption',
       'Suspect Page(s) Found in database ' + DB_NAME(database_id),
       N'File ID: ' + CONVERT(NVARCHAR(4000), file_id) + N' Page ID: ' + CONVERT(NVARCHAR(4000), page_id),
       CASE event_type
           WHEN 1 THEN
               'Error 823 or unspecified Error 824'
           WHEN 2 THEN
               'Bad Checksum'
           WHEN 3 THEN
               'Torn Page'
       END + N' (Count: ' + CONVERT(NVARCHAR(4000), error_count) + N', Last Update: '
       + CONVERT(NVARCHAR(4000), last_update_date, 121) + N')'
FROM   msdb.dbo.suspect_pages WITH (NOLOCK)
WHERE  event_type IN ( 1, 2, 3 );


INSERT INTO @Alerts
EXEC sp_MSforeachdb '
IF EXISTS (SELECT * FROM sys.databases WHERE state_desc = ''ONLINE'' AND name = ''?'')
SELECT ''General'', ''Untrusted Check Constraint(s)'', ''?'', QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id, DB_ID(''?''))) + ''.'' + QUOTENAME(OBJECT_NAME(parent_object_id, DB_ID(''?''))) + ''.'' + QUOTENAME(name)
FROM [?].sys.check_constraints
WHERE is_not_trusted = 1 AND is_not_for_replication = 0 AND is_disabled = 0';


INSERT INTO @Alerts
EXEC sp_MSforeachdb '
IF EXISTS (SELECT * FROM sys.databases WHERE state_desc = ''ONLINE'' AND name = ''?'')
SELECT ''General'', ''Untrusted Foreign Key(s)'', ''?'', QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id, DB_ID(''?''))) + ''.'' + QUOTENAME(OBJECT_NAME(parent_object_id, DB_ID(''?''))) + ''.'' + QUOTENAME(name)
FROM [?].sys.foreign_keys
WHERE is_not_trusted = 1 AND is_not_for_replication = 0 AND is_disabled = 0';


INSERT INTO @Alerts
SELECT 'General',
       'Database is not online!',
       QUOTENAME(db.name),
       'Database status is ' + db.state_desc
FROM   sys.databases AS db
JOIN   sys.database_mirroring AS dm
    ON db.database_id = dm.database_id
WHERE  is_in_standby = 0
       AND is_read_only = 0
       AND ISNULL(dm.mirroring_role, 1) <> 2
       AND state_desc <> 'ONLINE';


INSERT INTO @Alerts
SELECT     'Automation',
           'DB Mail Error',
           'MailItemID ' + CONVERT(VARCHAR, fi.mailitem_id),
           ' Recipient(s): "' + fi.recipients + ISNULL(';' + NULLIF(fi.copy_recipients, ''), '')
           + ISNULL(';' + NULLIF(fi.blind_copy_recipients, ''), '') + '", Subject: "' + fi.subject + '", Error Message: "'
           + el.description + '"'
FROM       msdb.dbo.sysmail_event_log AS el
INNER JOIN msdb.dbo.sysmail_faileditems AS fi
    ON el.mailitem_id = fi.mailitem_id
WHERE      el.event_type = 'error'
           AND el.log_date >= DATEADD(MINUTE, -@MinutesBackToCheck, GETDATE())
ORDER BY   el.log_date DESC;



IF OBJECT_ID('tempdb..#err_log_tmp') IS NOT NULL
    DROP TABLE #err_log_tmp;
CREATE TABLE #err_log_tmp
(
    ArchiveNo INT,
    CreateDate NVARCHAR(128),
    Size INT
);

INSERT INTO #err_log_tmp
EXEC master.dbo.sp_enumerrorlogs;

DECLARE @currentlogid INT,
        @createdate   DATETIME,
        @currfilesize INT;

SELECT   TOP 1
         @currentlogid = er.ArchiveNo,
         @createdate = CONVERT(DATETIME, er.CreateDate, 101),
         @currfilesize = er.Size
FROM     #err_log_tmp AS er
ORDER BY ArchiveNo ASC;

DROP TABLE #err_log_tmp;

IF ROUND(CONVERT(FLOAT, @currfilesize) / 1024, 2) > @MaxSQLErrorLogSize
BEGIN
    INSERT INTO @Alerts
    SELECT 'Performance',
           'SQL Server Error Log Size Too Big',
           'SQL Server Error Log Size is ' + CONVERT(NVARCHAR(4000), ROUND(CONVERT(FLOAT, @currfilesize) / 1024, 2))
           + N' MB.',
           'Please use sp_cycle_errorlog to cycle the Error Log periodically!';
END;




DECLARE @drives TABLE
(
    drive VARCHAR(2),
    MBFree INT
);

INSERT INTO @drives
EXEC master.dbo.xp_fixeddrives;

INSERT INTO @Alerts
SELECT 'Resources',
       'Free Disk Space',
       'Disk ' + drive,
       'Volume has only ' + CONVERT(VARCHAR(50), MBFree) + ' MB free space'
FROM   @drives
WHERE  MBFree < @FreespaceMinimumMB
       AND drive NOT IN ( 'Q' );

INSERT INTO @Alerts
SELECT 'Resources',
       'Free Disk Space',
       'Disk ' + drive,
       'Volume has only ' + CONVERT(VARCHAR(5), CONVERT(FLOAT, percentfree)) + ' % free space'
FROM
       (
           SELECT      DISTINCT
                       REPLACE(Stat.volume_mount_point, ':\', '') AS "drive",
                       ROUND(Stat.available_bytes * 100.0 / Stat.total_bytes, 2) AS "percentfree"
           FROM        sys.master_files AS dbfiles
           CROSS APPLY sys.dm_os_volume_stats(dbfiles.database_id, dbfiles.file_id) AS Stat
       ) AS D
WHERE  D.percentfree < @FreespaceMinimumPercent;



DECLARE @log AS TABLE
(
    logdate DATETIME,
    info VARCHAR(25),
    data VARCHAR(200)
);

INSERT INTO @log
EXECUTE sp_readerrorlog 0, 1, 'Login failed';

IF
(
    SELECT COUNT(*) AS "occurences"
    FROM   @log
    WHERE  logdate > DATEADD(MINUTE, -@MinutesBackToCheck, GETDATE())
) >= 10
BEGIN
    INSERT INTO @Alerts
    SELECT 'Security',
           N'High Number of Failed Login Attempts',
           CONVERT(NVARCHAR(25), logdate, 121),
           data
    FROM   @log
    WHERE  logdate > DATEADD(MINUTE, -@MinutesBackToCheck, GETDATE());
END;




IF OBJECT_ID('tempdb..#IdentityColumns') IS NOT NULL
    DROP TABLE #IdentityColumns;
CREATE TABLE #IdentityColumns
(
    DatabaseName sysname,
    SchemaName sysname,
    TableName sysname,
    ColumnName sysname,
    LastValue SQL_VARIANT,
    MaxValue SQL_VARIANT,
    PercentUsed DECIMAL(10, 2)
);

EXEC sp_MSforeachdb 'IF EXISTS (SELECT * FROM sys.databases WHERE name = ''?'' AND state_desc = ''ONLINE'')
INSERT INTO  #IdentityColumns(DatabaseName,SchemaName,TableName,ColumnName,LastValue,MaxValue,PercentUsed)	
SELECT ''?'' DatabaseName,
	OBJECT_SCHEMA_NAME(identity_columns.object_id, DB_ID(''?'')) SchemaName, OBJECT_NAME(identity_columns.object_id, DB_ID(''?'')) TableName
	, columns.name ColumnName, Last_Value LastValue, Calc1.MaxValue, Calc2.Percent_Used						
FROM		[?].sys.identity_columns WITH (NOLOCK)
INNER JOIN	[?].sys.columns WITH (NOLOCK) ON columns.column_id = identity_columns.column_id AND columns.object_id = identity_columns.object_id
INNER JOIN	[?].sys.types ON types.system_type_id = columns.system_type_id
CROSS APPLY (SELECT MaxValue = CASE WHEN identity_columns.max_length = 1 THEN 256 ELSE POWER(2.0, identity_columns.max_length * 8 - 1) - 1 END) Calc1
CROSS APPLY (SELECT Percent_Used = CAST(CAST(Last_Value AS FLOAT) *100.0/MaxValue AS DECIMAL(10, 2))) Calc2';

INSERT INTO @Alerts
SELECT 'General',
       'Identity Overflow Alert',
       QUOTENAME(DatabaseName),
       QUOTENAME(SchemaName) + '.' + QUOTENAME(TableName) + '.' + QUOTENAME(ColumnName) + ' last value: '
       + CONVERT(VARCHAR(MAX), LastValue) + ' (' + CONVERT(VARCHAR(MAX), PercentUsed) + ' %)'
FROM   #IdentityColumns
WHERE  PercentUsed >= 80;

DROP TABLE #IdentityColumns;



INSERT INTO @Alerts
SELECT    'Automation',
          'Invalid Job Owner',
          sj.name COLLATE DATABASE_DEFAULT,
          N'Invalid Owner SID: ' + CONVERT(NVARCHAR(4000), sj.owner_sid, 1)
FROM      msdb.dbo.sysjobs_view AS sj
LEFT JOIN master.dbo.syslogins AS sl
    ON sj.owner_sid = sl.sid
WHERE     sj.enabled = 1
          AND sl.sid IS NULL;


INSERT INTO @Alerts
SELECT 'Automation',
       'Failed Job(s)',
       jobs.name,
       ISNULL(jobServ.last_outcome_message, N'') + N' ('
       + CONVERT(NVARCHAR, msdb.dbo.agent_datetime(last_run_date, last_run_time), 121) + N')'
FROM   msdb..sysjobservers AS jobServ
JOIN   msdb..sysjobs AS jobs
    ON jobServ.job_id = jobs.job_id
WHERE  last_run_outcome IN ( 0, 3 )
       AND last_run_date > 0
       AND enabled = 1;


IF OBJECT_ID('tempdb..#logshipstats') IS NOT NULL
    DROP TABLE #logshipstats;
CREATE TABLE #logshipstats
(
    status BIT,
    is_primary BIT,
    server sysname,
    database_name sysname,
    time_since_last_backup INT,
    last_backup_file NVARCHAR(500),
    backup_threshold INT,
    is_backup_alert_enabled BIT,
    time_since_last_copy INT,
    last_copied_file NVARCHAR(500),
    time_since_last_restore INT,
    last_restored_file NVARCHAR(500),
    last_restored_latency INT,
    restore_threshold INT,
    is_restore_alert_enabled BIT
);

INSERT INTO #logshipstats
EXEC master..sp_help_log_shipping_monitor;

INSERT INTO @Alerts
SELECT 'HADR',
       'Log Shipping Alert',
       database_name + ' (' + CASE is_primary
                                  WHEN 1 THEN
                                      'Primary'
                                  ELSE
                                      'Secondary'
                              END + ')',
       CASE
           WHEN is_backup_alert_enabled = 1
                AND time_since_last_backup > backup_threshold THEN
               'Backup Threshold Alert! Last File Backed up: ' + ISNULL(last_backup_file, '(null)')
           WHEN is_restore_alert_enabled = 1
                AND time_since_last_restore > last_restored_latency THEN
               'Restore Threshold Alert! Last Restored File: ' + ISNULL(last_restored_file, '(null)')
           ELSE
               'Status is not healthy!'
       END
FROM   #logshipstats
WHERE  status = 1
       OR
       (
           is_backup_alert_enabled = 1
           AND time_since_last_backup > backup_threshold
       )
       OR
       (
           is_restore_alert_enabled = 1
           AND time_since_last_restore > last_restored_latency
       );


INSERT INTO @Alerts
SELECT 'Resources',
       'Low SQL Memory Alert',
       CASE
           WHEN process_physical_memory_low = 1
                AND process_virtual_memory_low = 1 THEN
               'Physical and Virtual'
           WHEN process_physical_memory_low = 1 THEN
               'Physical'
           WHEN process_virtual_memory_low = 1 THEN
               'Virtual'
       END + ' SQL Memory Low!',
       'You may need to increase SQL Max Memory setting, or add more RAM to the server'
FROM   sys.dm_os_process_memory WITH (NOLOCK)
WHERE  process_physical_memory_low = 1
       OR process_virtual_memory_low = 1;


INSERT INTO @Alerts
SELECT      TOP 1
            'Resources',
            'Low Windows Memory Alert',
            'Low Windows Memory Notification Detected',
            'You may need to lower SQL Max Memory setting, or add more RAM to the server'
FROM
            (
                SELECT     CAST(orb.record AS XML) AS "xmlRec"
                FROM       sys.dm_os_ring_buffers AS orb
                CROSS JOIN sys.dm_os_sys_info AS osi
                WHERE      orb.ring_buffer_type = 'RING_BUFFER_RESOURCE_MONITOR'
                           AND DATEADD(SECOND, - ((osi.cpu_ticks / (osi.cpu_ticks / osi.ms_ticks) - orb.timestamp) / 1000), GETDATE()) > DATEADD(
                                                                                                                                                    MINUTE,
                                                                                                                                                    -@MinutesBackToCheck,
                                                                                                                                                    GETDATE()
                                                                                                                                                )
            ) AS rb
CROSS APPLY rb.xmlRec.nodes('Record') AS rec(x)
WHERE       rec.x.value('(ResourceMonitor/IndicatorsSystem)[1]', 'tinyint') = 2;

IF OBJECT_ID('msdb.dbo.dbm_monitor_data') IS NOT NULL
BEGIN
    INSERT INTO @Alerts
    SELECT N'HADR',
           'Database Mirroring Alert ',
           DB_NAME(database_id) + ' (' + CASE role
                                             WHEN 1 THEN
                                                 'Principal'
                                             WHEN 2 THEN
                                                 'Mirror'
                                             ELSE
                                                 RTRIM(STR(role))
                                         END + ')',
           CASE
               WHEN status NOT IN ( 2, 4 ) THEN
                   'Mirroring State is ' + CASE status
                                               WHEN 0 THEN
                                                   'Suspended'
                                               WHEN 1 THEN
                                                   'Disconnected'
                                               WHEN 3 THEN
                                                   'Pending Failover'
                                               ELSE
                                                   RTRIM(STR(status))
                                           END
               WHEN witness_status = 2 THEN
                   'Witness Status is Disconnected' --RTRIM(STR([witness_status]))
               ELSE
                   STUFF(   CASE
                                WHEN transaction_delay > @TransactionDelayThresholdMil THEN
                                    ', Transaction Delay is ' + RTRIM(STR(transaction_delay))
                                ELSE
                                    ''
                            END + CASE
                                      WHEN send_queue_size > @UnsentLogThresholdKB THEN
                                          ', Unsent Log is ' + RTRIM(STR(send_queue_size))
                                      ELSE
                                          ''
                                  END + CASE
                                            WHEN redo_queue_size > @UnrestoredLogThresholdKB THEN
                                                ', Unrestored Log is ' + RTRIM(STR(redo_queue_size))
                                            ELSE
                                                ''
                                        END,
                            1,
                            2,
                            ''
                        )
           END
    FROM
           (
               SELECT *,
                      ROW_NUMBER() OVER (PARTITION BY database_id ORDER BY time DESC) AS "RankPerDB"
               FROM   msdb.dbo.dbm_monitor_data
           ) AS d
    WHERE  RankPerDB = 1
           AND
           (
               status NOT IN ( 2, 4 )
               OR witness_status = 2
               OR send_queue_size > @UnsentLogThresholdKB
               OR redo_queue_size > @UnrestoredLogThresholdKB
               OR transaction_delay > @TransactionDelayThresholdMil
           );
END;


DECLARE @passwords TABLE
(
    Deviation NVARCHAR(100),
    Name sysname,
    CreateDate DATETIME
);
DECLARE @word TABLE
(
    word NVARCHAR(50)
);
INSERT INTO @word
VALUES ('0'),
       ('1'),
       ('12'),
       ('123'),
       ('1234'),
       ('12345'),
       ('123456'),
       ('1234567'),
       ('12345678'),
       ('123456789'),
       ('1234567890'),
       ('11111'),
       ('111111'),
       ('1111111'),
       ('11111111'),
       ('21'),
       ('321'),
       ('4321'),
       ('54321'),
       ('654321'),
       ('7654321'),
       ('87654321'),
       ('987654321'),
       ('0987654321'),
       ('pwd'),
       ('Password'),
       ('Password1'),
       ('password'),
       ('P@ssw0rd'),
       ('p@ssw0rd'),
       ('Teste'),
       ('teste'),
       ('Test'),
       ('Test1'),
       ('test'),
       (''),
       ('p@wd'),
       ('qwerty'),
       ('Qwerty');

INSERT INTO @passwords
SELECT     DISTINCT
           'Weak or Common Password' AS "Deviation",
           RTRIM(s.name) AS "Name",
           createdate AS "CreateDate"
FROM       @word AS d
INNER JOIN master.sys.syslogins AS s
    ON PWDCOMPARE(RTRIM(RTRIM(d.word)), s.password) = 1
UNION ALL
SELECT 'NULL Password' AS "Deviation",
       RTRIM(name) AS "Name",
       createdate AS "CreateDate"
FROM   master.sys.syslogins
WHERE  password IS NULL
       AND isntname = 0
       AND Name NOT IN ( 'MSCRMSqlClrLogin', '##MS_SmoExtendedSigningCertificate##', '##MS_PolicySigningCertificate##',
                         '##MS_SQLResourceSigningCertificate##', '##MS_SQLReplicationSigningCertificate##',
                         '##MS_SQLAuthenticatorCertificate##', '##MS_AgentSigningCertificate##',
                         '##MS_SQLEnableSystemAssemblyLoadingUser##'
                       )
UNION ALL
SELECT DISTINCT
       'Login Name is the same as Password' AS "Deviation",
       RTRIM(s.name) AS "Name",
       createdate AS "CreateDate"
FROM   master.sys.syslogins AS s
WHERE  PWDCOMPARE(RTRIM(RTRIM(s.name)), s.password) = 1
ORDER BY Deviation,
         Name;

INSERT INTO @Alerts
SELECT   'Security',
         'Login Password Strength Check Failed',
         Name,
         Deviation
FROM     @passwords
ORDER BY Deviation,
         Name;


INSERT INTO @Alerts
EXEC sp_MSforeachdb '
IF EXISTS (SELECT * FROM sys.databases WHERE state_desc = ''ONLINE'' AND name = ''?'')
AND OBJECT_ID(''[?].sys.database_query_store_options'') IS NOT NULL
SELECT ''Automation'', ''Query Store Status Alert'', ''[?]'', N''Desired State is: '' + desired_state_desc + N'', Actual State: '' + actual_state_desc
FROM [?].sys.database_query_store_options
WHERE 
(actual_state_desc = ''ERROR'' OR desired_state <> actual_state)
AND NOT EXISTS
(
SELECT ags.primary_replica, adc.*
FROM sys.availability_databases_cluster adc
INNER JOIN sys.dm_hadr_availability_group_states ags
ON adc.group_id = ags.group_id
WHERE adc.database_name = ''?''
AND ags.primary_replica <> @@SERVERNAME
);';


IF OBJECT_ID('distribution.sys.sp_replmonitorhelppublication') IS NOT NULL
BEGIN
    -- Check replication status
    DECLARE @temp_Pub TABLE
    (
        publisher_db sysname,
        publication sysname NULL,
        publication_id sysname NULL,
        publication_type INT,
        status INT,
        warning INT,
        worst_latency INT,
        best_latency INT,
        average_latency INT,
        last_distsync DATETIME,
        retention INT,
        latencythreshold INT,
        expirationthreshold INT,
        agentnotrunningthreshold INT,
        subscriptioncount INT,
        runningdistagentcount INT,
        snapshot_agentname sysname NULL,
        logreader_agentname sysname NULL,
        qreader_agentname sysname NULL,
        worst_runspeedPerf INT,
        best_runspeedPerf INT,
        average_runspeedPerf INT,
        retention_period_unit TINYINT
    );

    INSERT INTO @temp_Pub
    EXECUTE ('EXEC distribution.sys.sp_replmonitorhelppublication');

    INSERT INTO @Alerts
    SELECT 'HADR',
           'Replication Error(s)',
           'Publication status is Failed!',
           'LogReader Agent: ' + logreader_agentname + ',  Snapshot Agent: ' + snapshot_agentname
    FROM   @temp_Pub
    WHERE  status = 6;

END;


INSERT INTO @Alerts
SELECT 'Automation',
       'SQLServerAgent Service',
       'SQL Server Agent service is not running or connected!',
       'Jobs and Alerts will not work until you start the SQL Server Agent service'
WHERE  NOT EXISTS
(
    SELECT *
    FROM   master.dbo.sysprocesses
    WHERE  program_name = 'SQLAgent - Generic Refresher'
)
       AND CONVERT(NVARCHAR(200), SERVERPROPERTY('Edition')) NOT LIKE 'Express%';


DECLARE @cpucount     INT,
        @affined_cpus INT;
SELECT @cpucount = COUNT(cpu_id)
FROM   sys.dm_os_schedulers
WHERE  scheduler_id < 255
       AND parent_node_id < 64;
SELECT @numa = COUNT(DISTINCT parent_node_id)
FROM   sys.dm_os_schedulers
WHERE  scheduler_id < 255
       AND parent_node_id < 64;
SELECT @affined_cpus = COUNT(cpu_id)
FROM   sys.dm_os_schedulers
WHERE  is_online = 1
       AND scheduler_id < 255
       AND parent_node_id < 64;

INSERT INTO @Alerts
SELECT 'Performance',
       'Not recommended Max DOP setting',
       N'Recommended MaxDOP: ' + CONVERT(NVARCHAR, Recommended_MaxDOP) + N', Current MaxDOP: '
       + CONVERT(NVARCHAR, Current_MaxDOP) + N', CPUs: ' + CONVERT(NVARCHAR, Available_Processors),
       Deviation
FROM
       (
           SELECT CASE
                      WHEN value > @affined_cpus THEN
                          'MaxDOP setting exceeds available processor count (affinity)'
                      WHEN @numa = 1
                           AND @affined_cpus > 8
                           AND
                           (
                               value = 0
                               OR value > 8
                           ) THEN
                          'MaxDOP setting is not recommended for current processor count (affinity)'
                      WHEN @numa > 1
                           AND (@cpucount / @numa) < 8
                           AND
                           (
                               value = 0
                               OR value > (@cpucount / @numa)
                           ) THEN
                          'MaxDOP setting is not recommended for current NUMA node to processor count (affinity) ratio'
                      WHEN @numa > 1
                           AND (@cpucount / @numa) >= 8
                           AND
                           (
                               value = 0
                               OR value > 8
                               OR value > (@cpucount / @numa)
                           ) THEN
                          'MaxDOP setting is not recommended for current NUMA node to processor count (affinity) ratio'
                      ELSE
                          '[OK]'
                  END AS "Deviation",
                  CASE
                      WHEN value > @affined_cpus THEN
                          @affined_cpus
                      WHEN @numa = 1
                           AND @affined_cpus > 8
                           AND
                           (
                               value = 0
                               OR value > 8
                           ) THEN
                          8
                      WHEN @numa > 1
                           AND (@cpucount / @numa) < 8
                           AND
                           (
                               value = 0
                               OR value > (@cpucount / @numa)
                           ) THEN
                          @cpucount / @numa
                      WHEN @numa > 1
                           AND (@cpucount / @numa) >= 8
                           AND
                           (
                               value = 0
                               OR value > 8
                               OR value > (@cpucount / @numa)
                           ) THEN
                          8
                      ELSE
                          0
                  END AS "Recommended_MaxDOP",
                  value AS "Current_MaxDOP",
                  @cpucount AS "Available_Processors",
                  @affined_cpus AS "Affined_Processors"
           FROM   sys.configurations (NOLOCK)
           WHERE  name = 'max degree of parallelism'
       ) AS a
WHERE  Deviation <> '[OK]'
--OR [Current_MaxDOP] = 0
;


DECLARE @ifi BIT;
DECLARE @xp_cmdshell_output2 TABLE
(
    Output VARCHAR(8000)
);
INSERT INTO @xp_cmdshell_output2
EXEC master.dbo.xp_cmdshell 'whoami /priv';

IF EXISTS
(
    SELECT *
    FROM   @xp_cmdshell_output2
    WHERE  Output LIKE '%SeManageVolumePrivilege%'
)
BEGIN
    SET @ifi = 1;
END;
ELSE
BEGIN
    INSERT INTO @Alerts
    SELECT 'Performance' AS "Category",
           'Instant File Initialization' AS "Check",
           'Instant File Initialization is disabled.' AS "ObjectName",
           'This can negatively impact data file autogrowth times' AS "Deviation";
    SET @ifi = 0;
END;

DECLARE @tdb_files    INT,
        @online_count INT,
        @filesizes    SMALLINT;
SELECT @tdb_files = COUNT(physical_name)
FROM   sys.master_files (NOLOCK)
WHERE  database_id = 2
       AND type = 0;
SELECT @online_count = COUNT(cpu_id)
FROM   sys.dm_os_schedulers
WHERE  is_online = 1
       AND scheduler_id < 255
       AND parent_node_id < 64;
SELECT @filesizes = COUNT(DISTINCT size)
FROM   tempdb.sys.database_files
WHERE  type = 0;

IF
(
    SELECT CASE
               WHEN @filesizes = 1
                    AND
                    (
                        (
                            @tdb_files >= 4
                            AND @tdb_files <= 8
                            AND @tdb_files % 4 = 0
                        ) /*OR (@tdb_files >= 8 AND @tdb_files % 4 = 0)*/
                        OR
                        (
                            @tdb_files >= (@online_count / 2)
                            AND @tdb_files >= 8
                            AND @tdb_files % 4 = 0
                        )
                    ) THEN
                   0
               ELSE
                   1
           END
) <> 0
BEGIN
    INSERT INTO @Alerts
    SELECT 'Performance',
           'TempDB Configuration',
           'TempDB Files',
           CASE
               WHEN @tdb_files < 4 THEN
                   'tempDB has only ' + CONVERT(VARCHAR(10), @tdb_files)
                   + ' file(s). Consider creating between 4 and 8 tempDB data files of the same size, with a minimum of 4'
               WHEN @filesizes = 1
                    AND @tdb_files < (@online_count / 2)
                    AND @tdb_files >= 8
                    AND @tdb_files % 4 = 0 THEN
                   'Number of Data files to Scheduler ratio might not be Optimal. Consider creating 1 data file per each 2 cores, in multiples of 4, all of the same size'
               WHEN @filesizes > 1
                    AND @tdb_files >= 4
                    AND @tdb_files % 4 > 0 THEN
                   'Data file sizes do not match and Number of data files is not multiple of 4'
               WHEN @filesizes = 1
                    AND @tdb_files >= 4
                    AND @tdb_files % 4 > 0 THEN
                   'Number of data files is not multiple of 4'
               WHEN @filesizes > 1
                    AND @tdb_files >= 4
                    AND @tdb_files % 4 = 0 THEN
                   'Data file sizes do not match'
               ELSE
                   '[OK]'
           END AS "Deviation";
END;

--------------------------------------------------------------------------------------------------------------------------------
-- tempDB data files autogrow of equal size subsection
--------------------------------------------------------------------------------------------------------------------------------
IF
(
    SELECT COUNT(DISTINCT growth)
    FROM   sys.master_files
    WHERE  database_id = 2
           AND type = 0
) > 1
OR
(
    SELECT COUNT(DISTINCT is_percent_growth)
    FROM   sys.master_files
    WHERE  database_id = 2
           AND type = 0
) > 1
BEGIN
    INSERT INTO @Alerts
    SELECT   'Performance' AS "Category",
             'TempDB Configuration',
             'Some tempDB data files have different growth settings' AS "Information",
             mf.name + N' (' + mf.type_desc + N'): ' + CONVERT(NVARCHAR, mf.size * 8) + N' KB, auto growth: '
             + CONVERT(   NVARCHAR,
                          CASE
                              WHEN is_percent_growth = 1 THEN
                                  mf.growth
                              ELSE
                                  mf.growth * 8
                          END
                      ) + CASE
                              WHEN is_percent_growth = 1 THEN
                                  'pct'
                              ELSE
                                  'pages'
                          END + N', next growth: ' + CONVERT(   NVARCHAR,
                                                                CASE
                                                                    WHEN is_percent_growth = 1
                                                                         AND mf.growth > 0 THEN
                                                                ((mf.size * 8) * CONVERT(BIGINT, mf.growth)) / 100
                                                                    WHEN is_percent_growth = 0
                                                                         AND mf.growth > 0 THEN
                                                                        mf.growth * 8
                                                                    ELSE
                                                                        0
                                                                END
                                                            ) + N', ' + CASE
                                                                            WHEN @ifi = 0
                                                                                 AND mf.type = 0 THEN
                                                                                'Instant File Initialization is disabled'
                                                                            WHEN @ifi = 1
                                                                                 AND mf.type = 0 THEN
                                                                                'Instant File Initialization is enabled'
                                                                            ELSE
                                                                                ''
                                                                        END
    FROM     tempdb.sys.database_files AS mf (NOLOCK)
    WHERE    type = 0
    GROUP BY mf.name,
             mf.size,
             is_percent_growth,
             mf.growth,
             mf.type_desc,
             mf.type;
END;

SELECT   *
FROM     @Alerts
ORDER BY 1,
         2,
         3;