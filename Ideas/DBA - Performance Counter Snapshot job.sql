USE [msdb]
GO

/****** Object:  Job [DBA - Performance Counter Snapshot]    Script Date: 13-9-2021 11:27:58 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 13-9-2021 11:27:58 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Performance Counter Snapshot', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Performance Counter Snapshot]    Script Date: 13-9-2021 11:27:58 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Performance Counter Snapshot', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF OBJECT_ID (''tempdb..#Baseline'') IS NOT NULL 
	DROP TABLE #Baseline;

SELECT GETDATE () AS "sample_time",
       pc1.object_name,
       pc1.counter_name,
       pc1.instance_name,
       pc1.cntr_value,
       pc1.cntr_type,
       x.cntr_value AS "base_cntr_value"
INTO #Baseline
FROM sys.dm_os_performance_counters AS pc1
OUTER APPLY (
    SELECT cntr_value
    FROM sys.dm_os_performance_counters AS pc2
    WHERE pc2.cntr_type = 1073939712
          AND UPPER (pc1.counter_name) = UPPER (pc2.counter_name)
          AND pc1.object_name = pc2.object_name
          AND pc1.instance_name = pc2.instance_name
) AS x
WHERE pc1.cntr_type IN ( 272696576, 1073874176 )
      AND (
          pc1.object_name LIKE ''%:Access Methods%''
          AND (
              pc1.counter_name LIKE ''Forwarded Records/sec%''
              OR pc1.counter_name LIKE ''FreeSpace Scans/sec%''
              OR pc1.counter_name LIKE ''Full Scans/sec%''
              OR pc1.counter_name LIKE ''Index Searches/sec%''
              OR pc1.counter_name LIKE ''Page Splits/sec%''
          )
      )
      OR (
          pc1.object_name LIKE ''%:Buffer Manager%''
          AND (
              pc1.counter_name LIKE ''Page life expectancy%''
              OR pc1.counter_name LIKE ''Page lookups/sec%''
          )
      )
      OR (
          pc1.object_name LIKE ''%:Locks%''
          AND (
              pc1.counter_name LIKE ''Lock Wait Time (ms)%''
              OR pc1.counter_name LIKE ''Lock Waits/sec%''
              OR pc1.counter_name LIKE ''Number of Deadlocks/sec%''
          )
      )
      OR (
          pc1.object_name LIKE ''%:SQL Statistics%''
          AND pc1.counter_name LIKE ''Batch Requests/sec%''
      );

WAITFOR DELAY ''00:00:10'';

INSERT INTO dbo.IndexingCounters (create_date,
                                  server_name,
                                  object_name,
                                  counter_name,
                                  instance_name,
                                  Calculated_Counter_value)
SELECT GETDATE (),
       LEFT(pc1.object_name, CHARINDEX ('':'', pc1.object_name) - 1),
       SUBSTRING (pc1.object_name, 1 + CHARINDEX ('':'', pc1.object_name), LEN (pc1.object_name)),
       pc1.counter_name,
       pc1.instance_name,
       CASE
           WHEN pc1.cntr_type = 65792 THEN pc1.cntr_value
           WHEN pc1.cntr_type = 272696576 THEN
               COALESCE ((1. * pc1.cntr_value - x.cntr_value) / NULLIF(DATEDIFF (s, sample_time, GETDATE ()), 0), 0)
           WHEN pc1.cntr_type = 537003264 THEN COALESCE ((1. * pc1.cntr_value) / NULLIF(base.cntr_value, 0), 0)
           WHEN pc1.cntr_type = 1073874176 THEN
               COALESCE (
                   (1. * pc1.cntr_value - x.cntr_value) / NULLIF(base.cntr_value - x.base_cntr_value, 0)
                   / NULLIF(DATEDIFF (s, sample_time, GETDATE ()), 0),
                   0
               )
       END AS "real_cntr_value"
FROM sys.dm_os_performance_counters AS pc1
OUTER APPLY (
    SELECT cntr_value,
           base_cntr_value,
           sample_time
    FROM #Baseline AS b
    WHERE b.object_name = pc1.object_name
          AND b.counter_name = pc1.counter_name
          AND b.instance_name = pc1.instance_name
) AS x
OUTER APPLY (
    SELECT cntr_value
    FROM sys.dm_os_performance_counters AS pc2
    WHERE pc2.cntr_type = 1073939712
          AND UPPER (pc1.counter_name) = UPPER (pc2.counter_name)
          AND pc1.object_name = pc2.object_name
          AND pc1.instance_name = pc2.instance_name
) AS base
WHERE pc1.cntr_type IN ( 65792, 272696576, 537003264, 1073874176 )
      AND (
          pc1.object_name LIKE ''%:Access Methods%''
          AND (
              pc1.counter_name LIKE ''Forwarded Records/sec''
              OR pc1.counter_name LIKE ''FreeSpace Scans/sec%''
              OR pc1.counter_name LIKE ''Full Scans/sec%''
              OR pc1.counter_name LIKE ''Index Searches/sec%''
              OR pc1.counter_name LIKE ''Page Splits/sec%''
          )
      )
      OR (
          pc1.object_name LIKE ''%:Buffer Manager%''
          AND (
              pc1.counter_name LIKE ''Page life expectancy%''
              OR pc1.counter_name LIKE ''Page lookups/sec%''
          )
      )
      OR (
          pc1.object_name LIKE ''%:Locks%''
          AND (
              pc1.counter_name LIKE ''Lock Wait Time (ms)%''
              OR pc1.counter_name LIKE ''Lock Waits/sec%''
              OR pc1.counter_name LIKE ''Number of Deadlocks/sec%''
          )
      )
      OR (
          pc1.object_name LIKE ''%:SQL Statistics%''
          AND pc1.counter_name LIKE ''Batch Requests/sec%''
      );', 
		@database_name=N'DBA', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 5 minutes', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=5, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20210910, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


