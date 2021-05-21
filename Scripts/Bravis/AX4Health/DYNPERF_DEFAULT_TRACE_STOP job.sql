USE [msdb]
GO

/****** Object:  Job [DYNPERF_DEFAULT_TRACE_STOP]    Script Date: 11-5-2020 16:50:00 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11-5-2020 16:50:00 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DYNPERF_DEFAULT_TRACE_STOP', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job stops the tracing started by the DYNPERF_Option1_Tracing job.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Stop Tracing]    Script Date: 11-5-2020 16:50:00 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Stop Tracing', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
DECLARE
	@TRACE_NAME  		NVARCHAR(40)	= ''DYNAMICS_DEFAULT'' -- Trace name - becomes base of trace file name
 

-- -----------------------------------------------------------------------
-- Declare variables
-- -----------------------------------------------------------------------
DECLARE	@CMD			NVARCHAR(1000),	-- Used for command or sql strings
		@RC				INT,			-- Return status for stored procedures
		@ON				BIT,			-- Used as on bit for set event
		@TRACEID 		INT, 			-- Queue handle running trace queue
		@DATABASE_ID 	INT, 			-- DB ID to filter trace
		@EVENT_ID 		INT, 			-- Trace Event
		@COLUMN_ID 		INT, 			-- Trace Event Column
		@TRACE_STOPTIME	DATETIME, 		-- Trace will be set to stop 25 hours after starting
		@FILE_NAME 		NVARCHAR(245)	-- Trace file name
DECLARE	@EVENTS_VAR		TABLE(EVENT_ID INT PRIMARY KEY(EVENT_ID))

-- -----------------------------------------------------------------------
-- Stop the trace queue if running
-- -----------------------------------------------------------------------
IF EXISTS	
	(
	SELECT	*
	FROM 	fn_trace_getinfo(DEFAULT)
	WHERE 	property = 2	-- TRACE FILE NAME
	AND		CONVERT(NVARCHAR(245),value)  LIKE ''%\''+@TRACE_NAME+''%''
	)
    BEGIN
		SELECT	@TRACEID = traceid
		FROM 	fn_trace_getinfo(DEFAULT)
		WHERE 	property = 2	-- TRACE FILE NAME
		AND		CONVERT(VARCHAR(240),value)  LIKE ''%\''+@TRACE_NAME+''%''
		EXEC @RC = sp_trace_setstatus @TRACEID, 0	-- STOPS SPECIFIED TRACE
		IF @RC = 0  PRINT ''SP_TRACE_SETSTATUS: STOPPED TRACE ID '' + STR(@TRACEID )
		IF @RC = 1  PRINT ''SP_TRACE_SETSTATUS: - UNKNOWN ERROR''
		IF @RC = 8  PRINT ''SP_TRACE_SETSTATUS: THE SPECIFIED STATUS IS NOT VALID''
		IF @RC = 9  PRINT ''SP_TRACE_SETSTATUS: THE SPECIFIED TRACE HANDLE IS NOT VALID''
		IF @RC = 13 PRINT ''SP_TRACE_SETSTATUS: OUT OF MEMORY''


		EXEC sp_trace_setstatus @TRACEID, 2 -- DELETE SPECIFIED TRACE

		IF @RC = 0  PRINT ''SP_TRACE_SETSTATUS: DELETED TRACE ID '' + STR(@TRACEID)
		IF @RC = 1  PRINT ''SP_TRACE_SETSTATUS: - UNKNOWN ERROR''
		IF @RC = 8  PRINT ''SP_TRACE_SETSTATUS: THE SPECIFIED STATUS IS NOT VALID''
		IF @RC = 9  PRINT ''SP_TRACE_SETSTATUS: THE SPECIFIED TRACE HANDLE IS NOT VALID''
		IF @RC = 13 PRINT ''SP_TRACE_SETSTATUS: OUT OF MEMORY''

    END

', 
		@database_name=N'DynamicsPerf', 
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


