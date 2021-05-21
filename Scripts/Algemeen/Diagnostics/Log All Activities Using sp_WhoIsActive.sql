--	http://ajaydwivedi.com/2016/12/log-all-activities-using-sp_whoisactive/

use Playground;
go

--	Verify Server Name
select @@SERVERNAME as SrvName;

--	Step 01: Create Your @destination_table
if OBJECT_ID('dbo.WhoIsActive_ResultSets') is null
begin
	declare @destination_table varchar(4000);
	set @destination_table = 'dbo.WhoIsActive_ResultSets';

	declare @schema varchar(4000);

	exec master..sp_WhoIsActive @get_plans = 2, @get_full_inner_text = 0, @get_transaction_info = 1, @get_task_info = 2, @get_locks = 1, @get_avg_time = 1, @get_additional_info = 1, @find_block_leaders = 1, @get_outer_command = 1, @return_schema = 1, @schema = @schema output;

	set @schema = REPLACE(@schema, '<table_name>', @destination_table);

	print @schema;
	exec (@schema);
end;
go

--create table dbo.WhoIsActive_ResultSets
--(
--	[dd hh:mm:ss.mss]       varchar(8000) null, 
--	[dd hh:mm:ss.mss (avg)] varchar(15) null, 
--	session_id              smallint not null, 
--	sql_text                xml null, 
--	sql_command             xml null, 
--	login_name              nvarchar(128) not null, 
--	wait_info               nvarchar(4000) null, 
--	tasks                   varchar(30) null, 
--	tran_log_writes         nvarchar(4000) null, 
--	CPU                     varchar(30) null, 
--	tempdb_allocations      varchar(30) null, 
--	tempdb_current          varchar(30) null, 
--	blocking_session_id     smallint null, 
--	blocked_session_count   varchar(30) null, 
--	reads                   varchar(30) null, 
--	writes                  varchar(30) null, 
--	context_switches        varchar(30) null, 
--	physical_io             varchar(30) null, 
--	physical_reads          varchar(30) null, 
--	query_plan              xml null, 
--	locks                   xml null, 
--	used_memory             varchar(30) null, 
--	status                  varchar(30) not null, 
--	tran_start_time         datetime null, 
--	open_tran_count         varchar(30) null, 
--	percent_complete        varchar(30) null, 
--	host_name               nvarchar(128) null, 
--	database_name           nvarchar(128) null, 
--	program_name            nvarchar(128) null, 
--	additional_info         xml null, 
--	start_time              datetime not null, 
--	login_time              datetime null, 
--	request_id              int null, 
--	collection_time         datetime not null);


--	Step 02: Add Computed Column to get TimeInMinutes
if not exists (select *
			   from INFORMATION_SCHEMA.COLUMNS as c
			   where c.TABLE_NAME = 'WhoIsActive_ResultSets'
					 and c.COLUMN_NAME = 'TimeInMinutes') 
begin
	alter table dbo.WhoIsActive_ResultSets
	add TimeInMinutes as ( CONVERT(bigint, LEFT([dd hh:mm:ss.mss], CHARINDEX(' ', [dd hh:mm:ss.mss]) - 1), 0) * 24 ) * ( 60 ) + CONVERT(int, SUBSTRING([dd hh:mm:ss.mss], CHARINDEX(' ', [dd hh:mm:ss.mss]) + 1, 2), 0) * 60 + CONVERT(int, SUBSTRING([dd hh:mm:ss.mss], CHARINDEX(':', [dd hh:mm:ss.mss]) + 1, 2), 0);
end;
go

--	Step 03: Add a clustered Index
if not exists (select *
			   from sys.indexes as i
			   where i.type_desc = 'CLUSTERED'
					 and i.object_id = OBJECT_ID('WhoIsActive_ResultSets')) 
begin
	create clustered index CI_WhoIsActive_ResultSets on dbo.WhoIsActive_ResultSets (collection_time asc, session_id);
end;
go

--	Step 04: Add a Non-clustered Index
if not exists (select *
			   from sys.indexes as i
			   where i.type_desc = 'NONCLUSTERED'
					 and i.object_id = OBJECT_ID('WhoIsActive_ResultSets')
					 and i.name = 'NCI_WhoIsActive_ResultSets_Blockings') 
begin
	create nonclustered index NCI_WhoIsActive_ResultSets_Blockings on dbo.WhoIsActive_ResultSets
	(blocking_session_id, blocked_session_count, collection_time asc, session_id) 
		include (login_name, host_name, database_name, program_name);
end;
go



/*********************************************************************************************************
--	Step 05: Test your Script
DECLARE	@destination_table VARCHAR(4000);
SET @destination_table = 'DBA.dbo.WhoIsActive_ResultSets';

EXEC DBA..sp_WhoIsActive @get_full_inner_text=0, @get_transaction_info=1, @get_task_info=2, @get_locks=1, 
					@get_avg_time=1, @get_additional_info=1,@find_block_leaders=1, @get_outer_command =1,
					@get_plans=2,
            @destination_table = @destination_table ;
GO
*********************************************************************************************************/


-- Step 06: Create SQL Agent Job
use [msdb];
go

if not exists (select *
			   from dbo.sysjobs as j
			   where j.name = 'Log_With_sp_WhoIsActive') 
begin


/*********************************************************************************************
***** Object:  Job [DBA - Log_With_sp_WhoIsActive]    Script Date: 6/12/2018 11:51:38 PM *****
*********************************************************************************************/


	begin transaction;
	declare @ReturnCode int;
	select @ReturnCode = 0;
	

/********************************************************************************************
***** Object:  JobCategory [Database Maintenance]    Script Date: 6/12/2018 11:51:38 PM *****
********************************************************************************************/


	if not exists (select name
				   from msdb.dbo.syscategories
				   where name = N'Database Maintenance'
						 and category_class = 1) 
	begin
		exec @ReturnCode = msdb.dbo.sp_add_category @class = N'JOB', @type = N'LOCAL', @name = N'Database Maintenance';
		if @@ERROR <> 0
		   or @ReturnCode <> 0
			goto QuitWithRollback;

	end;

	declare @jobId binary(16);
	exec @ReturnCode = msdb.dbo.sp_add_job @job_name = N'Log_With_sp_WhoIsActive', @enabled = 1, @notify_level_eventlog = 0, @notify_level_email = 0, @notify_level_netsend = 0, @notify_level_page = 0, @delete_level = 0, @description = N'This job will log activities using Adam Mechanic''s [sp_whoIsActive] stored procedure.

	Results are saved into WhoIsActive_ResultSets table.

	Job will run every 2 Minutes once started.', @category_name = N'Database Maintenance', @owner_login_name = N'sa', @job_id = @jobId output;
	if @@ERROR <> 0
	   or @ReturnCode <> 0
		goto QuitWithRollback;
	

/*****************************************************************************************************
***** Object:  Step [Log activities with [sp_WhoIsActive]]    Script Date: 6/12/2018 11:51:38 PM *****
*****************************************************************************************************/


	exec @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @jobId, @step_name = N'Log activities with [sp_WhoIsActive]', @step_id = 1, @cmdexec_success_code = 0, @on_success_action = 1, @on_success_step_id = 0, @on_fail_action = 2, @on_fail_step_id = 0, @retry_attempts = 0, @retry_interval = 0, @os_run_priority = 0, @subsystem = N'TSQL', @command = N'DECLARE	@destination_table VARCHAR(4000);
	SET @destination_table = ''dbo.WhoIsActive_ResultSets'';

	EXEC sp_WhoIsActive @get_full_inner_text=0, @get_transaction_info=1, @get_task_info=2, @get_locks=1, @get_avg_time=1, @get_additional_info=1,@find_block_leaders=1, @get_outer_command =1	
						,@get_plans=2, @destination_table = @destination_table ;
			
	update w
	set query_plan = qp.query_plan
	--select w.collection_time, w.session_id, w.sql_command, w.additional_info
	--		,qp.query_plan
	from [dbo].WhoIsActive_ResultSets AS w
	join sys.dm_exec_requests as r
	on w.session_id = r.session_id and w.request_id = r.request_id
	outer apply sys.dm_exec_text_query_plan(r.plan_handle, r.statement_start_offset, r.statement_end_offset) as qp
	where w.collection_time = (select max(ri.collection_time) from [dbo].WhoIsActive_ResultSets AS ri)
	and w.query_plan IS NULL and qp.query_plan is not null;
				', @database_name = N'Playground', @flags = 0;
	if @@ERROR <> 0
	   or @ReturnCode <> 0
		goto QuitWithRollback;
	exec @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1;
	if @@ERROR <> 0
	   or @ReturnCode <> 0
		goto QuitWithRollback;
	exec @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @jobId, @name = N'Log_Using_whoIsActive_Every_2_Minutes', @enabled = 1, @freq_type = 4, @freq_interval = 1, @freq_subday_type = 4, @freq_subday_interval = 2, @freq_relative_interval = 0, @freq_recurrence_factor = 0, @active_start_date = 20161227, @active_end_date = 20180618, @active_start_time = 0, @active_end_time = 235900, @schedule_uid = N'f583e6cd-9431-4afc-94a3-e3ef9bfa0d27';
	if @@ERROR <> 0
	   or @ReturnCode <> 0
		goto QuitWithRollback;
	exec @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'LT-RSD-01';
	if @@ERROR <> 0
	   or @ReturnCode <> 0
		goto QuitWithRollback;
	commit transaction;
	goto EndSave;
	QuitWithRollback:
	if @@TRANCOUNT > 0
		rollback transaction;
	EndSave:
end;
go

use [msdb];
go

if not exists (select *
			   from dbo.sysjobs as j
			   where j.name = 'Log_With_sp_WhoIsActive - Cleanup') 
begin
	begin transaction;
	declare @ReturnCode int;
	select @ReturnCode = 0;

	if not exists (select name
				   from msdb.dbo.syscategories
				   where name = N'DBA'
						 and category_class = 1) 
	begin
		exec @ReturnCode = msdb.dbo.sp_add_category @class = N'JOB', @type = N'LOCAL', @name = N'DBA';
		if @@ERROR <> 0
		   or @ReturnCode <> 0
			goto QuitWithRollback;

	end;

	declare @jobId binary(16);
	exec @ReturnCode = msdb.dbo.sp_add_job @job_name = N'Log_With_sp_WhoIsActive - Cleanup', @enabled = 1, @notify_level_eventlog = 2, @notify_level_email = 2, @notify_level_netsend = 0, @notify_level_page = 0, @delete_level = 0, @description = N'Cleanup job to clear data older than 60 days

	SET NOCOUNT ON;
	delete from dbo.WhoIsActive_ResultSets
		where collection_time <= DATEADD(DD,-60,GETDATE())', @category_name = N'DBA', @owner_login_name = N'sa', 
	--@notify_email_operator_name=N'AMGDBAs', 
	@job_id = @jobId output;

	if @@ERROR <> 0
	   or @ReturnCode <> 0
		goto QuitWithRollback;

	exec @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @jobId, @step_name = N'Purge-Data-Older-Than-60-Days', @step_id = 1, @cmdexec_success_code = 0, @on_success_action = 1, @on_success_step_id = 0, @on_fail_action = 2, @on_fail_step_id = 0, @retry_attempts = 1, @retry_interval = 7, @os_run_priority = 0, @subsystem = N'TSQL', @command = N'SET NOCOUNT ON;
	SET QUOTED_IDENTIFIER ON;
	delete from dbo.WhoIsActive_ResultSets
		where collection_time <= DATEADD(DD,-60,GETDATE())', @database_name = N'Playground', @flags = 0;
	if @@ERROR <> 0
	   or @ReturnCode <> 0
		goto QuitWithRollback;
	exec @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1;
	if @@ERROR <> 0
	   or @ReturnCode <> 0
		goto QuitWithRollback;
	exec @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @jobId, @name = N'2 Times a week', @enabled = 1, @freq_type = 8, @freq_interval = 35, @freq_subday_type = 1, @freq_subday_interval = 0, @freq_relative_interval = 0, @freq_recurrence_factor = 1, @active_start_date = 20190408, @active_end_date = 99991231, @active_start_time = 235700, @active_end_time = 235959, @schedule_uid = N'8f0b13cd-1933-4061-9a79-3f7175abea97';
	if @@ERROR <> 0
	   or @ReturnCode <> 0
		goto QuitWithRollback;
	exec @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)';
	if @@ERROR <> 0
	   or @ReturnCode <> 0
		goto QuitWithRollback;
	commit transaction;
	goto EndSave;
	QuitWithRollback:
	if @@TRANCOUNT > 0
		rollback transaction;
	EndSave:
end;
go