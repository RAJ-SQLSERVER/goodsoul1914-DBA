/******************************************************************************

Setup script for the creation of a generic DBA database.

Author	: M. Boomaars <m.boomaars@bravis.nl>
Date	: 2020-11-06
Note	: Before running this script, make sure SQLCMD mode is turned on!

******************************************************************************/

-------------------------------------------------------------------------------
-- Create DBA database
-------------------------------------------------------------------------------

DECLARE @SqlToExecute NVARCHAR(MAX);
DECLARE @InstanceDefaultDataPath SQL_VARIANT = SERVERPROPERTY('InstanceDefaultDataPath');
DECLARE @InstanceDefaultLogPath SQL_VARIANT = SERVERPROPERTY('InstanceDefaultLogPath');

IF NOT EXISTS (SELECT name FROM master.sys.databases WHERE name = N'DBA')
BEGIN
    SET @SqlToExecute
        = N'
    CREATE DATABASE [DBA] 
	ON PRIMARY
           (
               NAME = N''DBA'',
               FILENAME = N''' + CONVERT(NVARCHAR(255), @InstanceDefaultDataPath) + N'DBA.mdf'',
               SIZE = 1048576KB,
               MAXSIZE = UNLIMITED,
               FILEGROWTH = 524288KB
           )
    LOG ON
        (
            NAME = N''DBA_log'',
            FILENAME = N''' + CONVERT(NVARCHAR(255), @InstanceDefaultLogPath) + N'DBA_log.ldf'',
            SIZE = 262144KB,
            MAXSIZE = 2048GB,
            FILEGROWTH = 65536KB
        );';

    EXEC sp_executesql @SqlToExecute;
END;
GO

-------------------------------------------------------------------------------
-- Set recovery mode to SIMPLE
-------------------------------------------------------------------------------

ALTER DATABASE DBA SET RECOVERY SIMPLE;
GO

-------------------------------------------------------------------------------
-- Start using the new database
-------------------------------------------------------------------------------

USE DBA;
GO

EXEC sp_changedbowner 'sa';
GO

-------------------------------------------------------------------------------
-- Create tables
-------------------------------------------------------------------------------

IF NOT EXISTS (SELECT name FROM sys.tables WHERE name = N'DatabaseInfo')
BEGIN
    CREATE TABLE dbo.DatabaseInfo (
        CollectionTime    DATETIME2 NOT NULL,
        DatabaseName      sysname   NOT NULL,
        TableCount        INT       NOT NULL,
        TableColumnsCount INT       NOT NULL,
        ViewCount         INT       NOT NULL,
        ProcedureCount    INT       NOT NULL,
        TriggerCount      INT       NOT NULL,
        DataTotalSizeMB   BIGINT    NOT NULL,
        DataSpaceUtilMB   BIGINT    NOT NULL,
        LogTotalSizeMB    BIGINT    NOT NULL,
        LogSpaceUtilMB    BIGINT    NOT NULL
    );
END;
GO

-------------------------------------------------------------------------------
-- Install prerequisites
-------------------------------------------------------------------------------

:setvar path "C:\Users\adm_mboomaa1\Downloads\T-SQL\DBA\Prereqs"
:r $(path)\FirstResponderKit\Install-Core-Blitz-No-Query-Store.sql

:setvar path "C:\Users\adm_mboomaa1\Downloads\T-SQL\DBA\Prereqs"
:r $(path)\MaintenanceSolution.sql

:setvar path "C:\Users\adm_mboomaa1\Downloads\T-SQL\DBA\Prereqs"
:r $(path)\who_is_active.sql

-------------------------------------------------------------------------------
-- Create stored procedures
-------------------------------------------------------------------------------

:setvar path "C:\Users\adm_mboomaa1\Downloads\T-SQL\DBA\Stored Procedures"
:r $(path)\usp_ShowDataFileGrowth.sql

:setvar path "C:\Users\adm_mboomaa1\Downloads\T-SQL\DBA\Stored Procedures"
:r $(path)\usp_ReadCommandLog.sql

-------------------------------------------------------------------------------
-- Create TAB operator
-------------------------------------------------------------------------------

IF NOT EXISTS (SELECT name FROM msdb.dbo.sysoperators WHERE name = N'TAB')
BEGIN
    EXEC msdb.dbo.sp_add_operator @name = N'TAB',
                                  @enabled = 1,
                                  @weekday_pager_start_time = 90000,
                                  @weekday_pager_end_time = 180000,
                                  @saturday_pager_start_time = 90000,
                                  @saturday_pager_end_time = 180000,
                                  @sunday_pager_start_time = 90000,
                                  @sunday_pager_end_time = 180000,
                                  @pager_days = 0,
                                  @email_address = N'tab@bravis.nl',
                                  @category_name = N'[Uncategorized]';
END;
GO

-------------------------------------------------------------------------------
-- Create data collection jobs
-------------------------------------------------------------------------------

-- DBA: BlitzFirst Log to Table
DECLARE @jobId BINARY(16);
EXEC msdb.dbo.sp_add_job @job_name = N'DBA: BlitzFirst Log to Table',
                         @enabled = 1,
                         @notify_level_eventlog = 0,
                         @notify_level_email = 2,
                         @notify_level_netsend = 0,
                         @notify_level_page = 0,
                         @delete_level = 0,
                         @description = N'No description available.',
                         @category_name = N'Data Collector',
                         @owner_login_name = N'sa',
                         @notify_email_operator_name = N'TAB',
                         @job_id = @jobId OUTPUT;

EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId,
                             @step_name = N'BlitzFirst',
                             @step_id = 1,
                             @cmdexec_success_code = 0,
                             @on_success_action = 3,
                             @on_success_step_id = 0,
                             @on_fail_action = 3,
                             @on_fail_step_id = 0,
                             @retry_attempts = 0,
                             @retry_interval = 0,
                             @os_run_priority = 0,
                             @subsystem = N'TSQL',
                             @command = N'EXEC dbo.sp_BlitzFirst @OutputDatabaseName = ''DBA'',
										@OutputSchemaName = ''dbo'',
										@OutputTableName = ''BlitzFirst'',
										@OutputTableNameFileStats = ''BlitzFirstFileStats'',
										@OutputTableNameWaitStats = ''BlitzFirstWaitStats'',
										@OutputTableNamePerfmonStats = ''BlitzFirstPerfmonStats'',
										@OutputTableNameBlitzCache = ''BlitzFirstBlitzCache'',
										@ExpertMode = 1;',
                             @database_name = N'DBA',
                             @flags = 0;

EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId,
                             @step_name = N'Cleanup',
                             @step_id = 2,
                             @cmdexec_success_code = 0,
                             @on_success_action = 1,
                             @on_success_step_id = 0,
                             @on_fail_action = 2,
                             @on_fail_step_id = 0,
                             @retry_attempts = 0,
                             @retry_interval = 0,
                             @os_run_priority = 0,
                             @subsystem = N'TSQL',
                             @command = N'DELETE FROM dbo.BlitzFirst
										WHERE CheckDate < DATEADD(MONTH, -1, GETDATE());

										DELETE FROM dbo.BlitzFirstBlitzCache
										WHERE CheckDate < DATEADD(MONTH, -1, GETDATE());

										DELETE FROM dbo.BlitzFirstFileStats
										WHERE CheckDate < DATEADD(MONTH, -1, GETDATE());

										DELETE FROM dbo.BlitzFirstPerfmonStats
										WHERE CheckDate < DATEADD(MONTH, -1, GETDATE());

										DELETE FROM dbo.BlitzFirstWaitStats
										WHERE CheckDate < DATEADD(MONTH, -1, GETDATE());
														',
                             @database_name = N'DBA',
                             @flags = 0;

EXEC msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1;

EXEC msdb.dbo.sp_add_jobschedule @job_id = @jobId,
                                 @name = N'Ieder uur',
                                 @enabled = 1,
                                 @freq_type = 4,
                                 @freq_interval = 1,
                                 @freq_subday_type = 8,
                                 @freq_subday_interval = 1,
                                 @freq_relative_interval = 0,
                                 @freq_recurrence_factor = 0,
                                 @active_start_date = 20201030,
                                 @active_end_date = 99991231,
                                 @active_start_time = 0,
                                 @active_end_time = 235959;

EXEC msdb.dbo.sp_add_jobserver @job_id = @jobId,
                               @server_name = N'(local)';
GO

-- DBA: BlitzIndex Log to Table
DECLARE @jobId BINARY(16);
EXEC msdb.dbo.sp_add_job @job_name = N'DBA: BlitzIndex Log to Table',
                         @enabled = 1,
                         @notify_level_eventlog = 0,
                         @notify_level_email = 2,
                         @notify_level_netsend = 0,
                         @notify_level_page = 0,
                         @delete_level = 0,
                         @description = N'No description available.',
                         @category_name = N'Data Collector',
                         @owner_login_name = N'sa',
                         @notify_email_operator_name = N'TAB',
                         @job_id = @jobId OUTPUT;

EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId,
                             @step_name = N'BlitzIndex',
                             @step_id = 1,
                             @cmdexec_success_code = 0,
                             @on_success_action = 3,
                             @on_success_step_id = 0,
                             @on_fail_action = 3,
                             @on_fail_step_id = 0,
                             @retry_attempts = 0,
                             @retry_interval = 0,
                             @os_run_priority = 0,
                             @subsystem = N'TSQL',
                             @command = N'EXEC dbo.sp_BlitzIndex @GetAllDatabases = 1,
										   @OutputDatabaseName = ''DBA'',
										   @OutputSchemaName = ''dbo'',
										   @OutputTableName = ''BlitzIndex'',
										   @Mode = 2;',
                             @database_name = N'DBA',
                             @flags = 4;

EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId,
                             @step_name = N'Cleanup table',
                             @step_id = 2,
                             @cmdexec_success_code = 0,
                             @on_success_action = 1,
                             @on_success_step_id = 0,
                             @on_fail_action = 2,
                             @on_fail_step_id = 0,
                             @retry_attempts = 0,
                             @retry_interval = 0,
                             @os_run_priority = 0,
                             @subsystem = N'TSQL',
                             @command = N'DELETE FROM dbo.BlitzIndex
										WHERE run_datetime < DATEADD(MONTH, -1, GETDATE());',
                             @database_name = N'DBA',
                             @flags = 4;

EXEC msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1;

EXEC msdb.dbo.sp_add_jobschedule @job_id = @jobId,
                                 @name = N'Wekelijks',
                                 @enabled = 1,
                                 @freq_type = 8,
                                 @freq_interval = 1,
                                 @freq_subday_type = 1,
                                 @freq_subday_interval = 0,
                                 @freq_relative_interval = 0,
                                 @freq_recurrence_factor = 1,
                                 @active_start_date = 20201030,
                                 @active_end_date = 99991231,
                                 @active_start_time = 230000,
                                 @active_end_time = 235959;

EXEC msdb.dbo.sp_add_jobserver @job_id = @jobId,
                               @server_name = N'(local)';
GO

-- DBA: BlitzWho Log to Table
DECLARE @jobId BINARY(16);
EXEC msdb.dbo.sp_add_job @job_name = N'DBA: BlitzWho Log to Table',
                         @enabled = 1,
                         @notify_level_eventlog = 0,
                         @notify_level_email = 2,
                         @notify_level_netsend = 0,
                         @notify_level_page = 0,
                         @delete_level = 0,
                         @description = N'No description available.',
                         @category_name = N'Data Collector',
                         @owner_login_name = N'sa',
                         @notify_email_operator_name = N'TAB',
                         @job_id = @jobId OUTPUT;

EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId,
                             @step_name = N'BlitzWho',
                             @step_id = 1,
                             @cmdexec_success_code = 0,
                             @on_success_action = 3,
                             @on_success_step_id = 0,
                             @on_fail_action = 3,
                             @on_fail_step_id = 0,
                             @retry_attempts = 0,
                             @retry_interval = 0,
                             @os_run_priority = 0,
                             @subsystem = N'TSQL',
                             @command = N'EXEC dbo.sp_BlitzWho @OutputDatabaseName = ''DBA'',
										 @OutputSchemaName = ''dbo'',
										 @OutputTableName = ''BlitzWho'';',
                             @database_name = N'DBA',
                             @flags = 0;

EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId,
                             @step_name = N'Cleanup table',
                             @step_id = 2,
                             @cmdexec_success_code = 0,
                             @on_success_action = 1,
                             @on_success_step_id = 0,
                             @on_fail_action = 2,
                             @on_fail_step_id = 0,
                             @retry_attempts = 0,
                             @retry_interval = 0,
                             @os_run_priority = 0,
                             @subsystem = N'TSQL',
                             @command = N'DELETE FROM dbo.BlitzWho
										WHERE CheckDate < DATEADD(MONTH, -1, GETDATE());',
                             @database_name = N'DBA',
                             @flags = 0;

EXEC msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1;

EXEC msdb.dbo.sp_add_jobschedule @job_id = @jobId,
                                 @name = N'Iedere minuut',
                                 @enabled = 1,
                                 @freq_type = 4,
                                 @freq_interval = 1,
                                 @freq_subday_type = 4,
                                 @freq_subday_interval = 1,
                                 @freq_relative_interval = 0,
                                 @freq_recurrence_factor = 0,
                                 @active_start_date = 20201030,
                                 @active_end_date = 99991231,
                                 @active_start_time = 0,
                                 @active_end_time = 235959;

EXEC msdb.dbo.sp_add_jobserver @job_id = @jobId,
                               @server_name = N'(local)';
GO

-- DBA: Log DatabaseInfo to table
DECLARE @jobId BINARY(16);
EXEC msdb.dbo.sp_add_job @job_name = N'DBA: Log DatabaseInfo to table',
                         @enabled = 1,
                         @notify_level_eventlog = 0,
                         @notify_level_email = 2,
                         @notify_level_netsend = 0,
                         @notify_level_page = 0,
                         @delete_level = 0,
                         @description = N'No description available.',
                         @category_name = N'Data Collector',
                         @owner_login_name = N'sa',
                         @notify_email_operator_name = N'TAB',
                         @job_id = @jobId OUTPUT;

EXEC msdb.dbo.sp_add_jobstep @job_id = @jobId,
                             @step_name = N'Get DatabaseInfo and log to table',
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
                             @command = N'DECLARE @tsql NVARCHAR(MAX);
										DECLARE @crlf NVARCHAR(10) = NCHAR(13) + NCHAR(10);

										IF OBJECT_ID(''tempdb..#DatabaseInfo'', ''U'') IS NOT NULL
											DROP TABLE #DatabaseInfo;

										CREATE TABLE #DatabaseInfo (
											DatabaseName      sysname NOT NULL,
											TableCount        INT     NOT NULL,
											TableColumnsCount INT     NOT NULL,
											ViewCount         INT     NOT NULL,
											ProcedureCount    INT     NOT NULL,
											TriggerCount      INT     NOT NULL,
											DataTotalSizeMB   BIGINT  NOT NULL,
											DataSpaceUtilMB   BIGINT  NOT NULL,
											LogTotalSizeMB    BIGINT  NOT NULL,
											LogSpaceUtilMB    BIGINT  NOT NULL
										);

										SELECT @tsql
											= COALESCE(@tsql, N'''') + @crlf + N''USE '' + QUOTENAME(name) + N'';'' + @crlf + 
												N''INSERT INTO #DatabaseInfo'' + @crlf 
												+ N''SELECT'' + @crlf 
												+ N''       N'' + QUOTENAME(name, '''''''') + N'' AS DatabaseName'' + @crlf
												+ N''     , (SELECT COUNT(*) AS TableCount      FROM '' + QUOTENAME(name) + N''.sys.tables)'' + @crlf
												+ N''     , (SELECT ISNULL(SUM(max_column_id_used), 0) AS TableColumnsCount FROM '' + QUOTENAME(name) + N''.sys.tables)'' + @crlf 
												+ N''     , (SELECT COUNT(*) AS ViewCount       FROM '' + QUOTENAME(name) + N''.sys.views)'' + @crlf 
												+ N''     , (SELECT COUNT(*) AS ProcedureCount  FROM '' + QUOTENAME(name) + N''.sys.procedures)'' + @crlf 
												+ N''     , (SELECT COUNT(*) AS TriggerCount    FROM '' + QUOTENAME(name) + N''.sys.triggers)'' + @crlf 
												+ N''     , (SELECT SUM(CAST(size AS BIGINT) * 8 / 1024) AS DataTotalSizeMB FROM '' + QUOTENAME(name) + N''.sys.master_files WHERE database_id = DB_ID(DB_NAME()) AND type = 0)'' + @crlf
												+ N''     , (SELECT SUM(CAST(FILEPROPERTY(name, ''''SpaceUsed'''') AS BIGINT) * 8 / 1024) AS DataSpaceUtilMB FROM '' + QUOTENAME(name) + N''.sys.master_files WHERE database_id = DB_ID(DB_NAME()) AND type = 0)'' + @crlf
												+ N''     , (SELECT SUM(size * 8 / 1024) AS LogTotalSizeMB  FROM '' + QUOTENAME(name) + N''.sys.master_files WHERE database_id = DB_ID(DB_NAME()) AND type = 1)'' + @crlf
												+ N''     , (SELECT SUM(FILEPROPERTY(name, ''''SpaceUsed'''') * 8 / 1024) AS LogSpaceUtilMB FROM '' + QUOTENAME(name) + N''.sys.master_files WHERE database_id = DB_ID(DB_NAME()) AND type = 1);'' + @crlf
										FROM sys.databases
										ORDER BY name;

										EXEC sys.sp_executesql @command = @tsql;

										INSERT INTO DBA.dbo.DatabaseInfo
										SELECT GETDATE(), * FROM #DatabaseInfo
										GO',
                             @database_name = N'DBA',
                             @flags = 0;

EXEC msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1;

EXEC msdb.dbo.sp_add_jobschedule @job_id = @jobId,
                                 @name = N'Dagelijks',
                                 @enabled = 1,
                                 @freq_type = 4,
                                 @freq_interval = 1,
                                 @freq_subday_type = 1,
                                 @freq_subday_interval = 0,
                                 @freq_relative_interval = 0,
                                 @freq_recurrence_factor = 0,
                                 @active_start_date = 20201103,
                                 @active_end_date = 99991231,
                                 @active_start_time = 220000,
                                 @active_end_time = 235959;

EXEC msdb.dbo.sp_add_jobserver @job_id = @jobId,
                               @server_name = N'(local)';

GO

-------------------------------------------------------------------------------
-- Setup DBMail
-------------------------------------------------------------------------------

USE master;
GO

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE WITH OVERRIDE;

EXEC sp_configure 'Database Mail XPs', 1;
EXEC sp_configure 'Agent XPs', 1;
RECONFIGURE WITH OVERRIDE;

DECLARE @SMTPServer VARCHAR(100) = 'mail.zkh.local';
DECLARE @AdminEmail VARCHAR(100) = 'TAB@bravis.nl';
DECLARE @DomainName VARCHAR(100) = '@bravis.nl';
DECLARE @replyToEmail VARCHAR(100) = 'noreply@bravis.nl';

DECLARE @servername VARCHAR(100) = REPLACE(@@servername, '\', '_');
DECLARE @email_address VARCHAR(100) = @servername + @DomainName;
DECLARE @display_name VARCHAR(100) = 'MSSQL - ' + @servername;
DECLARE @testmsg VARCHAR(100) = 'Howdy! This is a test from a SQL Server named ' + @servername;

IF EXISTS (SELECT * FROM msdb.dbo.sysmail_profile)
    PRINT 'DB mail already configured';
ELSE
BEGIN
    -- Create database mail account
    EXEC msdb.dbo.sysmail_add_account_sp @account_name = @servername,
                                         @description = @servername,
                                         @email_address = @email_address,
                                         @replyto_address = @replyToEmail,
                                         @display_name = @display_name,
                                         @mailserver_name = @SMTPServer;

    -- Create global mail profile
    EXEC msdb.dbo.sysmail_add_profile_sp @profile_name = @servername,
                                         @description = @servername;

    -- Add the account to the profile
    EXEC msdb.dbo.sysmail_add_profileaccount_sp @profile_name = @servername,
                                                @account_name = @servername,
                                                @sequence_number = 1;

    -- Grant access to the profile to all users in the msdb database
    EXEC msdb.dbo.sysmail_add_principalprofile_sp @profile_name = @servername,
                                                  @principal_name = 'public',
                                                  @is_default = 1;

    -- Send a test message
    EXEC msdb..sp_send_dbmail @profile_name = @servername,
                              @recipients = @AdminEmail,
                              @subject = @testmsg,
                              @body = @testmsg;

    -- Show mail profile						  
    EXEC msdb.dbo.sysmail_help_profile_sp;
END;

-- Enabling SQL Agent notification
USE msdb;
EXEC msdb.dbo.sp_set_sqlagent_properties @email_save_in_sent_folder = 1;

EXEC master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                     N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                     N'UseDatabaseMail',
                                     N'REG_DWORD',
                                     1;

EXEC master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                     N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                     N'DatabaseMailProfile',
                                     N'REG_SZ',
                                     @servername;

--
DECLARE @AlertInfo TABLE (
    FailSafeOperator     NVARCHAR(255),
    NotificationMethod   INT,
    ForwardingServer     NVARCHAR(255),
    ForwardingSeverity   INT,
    PagerToTemplate      NVARCHAR(255),
    PagerCCTemplate      NVARCHAR(255),
    PagerSubjectTemplate NVARCHAR(255),
    PagerSendSubjectOnly NVARCHAR(255),
    ForwardAlways        INT
);
INSERT INTO @AlertInfo
EXEC master.dbo.sp_MSgetalertinfo @includeaddresses = 0;

IF (SELECT FailSafeOperator FROM @AlertInfo) IS NULL
	PRINT 'WARNING !!! A failsafe operator has not been specified.'


GO

-------------------------------------------------------------------------------
-- Setup some default alerts
-------------------------------------------------------------------------------

USE msdb;
GO

SET NOCOUNT ON;

DECLARE @OperatorName sysname = N'TAB';
DECLARE @CategoryName sysname = N'SQL Server Agent Alerts';

-- Make sure you have an Agent Operator defined that matches the name you supplied
IF NOT EXISTS (
    SELECT *
    FROM   msdb.dbo.sysoperators
    WHERE  name = @OperatorName
)
BEGIN
    RAISERROR('There is no SQL Operator with a name of %s', 18, 16, @OperatorName);

    RETURN;
END;

-- Add Alert Category if it does not exist
IF NOT EXISTS (
    SELECT *
    FROM   msdb.dbo.syscategories
    WHERE  category_class = 2 -- ALERT
           AND category_type = 3
           AND name = @CategoryName
)
BEGIN
    EXEC dbo.sp_add_category @class = N'ALERT',
                             @type = N'NONE',
                             @name = @CategoryName;
END;

-- Get the server name
DECLARE @ServerName sysname = (SELECT @@SERVERNAME);

-- Alert Names start with the name of the server 
DECLARE @Sev16AlertName sysname = @ServerName + N' Alert - Sev 16 Error: Fatal Error in Resource';
DECLARE @Sev17AlertName sysname = @ServerName + N' Alert - Sev 17 Error: Fatal Error in Resource';
DECLARE @Sev18AlertName sysname = @ServerName + N' Alert - Sev 18 Error: Fatal Error in Resource';
DECLARE @Sev19AlertName sysname = @ServerName + N' Alert - Sev 19 Error: Fatal Error in Resource';
DECLARE @Sev20AlertName sysname = @ServerName + N' Alert - Sev 20 Error: Fatal Error in Current Process'
DECLARE @Sev21AlertName sysname = @ServerName + N' Alert - Sev 21 Error: Fatal Error in Database Process';
DECLARE @Sev22AlertName sysname = @ServerName + N' Alert - Sev 22 Error: Fatal Error: Table Integrity Suspect';
DECLARE @Sev23AlertName sysname = @ServerName + N' Alert - Sev 23 Error: Fatal Error Database Integrity Suspect';
DECLARE @Sev24AlertName sysname = @ServerName + N' Alert - Sev 24 Error: Fatal Hardware Error';
DECLARE @Sev25AlertName sysname = @ServerName + N' Alert - Sev 25 Error: Fatal Error';
DECLARE @Error823AlertName sysname = @ServerName + N' Alert - Error 823: The operating system returned an error';
DECLARE @Error824AlertName sysname = @ServerName + N' Alert - Error 824: Logical consistency-based I/O error';
DECLARE @Error825AlertName sysname = @ServerName + N' Alert - Error 825: Read-Retry Required';
DECLARE @Error832AlertName sysname = @ServerName + N' Alert - Error 832: Constant page has changed';
DECLARE @Error855AlertName sysname = @ServerName + N' Alert - Error 855: Uncorrectable hardware memory corruption detected';
DECLARE @Error856AlertName sysname = @ServerName + N' Alert - Error 856: SQL Server has detected hardware memory corruption, but has recovered the page';

-- Sev 16 Error: general errors that can be corrected by the user
IF NOT EXISTS (
    SELECT name
    FROM   msdb.dbo.sysalerts
    WHERE  name = @Sev16AlertName
)
    EXEC msdb.dbo.sp_add_alert @name = @Sev16AlertName,
                               @message_id = 0,
                               @severity = 16,
                               @enabled = 1,
                               @delay_between_responses = 900,
                               @include_event_description_in = 1,
                               @category_name = @CategoryName,
                               @job_id = N'00000000-0000-0000-0000-000000000000';

-- Add a notification if it does not exist
IF NOT EXISTS (
    SELECT     *
    FROM       dbo.sysalerts AS sa
    INNER JOIN dbo.sysnotifications AS sn
        ON sa.id = sn.alert_id
    WHERE      sa.name = @Sev16AlertName
)
BEGIN
    EXEC msdb.dbo.sp_add_notification @alert_name = @Sev16AlertName,
                                      @operator_name = @OperatorName,
                                      @notification_method = 1;
END;

-- Sev 17 Error: Indicates that the statement caused SQL Server to run out of resources (such as memory, locks, or disk space for the database) or to exceed some limit set by the system administrator
IF NOT EXISTS (
    SELECT name
    FROM   msdb.dbo.sysalerts
    WHERE  name = @Sev17AlertName
)
    EXEC msdb.dbo.sp_add_alert @name = @Sev17AlertName,
                               @message_id = 0,
                               @severity = 17,
                               @enabled = 1,
                               @delay_between_responses = 900,
                               @include_event_description_in = 1,
                               @category_name = @CategoryName,
                               @job_id = N'00000000-0000-0000-0000-000000000000';

-- Add a notification if it does not exist

IF NOT EXISTS (
    SELECT     *
    FROM       dbo.sysalerts AS sa
    INNER JOIN dbo.sysnotifications AS sn
        ON sa.id = sn.alert_id
    WHERE      sa.name = @Sev17AlertName
)
BEGIN
    EXEC msdb.dbo.sp_add_notification @alert_name = @Sev17AlertName,
                                      @operator_name = @OperatorName,
                                      @notification_method = 1;
END;

-- Sev 18 Error: Error in the Database Engine software

IF NOT EXISTS (
    SELECT name
    FROM   msdb.dbo.sysalerts
    WHERE  name = @Sev18AlertName
)
    EXEC msdb.dbo.sp_add_alert @name = @Sev18AlertName,
                               @message_id = 0,
                               @severity = 18,
                               @enabled = 1,
                               @delay_between_responses = 900,
                               @include_event_description_in = 1,
                               @category_name = @CategoryName,
                               @job_id = N'00000000-0000-0000-0000-000000000000';

-- Add a notification if it does not exist
IF NOT EXISTS (
    SELECT     *
    FROM       dbo.sysalerts AS sa
    INNER JOIN dbo.sysnotifications AS sn
        ON sa.id = sn.alert_id
    WHERE      sa.name = @Sev18AlertName
)
BEGIN
    EXEC msdb.dbo.sp_add_notification @alert_name = @Sev18AlertName,
                                      @operator_name = @OperatorName,
                                      @notification_method = 1;
END;

-- Sev 19 Error: Fatal Error in Resource
IF NOT EXISTS (
    SELECT name
    FROM   msdb.dbo.sysalerts
    WHERE  name = @Sev19AlertName
)
    EXEC msdb.dbo.sp_add_alert @name = @Sev19AlertName,
                               @message_id = 0,
                               @severity = 19,
                               @enabled = 1,
                               @delay_between_responses = 900,
                               @include_event_description_in = 1,
                               @category_name = @CategoryName,
                               @job_id = N'00000000-0000-0000-0000-000000000000';

-- Add a notification if it does not exist
IF NOT EXISTS (
    SELECT     *
    FROM       dbo.sysalerts AS sa
    INNER JOIN dbo.sysnotifications AS sn
        ON sa.id = sn.alert_id
    WHERE      sa.name = @Sev19AlertName
)
BEGIN
    EXEC msdb.dbo.sp_add_notification @alert_name = @Sev19AlertName,
                                      @operator_name = @OperatorName,
                                      @notification_method = 1;
END;

-- Sev 20 Error: Fatal Error in Current Process

IF NOT EXISTS (
    SELECT name
    FROM   msdb.dbo.sysalerts
    WHERE  name = @Sev20AlertName
)
    EXEC msdb.dbo.sp_add_alert @name = @Sev20AlertName,
                               @message_id = 0,
                               @severity = 20,
                               @enabled = 1,
                               @delay_between_responses = 900,
                               @include_event_description_in = 1,
                               @category_name = @CategoryName,
                               @job_id = N'00000000-0000-0000-0000-000000000000';

-- Add a notification if it does not exist
IF NOT EXISTS (
    SELECT     *
    FROM       dbo.sysalerts AS sa
    INNER JOIN dbo.sysnotifications AS sn
        ON sa.id = sn.alert_id
    WHERE      sa.name = @Sev20AlertName
)
BEGIN
    EXEC msdb.dbo.sp_add_notification @alert_name = @Sev20AlertName,
                                      @operator_name = @OperatorName,
                                      @notification_method = 1;
END;

-- Sev 21 Error: Fatal Error in Database Process
IF NOT EXISTS (
    SELECT name
    FROM   msdb.dbo.sysalerts
    WHERE  name = @Sev21AlertName
)
    EXEC msdb.dbo.sp_add_alert @name = @Sev21AlertName,
                               @message_id = 0,
                               @severity = 21,
                               @enabled = 1,
                               @delay_between_responses = 900,
                               @include_event_description_in = 1,
                               @category_name = @CategoryName,
                               @job_id = N'00000000-0000-0000-0000-000000000000';

-- Add a notification if it does not exist

IF NOT EXISTS (
    SELECT     *
    FROM       dbo.sysalerts AS sa
    INNER JOIN dbo.sysnotifications AS sn
        ON sa.id = sn.alert_id
    WHERE      sa.name = @Sev21AlertName
)
BEGIN
    EXEC msdb.dbo.sp_add_notification @alert_name = @Sev21AlertName,
                                      @operator_name = @OperatorName,
                                      @notification_method = 1;
END;

-- Sev 22 Error: Fatal Error Table Integrity Suspect
IF NOT EXISTS (
    SELECT name
    FROM   msdb.dbo.sysalerts
    WHERE  name = @Sev22AlertName
)
    EXEC msdb.dbo.sp_add_alert @name = @Sev22AlertName,
                               @message_id = 0,
                               @severity = 22,
                               @enabled = 1,
                               @delay_between_responses = 900,
                               @include_event_description_in = 1,
                               @category_name = @CategoryName,
                               @job_id = N'00000000-0000-0000-0000-000000000000';

-- Add a notification if it does not exist
IF NOT EXISTS (
    SELECT     *
    FROM       dbo.sysalerts AS sa
    INNER JOIN dbo.sysnotifications AS sn
        ON sa.id = sn.alert_id
    WHERE      sa.name = @Sev22AlertName
)
BEGIN
    EXEC msdb.dbo.sp_add_notification @alert_name = @Sev22AlertName,
                                      @operator_name = @OperatorName,
                                      @notification_method = 1;
END;

-- Sev 23 Error: Fatal Error Database Integrity Suspect
IF NOT EXISTS (
    SELECT name
    FROM   msdb.dbo.sysalerts
    WHERE  name = @Sev23AlertName
)
    EXEC msdb.dbo.sp_add_alert @name = @Sev23AlertName,
                               @message_id = 0,
                               @severity = 23,
                               @enabled = 1,
                               @delay_between_responses = 900,
                               @include_event_description_in = 1,
                               @category_name = @CategoryName,
                               @job_id = N'00000000-0000-0000-0000-000000000000';

-- Add a notification if it does not exist
IF NOT EXISTS (
    SELECT     *
    FROM       dbo.sysalerts AS sa
    INNER JOIN dbo.sysnotifications AS sn
        ON sa.id = sn.alert_id
    WHERE      sa.name = @Sev23AlertName
)
BEGIN
    EXEC msdb.dbo.sp_add_notification @alert_name = @Sev23AlertName,
                                      @operator_name = @OperatorName,
                                      @notification_method = 1;
END;

-- Sev 24 Error: Fatal Hardware Error
IF NOT EXISTS (
    SELECT name
    FROM   msdb.dbo.sysalerts
    WHERE  name = @Sev24AlertName
)
    EXEC msdb.dbo.sp_add_alert @name = @Sev24AlertName,
                               @message_id = 0,
                               @severity = 24,
                               @enabled = 1,
                               @delay_between_responses = 900,
                               @include_event_description_in = 1,
                               @category_name = @CategoryName,
                               @job_id = N'00000000-0000-0000-0000-000000000000';

-- Add a notification if it does not exist
IF NOT EXISTS (
    SELECT     *
    FROM       dbo.sysalerts AS sa
    INNER JOIN dbo.sysnotifications AS sn
        ON sa.id = sn.alert_id
    WHERE      sa.name = @Sev24AlertName
)
BEGIN
    EXEC msdb.dbo.sp_add_notification @alert_name = @Sev24AlertName,
                                      @operator_name = @OperatorName,
                                      @notification_method = 1;
END;

-- Sev 25 Error: Fatal Error
IF NOT EXISTS (
    SELECT name
    FROM   msdb.dbo.sysalerts
    WHERE  name = @Sev25AlertName
)
    EXEC msdb.dbo.sp_add_alert @name = @Sev25AlertName,
                               @message_id = 0,
                               @severity = 25,
                               @enabled = 1,
                               @delay_between_responses = 900,
                               @include_event_description_in = 1,
                               @category_name = @CategoryName,
                               @job_id = N'00000000-0000-0000-0000-000000000000';

-- Add a notification if it does not exist

IF NOT EXISTS (
    SELECT     *
    FROM       dbo.sysalerts AS sa
    INNER JOIN dbo.sysnotifications AS sn
        ON sa.id = sn.alert_id
    WHERE      sa.name = @Sev25AlertName
)
BEGIN
    EXEC msdb.dbo.sp_add_notification @alert_name = @Sev25AlertName,
                                      @operator_name = @OperatorName,
                                      @notification_method = 1;
END;

-- Error 823 Alert added on 8/11/2014
-- Error 823: Operating System Error
-- How to troubleshoot a Msg 823 error in SQL Server	
-- http://support.microsoft.com/kb/2015755

IF NOT EXISTS (
    SELECT name
    FROM   msdb.dbo.sysalerts
    WHERE  name = @Error823AlertName
)
    EXEC msdb.dbo.sp_add_alert @name = @Error823AlertName,
                               @message_id = 823,
                               @severity = 0,
                               @enabled = 1,
                               @delay_between_responses = 900,
                               @include_event_description_in = 1,
                               @category_name = @CategoryName,
                               @job_id = N'00000000-0000-0000-0000-000000000000';

-- Add a notification if it does not exist
IF NOT EXISTS (
    SELECT     *
    FROM       dbo.sysalerts AS sa
    INNER JOIN dbo.sysnotifications AS sn
        ON sa.id = sn.alert_id
    WHERE      sa.name = @Error823AlertName
)
BEGIN
    EXEC msdb.dbo.sp_add_notification @alert_name = @Error823AlertName,
                                      @operator_name = @OperatorName,
                                      @notification_method = 1;
END;

-- Error 824 Alert added on 8/11/2014
-- Error 824: Logical consistency-based I/O error
-- How to troubleshoot Msg 824 in SQL Server
-- http://support.microsoft.com/kb/2015756

IF NOT EXISTS (
    SELECT name
    FROM   msdb.dbo.sysalerts
    WHERE  name = @Error824AlertName
)
    EXEC msdb.dbo.sp_add_alert @name = @Error824AlertName,
                               @message_id = 824,
                               @severity = 0,
                               @enabled = 1,
                               @delay_between_responses = 900,
                               @include_event_description_in = 1,
                               @category_name = @CategoryName,
                               @job_id = N'00000000-0000-0000-0000-000000000000';

-- Add a notification if it does not exist
IF NOT EXISTS (
    SELECT     *
    FROM       dbo.sysalerts AS sa
    INNER JOIN dbo.sysnotifications AS sn
        ON sa.id = sn.alert_id
    WHERE      sa.name = @Error824AlertName
)
BEGIN
    EXEC msdb.dbo.sp_add_notification @alert_name = @Error824AlertName,
                                      @operator_name = @OperatorName,
                                      @notification_method = 1;
END;

-- Error 825: Read-Retry Required
-- How to troubleshoot Msg 825 (read retry) in SQL Server
-- http://support.microsoft.com/kb/2015757

IF NOT EXISTS (
    SELECT name
    FROM   msdb.dbo.sysalerts
    WHERE  name = @Error825AlertName
)
    EXEC msdb.dbo.sp_add_alert @name = @Error825AlertName,
                               @message_id = 825,
                               @severity = 0,
                               @enabled = 1,
                               @delay_between_responses = 900,
                               @include_event_description_in = 1,
                               @category_name = @CategoryName,
                               @job_id = N'00000000-0000-0000-0000-000000000000';

-- Add a notification if it does not exist
IF NOT EXISTS (
    SELECT     *
    FROM       dbo.sysalerts AS sa
    INNER JOIN dbo.sysnotifications AS sn
        ON sa.id = sn.alert_id
    WHERE      sa.name = @Error825AlertName
)
BEGIN
    EXEC msdb.dbo.sp_add_notification @alert_name = @Error825AlertName,
                                      @operator_name = @OperatorName,
                                      @notification_method = 1;
END;

-- Error 832 Alert added on 10/30/2013
-- Error 832: Constant page has changed
-- http://www.sqlskills.com/blogs/paul/dont-confuse-error-823-and-error-832/
-- http://support.microsoft.com/kb/2015759

IF NOT EXISTS (
    SELECT name
    FROM   msdb.dbo.sysalerts
    WHERE  name = @Error832AlertName
)
    EXEC msdb.dbo.sp_add_alert @name = @Error832AlertName,
                               @message_id = 832,
                               @severity = 0,
                               @enabled = 1,
                               @delay_between_responses = 900,
                               @include_event_description_in = 1,
                               @category_name = @CategoryName,
                               @job_id = N'00000000-0000-0000-0000-000000000000';

-- Add a notification if it does not exist
IF NOT EXISTS (
    SELECT     *
    FROM       dbo.sysalerts AS sa
    INNER JOIN dbo.sysnotifications AS sn
        ON sa.id = sn.alert_id
    WHERE      sa.name = @Error832AlertName
)
BEGIN
    EXEC msdb.dbo.sp_add_notification @alert_name = @Error832AlertName,
                                      @operator_name = @OperatorName,
                                      @notification_method = 1;
END;

-- Memory Error Correction alerts added on 10/30/2013
-- Mitigation of RAM Hardware Errors	 		
-- When SQL Server 2012 Enterprise Edition is installed on a Windows 2012 operating system with hardware that supports bad memory diagnostics, 
-- you will notice new error messages like 854, 855, and 856 instead of the 832 errors that LazyWriter usually generates.
-- Error 854 is just informing you that your instance supports memory error correction
-- Using SQL Server in Windows 8 and Windows Server 2012 environments
-- http://support.microsoft.com/kb/2681562
-- Check for SQL Server 2012 or greater and Enterprise Edition
-- You also need Windows Server 2012 or greater, plus hardware that supports memory error correction

IF LEFT(CONVERT(CHAR(2), SERVERPROPERTY('ProductVersion')), 2) >= '11'
   AND SERVERPROPERTY('EngineEdition') = 3
BEGIN
    -- Error 855: Uncorrectable hardware memory corruption detected
    IF NOT EXISTS (
        SELECT name
        FROM   msdb.dbo.sysalerts
        WHERE  name = @Error855AlertName
    )
        EXEC msdb.dbo.sp_add_alert @name = @Error855AlertName,
                                   @message_id = 855,
                                   @severity = 0,
                                   @enabled = 1,
                                   @delay_between_responses = 900,
                                   @include_event_description_in = 1,
                                   @category_name = @CategoryName,
                                   @job_id = N'00000000-0000-0000-0000-000000000000';

    -- Add a notification if it does not exist
    IF NOT EXISTS (
        SELECT     *
        FROM       dbo.sysalerts AS sa
        INNER JOIN dbo.sysnotifications AS sn
            ON sa.id = sn.alert_id
        WHERE      sa.name = @Error855AlertName
    )
    BEGIN
        EXEC msdb.dbo.sp_add_notification @alert_name = @Error855AlertName,
                                          @operator_name = @OperatorName,
                                          @notification_method = 1;
    END;

    -- Error 856: SQL Server has detected hardware memory corruption, but has recovered the page
    IF NOT EXISTS (
        SELECT name
        FROM   msdb.dbo.sysalerts
        WHERE  name = @Error856AlertName
    )
        EXEC msdb.dbo.sp_add_alert @name = @Error856AlertName,
                                   @message_id = 856,
                                   @severity = 0,
                                   @enabled = 1,
                                   @delay_between_responses = 900,
                                   @include_event_description_in = 1,
                                   @category_name = @CategoryName,
                                   @job_id = N'00000000-0000-0000-0000-000000000000';

    -- Add a notification if it does not exist
    IF NOT EXISTS (
        SELECT     *
        FROM       dbo.sysalerts AS sa
        INNER JOIN dbo.sysnotifications AS sn
            ON sa.id = sn.alert_id
        WHERE      sa.name = @Error856AlertName
    )
    BEGIN
        EXEC msdb.dbo.sp_add_notification @alert_name = @Error856AlertName,
                                          @operator_name = @OperatorName,
                                          @notification_method = 1;
    END;
END;
GO

-------------------------------------------------------------------------------
-- Schedule Ola maintenance jobs
-------------------------------------------------------------------------------

