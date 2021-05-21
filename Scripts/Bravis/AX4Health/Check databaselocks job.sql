USE [msdb]
GO

/****** Object:  Job [ZKH : Check databaselocks]    Script Date: 9-3-2020 09:28:23 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 9-3-2020 09:28:23 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ZKH : Check databaselocks', 
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
/****** Object:  Step [ZKH : Opsporen databaselocks]    Script Date: 9-3-2020 09:28:23 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'ZKH : Opsporen databaselocks', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF ((select COUNT(*) from sys.sysprocesses where spid in (select distinct blocked from sys.sysprocesses) and blocked = 0) >= 1
and (select DATEADD(MINUTE, 15, ddLastMessage) from ZKH_Maintenance.dbo.ZKH_AX4H_Lockdate) <= getdate())
BEGIN
	WAITFOR DELAY ''00:01'';

	IF ((select COUNT(*) from sys.sysprocesses where spid in (select distinct blocked from sys.sysprocesses) and blocked = 0) >= 1
	and (select DATEADD(MINUTE, 15, ddLastMessage) from ZKH_Maintenance.dbo.ZKH_AX4H_Lockdate) <= getdate())
	BEGIN
		EXEC msdb.dbo.sp_send_dbmail
		@profile_name = ''GPAX4HSQL01'',
		@recipients = ''r.meijer@bravis.nl;r.ramdjielal@bravis.nl;s.riemens@bravis.nl;r.quaadgras@bravis.nl;h.decocq@bravis.nl;d.wurth@bravis.nl;f.intgroen@bravis.nl;ab.kooij@bravis.nl;remko.fafieanie@avanade.com;suraj.sewbalak@avanade.com'',
	--	@recipients = ''r.meijer@bravis.nl'',
		@subject = ''AX4Health Databaselock'',
		@query = N''select * from sys.sysprocesses where spid in (select distinct blocked from sys.sysprocesses) and blocked = 0;'',
		@attach_query_result_as_file = 1,
		@query_attachment_filename = ''AX4Health Databaselock.txt''

		INSERT INTO ZKH_Maintenance.dbo.ZKH_AX4H_Lockmessage
		SELECT * from sys.sysprocesses where spid in (select distinct blocked from sys.sysprocesses) and blocked = 0

		EXEC msdb.dbo.sp_send_dbmail
		@profile_name = ''GPAX4HSQL01'',
		@recipients = ''r.meijer@bravis.nl;r.ramdjielal@bravis.nl;j.meivogel@bravis.nl;s.riemens@bravis.nl;r.quaadgras@bravis.nl;h.decocq@bravis.nl;d.wurth@bravis.nl;f.intgroen@bravis.nl;remko.fafieanie@avanade.com;suraj.sewbalak@avanade.com'',
	--	@recipients = ''r.meijer@bravis.nl'',
		@subject = ''AX4Health Databaselock - status sos_scheduler_yield'',
		@query = N''SELECT [er].[session_id], [es].[program_name], [est].text, [er].[database_id], [eqp].[query_plan], [er].[cpu_time] FROM sys.dm_exec_requests [er]
INNER JOIN sys.dm_exec_sessions [es] ON [es].[session_id] = [er].[session_id] OUTER APPLY sys.dm_exec_sql_text ([er].[sql_handle]) [est]
OUTER APPLY sys.dm_exec_query_plan ([er].[plan_handle]) [eqp] WHERE [es].[is_user_process] = 1 AND [er].[last_Wait_type] = N''''SOS_SCHEDULER_YIELD''''
ORDER BY
    [er].[session_id];'',
		@attach_query_result_as_file = 1,
		@query_attachment_filename = ''AX4Health Databaselock.txt''

		EXEC msdb.dbo.sp_send_dbmail
		@profile_name = ''GPAX4HSQL01'',
		@recipients = ''r.meijer@bravis.nl;r.ramdjielal@bravis.nl;j.meivogel@bravis.nl;s.riemens@bravis.nl;r.quaadgras@bravis.nl;h.decocq@bravis.nl;d.wurth@bravis.nl;f.intgroen@bravis.nl;remko.fafieanie@avanade.com;suraj.sewbalak@avanade.com'',
	--	@recipients = ''r.meijer@bravis.nl'',
		@subject = ''AX4Health Databaselock - Extra info'',
		@query = N''SELECT command, session_id, start_time, DATEDIFF(SECOND, ''''19000101'''', ( getdate() - start_time )) AS age, --plan_handle,
                            text, cast(context_info as varchar(128)) AS [Context], r.wait_type, r.wait_time, r.reads, r.writes, r.granted_query_memory, p.query_plan
                            ,case (p.query_plan.exist(''''declare namespace
              qplan="http://schemas.microsoft.com/sqlserver/2004/07/showplan";
                                          //qplan:RelOp[@LogicalOp="Index Scan"
                                          or @LogicalOp="Clustered Index Scan"
                                          or @LogicalOp="Table Scan"]'''')) when 1 then ''''SCANNING'''' else ''''-'''' end
                            FROM sys.dm_exec_requests r
                            CROSS APPLY sys.dm_exec_sql_text(r.plan_handle) t
                            CROSS APPLY sys.dm_exec_query_plan (r.plan_handle) p
                            where session_id <> @@SPID -- Not own session
                            order by r.start_time'',
		@attach_query_result_as_file = 1,
		@query_attachment_filename = ''AX4Health Databaselock.txt''

		update ZKH_Maintenance.dbo.ZKH_AX4H_Lockdate set ddlastmessage = GETDATE()
	END
END', 
		@database_name=N'AX4HEALTH_PROD', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Opsporen databaselocks AX4H Productie', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20161216, 
		@active_end_date=99991231, 
		@active_start_time=80000, 
		@active_end_time=175959, 
		@schedule_uid=N'97ccb459-5c85-45a1-9717-714f1a6f4e37'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


