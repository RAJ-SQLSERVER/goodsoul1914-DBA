--CREATE DATABASE Baseline CONTAINMENT = NONE
--ON PRIMARY (
--       NAME = N'Baseline',
--       FILENAME = N'D:\SQLData\baseline_data.mdf',
--       SIZE = 1536000KB,
--       MAXSIZE = UNLIMITED,
--       FILEGROWTH = 10%
--   )
--LOG ON (
--    NAME = N'Baseline_log',
--    FILENAME = N'D:\SQLLogs\baseline_log.ldf',
--    SIZE = 102400KB,
--    MAXSIZE = 2048GB,
--    FILEGROWTH = 10%
--)
--WITH CATALOG_COLLATION=DATABASE_DEFAULT;
--GO

--IF (1 = FULLTEXTSERVICEPROPERTY ('IsFullTextInstalled'))
--BEGIN
--    EXEC Baseline.dbo.sp_fulltext_database @action = 'enable';
--END;
--GO

USE DBA;
GO

CREATE TABLE dbo.WaitStats (
    ws_ID             INT         IDENTITY(1, 1) NOT NULL,
    ws_DateTime       DATETIME    NULL,
    ws_Day            INT         NULL,
    ws_Month          INT         NULL,
    ws_Year           INT         NULL,
    ws_Hour           INT         NULL,
    ws_Minute         INT         NULL,
    ws_DayOfWeek      VARCHAR(15) NULL,
    ws_WaitType       VARCHAR(50) NULL,
    ws_WaitTime       INT         NULL,
    ws_WaitingTasks   INT         NULL,
    ws_SignalWaitTime INT         NULL,
    PRIMARY KEY CLUSTERED (ws_ID ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
          ALLOW_PAGE_LOCKS = ON--, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
    ) ON [PRIMARY]
) ON [PRIMARY];
GO

CREATE VIEW dbo.vwWaitsLastHour
AS
SELECT ws_DayOfWeek,
       CONVERT (VARCHAR(5), ws_DateTime, 108) AS "Time",
       ws_WaitType,
       ws_WaitTime,
       ws_WaitingTasks,
       ws_SignalWaitTime
FROM DBA.dbo.WaitStats
WHERE (ws_WaitTime > 0 OR ws_WaitingTasks > 0 OR ws_SignalWaitTime > 0)
      AND DATEDIFF (HOUR, ws_DateTime, GETDATE ()) <= 1;
GO

USE msdb;
GO

BEGIN TRANSACTION;
DECLARE @ReturnCode INT;
SELECT @ReturnCode = 0;

DECLARE @jobId BINARY(16);
EXEC @ReturnCode = msdb.dbo.sp_add_job @job_name = N'DBA - Delta Capture Method',
                                       @enabled = 1,
                                       @notify_level_eventlog = 0,
                                       @notify_level_email = 0,
                                       @notify_level_netsend = 0,
                                       @notify_level_page = 0,
                                       @delete_level = 0,
                                       @description = N'No description available.',
                                       @category_name = N'[Uncategorized (Local)]',
                                       @owner_login_name = N'sa',
                                       @job_id = @jobId OUTPUT;

IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
	GOTO QuitWithRollback;

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @jobId,
                                           @step_name = N'Insert',
                                           @step_id = 1,
                                           @cmdexec_success_code = 0,
                                           @on_success_action = 1,
                                           @on_success_step_id = 0,
                                           @on_fail_action = 2,
                                           @on_fail_step_id = 0,
                                           @retry_attempts = 0,
                                           @retry_interval = 0,
                                           @os_run_priority = 0,
                                           @subsystem = N'TSQL',
                                           @command = N'-- Listing 4-4. Delta capture method
-- Check if the temp table already exists
-- if it does drop it.
IF EXISTS (
    SELECT *
    FROM tempdb.dbo.sysobjects
    WHERE id = OBJECT_ID (N''tempdb..#ws_Capture'')
)
    DROP TABLE #ws_Capture;

-- Create temp table to hold our first measurement
CREATE TABLE #ws_Capture (
    wst_WaitType       VARCHAR(50),
    wst_WaitTime       BIGINT,
    wst_WaitingTasks   BIGINT,
    wst_SignalWaitTime BIGINT
);

-- Insert our first measurement into the temp table
INSERT INTO #ws_Capture
SELECT wait_type,
       wait_time_ms,
       waiting_tasks_count,
       signal_wait_time_ms
FROM sys.dm_os_wait_stats;

-- Wait for the next measurement
WAITFOR DELAY ''00:15:00'';

-- Combine the first measurement with a new measurement
-- Calculate deltas
-- Write the results into the WaitStats table
INSERT INTO WaitStats
SELECT GETDATE () AS "DateTime",
       DATEPART (DAY, GETDATE ()) AS "Day",
       DATEPART (MONTH, GETDATE ()) AS "Month",
       DATEPART (YEAR, GETDATE ()) AS "Year",
       DATEPART (HOUR, GETDATE ()) AS "Hour",
       DATEPART (MINUTE, GETDATE ()) AS "Minute",
       DATENAME (DW, GETDATE ()) AS "DayOfWeek",
       dm.wait_type AS "WaitType",
       dm.wait_time_ms - ws.wst_WaitTime AS "WaitTime",
       dm.waiting_tasks_count - ws.wst_WaitingTasks AS "WaitingTasks",
       dm.signal_wait_time_ms - ws.wst_SignalWaitTime AS "SignalWaitTime"
FROM sys.dm_os_wait_stats AS dm
INNER JOIN #ws_Capture AS ws
    ON dm.wait_type = ws.wst_WaitType;

-- Clean up the temp table
DROP TABLE #ws_Capture;',
                                           @database_name = N'DBA',
                                           @flags = 0;

IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
	GOTO QuitWithRollback;

EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId,
                                          @start_step_id = 1;

IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
	GOTO QuitWithRollback;

EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @jobId,
                                               @name = N'Every 15 minutes',
                                               @enabled = 1,
                                               @freq_type = 4,
                                               @freq_interval = 1,
                                               @freq_subday_type = 4,
                                               @freq_subday_interval = 1,
                                               @freq_relative_interval = 0,
                                               @freq_recurrence_factor = 0,
                                               @active_start_date = 20210915,
                                               @active_end_date = 99991231,
                                               @active_start_time = 0,
                                               @active_end_time = 235959;

IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
	GOTO QuitWithRollback;

EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId,
                                             @server_name = N'(local)';

IF (@@ERROR <> 0 OR @ReturnCode <> 0)
	GOTO QuitWithRollback;

COMMIT TRANSACTION;
GOTO EndSave;

QuitWithRollback:
IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION;

EndSave:
GO
