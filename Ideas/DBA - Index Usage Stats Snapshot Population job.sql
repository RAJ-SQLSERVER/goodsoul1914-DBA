USE [msdb]
GO

/****** Object:  Job [DBA - Index Usage Stats Snapshot Population]    Script Date: 13-9-2021 11:27:26 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 13-9-2021 11:27:26 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Index Usage Stats Snapshot Population', 
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
/****** Object:  Step [Index Usage Stats Snapshot Population]    Script Date: 13-9-2021 11:27:26 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Index Usage Stats Snapshot Population', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'INSERT INTO dbo.index_usage_stats_snapshot
SELECT GETDATE (),
       database_id,
       object_id,
       index_id,
       user_seeks,
       user_scans,
       user_lookups,
       user_updates,
       last_user_seek,
       last_user_scan,
       last_user_lookup,
       last_user_update,
       system_seeks,
       system_scans,
       system_lookups,
       system_updates,
       last_system_seek,
       last_system_scan,
       last_system_lookup,
       last_system_update
FROM sys.dm_db_index_usage_stats;', 
		@database_name=N'IndexingMethod', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Index Usage Stats Snapshot Population - step 2]    Script Date: 13-9-2021 11:27:26 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Index Usage Stats Snapshot Population - step 2', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'WITH IndexUsageCTE AS
(
    SELECT DENSE_RANK () OVER (ORDER BY create_date DESC) AS "HistoryID",
           create_date,
           database_id,
           object_id,
           index_id,
           user_seeks,
           user_scans,
           user_lookups,
           user_updates,
           last_user_seek,
           last_user_scan,
           last_user_lookup,
           last_user_update,
           system_seeks,
           system_scans,
           system_lookups,
           system_updates,
           last_system_seek,
           last_system_scan,
           last_system_lookup,
           last_system_update
    FROM dbo.index_usage_stats_snapshot
)
INSERT INTO dbo.index_usage_stats_history
SELECT i1.create_date,
       i1.database_id,
       i1.object_id,
       i1.index_id,
       i1.user_seeks - COALESCE (i2.user_seeks, 0),
       i1.user_scans - COALESCE (i2.user_scans, 0),
       i1.user_lookups - COALESCE (i2.user_lookups, 0),
       i1.user_updates - COALESCE (i2.user_updates, 0),
       i1.last_user_seek,
       i1.last_user_scan,
       i1.last_user_lookup,
       i1.last_user_update,
       i1.system_seeks - COALESCE (i2.system_seeks, 0),
       i1.system_scans - COALESCE (i2.system_scans, 0),
       i1.system_lookups - COALESCE (i2.system_lookups, 0),
       i1.system_updates - COALESCE (i2.system_updates, 0),
       i1.last_system_seek,
       i1.last_system_scan,
       i1.last_system_lookup,
       i1.last_system_update
FROM IndexUsageCTE AS i1
LEFT OUTER JOIN IndexUsageCTE AS i2
    ON i1.database_id = i2.database_id
       AND i1.object_id = i2.object_id
       AND i1.index_id = i2.index_id
       AND i2.HistoryID = 2
       --Verify no rows are less than 0
       AND NOT (
               i1.system_seeks - COALESCE (i2.system_seeks, 0) < 0
               AND i1.system_scans - COALESCE (i2.system_scans, 0) < 0
               AND i1.system_lookups - COALESCE (i2.system_lookups, 0) < 0
               AND i1.system_updates - COALESCE (i2.system_updates, 0) < 0
               AND i1.user_seeks - COALESCE (i2.user_seeks, 0) < 0
               AND i1.user_scans - COALESCE (i2.user_scans, 0) < 0
               AND i1.user_lookups - COALESCE (i2.user_lookups, 0) < 0
               AND i1.user_updates - COALESCE (i2.user_updates, 0) < 0
           )
WHERE i1.HistoryID = 1
      -- Only include rows are greater than 0
      AND (
          i1.system_seeks - COALESCE (i2.system_seeks, 0) > 0
          OR i1.system_scans - COALESCE (i2.system_scans, 0) > 0
          OR i1.system_lookups - COALESCE (i2.system_lookups, 0) > 0
          OR i1.system_updates - COALESCE (i2.system_updates, 0) > 0
          OR i1.user_seeks - COALESCE (i2.user_seeks, 0) > 0
          OR i1.user_scans - COALESCE (i2.user_scans, 0) > 0
          OR i1.user_lookups - COALESCE (i2.user_lookups, 0) > 0
          OR i1.user_updates - COALESCE (i2.user_updates, 0) > 0
      );', 
		@database_name=N'IndexingMethod', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 4 hours', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=4, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20210910, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'de4c1990-0320-47de-9cf4-faa432d43cd2'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

