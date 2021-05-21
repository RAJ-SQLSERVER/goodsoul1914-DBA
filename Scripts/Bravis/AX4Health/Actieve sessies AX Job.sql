USE [msdb]
GO

/****** Object:  Job [Actieve sessies AX]    Script Date: 11-5-2020 16:18:43 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11-5-2020 16:18:43 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Actieve sessies AX', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'ZKH\sa_pax4hsql_agent', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Actieve sessies AX]    Script Date: 11-5-2020 16:18:43 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Actieve sessies AX', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--## Current active queries with statements
                            SELECT command, session_id, start_time, DATEDIFF(SECOND, ''19000101'', ( getdate() - start_time )) AS age, --plan_handle,
                            text, cast(context_info as varchar(128)) AS [Context], r.wait_type, r.wait_time, r.reads, r.writes, r.granted_query_memory, p.query_plan
                            ,case (p.query_plan.exist(''declare namespace
              qplan="http://schemas.microsoft.com/sqlserver/2004/07/showplan";
                                          //qplan:RelOp[@LogicalOp="Index Scan"
                                          or @LogicalOp="Clustered Index Scan"
                                          or @LogicalOp="Table Scan"]'')) when 1 then ''SCANNING'' else ''-'' end
                            FROM sys.dm_exec_requests r
                            CROSS APPLY sys.dm_exec_sql_text(r.plan_handle) t
                            CROSS APPLY sys.dm_exec_query_plan (r.plan_handle) p
                            where session_id <> @@SPID -- Not own session
                            order by r.start_time', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


