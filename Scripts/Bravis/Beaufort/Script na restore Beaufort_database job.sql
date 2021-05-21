USE [msdb]
GO

/****** Object:  Job [ZKH: Script na restore Beaufort_database]    Script Date: 10-1-2020 13:34:45 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 10-1-2020 13:34:45 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ZKH: Script na restore Beaufort_database', 
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
/****** Object:  Step [ZKH: Script na restore Beaufort-database]    Script Date: 10-1-2020 13:34:45 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'ZKH: Script na restore Beaufort-database', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- Selecteer de juiste database
use Beaufort
go

-- Reset van de SID voor de SQL logins van Beaufort
exec sp_change_users_login ''UPDATE_ONE'', ''beaufort'', ''beaufort''
exec sp_change_users_login ''UPDATE_ONE'', ''logon'', ''logon''
exec sp_changedbowner ''prig_own''
go

-- Aanpassen omschrijving Hoofdmenu Beaufort
update dpia005 set func_naam = ''Hoofdmenu - Acceptatie'' where func_id = ''400000''
go

-- Aanpassing stuurgegevens Beaufort naar de juiste directory structuur voor Acceptatie
update dpia016 set stuur_wrd = ''\\zkh.local\zkh\applications\Beaufort_acc\cuo'' where stuur_id = ''BP_BOUPL''
update dpia016 set stuur_wrd = ''\\zkh.local\zkh\applications\Beaufort_acc\data\intracom\ontvang'' where stuur_id = ''BP_SNLOC''
update dpia016 set stuur_wrd = ''\\gadrp01\drpexport\'' where stuur_id = ''DRPIPATH''
update dpia016 set stuur_wrd = ''\\gadrp01\drpexport\'' where stuur_id = ''DRPPATH''
update dpia016 set stuur_wrd = ''\\zkh.local\zkh\applications\Beaufort_acc\data\intracom\zend'' where stuur_id = ''EXP_PATH''
update dpia016 set stuur_wrd = ''\\zkh.local\zkh\applications\Beaufort_acc\data\intracom\ontvang'' where stuur_id = ''FZKPATH''
update dpia016 set stuur_wrd = ''\\zkh.local\zkh\applications\Beaufort_acc\data\intracom\backup'' where stuur_id = ''IMP_BUL''
update dpia016 set stuur_wrd = ''\\zkh.local\zkh\applications\Beaufort_acc\data\intracom\ontvang'' where stuur_id = ''IMP_PAD''
update dpia016 set stuur_wrd = ''\\zkh.local\zkh\applications\Beaufort_acc\data\pkb\import'' where stuur_id = ''IMPPATH''
update dpia016 set stuur_wrd = ''\\zkh.local\zkh\applications\Beaufort_acc\data\pkb\journaalpost'' where stuur_id = ''JP_PATH''
update dpia016 set stuur_wrd = ''\\zkh.local\zkh\applications\Beaufort_acc\data\intracom\ontvang'' where stuur_id = ''SALPATH''
go
', 
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


