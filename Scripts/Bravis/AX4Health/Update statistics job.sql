USE [msdb]
GO

/****** Object:  Job [ZKH : Update statistics]    Script Date: 10-1-2020 13:14:25 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 10-1-2020 13:14:25 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ZKH : Update statistics', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'GPAX4HSQL02', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [ZKH: Update statistics en Indexen]    Script Date: 10-1-2020 13:14:25 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'ZKH: Update statistics en Indexen', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXECUTE dbo.IndexOptimize
@Databases = ''USER_DATABASES'',
@FragmentationLow = NULL,
@FragmentationMedium = ''INDEX_REBUILD_ONLINE,INDEX_REORGANIZE'',
@FragmentationHigh = ''INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'',
@FragmentationLevel1 = 30,
@FragmentationLevel2 = 71,
@UpdateStatistics = ''ALL'',
--@OnlyModifiedStatistics = ''Y'',
@StatisticsSample = 100,
@MinNumberOfPages = 2,
@MSShippedObjects = Y,
@FillFactor = 85,
--@MaxDop = 0,
@Indexes = ''ALL_INDEXES'',
@TimeLimit = 7200,
@LogToTable=''Y''', 
		@database_name=N'ZKH_Maintenance', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [ZKH : Clean Queryplans]    Script Date: 10-1-2020 13:14:25 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'ZKH : Clean Queryplans', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE AX4HEALTH_PROD
GO
IF (DAY(GETDATE()) = 1)
    DBCC FREEPROCCACHE WITH NO_INFOMSGS;
GO

USE AX4HEALTH_PROD_BL
GO
IF (DAY(GETDATE()) = 1)
    DBCC FREEPROCCACHE WITH NO_INFOMSGS;
GO

USE AX4HEALTH_PROD_model
GO
IF (DAY(GETDATE()) = 1)
    DBCC FREEPROCCACHE WITH NO_INFOMSGS;
GO', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'ZKH Onderhoud', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20181220, 
		@active_end_date=99991231, 
		@active_start_time=43000, 
		@active_end_time=235959, 
		@schedule_uid=N'a33b3670-4360-406e-8224-650eb3a59620'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'ZKH Onderhoud', 
		@enabled=0, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20181220, 
		@active_end_date=99991231, 
		@active_start_time=120000, 
		@active_end_time=235959, 
		@schedule_uid=N'feb7da8e-f5fa-423a-b73c-bcd692a971e4'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


