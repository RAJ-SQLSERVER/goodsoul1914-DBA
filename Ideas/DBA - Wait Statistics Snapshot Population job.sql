USE [msdb]
GO

/****** Object:  Job [DBA - Wait Statistics Snapshot Population]    Script Date: 13-9-2021 11:28:13 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 13-9-2021 11:28:13 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Wait Statistics Snapshot Population', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'DT-RSD-01\mboom', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Wait Statistics Snapshot Population]    Script Date: 13-9-2021 11:28:13 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Wait Statistics Snapshot Population', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'INSERT INTO dbo.wait_stats_snapshot (create_date,
                                     wait_type,
                                     waiting_tasks_count,
                                     wait_time_ms,
                                     max_wait_time_ms,
                                     signal_wait_time_ms)
SELECT GETDATE (),
       wait_type,
       waiting_tasks_count,
       wait_time_ms,
       max_wait_time_ms,
       signal_wait_time_ms
FROM sys.dm_os_wait_stats;', 
		@database_name=N'IndexingMethod', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Wait Statistics History Population]    Script Date: 13-9-2021 11:28:13 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Wait Statistics History Population', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'WITH WaitStatCTE AS
(
    SELECT create_date,
           DENSE_RANK () OVER (ORDER BY create_date DESC) AS "HistoryID",
           wait_type,
           waiting_tasks_count,
           wait_time_ms,
           max_wait_time_ms,
           signal_wait_time_ms
    FROM dbo.wait_stats_snapshot
)
INSERT INTO dbo.wait_stats_history
SELECT w1.create_date,
       w1.wait_type,
       w1.waiting_tasks_count - COALESCE (w2.waiting_tasks_count, 0),
       w1.wait_time_ms - COALESCE (w2.wait_time_ms, 0),
       w1.max_wait_time_ms - COALESCE (w2.max_wait_time_ms, 0),
       w1.signal_wait_time_ms - COALESCE (w2.signal_wait_time_ms, 0)
FROM WaitStatCTE AS w1
LEFT OUTER JOIN WaitStatCTE AS w2
    ON w1.wait_type = w2.wait_type
       AND w1.waiting_tasks_count >= COALESCE (w2.waiting_tasks_count, 0)
       AND w2.HistoryID = 2
WHERE w1.HistoryID = 1
      AND w1.waiting_tasks_count - COALESCE (w2.waiting_tasks_count, 0) > 0;', 
		@database_name=N'IndexingMethod', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every hour', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20210910, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'2186ad9c-ae14-4e9b-bd0c-ef0651951635'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


