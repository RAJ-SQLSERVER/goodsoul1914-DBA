DECLARE @DatabaseName  				varchar(50)		='HIX_ACCEPTATIE'
DECLARE @TableName     				varchar(50)		='zkh_blocklog'

DECLARE @ProcedureName				varchar(50)		='zkh_blockdetection'

DECLARE @AgentCategoryName     		varchar(50)		='Ziekenhuis'
DECLARE @AgentJobName     			varchar(50)		='ZKH: Block Detection'
DECLARE @AgentJobDescription		varchar(200)	='Automatic Block-Detection by zkh'
DECLARE @AgentJobMode				varchar(50)		='once'
DECLARE @AgentJobThreshold			varchar(50)		=1
DECLARE @AgentJobFrequency			varchar(50)		=1
DECLARE @AgentJobSave				varchar(50)		=1

DECLARE @AlertName					varchar(50)		='ZKH: Block Detection'

/*
	Step 1 – Block Log Table
*/

-- check if table exists
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].'+@TableName) AND type in (N'U'))
BEGIN
	PRINT 'Creating table: ['+@DatabaseName+'].[dbo].['+@TableName+']'
	EXEC('CREATE TABLE ['+@DatabaseName+'].[dbo].['+@TableName+'] (
		[entry_no] bigint identity constraint ['+@TableName+'_Tab$pk_ci] primary key clustered,
		[timestamp] datetime,
		[db] varchar(128) collate database_default,
		[waitresource] varchar(128),
		[table_name] varchar(128) collate database_default,
		[index_name] varchar(128) collate database_default,
		[waittime] bigint,
		[lastwaittype] varchar(128),
		[spid] int,
		[loginame] varchar(128) collate database_default,
		[hostname] varchar(128) collate database_default,
		[program_name] varchar(128) collate database_default,
		[cmd] nvarchar(max) collate database_default,
		[query_plan] xml,
		[status] varchar(128) collate database_default,
		[cpu] bigint,
		[lock_timeout] int,
		[blocked by] int,
		[spid 2] int,
		[loginame 2] varchar(128) collate database_default,
		[hostname 2] varchar(128) collate database_default,
		[program_name 2] varchar(128) collate database_default,
		[cmd 2] nvarchar(max) collate database_default,
		[query_plan 2] xml,
		[status 2] varchar(128) collate database_default,
		[cpu 2] bigint, 
		[block_orig_id] int,
		[block_orig_loginame] varchar(128) collate database_default
	)')
END


/*
	Step 2 – Stored Procedure to save the data 
*/

-- If procedure exists drop it
IF (OBJECT_ID(@ProcedureName) IS NOT NULL)
BEGIN
	PRINT 'Deleting procedure: [dbo].['+@ProcedureName+']'
	EXEC('DROP PROCEDURE [dbo].['+@ProcedureName+']')
END

-- Create procedure
PRINT 'Creating procedure: [dbo].['+@ProcedureName+']'
EXEC('
CREATE PROCEDURE [dbo].['+@ProcedureName+']
  @mode varchar(10) = ''loop'',         -- "loop" or "once"
  @threshold int = 1000,              -- Block threshold in milliseconds 
  @frequency int = 3,                 -- Check frequency in milliseconds
  @save tinyint = 0                   -- save output to table '+@TableName+' (0 = no, 1 = yes)
with encryption
as

if @mode <> ''once'' begin
  print ''*********************************************************''
  print ''***                  System Improvement               ***''
  print ''***    Performance Optimization & Troubleshooting     ***''
  print ''*********************************************************''
  print ''              Version 1.00, Date: 24.02.2013             ''
  print ''''
end

if (@mode not in (''loop'', ''once'')) begin
  raiserror (''ERROR: Invalid Parameter @mode: %s'', 15, 1, @mode)
  return
end
if (@threshold < 1) begin
  raiserror (''ERROR: Invalid Parameter @threshold: %i'', 15, 1, @threshold)
  return
end
if (@frequency < 1) begin
  raiserror (''ERROR: Invalid Parameter @frequency: %i'', 15, 1, @frequency)
  return
end
if (@save not in (0,1)) begin
  raiserror (''ERROR: Invalid Parameter @save: %i'', 15, 1, @save)
  return
end

set nocount on
set statistics io off
declare @spid int, @spid2 int, @loginame varchar(128), @blocked_by int, @blocked_by_name varchar(128), @orig_id int, @orig_name varchar(128), @timestmp datetime, @i int

if @mode = ''once''
  goto start_check

while 1 = 1 begin

  start_check:

  if exists (select * from sys.dm_exec_requests where [blocking_session_id] <> 0) begin
    print ''Checkpoint '' + convert(varchar(30), getdate())
       
    if @save = 0 begin

     select 
             [db] = db_name(s1.[database_id]), 
             [waitresource] = ltrim(rtrim(s1.[wait_resource])),
             [table_name] = object_name(sl.rsc_objid),            
             [index_name] = si.[name],
             s1.[wait_time], 
             s1.[last_wait_type], 
             s1.[session_id],
             session1.[login_name], 
             session1.[host_name], 
             session1.[program_name], 
             [cmd] = isnull(st1.[text], ''''),
             [query_plan] = isnull(qp1.[query_plan], ''''),
             session1.[status],
             session1.[cpu_time], 
             s1.[lock_timeout],
             [blocked by] = s1.[blocking_session_id],             
             [login_name 2] = session2.[login_name],
             [hostname 2] = session2.[host_name],
             [program_name 2] = session2.[program_name],
             [cmd 2] = isnull(st2.[text], ''''),
             [query_plan 2] = isnull(qp2.[query_plan], ''''),
             session2.[status],
             session2.[cpu_time]          
       -- Process Requests
       from sys.dm_exec_requests (nolock) s1 
       outer apply sys.dm_exec_sql_text(s1.sql_handle) st1
       outer apply sys.dm_exec_query_plan(s1.plan_handle) qp1
       left outer join sys.dm_exec_requests (nolock) s2 on s2.[session_id] = s1.[blocking_session_id]
       outer apply sys.dm_exec_sql_text(s2.sql_handle) st2
       outer apply sys.dm_exec_query_plan(s2.plan_handle) qp2
       -- Sessions
       left outer join sys.dm_exec_sessions (nolock) session1 on session1.[session_id] = s1.[session_id]
       left outer join sys.dm_exec_sessions (nolock) session2 on session2.[session_id] = s1.[blocking_session_id]
       -- Lock-Info
       left outer join  master.dbo.syslockinfo (nolock) sl on s1.[session_id] = sl.req_spid
       -- Indexes
       left outer join sys.indexes (nolock) si on sl.rsc_objid = si.[object_id] and sl.rsc_indid = si.[index_id]
       where s1.[blocking_session_id] <> 0 
             and (sl.rsc_type in (2,3,4,5,6,7,8,9)) and sl.req_status = 3
             and s1.[wait_time] >= @threshold

    end else begin

      set @timestmp = getdate()

      insert into ['+@TableName+']
      ([timestamp],[db],[waitresource],[table_name],[index_name],[waittime],[lastwaittype],[spid],[loginame],[hostname],[program_name],[cmd],[query_plan],[status],[cpu],[lock_timeout],[blocked by],[spid 2],[loginame 2],[hostname 2],[program_name 2],[cmd 2],[query_plan 2],[status 2],[cpu 2],[block_orig_id],[block_orig_loginame])
      select @timestmp,
             [db] = db_name(s1.[database_id]), 
             [waitresource] = ltrim(rtrim(s1.[wait_resource])),
             [table_name] = object_name(sl.rsc_objid),            
             [index_name] = si.[name],
             s1.[wait_time], 
             s1.[last_wait_type], 
             s1.[session_id],
             session1.[login_name], 
             session1.[host_name], 
             session1.[program_name], 
             [cmd] = isnull(st1.[text], ''''),
             [query_plan] = isnull(qp1.[query_plan], ''''),
             session1.[status],
             session1.[cpu_time], 
             s1.[lock_timeout],
             [blocked by] = s1.[blocking_session_id], 
			 s2.[session_id],
             [login_name 2] = session2.[login_name],
             [hostname 2] = session2.[host_name],
             [program_name 2] = session2.[program_name],
             [cmd 2] = isnull(st2.[text], ''''),
             [query_plan 2] = isnull(qp2.[query_plan], ''''),
             session2.[status],
             session2.[cpu_time],
             [block_orig_id] = null, 
             [block_orig_id] = null
       -- Process Requests
       from sys.dm_exec_requests (nolock) s1 
       outer apply sys.dm_exec_sql_text(s1.sql_handle) st1
       outer apply sys.dm_exec_query_plan(s1.plan_handle) qp1
       left outer join sys.dm_exec_requests (nolock) s2 on s2.[session_id] = s1.[blocking_session_id]
       outer apply sys.dm_exec_sql_text(s2.sql_handle) st2
       outer apply sys.dm_exec_query_plan(s2.plan_handle) qp2
       -- Sessions
       left outer join sys.dm_exec_sessions (nolock) session1 on session1.[session_id] = s1.[session_id]
       left outer join sys.dm_exec_sessions (nolock) session2 on session2.[session_id] = s1.[blocking_session_id]
       -- Lock-Info
       left outer join  master.dbo.syslockinfo (nolock) sl on s1.[session_id] = sl.req_spid
       -- Indexes
       left outer join sys.indexes (nolock) si on sl.rsc_objid = si.[object_id] and sl.rsc_indid = si.[index_id]
       where s1.[blocking_session_id] <> 0 
             and (sl.rsc_type in (2,3,4,5,6,7,8,9)) and sl.req_status = 3
             and s1.[wait_time] >= @threshold
    
      update ['+@DatabaseName+'].[dbo].['+@TableName+'] set [table_name] = ''- unknown -'' where [table_name] is null

      -- get block originator
      declare originator_cur cursor for select [blocked by], [loginame 2]
        from ['+@DatabaseName+'].[dbo].['+@TableName+']
        where [timestamp] = @timestmp
        for update
      open originator_cur
      fetch next from originator_cur into @blocked_by, @blocked_by_name
      while @@fetch_status = 0 begin
        set @i = 0
        set @orig_id = @blocked_by   
        set @orig_name = @blocked_by_name 
        set @spid2 = @blocked_by
        while (@spid2 <> 0) and (@i < 100) begin
          if exists(select top 1 [blocked by] from ['+@DatabaseName+'].[dbo].['+@TableName+'] where ([timestamp] = @timestmp) and ([spid] = @spid2)) begin
            select top 1 @spid = [blocked by], @loginame = [loginame 2] from ['+@DatabaseName+'].[dbo].['+@TableName+'] where ([timestamp] = @timestmp) and ([spid] = @spid2)
            set @orig_id = @spid
            set @orig_name = @loginame                       
            set @spid2 = @spid         
          end else
            set @spid2 = 0
          set @i = @i + 1   -- "Emergency Exit", to avoid recursive loop
        end 
        update ['+@DatabaseName+'].[dbo].['+@TableName+'] set [block_orig_id] = @orig_id, [block_orig_loginame] = @orig_name where current of originator_cur
        fetch next from originator_cur into @blocked_by, @blocked_by_name
      end
      close originator_cur
      deallocate originator_cur

    end
  end

  end_check:

  if @mode = ''once''
    return

  waitfor delay @frequency
end
')


/*
	Step 3 – SQL Server Agent Job that will then execute the procedure 
*/

-- If agent job exists, then drop
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = @AgentJobName)
BEGIN
	PRINT 'Deleting agent job: '+@AgentJobName
	EXEC msdb.dbo.sp_delete_job @job_name=@AgentJobName, @delete_unused_schedule=1
END

-- Create agent job to execute the procedure
PRINT 'Creating agent job: '+@AgentJobName
BEGIN TRANSACTION 
	DECLARE @ReturnCode INT 
	SELECT @ReturnCode = 0 
	IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=@AgentCategoryName AND category_class=1) 
	BEGIN 
		EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=@AgentCategoryName 
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
			GOTO QuitWithRollback 
	END 

	DECLARE @jobId BINARY(16) 

	EXEC @ReturnCode = msdb.dbo.sp_add_job @job_name=@AgentJobName, 
			@enabled=1, 
			@description=@AgentJobDescription, 
			@category_name=@AgentCategoryName, 
			@owner_login_name=N'sa', @job_id = @jobId OUTPUT 
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
		DECLARE @SQL VARCHAR(200) = 'EXECUTE '+@ProcedureName+' @mode='''+@AgentJobMode+''', @threshold='+@AgentJobThreshold+', @frequency='+@AgentJobFrequency+', @save='+@AgentJobSave
		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'blockdetection', 
			@step_id=1, 
			@cmdexec_success_code=0, 
			@on_success_action=1, 
			@on_fail_action=2, 
			@subsystem=N'TSQL', 
			@command=@SQL, 
			@database_name=@DatabaseName        
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


/*
	Step 4 – Alert to monitor "Processes Blocked"
*/

-- If alert exists then drop
IF  EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = @AlertName) 
BEGIN 
	PRINT 'Deleting Alert: '+@AlertName 
	EXEC msdb.dbo.sp_delete_alert @name=@AlertName 
END 

-- Create alert for SQL Server Performance Counter "SQLServer::General Statistics – Processes blocked"
PRINT 'Creating alert: '+@AlertName
declare @instance varchar(128), @perfcon varchar(256)
if @@servicename = 'MSSQLSERVER' -- Standard-Instance
  set @instance = 'SQLServer'
else -- Named Instance
  set @instance = 'MSSQL$' + @@servicename
set @perfcon = @instance + N':General Statistics|Processes blocked||>|0'

EXEC msdb.dbo.sp_add_alert @name=@AlertName, 
  @message_id=0, 
  @severity=0, 
  @enabled=1, 
  @delay_between_responses=10, 
  @include_event_description_in=0, 
  @performance_condition= @perfcon, 
  @job_name=@AgentJobName
GO
