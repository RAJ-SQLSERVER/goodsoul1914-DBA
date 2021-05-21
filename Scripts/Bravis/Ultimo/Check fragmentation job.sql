USE [msdb]
GO

/****** Object:  Job [ZKH : Check fragmentation]    Script Date: 9-1-2020 14:25:57 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 9-1-2020 14:25:57 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ZKH : Check fragmentation', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'GPULTIMOSQL01', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Aanmaken tabellen]    Script Date: 9-1-2020 14:25:57 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aanmaken tabellen', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--part 1: create the objects 
SET NOCOUNT ON;

if not exists (select name from sys.databases where name = ''ZKH_Maintenance'')
    create database ZKH_Maintenance
go
use ZKH_Maintenance
go
if not exists (select name from sys.objects where name = ''fragmentation_active'')
   create table fragmentation_active(
        history_id int identity(1,1), 
        database_id smallint NULL,
        database_name sysname NULL,
        schema_id int null,
        schema_name sysname null,
        object_id int NULL,
        object_name sysname NULL,
        index_id int NULL,
        index_name sysname NULL,
        partition_number int NULL,
        avg_fragmentation_in_percent_before float NULL,
        avg_fragmentation_in_percent_after float NULL,
        alter_start datetime NULL,
        alter_end datetime NULL,
        progress datetime NULL
    ) ON [PRIMARY]
if not exists (select name from sys.objects where name = ''fragmentation_history'')
   create table fragmentation_history(
        history_id int identity(1,1), 
        database_id smallint NULL,
        database_name sysname NULL,
        schema_id int null,
        schema_name sysname null,
        object_id int NULL,
        object_name sysname NULL,
        index_id int NULL,
        index_name sysname NULL,
        partition_number int NULL,
        avg_fragmentation_in_percent_before float NULL,
        avg_fragmentation_in_percent_after float NULL,
        alter_start datetime NULL,
        alter_end datetime NULL,
        progress datetime NULL
    ) ON [PRIMARY]
if not exists (select name from sys.objects where name = ''sql_errors'')
    create table sql_errors(
        error_id int identity(1,1),
        command varchar(4000) null,
        error_number int null,
        error_severity smallint null,
        error_state smallint null,
        error_line int null,
        error_message varchar(4000) null,
        error_procedure varchar(200) null,
        time_stamp datetime null,
        primary key clustered 
        (
            error_id asc
        ) ON [PRIMARY]
    ) ON [PRIMARY]
GO
if exists (select name from sys.objects where name = ''p_error_handling'')
    drop procedure p_error_handling
go
create procedure p_error_handling 
    @command varchar(4000)
as
DECLARE @error_number int
DECLARE @error_severity int
DECLARE @error_state int
DECLARE @error_line int
DECLARE @error_message varchar(4000)
DECLARE @error_procedure varchar(200)
DECLARE @time_stamp datetime

SELECT @error_number = isnull(error_number(),0),
        @error_severity = isnull(error_severity(),0),
        @error_state = isnull(error_state(),1),
        @error_line = isnull(error_line(), 0),
        @error_message = isnull(error_message(),''NULL Message''),
        @error_procedure = isnull(error_procedure(),''''),
        @time_stamp = GETDATE();

INSERT INTO dbo.sql_errors (command, error_number, error_severity, error_state, error_line, error_message, error_procedure, time_stamp)
SELECT @command, @error_number, @error_severity, @error_state, @error_line, @error_message, @error_procedure, @time_stamp

GO
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Verplaats data naar history-tabellen]    Script Date: 9-1-2020 14:25:57 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Verplaats data naar history-tabellen', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'INSERT INTO fragmentation_history
SELECT [database_id]
      ,[database_name]
      ,[schema_id]
      ,[schema_name]
      ,[object_id]
      ,[object_name]
      ,[index_id]
      ,[index_name]
      ,[partition_number]
      ,[avg_fragmentation_in_percent_before]
      ,[avg_fragmentation_in_percent_after]
      ,[alter_start]
      ,[alter_end]
      ,[progress]
  FROM fragmentation_active

', 
		@database_name=N'ZKH_Maintenance', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Truncate tables]    Script Date: 9-1-2020 14:25:57 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Truncate tables', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'TRUNCATE TABLE fragmentation_active', 
		@database_name=N'ZKH_Maintenance', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Collect fragmentatie gegevens]    Script Date: 9-1-2020 14:25:57 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Collect fragmentatie gegevens', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--part 2: Collect the fragmentation data
SET NOCOUNT ON;
DECLARE @command varchar(8000);
DECLARE @databaseid int;
DECLARE @databasename sysname;

DECLARE database_list CURSOR FOR 
    SELECT database_id, name 
    FROM sys.databases 
    where database_id > 4 and state not in (1)-- and database_id = 5
    order by name

-- Open the cursor.
OPEN database_list

-- Loop through the partitions.
FETCH NEXT FROM database_list 
   INTO @databaseid, @databasename

WHILE @@FETCH_STATUS = 0
    BEGIN
        --set @databasename = ''AdventureWorks2008''
        set @command = ''use ['' + @databasename + ''];''
        set @command = @command + ''
                                    insert into ZKH_Maintenance.dbo.fragmentation_active (database_id, database_name, schema_id, schema_name, object_id, object_name, index_id, index_name, partition_number, avg_fragmentation_in_percent_before)
                                    SELECT     D.database_id, D.name, O.schema_id, s.name, IPS.object_id, O.name, IPS.index_id, I.name, partition_number, avg_fragmentation_in_percent
                                    FROM sys.dm_db_index_physical_stats ('' + convert(varchar(3), @databaseid) + '', NULL, NULL , NULL, ''''LIMITED'''') IPS
                                    join sys.databases D on IPS.database_id=D.database_id
                                    join sys.objects O on IPS.object_id = O.object_id
                                    join sys.schemas as s ON s.schema_id = O.schema_id
                                    join sys.indexes I on IPS.object_id = I.object_id and IPS.index_id = I.index_id
                                    WHERE D.state not in (1) and avg_fragmentation_in_percent > 5.0 AND IPS.index_id > 0
                                    and page_count>10                                   
                                    ''
        exec (@command)
        FETCH NEXT FROM database_list 
           INTO @databaseid, @databasename
    END;
-- Close and deallocate the cursor.
CLOSE database_list;
DEALLOCATE database_list;
', 
		@database_name=N'ZKH_Maintenance', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Oplossen fragmentatie-items]    Script Date: 9-1-2020 14:25:57 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Oplossen fragmentatie-items', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--part 3: fix the fragmentation with rebuild or reorganize according to the threshold
SET NOCOUNT ON;
DECLARE @historyid int;
DECLARE @command varchar(8000);
DECLARE @command1 varchar(7950);
DECLARE @command2 varchar(50);
DECLARE @databaseid int;
DECLARE @databasename sysname;
DECLARE @schemaid int;
DECLARE @schemaname sysname;
DECLARE @objectid int;
DECLARE @objectname sysname;
DECLARE @indexid int;
DECLARE @indexname sysname;
DECLARE @partitionnumber bigint;
DECLARE @frag_before float;
DECLARE @frag_after float;
DECLARE @alterstart datetime;
DECLARE @alterend datetime;
DECLARE @progress datetime;

set @progress = getdate()

DECLARE fragmentation_list CURSOR FOR 
    SELECT history_id, database_id, database_name, schema_id, schema_name, object_id, object_name, index_id, index_name, partition_number, avg_fragmentation_in_percent_before 
    FROM ZKH_Maintenance.dbo.fragmentation_active 
    where progress is null
    order by avg_fragmentation_in_percent_before desc;

-- Open the cursor.
OPEN fragmentation_list;

-- Loop through the partitions.
FETCH NEXT
   FROM fragmentation_list
   INTO @historyid, @databaseid, @databasename, @schemaid, @schemaname, @objectid, @objectname, @indexid, @indexname, @partitionnumber, @frag_before;

WHILE @@FETCH_STATUS = 0

    BEGIN;

        -- 25 is an arbitrary decision point at which to switch between reorganizing and rebuilding
        IF @frag_before < 25.0
            BEGIN;
                set @command1 = ''use ['' + @databasename + ''];''
                set @command1 = @command1 + ''
                                            SET QUOTED_IDENTIFIER ON;
                                            DECLARE @partitioncount bigint;
                                            SELECT @partitioncount = count (*)
                                            FROM sys.partitions
                                            WHERE object_id = '' + convert(varchar(10), @objectid) + '' AND index_id = '' + convert(varchar(10), @indexid) + '';
                                            IF @partitioncount > 1
											
                                                ALTER INDEX ['' + @indexname + ''] ON ['' + @schemaname + ''].['' + @objectname + ''] REORGANIZE'' + '' PARTITION='' + CONVERT (CHAR, @partitionnumber) + '';
                                            else
                                                ALTER INDEX ['' + @indexname + ''] ON ['' + @schemaname + ''].['' + @objectname + ''] REORGANIZE'' + '';
                                            UPDATE STATISTICS ['' + @schemaname + ''].['' + @objectname + ''] ['' + @indexname + ''];
                                            ''
                set @command = @command1
				--select @command
            END;

        IF @frag_before >= 25.0
            BEGIN;
                set @command1 = ''use ['' + @databasename + ''];''
                set @command1 = @command1 + ''
                                            SET QUOTED_IDENTIFIER ON;
                                            DECLARE @partitioncount bigint;
                                            SELECT @partitioncount = count (*)
                                            FROM sys.partitions
                                            WHERE object_id = '' + convert(varchar(10), @objectid) + '' AND index_id = '' + convert(varchar(10), @indexid) + '';
                                            IF @partitioncount > 1
                                                ALTER INDEX ['' + @indexname +''] ON ['' + @schemaname + ''].['' + @objectname + ''] REBUILD'' + '' PARTITION='' + CONVERT (CHAR, @partitionnumber) + ''
                                            else
                                                ALTER INDEX ['' + @indexname +''] ON ['' + @schemaname + ''].['' + @objectname + ''] REBUILD'' + ''
                                            ''
                set @command2 = '''' --''with (online=ON)''
                set @command = @command1 + '' '' + @command2
				--select @command
            END;

            begin try
                    set @alterstart = getdate() 
                    EXEC (@command);
                    set @alterend = getdate()
    
                    select @frag_after = avg_fragmentation_in_percent  
                    from sys.dm_db_index_physical_stats(@databaseid, @objectid, @indexid, @partitionnumber,  ''LIMITED'')

                    update ZKH_Maintenance.dbo.fragmentation_active
                    set alter_start = @alterstart,
                        alter_end = @alterend,
                        avg_fragmentation_in_percent_after = @frag_after,
                        progress = @progress
                    where history_id = @historyid
            end try    
            begin catch
                    if error_number() = 2275 or error_number() = 153
                        begin
                            set @alterstart = getdate() 
                            EXEC (@command1);
                            set @alterend = getdate()
    
                            select @frag_after = avg_fragmentation_in_percent  
                            from sys.dm_db_index_physical_stats(@databaseid, @objectid, @indexid, @partitionnumber,  ''LIMITED'')

                            update ZKH_Maintenance.dbo.fragmentation_active
                            set alter_start = @alterstart,
                                alter_end = @alterend,
                                avg_fragmentation_in_percent_after = @frag_after,
                                progress = @progress
                            where history_id = @historyid
                        end
                    select @command command, @databasename database_name, @schemaname schema_name, @objectname object_name, @indexname index_name, @partitionnumber partition_number, 
                            error_number() error_number , ERROR_SEVERITY() error_severity, ERROR_STATE() error_state, ERROR_LINE() error_line, ERROR_MESSAGE() error_message
                    exec p_error_handling  @command
            end catch

            FETCH NEXT
               FROM fragmentation_list
               INTO @historyid, @databaseid, @databasename,  @schemaid, @schemaname, @objectid, @objectname, @indexid, @indexname, @partitionnumber, @frag_before;
    END;

-- Close and deallocate the cursor.
CLOSE fragmentation_list;
DEALLOCATE fragmentation_list;', 
		@database_name=N'ZKH_Maintenance', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule 1', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20150730, 
		@active_end_date=99991231, 
		@active_start_time=60000, 
		@active_end_time=235959, 
		@schedule_uid=N'0719ca88-ec20-4e88-a7f8-8465d4b630c7'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


