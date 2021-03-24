/****************************************************************************/
/*							 DBA Framework									*/
/*                                                                          */
/*						Written by Mark Boomaars							*/
/*					 http://www.bravisziekenhuis.nl							*/
/*                        m.boomaars@bravis.nl								*/
/*																			*/
/*							  2021-03-24									*/
/****************************************************************************/
/*					  Get SQL Server Log Entries.							*/
/****************************************************************************/

USE DBA;
GO

CREATE OR ALTER PROCEDURE dbo.usp_SetSQLLogEntries
AS
BEGIN
    SET NOCOUNT ON;

    -------------------------------------------------------------------------------
    -- Declarations
    -------------------------------------------------------------------------------
    DECLARE @filename NVARCHAR(1000);
    DECLARE @LastMonitoredDateTime DATETIME;
    DECLARE @LastMonitoredTimeSpanDefault INT;
    DECLARE @CleanupTimeSpanValue INT;

    -------------------------------------------------------------------------------
    -- Cleanup old entries
    -------------------------------------------------------------------------------
    SELECT @CleanupTimeSpanValue = CONVERT (INT, Value)
    FROM dbo.DBA_Config
    WHERE [Key] = 'CleanupTimeSpanValue';

    DELETE FROM dbo.DBA_ServerLogging
    WHERE DATEDIFF (DAY, LogDate, GETDATE ()) > @CleanupTimeSpanValue;

    -------------------------------------------------------------------------------
    -- Preparation 
    -------------------------------------------------------------------------------
    SELECT @LastMonitoredDateTime = CONVERT (DATETIME, Value)
    FROM dbo.DBA_Config
    WHERE [Key] = 'LastMonitoredDateTime';

    IF @LastMonitoredDateTime IS NULL
    BEGIN
        SELECT @LastMonitoredTimeSpanDefault = CONVERT (INT, Value)
        FROM dbo.DBA_Config
        WHERE [Key] = 'LastMonitoredTimeSpanDefault';
        SELECT @LastMonitoredDateTime = GETDATE () - @LastMonitoredTimeSpanDefault;
    END;

    IF OBJECT_ID ('tempdb.dbo.#SQLErrorLog') IS NOT NULL DROP TABLE #SQLErrorLog;
    CREATE TABLE #SQLErrorLog (
        LogDate     DATETIME       NOT NULL,
        ProcessInfo NVARCHAR(200)  NOT NULL,
        LogText     NVARCHAR(3999) NULL
    );

    -------------------------------------------------------------------------------
    -- Process all server logs
    -------------------------------------------------------------------------------

    -- Error log
    INSERT INTO #SQLErrorLog (LogDate, ProcessInfo, LogText)
    EXEC sp_readerrorlog @p1 = 0, @p2 = 1;

    -- Agent Error log
    INSERT INTO #SQLErrorLog (LogDate, ProcessInfo, LogText)
    EXEC sp_readerrorlog @p1 = 0, @p2 = 2;

    -- Default Trace
    SELECT @filename = CAST(value AS NVARCHAR(1000))
    FROM::fn_trace_getinfo(DEFAULT)
    WHERE traceid = 1
          AND property = 2;

    -- Append all gathered data to table
    INSERT INTO dbo.DBA_ServerLogging (SQLInstance, LogDate, ProcessInfo, LogType, LogText)
    SELECT @@SERVERNAME,
           LogDate,
           ProcessInfo,
           'Errorlog',
           LogText
    FROM #SQLErrorLog
    WHERE LogDate > @LastMonitoredDateTime
    UNION ALL
    SELECT @@SERVERNAME,
           msdb.dbo.agent_datetime (jh.run_date, jh.run_time) AS "LogDate",
           j.name AS "ProcessInfo",
           'Agentlog',
           SUBSTRING (jh.message, 0, 3999) AS "LogText"
    FROM msdb.dbo.sysjobs AS j
    INNER JOIN msdb.dbo.sysjobsteps AS js
        ON js.job_id = j.job_id
    INNER JOIN msdb.dbo.sysjobhistory AS jh
        ON jh.job_id = j.job_id
           AND jh.step_id = js.step_id
    WHERE jh.run_status = 0
          AND msdb.dbo.agent_datetime (jh.run_date, jh.run_time) > @LastMonitoredDateTime
    UNION ALL
    SELECT @@SERVERNAME,
           ftg.StartTime AS "LogDate",
           te.name AS "ProcessInfo",
           'DefaultTrace' AS "LogType",
           SUBSTRING (
               COALESCE (ftg.TextData, CONCAT (ftg.ServerName, ':', ftg.DatabaseName, ':', ftg.LoginName)), 0, 4000
           ) AS "LogText"
    FROM::fn_trace_gettable(@filename, DEFAULT) AS ftg
    INNER JOIN sys.trace_events AS te
        ON ftg.EventClass = te.trace_event_id
    WHERE te.name NOT IN ( 'ErrorLog' )
          AND ftg.DatabaseId <> 2
          AND ftg.StartTime > @LastMonitoredDateTime;

    -------------------------------------------------------------------------------
    -- Update DBA_Config entry
    -------------------------------------------------------------------------------

    UPDATE dbo.DBA_Config
    SET Value = GETDATE ()
    WHERE [Key] = 'LastMonitoredDateTime';
END;
GO
