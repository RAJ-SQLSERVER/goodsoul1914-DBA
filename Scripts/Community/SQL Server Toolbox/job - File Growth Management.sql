--Replaces our monthly findings to prevent autogrowths by proactively growing files.
--Replaces our Space In Files Monitoring job which only notified. 
--TODO: Update the @Threshold variable if using  value other than 10%, Update the email operator for the job notification

USE DBA; --TODO
GO
--If not exists, create the table anew
-- Create Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'Space_in_Files')
    CREATE TABLE dbo.Space_in_Files (
        ID                   INT           IDENTITY(1, 1) NOT NULL,
        DatabaseName         VARCHAR(128),
        recovery_model_desc  VARCHAR(50),
        DatabaseFileName     VARCHAR(500),
        FileLocation         VARCHAR(500),
        FileId               INT,
        FileSizeMB           DECIMAL(19, 2),
        SpaceUsedMB          DECIMAL(19, 2),
        AvailableMB          DECIMAL(19, 2),
        FreePercent          DECIMAL(9, 2),
        JobFileGrowth        VARCHAR(2000),
        FileGrowthDuration_s INT,
        DateTimePerformed    DATETIMEOFFSET(2)
            CONSTRAINT DF_Space_in_Files_DateTimePerformed
                DEFAULT (SYSDATETIMEOFFSET ())
            CONSTRAINT PK_Space_in_Files
            PRIMARY KEY CLUSTERED (ID ASC)
            WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
                  ALLOW_PAGE_LOCKS = ON
            ) ON [PRIMARY]
    ) ON [PRIMARY];
GO
--If it already exists, add these columns if they don't exist.
IF NOT EXISTS (
    SELECT *
    FROM sys.objects AS o
    INNER JOIN sys.columns AS c
        ON o.object_id = c.object_id
    WHERE o.name = 'Space_in_Files'
          AND c.name = 'JobFileGrowth'
)
    ALTER TABLE dbo.Space_in_Files
    ADD JobFileGrowth VARCHAR(2000),
        FileGrowthDuration_s INT;
GO

--Create Job
USE msdb;
GO
DECLARE @startup_job_id UNIQUEIDENTIFIER;
SELECT @startup_job_id = job_id
FROM msdb.dbo.sysjobs
WHERE name = 'File Growth Management Job';

IF @startup_job_id IS NOT NULL
    EXEC msdb.dbo.sp_delete_job @job_id = @startup_job_id,
                                @delete_unused_schedule = 1;
GO



BEGIN TRANSACTION;
DECLARE @ReturnCode INT;
SELECT @ReturnCode = 0;

IF NOT EXISTS (
    SELECT name
    FROM msdb.dbo.syscategories
    WHERE name = N'[Uncategorized (Local)]'
          AND category_class = 1
)
BEGIN
    EXEC @ReturnCode = msdb.dbo.sp_add_category @class = N'JOB',
                                                @type = N'LOCAL',
                                                @name = N'[Uncategorized (Local)]';
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;

END;

DECLARE @jobId BINARY(16);
EXEC @ReturnCode = msdb.dbo.sp_add_job @job_name = N'File Growth Management Job',
                                       @enabled = 1,
                                       @notify_level_eventlog = 0,
                                       @notify_level_email = 2,
                                       @notify_level_netsend = 0,
                                       @notify_level_page = 0,
                                       @delete_level = 0,
                                       @description = N'No description available.',
                                       @category_name = N'[Uncategorized (Local)]',
                                       @owner_login_name = N'sa',
                                       @notify_email_operator_name = N'Mark', --TODO: Update with a valid operator
                                       @job_id = @jobId OUTPUT;
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;


EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @jobId,
                                           @step_name = N'File Growth Management',
                                           @step_id = 1,
                                           @cmdexec_success_code = 0,
                                           @on_success_action = 1,
                                           @on_success_step_id = 0,
                                           @on_fail_action = 2,
                                           @on_fail_step_id = 0,
                                           @retry_attempts = 0,
                                           @retry_interval = 0,
                                           @os_run_priority = 0,
                                           @subsystem = N'TSQL',
                                           @command = N'Version# Q419 Rev01
		DECLARE @TempTable TABLE
(ID INT Identity(1,1) not null,
DatabaseName varchar(128)
,recovery_model_desc varchar(50)
,DatabaseFileName varchar(500)
,FileLocation varchar(500)
,FileId int
,FileSizeMB decimal(19,2)
,SpaceUsedMB decimal(19,2)
,AvailableMB decimal(19,2)
,FreePercent decimal(19,2)
,growTSQL nvarchar(4000)
)

DECLARE @GrowFileTxt nvarchar(4000)

INSERT INTO @TempTable
exec sp_MSforeachdb  ''use [?]; 
DECLARE @Threshold decimal(9,2) = 10.0 -- TODO Modify if desired.
select *,
growTSQL = ''''ALTER DATABASE [''''+DatabaseName_____________ COLLATE SQL_Latin1_General_CP1_CI_AS+''''] 
MODIFY FILE ( NAME = N''''''''''''+DatabaseFileName_______ COLLATE SQL_Latin1_General_CP1_CI_AS +''''''''''''
, '''' + CASE WHEN FileSizeMB < 100 THEN ''''SIZE = ''''+STR(FileSizeMB+64)
                                                WHEN FileSizeMB < 1000 THEN ''''SIZE = ''''+STR(FileSizeMB+256)
                                                WHEN FileSizeMB < 10000 THEN ''''SIZE = ''''+STR(FileSizeMB+1024)
                                                WHEN FileSizeMB < 40000 THEN ''''SIZE = ''''+STR(FileSizeMB+4092)
                                                ELSE ''''SIZE = ''''+STR(FileSizeMB+(FileSizeMB*.05)) END +''''MB )''''
FROM (
SELECT 
  ''''DatabaseName_____________'''' = d.name
, Recovery                                           = d.recovery_model_desc
, ''''DatabaseFileName_______'''' = df.name
, Location                                             = df.physical_name
, File_ID                                = df.File_ID
, FileSizeMB                        = CAST(size/128.0 as Decimal(9,2))
, SpaceUsedMB                = CAST(CAST(FILEPROPERTY(df.name, ''''SpaceUsed'''') AS int)/128.0 as Decimal(9,2))
, AvailableMB                    = CAST(size/128.0 - CAST(FILEPROPERTY(df.name, ''''SpaceUsed'''') AS int)/128.0 as Decimal(9,2))
, FreePercent                    = CAST((((size/128.0) - (CAST(FILEPROPERTY(df.name, ''''SpaceUsed'''') AS int)/128.0)) / (size/128.0) ) * 100. as Decimal(9,2))
FROM sys.database_files df
CROSS APPLY sys.databases d
WHERE d.database_id = DB_ID()
AND df.Type_desc <> ''''FILESTREAM'''' 
 AND d.is_read_only = 0
AND df.size > 0) AS x
WHERE FreePercent < @Threshold Or FreePercent is NULL;''

DECLARE @FileCounter INT = 1
DECLARE @FileMax INT
Set @FileMax = (Select Max(ID) from @TempTable)

DECLARE @starttime datetimeoffset(2), @endtime datetimeoffset(2)

while @FileCounter <= @FileMax
begin
                BEGIN TRY 
                Set @GrowFileTxt = (Select growTSQL from @TempTable where ID = @FileCounter)
				Set @starttime = SYSDATETIMEOFFSET()

                Exec (@GrowFileTxt)
                set @endtime = SYSDATETIMEOFFSET()

 
                                --Log the activity
                                INSERT INTO [DBA].dbo.[Space_in_Files] (DatabaseName,recovery_model_desc  ,DatabaseFileName  ,FileLocation  ,FileId ,FileSizeMB ,SpaceUsedMB,AvailableMB,FreePercent,
                                JobFileGrowth, FileGrowthDuration_s)
                                SELECT DatabaseName,recovery_model_desc ,DatabaseFileName  ,FileLocation  ,FileId ,FileSizeMB ,SpaceUsedMB,AvailableMB,FreePercent,  
                                @GrowFileTxt, datediff(s,@starttime, @endtime) FROM @TempTable
								WHERE ID = @FileCounter 
                END TRY
                BEGIN CATCH
                
                                --Log the activity
                                INSERT INTO [DBA].dbo.[Space_in_Files] (DatabaseName,recovery_model_desc  ,DatabaseFileName  ,FileLocation  ,FileId ,FileSizeMB ,SpaceUsedMB,AvailableMB,FreePercent,
                                JobFileGrowth, FileGrowthDuration_s)
                                SELECT DatabaseName,recovery_model_desc ,DatabaseFileName  ,FileLocation  ,FileId ,FileSizeMB ,SpaceUsedMB,AvailableMB,FreePercent,  
                                ERROR_MESSAGE(), datediff(s,@starttime, @endtime)FROM @TempTable 
								WHERE ID = @FileCounter

                                --SEND EMAIL
								DECLARE @ERR_TEXT nvarchar(MAX)
								Set @ERR_TEXT = CONCAT(''While executeing the File growth command: '', @GrowFileTxt, '', the following error was encountered. '', ERROR_MESSAGE())
                                --THROW --don''t do this, it would stop the loop
										EXEC msdb.dbo.sp_send_dbmail  
										@profile_name  = ''sh-tenroxsql'', --TODO change dbmail profile 
										@recipients = ''sql.alerts@sparkhound.com'',  
										@body = @ERR_TEXT,
										@importance = ''HIGH'',
										@body_format =''TEXT'',
										@subject = ''File Growth Management Job Alert'' ; 
                END CATCH
    set @FileCounter = @FileCounter +1;
	set @GrowFileTxt = null;
end',
                                           @database_name = N'master',
                                           @flags = 0;
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId,
                                          @start_step_id = 1;
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @jobId,
                                               @name = N'Daily',
                                               @enabled = 1,
                                               @freq_type = 4,
                                               @freq_interval = 1,
                                               @freq_subday_type = 1,
                                               @freq_subday_interval = 0,
                                               @freq_relative_interval = 0,
                                               @freq_recurrence_factor = 0,
                                               @active_start_date = 20191012,
                                               @active_end_date = 99991231,
                                               @active_start_time = 40000,
                                               @active_end_time = 235959,
                                               @schedule_uid = N'f80fd49a-6ae8-4ede-b22d-83d26f54d6b5';
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId,
                                             @server_name = N'(local)';
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;
COMMIT TRANSACTION;
GOTO EndSave;
QuitWithRollback:
IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION;
EndSave:
GO

--Can get rid of old Space In Files Monitoring if it exists
DECLARE @startup_job_id UNIQUEIDENTIFIER;
SELECT @startup_job_id = job_id
FROM msdb.dbo.sysjobs
WHERE name = 'Space In Files Monitoring';

IF @startup_job_id IS NOT NULL
    EXEC msdb.dbo.sp_delete_job @job_id = @startup_job_id,
                                @delete_unused_schedule = 1;
GO
