USE [msdb]
GO

/****** Object:  Job [ZKH: Restore testdatabase]    Script Date: 20-4-2015 09:25:20 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 20-4-2015 09:25:20 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ZKH: Restore testdatabase', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'ZKH\adm_rmeijer', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Drop database]    Script Date: 20-4-2015 09:25:20 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Drop database', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- STAP 1, DROP DATABASE HIX_TEST
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N''HIX_TEST''
GO
USE [master]
GO
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = ''HIX_TEST'')
BEGIN
	ALTER DATABASE [HIX_TEST] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
END
GO
USE [master]
GO
/****** Object:  Database [HIX_TEST]    Script Date: 10/27/2013 14:40:35 ******/
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = ''HIX_TEST'')
BEGIN
	DROP DATABASE [HIX_TEST]
END
GO', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Restore database]    Script Date: 20-4-2015 09:25:20 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Restore database', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- STAP 2, RESTORE DATABASE
RESTORE DATABASE [HIX_TEST] FROM  DISK = N''\\gphixsql01.zkh.local\share$\HIX_BACKUP_VOORTESTACC.bak'' WITH  FILE = 1,  
MOVE N''HIX_PRODUCTIE_Data'' TO N''D:\SQLDATA\HIX_TEST.mdf'',  
MOVE N''HIX_PRODUCTIE_Log'' TO N''E:\SQLLog\HIX_TEST.ldf'',  
MOVE N''HIX_PRODUCTIE_MULTIMEDIA'' TO N''D:\SQLData\HIX_TEST.EZIS_PRODUCTIE_MULTIMEDIA'',  
NOUNLOAD,  REPLACE,  STATS = 1
GO', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Wijzig naamgeving]    Script Date: 20-4-2015 09:25:20 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Wijzig naamgeving', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE HIX_TEST
GO
UPDATE CONFIG_INSTVARS
   SET VALUE = ''CHIX_TEST '' + CONVERT(VARCHAR(10), GETDATE(),105) + ''''
 WHERE NAAM =  ''ALG_ZH_OMGEVING'' 
   AND OWNER = ''CHIPSOFT'' ', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Wijzig kleur]    Script Date: 20-4-2015 09:25:20 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Wijzig kleur', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE HIX_TEST
GO
update CONFIG_INSTVARS 
SET value = ''C'' + ''CSTEST'' + ''.'' 
WHERE naam = ''SCHIL_CLRSCH''

insert into config_instvars (naam,owner, insttype, speccode, value, etd_status) 
values (''SCHIL_CLRSCH'', ''CHIPSOFT'', ''G'', '''', ''C'' + ''CSTEST'' + ''.'' , '''')', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [COMEZ aanpassen]    Script Date: 20-4-2015 09:25:20 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'COMEZ aanpassen', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE HIX_TEST
GO
UPDATE config_instvars
SET [VALUE] = CAST(REPLACE(CAST([VALUE] as NVarchar(MAX)), ''comez'' ,''TESTCOMEZTEST'') AS NText)
WHERE [VALUE] like ''%comez%'' and OWNER = ''chipsoft''', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Versie controle starten]    Script Date: 20-4-2015 09:25:20 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Versie controle starten', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE HIX_TEST
GO
update CONFIG_INSTVARS set VALUE = ''C6.0 HF0.8.2''
where NAAM = ''zc_hfcheck'' and OWNER = ''chipsoft''', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Recovery model aanpassen]    Script Date: 20-4-2015 09:25:20 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Recovery model aanpassen', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [master]
GO
ALTER DATABASE [HIX_TEST] SET RECOVERY SIMPLE WITH NO_WAIT
GO', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Aanpassen paden]    Script Date: 20-4-2015 09:25:20 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aanpassen paden', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE HIX_TEST
GO
--update van config_instvars voor het wijzigen van de paden verwijzend naar \\zkh.local\zkh\Financieel
update CONFIG_INSTVARS
set value = replace(cast(value as varchar(max)), ''\\zkh.local\zkh\Financieel\'', ''\\zkh.local\zkh\Financieel\Test\'')
      where (value like ''%\%'' or value like ''%{$%}'' or value like ''%${%}'') 
            and value not like ''C<opmaak%'' 
            and naam <> ''RBUILDERINI'' 
            and  substring(cast(value as varchar(8000)),2,len(cast(value as varchar(8000)))-2) like ''\\zkh.local\zkh\Financieel%''
            -- onderstaande zou nog toegevoegd kunnen worden zodat een eventeel reeds bestaande verwijzing naar het juist path wordt uitgesloten. 
            -- momenteel niet in productie aanwezig, maar zou je het testen op acceptatie dan zijn ze wel aanwezig. 
            --and substring(cast(value as varchar(8000)),2,len(cast(value as varchar(8000)))-2) not like  ''\\zkh.local\zkh\financieel\Test\%''', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Enable ChipsoftWinzis]    Script Date: 20-4-2015 09:25:20 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Enable ChipsoftWinzis', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC sp_change_users_login ''Auto_Fix'', ''ChipSoftWinZis''
GO

EXEC sp_change_users_login ''Auto_Fix'', ''SQLReport''
GO
', 
		@database_name=N'HIX_TEST', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Script opsporen locks]    Script Date: 20-4-2015 09:25:20 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Script opsporen locks', 
		@step_id=10, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @DatabaseName  				varchar(50)		=''HIX_TEST''
DECLARE @TableName     				varchar(50)		=''zkh_blocklog''

DECLARE @ProcedureName				varchar(50)		=''zkh_blockdetection''

DECLARE @AgentCategoryName     		varchar(50)		=''Ziekenhuis''
DECLARE @AgentJobName     			varchar(50)		=''ZKH: Block Detection''
DECLARE @AgentJobDescription		varchar(200)	=''Automatic Block-Detection by zkh''
DECLARE @AgentJobMode				varchar(50)		=''once''
DECLARE @AgentJobThreshold			varchar(50)		=1
DECLARE @AgentJobFrequency			varchar(50)		=1
DECLARE @AgentJobSave				varchar(50)		=1

DECLARE @AlertName					varchar(50)		=''ZKH: Block Detection''

/*
	Step 1 – Block Log Table
*/

-- check if table exists
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].''+@TableName) AND type in (N''U''))
BEGIN
	PRINT ''Creating table: [''+@DatabaseName+''].[dbo].[''+@TableName+'']''
	EXEC(''CREATE TABLE [''+@DatabaseName+''].[dbo].[''+@TableName+''] (
		[entry_no] bigint identity constraint [''+@TableName+''_Tab$pk_ci] primary key clustered,
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
	)'')
END


/*
	Step 2 – Stored Procedure to save the data 
*/

-- If procedure exists drop it
IF (OBJECT_ID(@ProcedureName) IS NOT NULL)
BEGIN
	PRINT ''Deleting procedure: [dbo].[''+@ProcedureName+'']''
	EXEC(''DROP PROCEDURE [dbo].[''+@ProcedureName+'']'')
END

-- Create procedure
PRINT ''Creating procedure: [dbo].[''+@ProcedureName+'']''
EXEC(''
CREATE PROCEDURE [dbo].[''+@ProcedureName+'']
  @mode varchar(10) = ''''loop'''',         -- "loop" or "once"
  @threshold int = 1000,              -- Block threshold in milliseconds 
  @frequency int = 3,                 -- Check frequency in milliseconds
  @save tinyint = 0                   -- save output to table ''+@TableName+'' (0 = no, 1 = yes)
with encryption
as

if @mode <> ''''once'''' begin
  print ''''*********************************************************''''
  print ''''***                  System Improvement               ***''''
  print ''''***    Performance Optimization & Troubleshooting     ***''''
  print ''''*********************************************************''''
  print ''''              Version 1.00, Date: 24.02.2013             ''''
  print ''''''''
end

if (@mode not in (''''loop'''', ''''once'''')) begin
  raiserror (''''ERROR: Invalid Parameter @mode: %s'''', 15, 1, @mode)
  return
end
if (@threshold < 1) begin
  raiserror (''''ERROR: Invalid Parameter @threshold: %i'''', 15, 1, @threshold)
  return
end
if (@frequency < 1) begin
  raiserror (''''ERROR: Invalid Parameter @frequency: %i'''', 15, 1, @frequency)
  return
end
if (@save not in (0,1)) begin
  raiserror (''''ERROR: Invalid Parameter @save: %i'''', 15, 1, @save)
  return
end

set nocount on
set statistics io off
declare @spid int, @spid2 int, @loginame varchar(128), @blocked_by int, @blocked_by_name varchar(128), @orig_id int, @orig_name varchar(128), @timestmp datetime, @i int

if @mode = ''''once''''
  goto start_check

while 1 = 1 begin

  start_check:

  if exists (select * from sys.dm_exec_requests where [blocking_session_id] <> 0) begin
    print ''''Checkpoint '''' + convert(varchar(30), getdate())
       
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
             [cmd] = isnull(st1.[text], ''''''''),
             [query_plan] = isnull(qp1.[query_plan], ''''''''),
             session1.[status],
             session1.[cpu_time], 
             s1.[lock_timeout],
             [blocked by] = s1.[blocking_session_id],             
             [login_name 2] = session2.[login_name],
             [hostname 2] = session2.[host_name],
             [program_name 2] = session2.[program_name],
             [cmd 2] = isnull(st2.[text], ''''''''),
             [query_plan 2] = isnull(qp2.[query_plan], ''''''''),
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

      insert into [''+@TableName+'']
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
             [cmd] = isnull(st1.[text], ''''''''),
             [query_plan] = isnull(qp1.[query_plan], ''''''''),
             session1.[status],
             session1.[cpu_time], 
             s1.[lock_timeout],
             [blocked by] = s1.[blocking_session_id], 
			 s2.[session_id],
             [login_name 2] = session2.[login_name],
             [hostname 2] = session2.[host_name],
             [program_name 2] = session2.[program_name],
             [cmd 2] = isnull(st2.[text], ''''''''),
             [query_plan 2] = isnull(qp2.[query_plan], ''''''''),
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
    
      update [''+@DatabaseName+''].[dbo].[''+@TableName+''] set [table_name] = ''''- unknown -'''' where [table_name] is null

      -- get block originator
      declare originator_cur cursor for select [blocked by], [loginame 2]
        from [''+@DatabaseName+''].[dbo].[''+@TableName+'']
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
          if exists(select top 1 [blocked by] from [''+@DatabaseName+''].[dbo].[''+@TableName+''] where ([timestamp] = @timestmp) and ([spid] = @spid2)) begin
            select top 1 @spid = [blocked by], @loginame = [loginame 2] from [''+@DatabaseName+''].[dbo].[''+@TableName+''] where ([timestamp] = @timestmp) and ([spid] = @spid2)
            set @orig_id = @spid
            set @orig_name = @loginame                       
            set @spid2 = @spid         
          end else
            set @spid2 = 0
          set @i = @i + 1   -- "Emergency Exit", to avoid recursive loop
        end 
        update [''+@DatabaseName+''].[dbo].[''+@TableName+''] set [block_orig_id] = @orig_id, [block_orig_loginame] = @orig_name where current of originator_cur
        fetch next from originator_cur into @blocked_by, @blocked_by_name
      end
      close originator_cur
      deallocate originator_cur

    end
  end

  end_check:

  if @mode = ''''once''''
    return

  waitfor delay @frequency
end
'')


/*
	Step 3 – SQL Server Agent Job that will then execute the procedure 
*/

-- If agent job exists, then drop
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = @AgentJobName)
BEGIN
	PRINT ''Deleting agent job: ''+@AgentJobName
	EXEC msdb.dbo.sp_delete_job @job_name=@AgentJobName, @delete_unused_schedule=1
END

-- Create agent job to execute the procedure
PRINT ''Creating agent job: ''+@AgentJobName
BEGIN TRANSACTION 
	DECLARE @ReturnCode INT 
	SELECT @ReturnCode = 0 
	IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=@AgentCategoryName AND category_class=1) 
	BEGIN 
		EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N''JOB'', @type=N''LOCAL'', @name=@AgentCategoryName 
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
			GOTO QuitWithRollback 
	END 

	DECLARE @jobId BINARY(16) 

	EXEC @ReturnCode = msdb.dbo.sp_add_job @job_name=@AgentJobName, 
			@enabled=1, 
			@description=@AgentJobDescription, 
			@category_name=@AgentCategoryName, 
			@owner_login_name=N''sa'', @job_id = @jobId OUTPUT 
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
		DECLARE @SQL VARCHAR(200) = ''EXECUTE ''+@ProcedureName+'' @mode=''''''+@AgentJobMode+'''''', @threshold=''+@AgentJobThreshold+'', @frequency=''+@AgentJobFrequency+'', @save=''+@AgentJobSave
		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N''blockdetection'', 
			@step_id=1, 
			@cmdexec_success_code=0, 
			@on_success_action=1, 
			@on_fail_action=2, 
			@subsystem=N''TSQL'', 
			@command=@SQL, 
			@database_name=@DatabaseName        
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
		EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1 
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
		EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N''(local)'' 
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
	PRINT ''Deleting Alert: ''+@AlertName 
	EXEC msdb.dbo.sp_delete_alert @name=@AlertName 
END 

-- Create alert for SQL Server Performance Counter "SQLServer::General Statistics – Processes blocked"
PRINT ''Creating alert: ''+@AlertName
declare @instance varchar(128), @perfcon varchar(256)
if @@servicename = ''MSSQLSERVER'' -- Standard-Instance
  set @instance = ''SQLServer''
else -- Named Instance
  set @instance = ''MSSQL$'' + @@servicename
set @perfcon = @instance + N'':General Statistics|Processes blocked||>|0''

EXEC msdb.dbo.sp_add_alert @name=@AlertName, 
  @message_id=0, 
  @severity=0, 
  @enabled=1, 
  @delay_between_responses=10, 
  @include_event_description_in=0, 
  @performance_condition= @perfcon, 
  @job_name=@AgentJobName
GO
', 
		@database_name=N'HIX_TEST', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Extra views]    Script Date: 20-4-2015 09:25:20 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Extra views', 
		@step_id=11, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF EXISTS (SELECT 1 FROM sys.views WHERE name = ''ZKH_V0000'')
BEGIN
	DROP VIEW ZKH_V0000
END
GO
CREATE VIEW ZKH_V0000
AS
SELECT ''ZKH_V0000''               AS sdNaam
     , ''Overzicht alle views''    AS sdOmchrijving
     , ''Robert Meijer''           AS sdAuteur
     , ''2014-01-21''              AS ddGemaakt
     , ''0.1''                     AS ndVersie
     , ''Robert Meijer''           AS sdGewijzigdDoor
     , ''2014-01-21''              AS ddLaatsteWijziging
UNION
SELECT ''ZKH_V0001'' 
     , ''Omgeving met hotfixversie''
     , ''Robert Meijer''
     , ''2014-01-21''
     , ''0.1''
     , ''Robert Meijer''
     , ''2014-01-21''
UNION
SELECT ''ZKH_V0002'' 
     , ''Historie alle hotfixes''
     , ''Robert Meijer''
     , ''2014-01-21''
     , ''0.1''
     , ''Robert Meijer''
     , ''2014-01-21''
UNION
SELECT ''ZKH_V0003'' 
     , ''Laatste locks per database''
     , ''Maico Pijnen''
     , ''2014-02-20''
     , ''0.2''
     , ''Maico Pijnen''
     , ''2014-03-04''
UNION
SELECT ''ZKH_V0004'' 
     , ''Activity monitor''
     , ''Maico Pijnen''
     , ''2014-02-27''
     , ''0.1''
     , ''Maico Pijnen''
     , ''2014-02-27''
UNION
SELECT ''ZKH_V0005'' 
     , ''SQL PerfCounters''
     , ''Maico Pijnen''
     , ''2014-03-01''
     , ''0.2''
     , ''Maico Pijnen''
     , ''2014-04-16''
GO

IF EXISTS (SELECT 1 FROM sys.views WHERE name = ''ZKH_V0001'')
BEGIN
	DROP VIEW ZKH_V0001
END
GO
CREATE VIEW ZKH_V0001
AS
SELECT b.name AS Omgeving
     , b.create_date AS DatumOmgeving
     , INDATUM AS Datum
     , LATEST_HF AS HOTFIX
  FROM ZISCON_LOGSESSI
     , sys.databases b
 WHERE APPLICATIE = ''CHIPSOFT.DATABAS'' AND INDATUM =
                          (SELECT     MAX(INDATUM)
                            FROM          ZISCON_LOGSESSI
                            WHERE      APPLICATIE = ''CHIPSOFT.DATABAS'') AND b.name LIKE ''HIX_%''
GO
                       
IF EXISTS (SELECT 1 FROM sys.views WHERE name = ''ZKH_V0002'')
BEGIN
	DROP VIEW ZKH_V0002
END
GO
CREATE VIEW ZKH_V0002
AS
SELECT DISTINCT INDATUM
     , LATEST_HF
  FROM ZISCON_LOGSESSI AS a
 WHERE APPLICATIE = ''CHIPSOFT.DATABAS''
GO

IF EXISTS (SELECT 1 FROM sys.views WHERE name = ''ZKH_V0003'')
BEGIN
	DROP VIEW ZKH_V0003
END
GO
CREATE VIEW ZKH_V0003
AS
SELECT      timestamp, block_orig_id AS spid, [loginame 2] AS loginname, [hostname 2] AS hostname, [program_name 2] AS programname, [cmd 2] AS query
FROM          zkh_blocklog
WHERE      (block_orig_id = [spid 2]) OR
                        (block_orig_id = spid)
GROUP BY timestamp, block_orig_id, [loginame 2], [hostname 2], [program_name 2], [cmd 2]
GO

IF EXISTS (SELECT 1 FROM sys.views WHERE name = ''ZKH_V0004'')
BEGIN
	DROP VIEW ZKH_V0004
END
GO
CREATE VIEW [dbo].[ZKH_V0004]
AS
SELECT 
   SessionId    = s.session_id, 
   UserProcess  = CONVERT(CHAR(1), s.is_user_process),
   LoginInfo    = s.login_name,   
   DbInstance   = ISNULL(db_name(r.database_id), N''''), 
   TaskState    = ISNULL(t.task_state, N''''), 
   Command      = ISNULL(r.command, N''''), 
   App            = ISNULL(s.program_name, N''''), 
   WaitTime_ms  = ISNULL(w.wait_duration_ms, 0),
   WaitType     = ISNULL(w.wait_type, N''''),
   WaitResource = ISNULL(w.resource_description, N''''), 
   BlockBy        = ISNULL(CONVERT (varchar, w.blocking_session_id), ''''),
   HeadBlocker  = 
        CASE 
            -- session has active request; is blocked; blocking others
            WHEN r2.session_id IS NOT NULL AND r.blocking_session_id = 0 THEN ''1'' 
            -- session idle; has an open tran; blocking others
            WHEN r.session_id IS NULL THEN ''1'' 
            ELSE ''''
        END, 
   TotalCPU_ms        = s.cpu_time, 
   TotalPhyIO_mb    = (s.reads + s.writes) * 8 / 1024, 
   MemUsage_kb        = s.memory_usage * 8192 / 1024, 
   OpenTrans        = ISNULL(r.open_transaction_count,0), 
   LoginTime        = s.login_time, 
   LastReqStartTime = s.last_request_start_time,
   HostName            = ISNULL(s.host_name, N''''),
   NetworkAddr        = ISNULL(c.client_net_address, N''''), 
   ExecContext        = ISNULL(t.exec_context_id, 0),
   ReqId            = ISNULL(r.request_id, 0),
   WorkLoadGrp        = N'''',
   LastCommandBatch = (select text from sys.dm_exec_sql_text(c.most_recent_sql_handle)) 
FROM sys.dm_exec_sessions s LEFT OUTER JOIN sys.dm_exec_connections c ON (s.session_id = c.session_id)
LEFT OUTER JOIN sys.dm_exec_requests r ON (s.session_id = r.session_id)
LEFT OUTER JOIN sys.dm_os_tasks t ON (r.session_id = t.session_id AND r.request_id = t.request_id)
LEFT OUTER JOIN 
(
    -- Using row_number to select longest wait for each thread, 
    -- should be representative of other wait relationships if thread has multiple involvements. 
    SELECT *, ROW_NUMBER() OVER (PARTITION BY waiting_task_address ORDER BY wait_duration_ms DESC) AS row_num
    FROM sys.dm_os_waiting_tasks 
) w ON (t.task_address = w.waiting_task_address) AND w.row_num = 1
LEFT OUTER JOIN sys.dm_exec_requests r2 ON (r.session_id = r2.blocking_session_id)
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) as st

WHERE s.session_Id > 50                         -- ignore anything pertaining to the system spids.

AND s.session_Id NOT IN (@@SPID)     -- let''s avoid our own query! :)

GO


IF EXISTS (SELECT 1 FROM sys.views WHERE name = ''ZKH_V0005'')
BEGIN
	DROP VIEW ZKH_V0005
END
GO
CREATE VIEW [dbo].[ZKH_V0005]
AS
SELECT      object_name, counter_name, instance_name, cntr_value, cntr_type
FROM          master.dbo.sysperfinfo
UNION
SELECT 
	''SQLServer:Custom'',
	''Total memory usage %'',
	'''',
	round(100 - (cast([available_physical_memory_kb] as decimal) / cast([total_physical_memory_kb] as decimal) * 100),2),
	''''
FROM 
	[master].[sys].[dm_os_sys_memory]
UNION
SELECT 
	''SQLServer:Custom'',
	''Total cpu usage %'',
	'''',
	cast((SELECT sum(cntr_value) FROM sys.dm_os_performance_counters WHERE object_name = ''SQLServer:Resource Pool Stats'' and cntr_type = 537003264) as float) / cast((select distinct cntr_value from sys.dm_os_performance_counters where object_name = ''SQLServer:Resource Pool Stats'' and cntr_type = 1073939712) as float)*100,
	''''
GO


GRANT SELECT ON ZKH_V0000 TO SQLReport
GRANT SELECT ON ZKH_V0001 TO SQLReport
GRANT SELECT ON ZKH_V0002 TO SQLReport
GRANT SELECT ON ZKH_V0003 TO SQLReport
GRANT SELECT ON ZKH_V0004 TO SQLReport
GRANT SELECT ON ZKH_V0005 TO SQLReport', 
		@database_name=N'HIX_TEST', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Restore testdatabase', 
		@enabled=0, 
		@freq_type=1, 
		@freq_interval=0, 
		@freq_subday_type=0, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20150408, 
		@active_end_date=99991231, 
		@active_start_time=91500, 
		@active_end_time=235959, 
		@schedule_uid=N'42adceb2-e611-47c4-a5ff-4eef06908ebd'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


