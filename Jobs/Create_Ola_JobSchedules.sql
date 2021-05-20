/*******************************************************************
Use these links and scripts at your own risk. 
Kevin Hill and Pluralsight are not responsible for their contents 
or any possible negative impact to your systems. Use 
only on test systems while you learn how they work.
*******************************************************************/

 -- Add job schedules (all disabled by default)

EXEC msdb.dbo.sp_add_jobschedule @job_name=N'CommandLog Cleanup', @name=N'Weekly at 12:01 am', 
		@enabled = 0, 
		@freq_type=8, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180108, 
		@active_end_date=99991231, 
		@active_start_time=100, 
		@active_end_time=235959
GO

EXEC msdb.dbo.sp_add_jobschedule @job_name=N'DatabaseBackup - SYSTEM_DATABASES - FULL', @name=N'Daily at 12:05am', 
		@enabled = 0, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180108, 
		@active_end_date=99991231, 
		@active_start_time=500, 
		@active_end_time=235959
GO

EXEC msdb.dbo.sp_add_jobschedule @job_name=N'DatabaseBackup - USER_DATABASES - DIFF', @name=N'Daily Mon-Sat 12:15am', 
		@enabled = 0, 
		@freq_type=8, 
		@freq_interval=126, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180108, 
		@active_end_date=99991231, 
		@active_start_time=1500, 
		@active_end_time=235959
GO

-- this is the first of TWO schedules that will be created for FULL backups
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'DatabaseBackup - USER_DATABASES - FULL', @name=N'Sunday at 12:15am', 
		@enabled = 0, 
		@freq_type=8, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180108, 
		@active_end_date=99991231, 
		@active_start_time=1500, 
		@active_end_time=235959
GO

-- this is the second of TWO schedules that will be created for FULL backups
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'DatabaseBackup - USER_DATABASES - FULL', @name=N'Daily at 12:15am', 
		@enabled = 0, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180108, 
		@active_end_date=99991231, 
		@active_start_time=1500, 
		@active_end_time=235959
GO

EXEC msdb.dbo.sp_add_jobschedule @job_name=N'DatabaseBackup - USER_DATABASES - LOG', @name=N'Hourly', 
		@enabled = 0, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180108, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959
GO

EXEC msdb.dbo.sp_add_jobschedule @job_name=N'DatabaseIntegrityCheck - SYSTEM_DATABASES', @name=N'Daily at 11pm', 
		@enabled = 0, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180108, 
		@active_end_date=99991231, 
		@active_start_time=230000, 
		@active_end_time=235959
GO

EXEC msdb.dbo.sp_add_jobschedule @job_name=N'DatabaseIntegrityCheck - USER_DATABASES', @name=N'Daily at 11pm', 
		@enabled = 0, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180108, 
		@active_end_date=99991231, 
		@active_start_time=230000, 
		@active_end_time=235959
GO

EXEC msdb.dbo.sp_add_jobschedule @job_name=N'IndexOptimize - USER_DATABASES', @name=N'Daily at 10pm', 
		@enabled = 0, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180108, 
		@active_end_date=99991231, 
		@active_start_time=220000, 
		@active_end_time=235959
GO

EXEC msdb.dbo.sp_add_jobschedule @job_name=N'Output File Cleanup', @name=N'Daily at 12:00 am', 
		@enabled = 0, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180108, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959
GO

EXEC msdb.dbo.sp_add_jobschedule @job_name=N'sp_delete_backuphistory', @name=N'Daily at 12:00 am', 
		@enabled = 0, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180108, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959
GO

EXEC msdb.dbo.sp_add_jobschedule @job_name=N'sp_purge_jobhistory', @name=N'Daily at 12:00 am', 
		@enabled = 0, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180108, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959
GO




GO
