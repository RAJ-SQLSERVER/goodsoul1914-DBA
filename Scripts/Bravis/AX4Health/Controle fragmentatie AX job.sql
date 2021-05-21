USE [msdb]
GO

/****** Object:  Job [ZKH : Controle fragmentatie AX]    Script Date: 9-3-2020 09:28:26 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 9-3-2020 09:28:26 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ZKH : Controle fragmentatie AX', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'zkh\adm_rmeijer', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Controle fragmentatie AX]    Script Date: 9-3-2020 09:28:26 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Controle fragmentatie AX', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'INSERT INTO ZKH_Maintenance.dbo.ZKH_AX4H_Fragmentation
SELECT getdate(), ROW_NUMBER() OVER (ORDER BY indexstats.avg_fragmentation_in_percent DESC) as RowNumber, db_name() AS Databasename, 
dbtables.[name] as ''Table'',
dbindexes.[name] as ''Index'',
indexstats.page_count as Pages,
indexstats.avg_fragmentation_in_percent AS AVG_Fragmentation, 
''ALTER INDEX '' + dbindexes.[name] + '' ON '' + db_name() + ''.'' + dbschemas.[name] + ''.'' + dbtables.[name] + '' REBUILD WITH (FILLFACTOR = 80, ONLINE = OFF, SORT_IN_TEMPDB = ON);'' AS SqlCommand, fill_factor as Fill_Factor 
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
INNER JOIN sys.tables dbtables on dbtables.[object_id] = indexstats.[object_id]
INNER JOIN sys.schemas dbschemas on dbtables.[schema_id] = dbschemas.[schema_id]
INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
AND indexstats.index_id = dbindexes.index_id
WHERE indexstats.database_id = DB_ID()
--and indexstats.avg_fragmentation_in_percent >= 60
and indexstats.page_count > 100
and dbindexes.[name] is not null
ORDER BY indexstats.avg_fragmentation_in_percent desc', 
		@database_name=N'AX4HEALTH_PROD', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Check AX fragmentatie', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=62, 
		@freq_subday_type=4, 
		@freq_subday_interval=10, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20170102, 
		@active_end_date=99991231, 
		@active_start_time=70000, 
		@active_end_time=185959, 
		@schedule_uid=N'bb25760a-98e3-44da-842a-e909afbd2cad'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


