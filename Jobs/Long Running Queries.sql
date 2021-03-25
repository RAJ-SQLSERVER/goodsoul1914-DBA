USE [msdb]
GO

/****** Object:  Job [DBA Long Running Queries]    Script Date: 2-10-2020 09:57:15 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Troubleshooting]    Script Date: 2-10-2020 09:57:15 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Troubleshooting' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Troubleshooting'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA Long Running Queries', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'Troubleshooting', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'TAB', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Show long running queries]    Script Date: 2-10-2020 09:57:16 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Show long running queries', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'INSERT INTO LongRunningQueries
select DateTime = GETDATE(), 
	   HostName = qs.hostname, 
	   UserName = qs.loginame, 
	   DatabaseName = DB_NAME(qs.dbid), 
	   Session_ID = spid, 
	   Start_Time = (select start_time
					 from sys.dm_exec_requests
					 where spid = session_id), 
	   Status = LTRIM(RTRIM(status)), 
	   Duration_Minutes = DATEDIFF(mi, (select start_time
										from sys.dm_exec_requests
										where spid = session_id), GETDATE()), 
	   Query = SUBSTRING(st.text, qs.stmt_start / 2 + 1, ( case qs.stmt_end
															   when -1 then DATALENGTH(st.text)
														   else qs.stmt_end
														   end - qs.stmt_start ) / 2 + 1), 
	   CPU = qs.cpu, 
	   Physical_IO = qs.physical_io
from sys.sysprocesses as qs
	 cross apply sys.dm_exec_sql_text(sql_handle) as st
where st.text not like ''WAITFOR(RECEIVE conversation_handle%''
	  and st.text not like ''BACKUP DATABASE%''
	  and st.text not like ''UPDATE STATISTICS%''
	  and st.text not like ''ALTER INDEX%''
	  and DB_NAME(qs.dbid) != ''msdb''
	  and not st.text = ''sp_server_diagnostics''
	  and DATEDIFF(mi, (select start_time
						from sys.dm_exec_requests
						where spid = session_id), GETDATE()) > 2;', 
		@database_name=N'DBA', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Iedere 2 minuten', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=2, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200511, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'a2fd0142-d4d6-47b3-9da2-dcf81e6e9b2a'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


