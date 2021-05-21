USE msdb;
GO

DECLARE @jobId BINARY(16);
EXEC msdb.dbo.sp_add_job @job_name = N'DBA: Fix plan cache bloat',
                         @enabled = 1,
                         @notify_level_eventlog = 0,
                         @notify_level_email = 2,
                         @notify_level_netsend = 0,
                         @notify_level_page = 0,
                         @delete_level = 0,
                         @description = N'No description available.',
                         @category_name = N'Database Maintenance',
                         @owner_login_name = N'sa',
                         @notify_email_operator_name = N'TAB',
                         @job_id = @jobId OUTPUT;

EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId,
                             @step_name = N'Fix plan cache bloat',
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
                             @command = N'DECLARE @Percent    DECIMAL(6, 3),
                                                @WastedMB   DECIMAL(19, 3),
                                                @StrMB      NVARCHAR(20),
                                                @StrPercent NVARCHAR(20);

                                        EXEC sp_CheckPlanCache @Percent OUTPUT, @WastedMB OUTPUT;

                                        SELECT @StrMB = CONVERT(NVARCHAR(20), @WastedMB),
                                               @StrPercent = CONVERT(NVARCHAR(20), @Percent);

                                        IF @Percent > 10
                                           OR @WastedMB > 2000 -- 2GB
                                        BEGIN
                                            DBCC FREESYSTEMCACHE(''SQL Plans'');
                                            RAISERROR(
                                                         ''%s MB (%s percent) was allocated to single-use plan cache. Single-use plans have been cleared.'',
                                                         10,
                                                         1,
                                                         @StrMB,
                                                         @StrPercent
                                                     );
                                        END;
                                        ELSE
                                        BEGIN
                                            RAISERROR(
                                                         ''Only %s MB (%s percent) is allocated to single-use plan cache - no need to clear cache now.'',
                                                         10,
                                                         1,
                                                         @StrMB,
                                                         @StrPercent
                                                     );
                                        -- Note: this is only a warning message and not an actual error.
                                        END;
                                        GO',
                             @database_name = N'DBA',
                             @flags = 0;

EXEC msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1;

EXEC msdb.dbo.sp_add_jobschedule @job_id = @jobId,
                                 @name = N'Weekly',
                                 @enabled = 1,
                                 @freq_type = 8,
                                 @freq_interval = 1,
                                 @freq_subday_type = 1,
                                 @freq_subday_interval = 0,
                                 @freq_relative_interval = 0,
                                 @freq_recurrence_factor = 1,
                                 @active_start_date = 20201108,
                                 @active_end_date = 99991231,
                                 @active_start_time = 220000,
                                 @active_end_time = 235959;

EXEC msdb.dbo.sp_add_jobserver @job_id = @jobId,
                               @server_name = N'(local)';

