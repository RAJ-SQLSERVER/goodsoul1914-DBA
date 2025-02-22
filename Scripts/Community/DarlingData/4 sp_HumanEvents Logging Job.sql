USE msdb;
GO

BEGIN TRANSACTION;

DECLARE @ReturnCode INT;
SELECT @ReturnCode = 0;

IF NOT EXISTS (
    SELECT name
    FROM msdb.dbo.syscategories
    WHERE name = N'[Uncategorized (Local)]'
          AND category_class = 1
)
BEGIN
    EXEC @ReturnCode = msdb.dbo.sp_add_category @class = N'JOB',
                                                @type = N'LOCAL',
                                                @name = N'[Uncategorized (Local)]';
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;

END;

DECLARE @jobId BINARY(16);
EXEC @ReturnCode = msdb.dbo.sp_add_job @job_name = N'sp_HumanEvents Logging',
                                       @enabled = 1,
                                       @notify_level_eventlog = 0,
                                       @notify_level_email = 0,
                                       @notify_level_netsend = 0,
                                       @notify_level_page = 0,
                                       @delete_level = 0,
                                       @description = N'Used to log sp_HumanEvents session data to permanent tables.',
                                       @category_name = N'[Uncategorized (Local)]',
                                       @owner_login_name = N'sa',
                                       @job_id = @jobId OUTPUT;

IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
	GOTO QuitWithRollback;

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @jobId,
                                           @step_name = N'Log sp_HumanEvents To Tables',
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
                                           @command = N'EXEC sp_HumanEvents @output_database_name = N''DBA'', @output_schema_name = N''dbo'';',
                                           @database_name = N'DBA',
                                           @flags = 0;

IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
	GOTO QuitWithRollback;

EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId,
                                          @start_step_id = 1;

IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
	GOTO QuitWithRollback;

EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @jobId,
                                               @name = N'sp_HumanEvents: 10 second Check In',
                                               @enabled = 1,
                                               @freq_type = 8,
                                               @freq_interval = 1,
                                               @freq_subday_type = 1,
                                               @freq_subday_interval = 0,
                                               @freq_relative_interval = 0,
                                               @freq_recurrence_factor = 1,
                                               @active_start_date = 20200323,
                                               @active_end_date = 99991231,
                                               @active_start_time = 0,
                                               @active_end_time = 235959,
                                               @schedule_uid = N'6897d425-3e01-43a4-b04a-1d58c5cb3212';

IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
	GOTO QuitWithRollback;

EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId,
                                             @server_name = N'(local)';

IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
	GOTO QuitWithRollback;

COMMIT TRANSACTION;
GOTO EndSave;

QuitWithRollback:
IF (@@TRANCOUNT > 0) 
	ROLLBACK TRANSACTION;

EndSave:
GO