USE [msdb];
GO

/****** Object:  Job [DBA Run Diagnostic Info]    Script Date: 30-9-2020 18:30:59 ******/
BEGIN TRANSACTION;
DECLARE @ReturnCode INT;
SELECT @ReturnCode = 0;
/****** Object:  JobCategory [Data Collector]    Script Date: 30-9-2020 18:30:59 ******/
IF NOT EXISTS
(
    SELECT name
    FROM msdb.dbo.syscategories
    WHERE name = N'Data Collector'
          AND category_class = 1
)
BEGIN
    EXEC @ReturnCode = msdb.dbo.sp_add_category @class = N'JOB',
                                                @type = N'LOCAL',
                                                @name = N'Data Collector';
    IF (@@ERROR <> 0 OR @ReturnCode <> 0)
        GOTO QuitWithRollback;

END;

DECLARE @jobId BINARY(16);
EXEC @ReturnCode = msdb.dbo.sp_add_job @job_name = N'DBA Run Diagnostic Info',
                                       @enabled = 1,
                                       @notify_level_eventlog = 0,
                                       @notify_level_email = 0,
                                       @notify_level_netsend = 0,
                                       @notify_level_page = 0,
                                       @delete_level = 0,
                                       @description = N'No description available.',
                                       @category_name = N'Data Collector',
                                       @owner_login_name = N'sa',
                                       @job_id = @jobId OUTPUT;
IF (@@ERROR <> 0 OR @ReturnCode <> 0)
    GOTO QuitWithRollback;
/****** Object:  Step [Execute all diagnostic inventory scripts]    Script Date: 30-9-2020 18:31:00 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @jobId,
                                           @step_name = N'Execute all diagnostic inventory scripts',
                                           @step_id = 1,
                                           @cmdexec_success_code = 0,
                                           @on_success_action = 3,
                                           @on_success_step_id = 0,
                                           @on_fail_action = 3,
                                           @on_fail_step_id = 0,
                                           @retry_attempts = 0,
                                           @retry_interval = 0,
                                           @os_run_priority = 0,
                                           @subsystem = N'TSQL',
                                           @command = N'EXEC dbo.usp_GetDiagnosticInfo',
                                           @database_name = N'DBA',
                                           @flags = 0;
IF (@@ERROR <> 0 OR @ReturnCode <> 0)
    GOTO QuitWithRollback;
/****** Object:  Step [Cleanup tables]    Script Date: 30-9-2020 18:31:00 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @jobId,
                                           @step_name = N'Cleanup tables',
                                           @step_id = 2,
                                           @cmdexec_success_code = 0,
                                           @on_success_action = 1,
                                           @on_success_step_id = 0,
                                           @on_fail_action = 2,
                                           @on_fail_step_id = 0,
                                           @retry_attempts = 0,
                                           @retry_interval = 0,
                                           @os_run_priority = 0,
                                           @subsystem = N'TSQL',
                                           @command = N'exec dbo.usp_CleanupDiagnosticInfo @Weeks = 4',
                                           @database_name = N'DBA',
                                           @flags = 0;
IF (@@ERROR <> 0 OR @ReturnCode <> 0)
    GOTO QuitWithRollback;
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId,
                                          @start_step_id = 1;
IF (@@ERROR <> 0 OR @ReturnCode <> 0)
    GOTO QuitWithRollback;
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @jobId,
                                               @name = N'Iedere 6 uur',
                                               @enabled = 1,
                                               @freq_type = 4,
                                               @freq_interval = 1,
                                               @freq_subday_type = 8,
                                               @freq_subday_interval = 6,
                                               @freq_relative_interval = 0,
                                               @freq_recurrence_factor = 0,
                                               @active_start_date = 20200930,
                                               @active_end_date = 99991231,
                                               @active_start_time = 0,
                                               @active_end_time = 235959,
                                               @schedule_uid = N'c304f930-0bd4-4173-ad05-1a916672d351';
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


