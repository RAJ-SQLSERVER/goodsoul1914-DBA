USE [msdb]
GO

/****** Object:  Job [ZKH: SACZ_Maandelijkse logging]    Script Date: 7-1-2020 23:32:07 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Data Collector]    Script Date: 7-1-2020 23:32:07 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Data Collector' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Data Collector'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ZKH: SACZ_Maandelijkse logging', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'Data Collector', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [SACZ - ophalen maandelijkse logging]    Script Date: 7-1-2020 23:32:07 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'SACZ - ophalen maandelijkse logging', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [HIX_LOGGING]
GO

Declare @CurrentDate DateTime
Declare @PrevMonthDate DateTime
Declare @StartJaarMaand_CALC NVARCHAR (6)

Set @CurrentDate=Dateadd(dd,datediff(d,0,getdate()),0)

Set @PrevMonthDate=dateadd(month,-1,@CurrentDate)

SET @StartJaarMaand_CALC = cast(datepart(year,@PrevMonthDate) as varchar(4)) + right(''00'' + cast(datepart(month,@PrevMonthDate) as varchar(2)),2) -- integer (1,2,3...)

DECLARE	@return_value int

EXEC	@return_value = [dbo].[SACZ_BRAVIS]
		@StartJaarMaand = @StartJaarMaand_CALC

SELECT	''Return Value'' = @return_value

GO
', 
		@database_name=N'HIX_LOGGING', 
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


