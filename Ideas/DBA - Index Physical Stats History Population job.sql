USE [msdb]
GO

/****** Object:  Job [DBA - Index Physical Stats History Population]    Script Date: 13-9-2021 11:27:08 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 13-9-2021 11:27:08 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Index Physical Stats History Population', 
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
/****** Object:  Step [Index Physical Stats History Population]    Script Date: 13-9-2021 11:27:08 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Index Physical Stats History Population', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @DatabaseID INT;
DECLARE DatabaseList CURSOR FAST_FORWARD FOR
SELECT database_id
FROM sys.databases
WHERE state_desc = ''ONLINE'';
OPEN DatabaseList;
FETCH NEXT FROM DatabaseList
INTO @DatabaseID;
WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO dbo.index_physical_stats_history (create_date,
                                                  database_id,
                                                  object_id,
                                                  index_id,
                                                  partition_number,
                                                  index_type_desc,
                                                  alloc_unit_type_desc,
                                                  index_depth,
                                                  index_level,
                                                  avg_fragmentation_in_percent,
                                                  fragment_count,
                                                  avg_fragment_size_in_pages,
                                                  page_count,
                                                  avg_page_space_used_in_percent,
                                                  record_count,
                                                  ghost_record_count,
                                                  version_ghost_record_count,
                                                  min_record_size_in_bytes,
                                                  max_record_size_in_bytes,
                                                  avg_record_size_in_bytes,
                                                  forwarded_record_count,
                                                  compressed_page_count)
    SELECT GETDATE (),
           database_id,
           object_id,
           index_id,
           partition_number,
           index_type_desc,
           alloc_unit_type_desc,
           index_depth,
           index_level,
           avg_fragmentation_in_percent,
           fragment_count,
           avg_fragment_size_in_pages,
           page_count,
           avg_page_space_used_in_percent,
           record_count,
           ghost_record_count,
           version_ghost_record_count,
           min_record_size_in_bytes,
           max_record_size_in_bytes,
           avg_record_size_in_bytes,
           forwarded_record_count,
           compressed_page_count
    FROM sys.dm_db_index_physical_stats (@DatabaseID, NULL, NULL, NULL, ''SAMPLED'');
    FETCH NEXT FROM DatabaseList
    INTO @DatabaseID;
END;
CLOSE DatabaseList;
DEALLOCATE DatabaseList;', 
		@database_name=N'IndexingMethod', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every day', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20210910, 
		@active_end_date=99991231, 
		@active_start_time=10000, 
		@active_end_time=235959, 
		@schedule_uid=N'12eb85b8-d171-4cb0-b332-8a7b1f521789'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


