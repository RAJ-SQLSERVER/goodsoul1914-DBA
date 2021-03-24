USE DBA;
GO

-------------------------------------------------------------------------------
-- Start 
-------------------------------------------------------------------------------

DECLARE @LastMonitoredTime DATETIME;

SELECT @LastMonitoredTime = COALESCE (MAX (LogDate), GETDATE () - 31)
FROM dbo.ServerLogging;

IF OBJECT_ID ('tempdb.dbo.#SQLErrorLog') IS NOT NULL DROP TABLE #SQLErrorLog;
CREATE TABLE #SQLErrorLog (LogDate DATETIME, ProcessInfo NVARCHAR(200), LogText NVARCHAR(3999));

-------------------------------------------------------------------------------
-- Process all server logs
-------------------------------------------------------------------------------

INSERT INTO #SQLErrorLog (LogDate, ProcessInfo, LogText)
EXEC sp_readerrorlog;

DECLARE @file VARCHAR(255);
SELECT @file = path
FROM sys.traces
WHERE is_default = 1;

WITH TraceCTE AS
(
    SELECT DatabaseID,
           DatabaseName,
           LoginName,
           HostName,
           ApplicationName,
           SPID,
           StartTime,
           LEAD (StartTime) OVER (PARTITION BY XactSequence
ORDER BY EventSequence
                            ) AS EndTime,
           EventClass,
           CASE EventClass
               WHEN 46 THEN 'Object:Created'
               WHEN 47 THEN 'Object:Deleted'
               WHEN 164 THEN 'Object:Altered'
               WHEN 92 THEN 'Data File Auto Grow'
               WHEN 93 THEN 'Log File Auto Grow'
               WHEN 94 THEN 'Data File Auto Shrink'
               WHEN 95 THEN 'Log File Auto Shrink'
               WHEN 55 THEN 'Hash Warning'
               WHEN 69 THEN 'Sort Warnings'
               WHEN 79 THEN 'Missing Column Statistics'
               WHEN 80 THEN 'Missing Join Predicate'
               WHEN 81 THEN 'Server Memory Change'
               ELSE CAST(EventClass AS VARCHAR(MAX))
           END AS EventClassDesc,
           ObjectType,
           CASE ObjectType
               WHEN 8259 THEN 'Check Constraint'
               WHEN 8260 THEN 'Default (constraint or standalone)'
               WHEN 8262 THEN 'Foreign-key Constraint'
               WHEN 8272 THEN 'Stored Procedure'
               WHEN 8274 THEN 'Rule'
               WHEN 8275 THEN 'System Table'
               WHEN 8276 THEN 'Trigger on Server'
               WHEN 8277 THEN '(User-defined) Table'
               WHEN 8278 THEN 'View'
               WHEN 8280 THEN 'Extended Stored Procedure'
               WHEN 16724 THEN 'CLR Trigger'
               WHEN 16964 THEN 'Database'
               WHEN 16975 THEN 'Object'
               WHEN 17222 THEN 'FullText Catalog'
               WHEN 17232 THEN 'CLR Stored Procedure'
               WHEN 17235 THEN 'Schema'
               WHEN 17475 THEN 'Credential'
               WHEN 17491 THEN 'DDL Event'
               WHEN 17741 THEN 'Management Event'
               WHEN 17747 THEN 'Security Event'
               WHEN 17749 THEN 'User Event'
               WHEN 17985 THEN 'CLR Aggregate Function'
               WHEN 17993 THEN 'Inline Table-valued SQL Function'
               WHEN 18000 THEN 'Partition Function'
               WHEN 18002 THEN 'Replication Filter Procedure'
               WHEN 18004 THEN 'Table-valued SQL Function'
               WHEN 18259 THEN 'Server Role'
               WHEN 18263 THEN 'Microsoft Windows Group'
               WHEN 19265 THEN 'Asymmetric Key'
               WHEN 19277 THEN 'Master Key'
               WHEN 19280 THEN 'Primary Key'
               WHEN 19283 THEN 'ObfusKey'
               WHEN 19521 THEN 'Asymmetric Key Login'
               WHEN 19523 THEN 'Certificate Login'
               WHEN 19538 THEN 'Role'
               WHEN 19539 THEN 'SQL Login'
               WHEN 19543 THEN 'Windows Login'
               WHEN 20034 THEN 'Remote Service Binding'
               WHEN 20036 THEN 'Event Notification on Database'
               WHEN 20037 THEN 'Event Notification'
               WHEN 20038 THEN 'Scalar SQL Function'
               WHEN 20047 THEN 'Event Notification on Object'
               WHEN 20051 THEN 'Synonym'
               WHEN 20307 THEN 'Sequence'
               WHEN 20549 THEN 'End Point'
               WHEN 20801 THEN 'Adhoc Queries which may be cached'
               WHEN 20816 THEN 'Prepared Queries which may be cached'
               WHEN 20819 THEN 'Service Broker Service Queue'
               WHEN 20821 THEN 'Unique Constraint'
               WHEN 21057 THEN 'Application Role'
               WHEN 21059 THEN 'Certificate'
               WHEN 21075 THEN 'Server'
               WHEN 21076 THEN 'Transact-SQL Trigger'
               WHEN 21313 THEN 'Assembly'
               WHEN 21318 THEN 'CLR Scalar Function'
               WHEN 21321 THEN 'Inline scalar SQL Function'
               WHEN 21328 THEN 'Partition Scheme'
               WHEN 21333 THEN 'User'
               WHEN 21571 THEN 'Service Broker Service Contract'
               WHEN 21572 THEN 'Trigger on Database'
               WHEN 21574 THEN 'CLR Table-valued Function'
               WHEN 21577 THEN 'Internal Table (For example, XML Node Table, Queue Table.)'
               WHEN 21581 THEN 'Service Broker Message Type'
               WHEN 21586 THEN 'Service Broker Route'
               WHEN 21587 THEN 'Statistics'
               WHEN 21825 THEN 'User'
               WHEN 21827 THEN 'User'
               WHEN 21831 THEN 'User'
               WHEN 21843 THEN 'User'
               WHEN 21847 THEN 'User'
               WHEN 22099 THEN 'Service Broker Service'
               WHEN 22601 THEN 'Index'
               WHEN 22604 THEN 'Certificate Login'
               WHEN 22611 THEN 'XMLSchema'
               WHEN 22868 THEN 'Type'
               ELSE CAST(ObjectType AS VARCHAR(MAX))
           END AS ObjectTypeDesc,
           ObjectID,
           ObjectName,
           EventSubClass
    FROM sys.fn_trace_gettable (@file, DEFAULT)
    WHERE ApplicationName <> 'SQLServerCEIP'
)

/* Append data to table */
INSERT INTO dbo.ServerLogging (SQLInstance, LogDate, ProcessInfo, LogType, LogText)
SELECT @@SERVERNAME,
       LogDate,
       ProcessInfo,
       'Errorlog',
       LogText
FROM #SQLErrorLog
WHERE LogDate > @LastMonitoredTime
      AND LogText NOT LIKE ('%Login succeeded%')
      AND LogText NOT LIKE '%BACKUP DATABASE successfully%'
      AND LogText NOT LIKE '%Error: %, Severity: %, State:%'
      AND LogText NOT LIKE '%Database backed up. Database:%'
      AND LogText NOT LIKE '%DBCC CHECKDB (%) WITH all_errormsgs, no_infomsgs executed by % found 0 errors and repaired 0 errors%'
      AND LogText NOT LIKE '%DBCC TRACE%, server process ID (SPID) %. This is an informational message only; no user action is required%'
      AND LogText NOT LIKE '%The operating system returned the error ''21(The device is not ready.)'' while attempting ''GetDiskFreeSpace'' on %'
      AND LogText NOT LIKE '%informational message%'
      AND LogText NOT LIKE '%found 0 errors and repaired 0 errors%'
      AND LogText NOT LIKE '%The log shipping secondary database%'
      AND LogText NOT LIKE '%UTC adjustment:%'
      AND LogText NOT LIKE '%(c) Microsoft Corporation%'
      AND LogText NOT LIKE '%All rights reserved%'
      AND LogText NOT LIKE '%Server process ID is %'
      AND LogText NOT LIKE '%System Manufacturer:%'
      AND LogText NOT LIKE '%Starting up database %'
      AND LogText NOT LIKE '%Parallel redo is started for database%'
      AND LogText NOT LIKE '%Parallel redo is shutdown for database%'
      AND LogText NOT LIKE '%CLR%'
UNION ALL
SELECT @@SERVERNAME,
       msdb.dbo.agent_datetime (jh.run_date, jh.run_time) AS LogDate,
       j.name AS ProcessInfo,
       'Agentlog',
       SUBSTRING (jh.message, 0, 3999) AS LogText
FROM msdb.dbo.sysjobs AS j
INNER JOIN msdb.dbo.sysjobsteps AS js
    ON js.job_id = j.job_id
INNER JOIN msdb.dbo.sysjobhistory AS jh
    ON jh.job_id = j.job_id
       AND jh.step_id = js.step_id
WHERE jh.run_status = 0
      AND msdb.dbo.agent_datetime (jh.run_date, jh.run_time) > @LastMonitoredTime
UNION ALL
SELECT @@SERVERNAME AS SQLInstance,
       TraceCTE.StartTime AS LogDate,
       TraceCTE.ApplicationName AS ProcessInfo,
       'Trace',
       CONCAT (
           TraceCTE.EventClassDesc,
           ' ',
           TraceCTE.ObjectTypeDesc,
           ' [',
           TraceCTE.DatabaseName,
           '][',
           COALESCE (TraceCTE.ObjectName, '.'),
           '] by ',
           TraceCTE.LoginName,
           ' from ',
           TraceCTE.HostName
       ) AS LogText
FROM TraceCTE
WHERE EventSubClass = 0
      AND DatabaseID <> 2
      AND TraceCTE.StartTime > @LastMonitoredTime;
GO
