IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'ZKH_V0000')
BEGIN
	DROP VIEW ZKH_V0000
END
GO
CREATE VIEW ZKH_V0000
AS
SELECT 'ZKH_V0000'               AS sdNaam
     , 'Overzicht alle views'    AS sdOmchrijving
     , 'Robert Meijer'           AS sdAuteur
     , '2014-01-21'              AS ddGemaakt
     , '0.1'                     AS ndVersie
     , 'Robert Meijer'           AS sdGewijzigdDoor
     , '2014-01-21'              AS ddLaatsteWijziging
UNION
SELECT 'ZKH_V0001' 
     , 'Omgeving met hotfixversie'
     , 'Robert Meijer'
     , '2014-01-21'
     , '0.1'
     , 'Robert Meijer'
     , '2014-01-21'
UNION
SELECT 'ZKH_V0002' 
     , 'Historie alle hotfixes'
     , 'Robert Meijer'
     , '2014-01-21'
     , '0.1'
     , 'Robert Meijer'
     , '2014-01-21'
UNION
SELECT 'ZKH_V0003' 
     , 'Laatste locks per database'
     , 'Maico Pijnen'
     , '2014-02-20'
     , '0.2'
     , 'Maico Pijnen'
     , '2014-03-04'
UNION
SELECT 'ZKH_V0004' 
     , 'Activity monitor'
     , 'Maico Pijnen'
     , '2014-02-27'
     , '0.1'
     , 'Maico Pijnen'
     , '2014-02-27'
UNION
SELECT 'ZKH_V0005' 
     , 'SQL PerfCounters'
     , 'Maico Pijnen'
     , '2014-03-01'
     , '0.3'
     , 'Maico Pijnen'
     , '2015-08-05'
UNION
SELECT 'ZKH_V0006' 
     , 'Table sizes'
     , 'Maico Pijnen'
     , '2014-08-11'
     , '0.0'
     , 'Maico Pijnen'
     , '2014-08-11'
UNION
SELECT 'ZKH_V0007' 
     , 'Apotheek rules'
     , 'Maico Pijnen'
     , '2014-11-10'
     , '0.1'
     , 'Maico Pijnen'
     , '2014-10-10'
GO

IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'ZKH_V0001')
BEGIN
	DROP VIEW ZKH_V0001
END
GO
CREATE VIEW ZKH_V0001
AS
SELECT b.name AS Omgeving
     , b.create_date AS DatumOmgeving
     , INDATUM AS Datum
     , LATEST_HF AS HOTFIX
  FROM ZISCON_LOGSESSI
     , sys.databases b
 WHERE APPLICATIE = 'CHIPSOFT.DATABAS' AND INDATUM =
                          (SELECT     MAX(INDATUM)
                            FROM          ZISCON_LOGSESSI
                            WHERE      APPLICATIE = 'CHIPSOFT.DATABAS') AND b.name LIKE 'HIX_%'
GO
                       
IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'ZKH_V0002')
BEGIN
	DROP VIEW ZKH_V0002
END
GO
CREATE VIEW ZKH_V0002
AS
SELECT DISTINCT INDATUM
     , LATEST_HF
  FROM ZISCON_LOGSESSI AS a
 WHERE APPLICATIE = 'CHIPSOFT.DATABAS'
GO

IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'ZKH_V0003')
BEGIN
	DROP VIEW ZKH_V0003
END
GO
CREATE VIEW ZKH_V0003
AS
SELECT      timestamp, block_orig_id AS spid, [loginame 2] AS loginname, [hostname 2] AS hostname, [program_name 2] AS programname, [cmd 2] AS query
FROM          zkh_blocklog
WHERE      (block_orig_id = [spid 2]) OR
                        (block_orig_id = spid)
GROUP BY timestamp, block_orig_id, [loginame 2], [hostname 2], [program_name 2], [cmd 2]
GO

IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'ZKH_V0004')
BEGIN
	DROP VIEW ZKH_V0004
END
GO
CREATE VIEW [dbo].[ZKH_V0004]
AS
SELECT 
   SessionId    = s.session_id, 
   UserProcess  = CONVERT(CHAR(1), s.is_user_process),
   LoginInfo    = s.login_name,   
   DbInstance   = ISNULL(db_name(r.database_id), N''), 
   TaskState    = ISNULL(t.task_state, N''), 
   Command      = ISNULL(r.command, N''), 
   App            = ISNULL(s.program_name, N''), 
   WaitTime_ms  = ISNULL(w.wait_duration_ms, 0),
   WaitType     = ISNULL(w.wait_type, N''),
   WaitResource = ISNULL(w.resource_description, N''), 
   BlockBy        = ISNULL(CONVERT (varchar, w.blocking_session_id), ''),
   HeadBlocker  = 
        CASE 
            -- session has active request; is blocked; blocking others
            WHEN r2.session_id IS NOT NULL AND r.blocking_session_id = 0 THEN '1' 
            -- session idle; has an open tran; blocking others
            WHEN r.session_id IS NULL THEN '1' 
            ELSE ''
        END, 
   TotalCPU_ms        = s.cpu_time, 
   TotalPhyIO_mb    = (s.reads + s.writes) * 8 / 1024, 
   MemUsage_kb        = s.memory_usage * 8192 / 1024, 
   OpenTrans        = ISNULL(r.open_transaction_count,0), 
   LoginTime        = s.login_time, 
   LastReqStartTime = s.last_request_start_time,
   HostName            = ISNULL(s.host_name, N''),
   NetworkAddr        = ISNULL(c.client_net_address, N''), 
   ExecContext        = ISNULL(t.exec_context_id, 0),
   ReqId            = ISNULL(r.request_id, 0),
   WorkLoadGrp        = N'',
   LastCommandBatch = (select text from sys.dm_exec_sql_text(c.most_recent_sql_handle)) 
FROM sys.dm_exec_sessions s LEFT OUTER JOIN sys.dm_exec_connections c ON (s.session_id = c.session_id)
LEFT OUTER JOIN sys.dm_exec_requests r ON (s.session_id = r.session_id)
LEFT OUTER JOIN sys.dm_os_tasks t ON (r.session_id = t.session_id AND r.request_id = t.request_id)
LEFT OUTER JOIN 
(
    -- Using row_number to select longest wait for each thread, 
    -- should be representative of other wait relationships if thread has multiple involvements. 
    SELECT *, ROW_NUMBER() OVER (PARTITION BY waiting_task_address ORDER BY wait_duration_ms DESC) AS row_num
    FROM sys.dm_os_waiting_tasks 
) w ON (t.task_address = w.waiting_task_address) AND w.row_num = 1
LEFT OUTER JOIN sys.dm_exec_requests r2 ON (r.session_id = r2.blocking_session_id)
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) as st

WHERE s.session_Id > 50                         -- ignore anything pertaining to the system spids.

AND s.session_Id NOT IN (@@SPID)     -- let's avoid our own query! :)

GO


IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'ZKH_V0005')
BEGIN
	DROP VIEW ZKH_V0005
END
GO
CREATE VIEW [dbo].[ZKH_V0005]
AS
SELECT      object_name, counter_name, instance_name, cntr_value, cntr_type
FROM          master.dbo.sysperfinfo
UNION
SELECT 
	'SQLServer:Custom',
	'Total memory usage %',
	'',
	round(100 - (cast([available_physical_memory_kb] as decimal) / cast([total_physical_memory_kb] as decimal) * 100),2),
	''
FROM 
	[master].[sys].[dm_os_sys_memory]
UNION
SELECT
	'SQLServer:Custom',
	'Total cpu usage %',
	'', 
	(
		SELECT TOP(1) 
			SQLCPUUtilization
		FROM ( 
           SELECT 
               record.value('(./Record/@id)[1]', 'int')                                                 AS RecordID, 
               record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int')           AS SystemIdle, 
               record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]','int')   AS SQLCPUUtilization,
               [timestamp] 
           FROM 
           ( 
               SELECT 
                   [timestamp], 
                   CONVERT(xml, record) AS [record] 
               FROM sys.dm_os_ring_buffers 
               WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR' 
               AND record LIKE N'%<SystemHealth>%'
           ) AS x 
        ) AS y 
		ORDER BY RecordID DESC
	),
	''
GO


IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'ZKH_V0006')
BEGIN
	DROP VIEW ZKH_V0006
END
GO
CREATE VIEW [dbo].[ZKH_V0006]
AS
SELECT 
    t.NAME AS TableName,
    s.Name AS SchemaName,
    p.rows AS RowCounts,
    SUM(a.total_pages) * 8 AS TotalSpaceKB, 
    SUM(a.used_pages) * 8 AS UsedSpaceKB, 
    (SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
WHERE 
    t.NAME NOT LIKE 'dt%' 
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255 
GROUP BY 
    t.Name, s.Name, p.Rows
GO


IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'ZKH_V0007')
BEGIN
	DROP VIEW ZKH_V0007
END
GO
CREATE VIEW [dbo].[ZKH_V0007]
AS
SELECT GEBRUIKER
     , DATUM
	 , TIJD
	 , ERRCODE
	 , CASE ERRCODE
	     WHEN '004' THEN 'Taak gestart'
	     WHEN '000' THEN 'Taak succesvol beeindigd'
	     WHEN '002' THEN 'Fout opgetreden'
		 WHEN '009' THEN 'Taak afgebroken'
	   ELSE 'Foutcode onbekend'
	   END AS FOUTCODE
     , RESULT
  FROM TAAK_TAAKLOG
 WHERE MACHINE = 'GPHIXTAAK02'
   AND TAAKID IN (SELECT ID	
	                FROM TAAK_TAAK
		           WHERE OMSCHRIJV LIKE 'Apotheek rules V2%')
   AND DATUM >= DATEADD(d, -28, getdate())
GO


IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'ZKH_V0008')
BEGIN
	DROP VIEW ZKH_V0008
END
GO
CREATE VIEW [dbo].[ZKH_V0008]
AS
SELECT [Date]
      ,[Time]
      ,[Workstation]
      ,[ProcessId]
      ,[Version]
      ,[EnvironmentID]
      ,[LogUserId]
      ,[WindowsUserName]
      ,[UserCode]
      ,[MutationUserCode]
      ,[Identifier]
      ,[Message]
      ,[MemorySnapshotId]
      ,[UnhandledExceptionId]
      ,[PerformanceLogFlushId]
      ,[AutoID]
      ,[ApplicationName]
      ,[ThreadID]
      ,[ActiveViewUri]
      ,[ExceptionType]
      ,[ExceptionMessage]
      ,[ExceptionIdentifier]
      ,[CallstackNamespace]
      ,[ActiveViewNamespace]
      ,[ScreenshotBlobId]
  FROM [LOG_LOGJIP]
GO


GRANT SELECT ON ZKH_V0001 TO SQLReport
GRANT SELECT ON ZKH_V0002 TO SQLReport
GRANT SELECT ON ZKH_V0003 TO SQLReport
GRANT SELECT ON ZKH_V0004 TO SQLReport
GRANT SELECT ON ZKH_V0005 TO SQLReport
GRANT SELECT ON ZKH_V0006 TO SQLReport
GRANT SELECT ON ZKH_V0007 TO SQLReport
GRANT SELECT ON ZKH_V0008 TO SQLReport