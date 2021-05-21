/********************************************************************************************************
    
    NAME:           usp_GetDiagnosticInfo

    SYNOPSIS:       Creates a list of RESTORE statements that have to be executed in order to 
                    return to a particular point in time.

    DEPENDENCIES:   None.
                    
	PARAMETERS:     Optional:

					@Hours specifies the number of hours some queries should go back in time.

					@Checks is a comma-delimited string of checks to execute.
					
					@SkipChecks is a comma-delimited string of checks to ignore.
	
	NOTES:			A lot of these checks are using code created by Glenn Berry
					(https://glennsqlperformance.com/resources/)

    AUTHOR:         Mark Boomaars
    
    CREATED:        2020-10-03
    
    VERSION:        1.0

    LICENSE:        MIT

    USAGE:          EXEC dbo.usp_GetDiagnosticInfo 
						@SkipChecks = 'TotalBufferUsageByDatabase,RingBufferConnectivityLoginTimers';

	--------------------------------------------------------------------------------------------
	    DATE       VERSION     AUTHOR               DESCRIPTION                               
	--------------------------------------------------------------------------------------------
        20201003   1.0         Mark Boomaars		Open Sourced on GitHub

*********************************************************************************************************/

USE DBA;
GO

IF OBJECT_ID('usp_GetDiagnosticInfo') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetDiagnosticInfo;
GO

CREATE PROCEDURE dbo.usp_GetDiagnosticInfo
(
    @Checks VARCHAR(4000) = NULL,
    @Hours INT = 6,
    @SkipChecks VARCHAR(4000) = NULL
)
AS
BEGIN

    SET QUOTED_IDENTIFIER ON;
    SET NOCOUNT ON;

    DECLARE @crlf NVARCHAR(10) = NCHAR(13) + NCHAR(10);
    DECLARE @t INT = 0;

    --10.0 (SQL2008), 10.5 (SQL2008 R2), 11 (SQL2012), 12 (SQL2014), 13 (SQL2016), 14 (SQL2017), 15 (SQL2019) 
    DECLARE @Version NUMERIC(18, 10)
        = CAST(LEFT(CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(MAX)), CHARINDEX(
                                                                                          '.',
                                                                                          CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(MAX))
                                                                                      ) - 1) + '.'
               + REPLACE(
                            RIGHT(CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(MAX)), LEN(CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(MAX)))
                                                                                           - CHARINDEX(
                                                                                                          '.',
                                                                                                          CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(MAX))
                                                                                                      )),
                            '.',
                            ''
                        ) AS NUMERIC(18, 10));

    DECLARE @tsql NVARCHAR(MAX);

    DECLARE @_Checks TABLE
    (
        [Check] VARCHAR(128) NOT NULL
    );
    DECLARE @_SkipChecks TABLE
    (
        [Check] VARCHAR(128) NOT NULL
    );

    IF (@Checks IS NOT NULL)
    BEGIN
        INSERT INTO @_Checks
        SELECT value
        FROM STRING_SPLIT(@Checks, ',');
    END;

    IF (@SkipChecks IS NOT NULL)
    BEGIN
        INSERT INTO @_SkipChecks
        SELECT value
        FROM STRING_SPLIT(@SkipChecks, ',');
    END;

    -------------------------------------------------------------------------------
    -- Get SQL Server Agent Alert Information (Query 10) (SQL Server Agent Alerts)
    -------------------------------------------------------------------------------

    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'AgentAlerts'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'AgentAlerts'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'AgentAlerts'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.AgentAlerts') IS NULL
        BEGIN
            CREATE TABLE dbo.AgentAlerts
            (
                CollectionTime DATETIME2(0) NOT NULL,
                Name sysname NOT NULL,
                EventSource NVARCHAR(100) NOT NULL,
                MesssageID INT NOT NULL,
                Severity INT NOT NULL,
                Enabled TINYINT NOT NULL,
                HasNotification INT NOT NULL,
                DelayBetweenResponses INT NOT NULL,
                OccurrenceCount INT NOT NULL,
                LastOccurrenceDate INT NOT NULL,
                LastOccurrenceTime INT NOT NULL
            ) ON [PRIMARY];
        END;

        INSERT INTO dbo.AgentAlerts
        (
            CollectionTime,
            Name,
            EventSource,
            MesssageID,
            Severity,
            Enabled,
            HasNotification,
            DelayBetweenResponses,
            OccurrenceCount,
            LastOccurrenceDate,
            LastOccurrenceTime
        )
        SELECT GETDATE(),
               name,
               event_source,
               message_id,
               severity,
               enabled,
               has_notification,
               delay_between_responses,
               occurrence_count,
               last_occurrence_date,
               last_occurrence_time
        FROM msdb.dbo.sysalerts WITH (NOLOCK)
        OPTION (RECOMPILE);
    END;

    -------------------------------------------------------------------------------
    -- Agentjob errors
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'AgentJobErrors'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'AgentJobErrors'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'AgentJobErrors'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.AgentJobErrors') IS NULL
        BEGIN
            CREATE TABLE dbo.AgentJobErrors
            (
                CollectionTime DATETIME2(0) NOT NULL,
                ErrorDate DATETIME NOT NULL,
                JobID UNIQUEIDENTIFIER NOT NULL,
                JobName sysname NOT NULL,
                JobStepID INT NOT NULL,
                JobStepName sysname NOT NULL,
                SQLMessageID BIGINT NOT NULL,
                ErrorMessage NVARCHAR(4000) NULL
            ) ON [PRIMARY];
        END;

        INSERT INTO dbo.AgentJobErrors
        (
            CollectionTime,
            ErrorDate,
            JobID,
            JobName,
            JobStepID,
            JobStepName,
            SQLMessageID,
            ErrorMessage
        )
        SELECT GETDATE(),
               msdb.dbo.agent_datetime(jh.run_date, jh.run_time),
               j.job_id,
               j.name AS "JobName",
               js.step_id,
               js.step_name,
               jh.sql_message_id,
               jh.message
        FROM msdb.dbo.sysjobs AS j
            INNER JOIN msdb.dbo.sysjobsteps AS js
                ON js.job_id = j.job_id
            INNER JOIN msdb.dbo.sysjobhistory AS jh
                ON jh.job_id = j.job_id
                   AND jh.step_id = js.step_id
        WHERE jh.run_status = 0
              AND msdb.dbo.agent_datetime(jh.run_date, jh.run_time) >= DATEADD(HOUR, -1 * @Hours, GETDATE());
    END;

    -------------------------------------------------------------------------------
    -- Get SQL Server Agent jobs and Category information 
    -- (Query 9) (SQL Server Agent Jobs)
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'AgentJobs'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'AgentJobs'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'AgentJobs'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.AgentJobs') IS NULL
        BEGIN
            CREATE TABLE dbo.AgentJobs
            (
                CollectionTime DATETIME2(0) NOT NULL,
                JobName sysname NOT NULL,
                JobDescription NVARCHAR(512) NULL,
                JobOwner NVARCHAR(256) NOT NULL,
                DateCreated DATETIME NOT NULL,
                JobEnabled TINYINT NOT NULL,
                NotifyEmailOperatorID INT NOT NULL,
                NotifyLevelEmail INT NOT NULL,
                CategoryName sysname NOT NULL,
                ScheduleEnabled INT NULL,
                NextRunDate INT NULL,
                NextRunTime INT NULL
            ) ON [PRIMARY];
        END;

        INSERT INTO dbo.AgentJobs
        (
            CollectionTime,
            JobName,
            JobDescription,
            JobOwner,
            DateCreated,
            JobEnabled,
            NotifyEmailOperatorID,
            NotifyLevelEmail,
            CategoryName,
            ScheduleEnabled,
            NextRunDate,
            NextRunTime
        )
        SELECT GETDATE(),
               sj.name,
               sj.description,
               SUSER_SNAME(sj.owner_sid),
               sj.date_created,
               sj.enabled,
               sj.notify_email_operator_id,
               sj.notify_level_email,
               sc.name,
               s.enabled,
               js.next_run_date,
               js.next_run_time
        FROM msdb.dbo.sysjobs AS sj WITH (NOLOCK)
            INNER JOIN msdb.dbo.syscategories AS sc WITH (NOLOCK)
                ON sj.category_id = sc.category_id
            LEFT OUTER JOIN msdb.dbo.sysjobschedules AS js WITH (NOLOCK)
                ON sj.job_id = js.job_id
            LEFT OUTER JOIN msdb.dbo.sysschedules AS s WITH (NOLOCK)
                ON js.schedule_id = s.schedule_id
        OPTION (RECOMPILE);
    END;

    -------------------------------------------------------------------------------
    -- Agentlog information
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'AgentLog'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'AgentLog'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'AgentLog'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.AgentLog') IS NULL
        BEGIN
            CREATE TABLE dbo.AgentLog
            (
                CollectionTime DATETIME2(0) NOT NULL,
                LogDate DATETIME NOT NULL,
                ProcessInfo VARCHAR(64) NOT NULL,
                Text VARCHAR(MAX) NOT NULL
            ) ON [PRIMARY];
        END;

        IF OBJECT_ID('tempdb..#agentlog', 'U') IS NOT NULL
            DROP TABLE #agentlog;

        CREATE TABLE #agentLog
        (
            LogDate DATETIME NOT NULL,
            ProcessInfo VARCHAR(64) NOT NULL,
            Text VARCHAR(MAX) NOT NULL
        );

        SET @t = 0;
        WHILE (@t < 5)
        BEGIN
            INSERT INTO #agentLog
            (
                LogDate,
                ProcessInfo,
                Text
            )
            EXEC sys.sp_readerrorlog @p1 = @t, @p2 = 2;
            SET @t += 1;
        END;

        INSERT INTO dbo.AgentLog
        (
            CollectionTime,
            LogDate,
            ProcessInfo,
            Text
        )
        SELECT GETDATE(),
               a.LogDate,
               a.ProcessInfo,
               a.Text
        FROM #agentLog AS a
        WHERE EXISTS
        (
            SELECT *
            FROM #agentLog AS b
            WHERE a.LogDate = b.LogDate
                  AND a.ProcessInfo = b.ProcessInfo
        )
              AND a.LogDate >= DATEADD(HOUR, -1 * @Hours, GETDATE());
    END;

    -------------------------------------------------------------------------------
    -- Get instance-level configuration values for instance 
    -- (Query 4) (Configuration Values)
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'ConfigurationValues'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'ConfigurationValues'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'ConfigurationValues'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.ConfigurationValues') IS NULL
        BEGIN
            CREATE TABLE dbo.ConfigurationValues
            (
                CollectionTime DATETIME2(0) NOT NULL,
                Name NVARCHAR(35) NOT NULL,
                Value SQL_VARIANT NULL,
                ValueInUse SQL_VARIANT NULL,
                Minimum SQL_VARIANT NULL,
                Maximum SQL_VARIANT NULL,
                Description NVARCHAR(255) NULL,
                IsDynamic BIT NOT NULL,
                IsAdvanced BIT NOT NULL
            ) ON [PRIMARY];
        END;

        INSERT INTO dbo.ConfigurationValues
        (
            CollectionTime,
            Name,
            Value,
            ValueInUse,
            Minimum,
            Maximum,
            Description,
            IsDynamic,
            IsAdvanced
        )
        SELECT GETDATE(),
               name,
               value,
               value_in_use,
               minimum,
               maximum,
               description,
               is_dynamic,
               is_advanced
        FROM sys.configurations WITH (NOLOCK)
        OPTION (RECOMPILE);
    END;

    -------------------------------------------------------------------------------
    -- Get a count of SQL connections by IP address
    -- (Query 39) (Connection Counts by IP Address)
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'ConnectionCountsByIPAddress'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'ConnectionCountsByIPAddress'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'ConnectionCountsByIPAddress'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.ConnectionCountsByIPAddress') IS NULL
        BEGIN
            CREATE TABLE dbo.ConnectionCountsByIPAddress
            (
                CollectionTime DATETIME2(0) NOT NULL,
                ClientNetAddress NVARCHAR(48) NULL,
                ProgramName NVARCHAR(128) NULL,
                HostName NVARCHAR(128) NULL,
                LoginName NVARCHAR(128) NOT NULL,
                ConnectionCount INT NOT NULL
            ) ON [PRIMARY];
        END;

        INSERT INTO dbo.ConnectionCountsByIPAddress
        (
            CollectionTime,
            ClientNetAddress,
            ProgramName,
            HostName,
            LoginName,
            ConnectionCount
        )
        SELECT GETDATE(),
               ec.client_net_address,
               es.program_name,
               es.host_name,
               es.login_name,
               COUNT(ec.session_id)
        FROM sys.dm_exec_sessions AS es WITH (NOLOCK)
            INNER JOIN sys.dm_exec_connections AS ec WITH (NOLOCK)
                ON es.session_id = ec.session_id
        GROUP BY ec.client_net_address,
                 es.program_name,
                 es.host_name,
                 es.login_name
        OPTION (RECOMPILE);
    END;

    -------------------------------------------------------------------------------
    -- Get CPU utilization by database (Query 34) (CPU Usage by Database)
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'CPUUsageByDatabase'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'CPUUsageByDatabase'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'CPUUsageByDatabase'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.CPUUsageByDatabase') IS NULL
        BEGIN
            CREATE TABLE dbo.CPUUsageByDatabase
            (
                CollectionTime DATETIME2(0) NOT NULL,
                CPURank BIGINT NULL,
                DatabaseName sysname NOT NULL,
                CPUTimeMs BIGINT NOT NULL,
                CPUPercent DECIMAL(5, 2) NOT NULL
            ) ON [PRIMARY];
        END;

        WITH DB_CPU_Stats
        AS (SELECT pa.DatabaseID,
                   DB_NAME(pa.DatabaseID) AS "DatabaseName",
                   SUM(qs.total_worker_time / 1000) AS "CPUTimeMs"
            FROM sys.dm_exec_query_stats AS qs WITH (NOLOCK)
                CROSS APPLY
            (
                SELECT CONVERT(INT, value) AS "DatabaseID"
                FROM sys.dm_exec_plan_attributes(qs.plan_handle)
                WHERE attribute = N'dbid'
            ) AS pa
            GROUP BY pa.DatabaseID)
        INSERT INTO dbo.CPUUsageByDatabase
        (
            CollectionTime,
            CPURank,
            DatabaseName,
            CPUTimeMs,
            CPUPercent
        )
        SELECT GETDATE(),
               ROW_NUMBER() OVER (ORDER BY DB_CPU_Stats.CPUTimeMs DESC),
               DB_CPU_Stats.DatabaseName,
               DB_CPU_Stats.CPUTimeMs,
               CAST(DB_CPU_Stats.CPUTimeMs * 1.0 / SUM(DB_CPU_Stats.CPUTimeMs) OVER () * 100.0 AS DECIMAL(5, 2))
        FROM DB_CPU_Stats
        WHERE DB_CPU_Stats.DatabaseID <> 32767 -- ResourceDB
        OPTION (RECOMPILE);
    END;

    -------------------------------------------------------------------------------
    -- File names and paths for all user and system databases on instance 
    -- (Query 24) (Database Filenames and Paths)
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'DatabaseFilenamesAndPaths'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'DatabaseFilenamesAndPaths'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'DatabaseFilenamesAndPaths'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.DatabaseFilenamesAndPaths') IS NULL
        BEGIN
            CREATE TABLE dbo.DatabaseFilenamesAndPaths
            (
                CollectionTime DATETIME2(0) NOT NULL,
                DatabaseName NVARCHAR(128) NOT NULL,
                FileID INT NOT NULL,
                Name sysname NOT NULL,
                PhysicalName NVARCHAR(260) NOT NULL,
                Type NVARCHAR(60) NOT NULL,
                State NVARCHAR(60) NOT NULL,
                IsPercentGrowth BIT NOT NULL,
                Growth INT NOT NULL,
                GrowthMB BIGINT NOT NULL,
                TotalSizeMB BIGINT NOT NULL,
                MaxSize BIGINT NOT NULL
            ) ON [PRIMARY];
        END;

        INSERT INTO dbo.DatabaseFilenamesAndPaths
        (
            CollectionTime,
            DatabaseName,
            FileID,
            Name,
            PhysicalName,
            Type,
            State,
            IsPercentGrowth,
            Growth,
            GrowthMB,
            TotalSizeMB,
            MaxSize
        )
        SELECT GETDATE(),
               DB_NAME(database_id),
               file_id,
               name,
               physical_name,
               type_desc,
               state_desc,
               is_percent_growth,
               growth,
               CONVERT(BIGINT, growth / 128.0),
               CONVERT(BIGINT, size / 128.0),
               CONVERT(BIGINT, max_size / 128.0)
        FROM sys.master_files WITH (NOLOCK)
        OPTION (RECOMPILE);        
    END;

    -------------------------------------------------------------------------------
    -- Database information
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'DatabaseInfo'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'DatabaseInfo'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'DatabaseInfo'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.DatabaseInfo') IS NULL
        BEGIN
            CREATE TABLE dbo.DatabaseInfo
            (
                CollectionTime DATETIME2(0) NOT NULL,
                DBName sysname NOT NULL,
                TableCount INT NOT NULL,
                TableColumnsCount INT NOT NULL,
                ViewCount INT NOT NULL,
                ProcedureCount INT NOT NULL,
                TriggerCount INT NOT NULL,
                FullTextCatalog INT NOT NULL,
                XmlIndexes INT NOT NULL,
                SpatialIndexes INT NOT NULL,
                DataTotalSizeMb BIGINT NOT NULL,
                DataSpaceUtilMb BIGINT NOT NULL,
                LogTotalSizeMb BIGINT NOT NULL,
                LogSpaceUtilMb BIGINT NOT NULL
            );
        END;

        IF OBJECT_ID('tempdb..#DatabaseInfo', 'U') IS NOT NULL
            DROP TABLE #DatabaseInfo;

        CREATE TABLE #DatabaseInfo
        (
            DBName sysname NOT NULL,
            TableCount INT NOT NULL,
            TableColumnsCount INT NOT NULL,
            ViewCount INT NOT NULL,
            ProcedureCount INT NOT NULL,
            TriggerCount INT NOT NULL,
            FullTextCatalog INT NOT NULL,
            XmlIndexes INT NOT NULL,
            SpatialIndexes INT NOT NULL,
            DataTotalSizeMB BIGINT NOT NULL,
            DataSpaceUtilMB BIGINT NOT NULL,
            LogTotalSizeMB BIGINT NOT NULL,
            LogSpaceUtilMB BIGINT NOT NULL
        );

        SELECT @tsql
            = COALESCE(@tsql, N'') + @crlf + N'USE ' + QUOTENAME(name) + N';' + @crlf + N'INSERT INTO #DatabaseInfo'
              + @crlf + N'SELECT' + @crlf + N'       N' + QUOTENAME(name, '''') + N' AS DBName' + @crlf
              + N'     , (SELECT COUNT(*) AS TableCount      FROM ' + QUOTENAME(name) + N'.sys.tables)' + @crlf
              + N'     , (SELECT ISNULL(SUM(max_column_id_used), 0) AS TableColumnsCount FROM ' + QUOTENAME(name)
              + N'.sys.tables)' + @crlf + N'     , (SELECT COUNT(*) AS ViewCount       FROM ' + QUOTENAME(name)
              + N'.sys.views)' + @crlf + N'     , (SELECT COUNT(*) AS ProcedureCount  FROM ' + QUOTENAME(name)
              + N'.sys.procedures)' + @crlf + N'     , (SELECT COUNT(*) AS TriggerCount    FROM ' + QUOTENAME(name)
              + N'.sys.triggers)' + @crlf + N'     , (SELECT COUNT(*) AS FullTextCatalog FROM ' + QUOTENAME(name)
              + N'.sys.fulltext_catalogs)' + @crlf + N'     , (SELECT COUNT(*) AS XmlIndexes      FROM '
              + QUOTENAME(name) + N'.sys.xml_indexes)' + @crlf + N'     , (SELECT COUNT(*) AS SpatialIndexes  FROM '
              + QUOTENAME(name) + N'.sys.spatial_indexes)' + @crlf
              + N'     , (SELECT SUM(CAST(size AS BIGINT) * 8 / 1024) AS DataTotalSizeMB FROM ' + QUOTENAME(name)
              + N'.sys.master_files WHERE database_id = DB_ID(DB_NAME()) AND type = 0)' + @crlf
              + N'     , (SELECT SUM(CAST(FILEPROPERTY(name, ''SpaceUsed'') AS BIGINT) * 8 / 1024) AS DataSpaceUtilMB FROM '
              + QUOTENAME(name) + N'.sys.master_files WHERE database_id = DB_ID(DB_NAME()) AND type = 0)' + @crlf
              + N'     , (SELECT SUM(size * 8 / 1024) AS LogTotalSizeMB  FROM ' + QUOTENAME(name)
              + N'.sys.master_files WHERE database_id = DB_ID(DB_NAME()) AND type = 1)' + @crlf
              + N'     , (SELECT SUM(FILEPROPERTY(name, ''SpaceUsed'') * 8 / 1024) AS LogSpaceUtilMB FROM '
              + QUOTENAME(name) + N'.sys.master_files WHERE database_id = DB_ID(DB_NAME()) AND type = 1);' + @crlf
        FROM sys.databases
        ORDER BY name;

        EXEC sys.sp_executesql @command = @tsql;

        INSERT INTO dbo.DatabaseInfo
        (
            CollectionTime,
            DBName,
            TableCount,
            TableColumnsCount,
            ViewCount,
            ProcedureCount,
            TriggerCount,
            FullTextCatalog,
            XmlIndexes,
            SpatialIndexes,
            DataTotalSizeMb,
            DataSpaceUtilMb,
            LogTotalSizeMb,
            LogSpaceUtilMb
        )
        SELECT GETDATE(),
               DBName,
               TableCount,
               TableColumnsCount,
               ViewCount,
               ProcedureCount,
               TriggerCount,
               FullTextCatalog,
               XmlIndexes,
               SpatialIndexes,
               DataTotalSizeMB,
               DataSpaceUtilMB,
               LogTotalSizeMB,
               LogSpaceUtilMB
        FROM #DatabaseInfo;
    END;

    -------------------------------------------------------------------------------
    -- Database principals
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'DatabasePrincipals'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'DatabasePrincipals'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'DatabasePrincipals'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.DatabasePrincipals') IS NULL
        BEGIN
            CREATE TABLE dbo.DatabasePrincipals
            (
                CollectionTime DATETIME2(0) NOT NULL,
                DatabaseName sysname NOT NULL,
                Name sysname NOT NULL,
                PrincipalID INT NOT NULL,
                Type NVARCHAR(60) NOT NULL,
                DefaultSchemaName sysname NULL,
                CreateDate DATETIME NOT NULL,
                ModifyDate DATETIME NOT NULL,
                OwningPrincipalID INT NULL,
                SID VARBINARY(85) NULL,
                IsFixedRole BIT NOT NULL,
                AuthenticationType NVARCHAR(60) NOT NULL
            ) ON [PRIMARY];
        END;

        IF OBJECT_ID('tempdb..#DatabasePrincipals', 'U') IS NOT NULL
            DROP TABLE #DatabasePrincipals;

        CREATE TABLE #DatabasePrincipals
        (
            DatabaseName sysname NOT NULL,
            Name sysname NOT NULL,
            PrincipalID INT NOT NULL,
            Type NVARCHAR(60) NOT NULL,
            DefaultSchemaName sysname NULL,
            CreateDate DATETIME NOT NULL,
            ModifyDate DATETIME NOT NULL,
            OwningPrincipalID INT NULL,
            SID VARBINARY(85) NULL,
            IsFixedRole BIT NOT NULL,
            AuthenticationType NVARCHAR(60) NOT NULL
        );

        EXEC sys.sp_MSforeachdb @command1 = 'USE ?;
	        INSERT INTO #DatabasePrincipals
	        SELECT DB_NAME() AS DatabaseName,
		           name AS [Name],
		           principal_id AS PrincipalID,
		           type_desc AS [Type],
		           default_schema_name as DefaultSchemaName,
		           create_date AS CreateDate,
		           modify_date AS ModifyDate,
		           owning_principal_id AS OwningPrincipalID,
		           sid AS [SID],
		           is_fixed_role AS IsFixedRole,
		           authentication_type_desc AS AuthenticationType
	        FROM [?].sys.database_principals';

        INSERT INTO dbo.DatabasePrincipals
        (
            CollectionTime,
            DatabaseName,
            Name,
            PrincipalID,
            Type,
            DefaultSchemaName,
            CreateDate,
            ModifyDate,
            OwningPrincipalID,
            SID,
            IsFixedRole,
            AuthenticationType
        )
        SELECT GETDATE(),
               DatabaseName,
               Name,
               PrincipalID,
               Type,
               DefaultSchemaName,
               CreateDate,
               ModifyDate,
               OwningPrincipalID,
               SID,
               IsFixedRole,
               AuthenticationType
        FROM #DatabasePrincipals;
    END;

    -------------------------------------------------------------------------------
    -- Recovery model, log reuse wait description, log file size, log usage size 
    -- (Query 31) (Database Properties)
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'DatabaseProperties'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'DatabaseProperties'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'DatabaseProperties'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.DatabaseProperties') IS NULL
        BEGIN
            CREATE TABLE dbo.DatabaseProperties
            (
                CollectionTime DATETIME2(0) NOT NULL,
                DatabaseName sysname NOT NULL,
                DatabaseOwner NVARCHAR(128) NULL,
                RecoveryModel NVARCHAR(60) NULL,
                State NVARCHAR(60) NULL,
                Containment NVARCHAR(60) NULL,
                LogReuseWaitDescription NVARCHAR(60) NULL,
                LogSizeMB DECIMAL(18, 2) NOT NULL,
                LogUsedMB DECIMAL(18, 2) NOT NULL,
                LogUsedPercentage DECIMAL(18, 2) NOT NULL,
                DBCompatibilityLevel TINYINT NOT NULL,
                IsMixedPageAllocationOn BIT NULL,
                PageVerifyOption NVARCHAR(60) NULL,
                IsAutoCreateStatsOn BIT NULL,
                IsAutoUpdateStatsOn BIT NULL,
                IsAutoUpdateStatsAsyncOn BIT NULL,
                IsParameterizationForced BIT NULL,
                SnapshotIsolationStateDesc NVARCHAR(60) NULL,
                IsReadCommittedSnapshotOn BIT NULL,
                IsAutoCloseOn BIT NULL,
                IsAutoShrinkOn BIT NULL,
                TargetRecoveryTimeInSeconds INT NULL,
                IsCDCEnabled BIT NULL,
                IsPublished BIT NULL,
                IsDistributor BIT NULL,
                GroupDatabaseID UNIQUEIDENTIFIER NULL,
                ReplicaID UNIQUEIDENTIFIER NULL,
                IsSyncWithBackup BIT NULL,
                IsSupplementalLoggingEnabled BIT NULL,
                IsEncrypted BIT NULL,
                EncryptionState INT NULL,
                PercentComplete REAL NULL,
                KeyAlgorithm NVARCHAR(128) NULL,
                KeyLength INT NULL
            ) ON [PRIMARY];
        END;

        INSERT INTO dbo.DatabaseProperties
        (
            CollectionTime,
            DatabaseName,
            DatabaseOwner,
            RecoveryModel,
            State,
            Containment,
            LogReuseWaitDescription,
            LogSizeMB,
            LogUsedMB,
            LogUsedPercentage,
            DBCompatibilityLevel,
            PageVerifyOption,
            IsAutoCreateStatsOn,
            IsAutoUpdateStatsOn,
            IsAutoUpdateStatsAsyncOn,
            IsParameterizationForced,
            SnapshotIsolationStateDesc,
            IsReadCommittedSnapshotOn,
            IsAutoCloseOn,
            IsAutoShrinkOn,
            TargetRecoveryTimeInSeconds,
            IsCDCEnabled,
            IsPublished,
            IsDistributor,
            GroupDatabaseID,
            ReplicaID,
            IsSyncWithBackup,
            IsSupplementalLoggingEnabled,
            IsEncrypted,
            EncryptionState,
            PercentComplete,
            KeyAlgorithm,
            KeyLength
        )
        SELECT GETDATE(),
               db.name,
               SUSER_SNAME(db.owner_sid),
               db.recovery_model_desc,
               db.state_desc,
               db.containment_desc,
               db.log_reuse_wait_desc,
               CONVERT(DECIMAL(18, 2), ls.cntr_value / 1024.0),
               CONVERT(DECIMAL(18, 2), lu.cntr_value / 1024.0),
               CAST(CAST(lu.cntr_value AS FLOAT) / CAST(ls.cntr_value AS FLOAT) AS DECIMAL(18, 2)) * 100,
               db.compatibility_level,
               db.page_verify_option_desc,
               db.is_auto_create_stats_on,
               db.is_auto_update_stats_on,
               db.is_auto_update_stats_async_on,
               db.is_parameterization_forced,
               db.snapshot_isolation_state_desc,
               db.is_read_committed_snapshot_on,
               db.is_auto_close_on,
               db.is_auto_shrink_on,
               db.target_recovery_time_in_seconds,
               db.is_cdc_enabled,
               db.is_published,
               db.is_distributor,
               db.group_database_id,
               db.replica_id,
               db.is_sync_with_backup,
               db.is_supplemental_logging_enabled,
               db.is_encrypted,
               de.encryption_state,
               de.percent_complete,
               de.key_algorithm,
               de.key_length
        FROM sys.databases AS db WITH (NOLOCK)
            INNER JOIN sys.dm_os_performance_counters AS lu WITH (NOLOCK)
                ON db.name = lu.instance_name
            INNER JOIN sys.dm_os_performance_counters AS ls WITH (NOLOCK)
                ON db.name = ls.instance_name
            LEFT OUTER JOIN sys.dm_database_encryption_keys AS de WITH (NOLOCK)
                ON db.database_id = de.database_id
        WHERE lu.counter_name LIKE N'Log File(s) Used Size (KB)%'
              AND ls.counter_name LIKE N'Log File(s) Size (KB)%'
              AND ls.cntr_value > 0
        OPTION (RECOMPILE);
    END;

    -------------------------------------------------------------------------------
    -- Database roles and members (including server login)
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'DatabaseRolesAndMembers'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'DatabaseRolesAndMembers'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'DatabaseRolesAndMembers'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.DatabaseRolesAndMembers') IS NULL
        BEGIN
            CREATE TABLE dbo.DatabaseRolesAndMembers
            (
                CollectionTime DATETIME2(0) NOT NULL,
                DatabaseName sysname NOT NULL,
                RoleName sysname NOT NULL,
                MemberName sysname NOT NULL,
                MemberType NVARCHAR(60) NULL,
                DefaultSchema sysname NULL,
                ServerLogin sysname NOT NULL
            ) ON [PRIMARY];
        END;

        IF OBJECT_ID('tempdb..#DatabaseRolesAndMembers', 'U') IS NOT NULL
            DROP TABLE #DatabaseRolesAndMembers;

        CREATE TABLE #DatabaseRolesAndMembers
        (
            CollectionTime DATETIME2(0) NOT NULL,
            DatabaseName sysname NOT NULL,
            RoleName sysname NOT NULL,
            MemberName sysname NOT NULL,
            MemberType NVARCHAR(60) NULL,
            DefaultSchema sysname NULL,
            ServerLogin sysname NOT NULL
        );

        EXEC sys.sp_MSforeachdb @command1 = 'USE ?;
	        INSERT INTO #DatabaseRolesAndMembers
	        SELECT GETDATE() as CollectionTime,
		           DB_NAME() AS DatabaseName,
		           ROL.name AS RoleName,
		           MEM.name AS MemberName,
		           MEM.type_desc AS MemberType,
		           MEM.default_schema_name AS DefaultSchema,
		           SP.name AS ServerLogin
	        FROM [?].sys.database_role_members AS DRM
	        INNER JOIN [?].sys.database_principals AS ROL ON DRM.role_principal_id = ROL.principal_id
	        INNER JOIN [?].sys.database_principals AS MEM ON DRM.member_principal_id = MEM.principal_id
	        INNER JOIN [?].sys.server_principals AS SP ON MEM.sid = SP.sid
	        ORDER BY RoleName,
			         MemberName;';

        INSERT INTO dbo.DatabaseRolesAndMembers
        (
            CollectionTime,
            DatabaseName,
            RoleName,
            MemberName,
            MemberType,
            DefaultSchema,
            ServerLogin
        )
        SELECT CollectionTime,
               DatabaseName,
               RoleName,
               MemberName,
               MemberType,
               DefaultSchema,
               ServerLogin
        FROM #DatabaseRolesAndMembers;
    END;

    -------------------------------------------------------------------------------
    -- List all database triggers
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'DatabaseTriggers'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'DatabaseTriggers'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'DatabaseTriggers'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.DatabaseTriggers') IS NULL
        BEGIN
            CREATE TABLE dbo.DatabaseTriggers
            (
                CollectionTime DATETIME2(0) NOT NULL,
                TriggerName sysname NOT NULL,
                [Database] sysname NULL,
                [Table] sysname NULL,
                Activation NVARCHAR(10) NOT NULL,
                Event NVARCHAR(30) NULL,
                Class NVARCHAR(30) NOT NULL,
                Type NVARCHAR(30) NOT NULL,
                Status NVARCHAR(10) NOT NULL,
                Definition NVARCHAR(MAX) NULL
            ) ON [PRIMARY];
        END;

        IF OBJECT_ID('tempdb..#DatabaseTriggers', 'U') IS NOT NULL
            DROP TABLE #DatabaseTriggers;

        CREATE TABLE #DatabaseTriggers
        (
            CollectionTime DATETIME2(0) NOT NULL,
            TriggerName sysname NOT NULL,
            [Database] sysname NULL,
            [Table] sysname NULL,
            Activation NVARCHAR(10) NOT NULL,
            Event NVARCHAR(30) NULL,
            Class NVARCHAR(30) NOT NULL,
            Type NVARCHAR(30) NOT NULL,
            Status NVARCHAR(10) NOT NULL,
            Definition NVARCHAR(MAX) NULL
        );

        EXEC sys.sp_MSforeachdb @command1 = 'USE ?; 
								INSERT INTO #DatabaseTriggers
								SELECT GETDATE() AS CollectionTime,
								trg.name AS trigger_name,
								DB_NAME() as [Database],
								SCHEMA_NAME(tab.schema_id) + ''.'' + tab.name AS [Table],
								CASE
								   WHEN is_instead_of_trigger = 1 THEN
									   ''Instead of''
								   ELSE
									   ''After''
								END AS [Activation],
								(CASE
									WHEN OBJECTPROPERTY(trg.object_id, ''ExecIsUpdateTrigger'') = 1 THEN
										''Update ''
									ELSE
										''''
								END + CASE
										  WHEN OBJECTPROPERTY(trg.object_id, ''ExecIsDeleteTrigger'') = 1 THEN
											  ''Delete ''
										  ELSE
											  ''''
									  END + CASE
												WHEN OBJECTPROPERTY(trg.object_id, ''ExecIsInsertTrigger'') = 1 THEN
													''Insert''
												ELSE
													''''
											END
								) AS [Event],
								CASE
								   WHEN trg.parent_class = 1 THEN
									   ''Table trigger''
								   WHEN trg.parent_class = 0 THEN
									   ''Database trigger''
								END [class],
								CASE
								   WHEN trg.[type] = ''TA'' THEN
									   ''Assembly (CLR) trigger''
								   WHEN trg.[type] = ''TR'' THEN
									   ''SQL trigger''
								   ELSE
									   ''''
								END AS [type],
								CASE
								   WHEN is_disabled = 1 THEN
									   ''[Disabled]''
								   ELSE
									   ''[Active]''
								END AS [Status],
								OBJECT_DEFINITION(trg.object_id) AS [Definition]
						FROM [?].sys.triggers trg
						LEFT JOIN [?].sys.objects tab ON trg.parent_id = tab.object_id
						ORDER BY trg.name;';

        INSERT INTO dbo.DatabaseTriggers
        (
            CollectionTime,
            TriggerName,
            [Database],
            [Table],
            Activation,
            Event,
            Class,
            Type,
            Status,
            Definition
        )
        SELECT CollectionTime,
               TriggerName,
               [Database],
               [Table],
               Activation,
               Event,
               Class,
               Type,
               Status,
               Definition
        FROM #DatabaseTriggers;
    END;

    -------------------------------------------------------------------------------
    -- Drive level latency information (Query 27) (Drive Level Latency)
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'DriveLevelLatency'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'DriveLevelLatency'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'DriveLevelLatency'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.DriveLevelLatency') IS NULL
        BEGIN
            CREATE TABLE dbo.DriveLevelLatency
            (
                CollectionTime DATETIME2(0) NOT NULL,
                Drive NVARCHAR(260) NULL,
                VolumeMountPoint NVARCHAR(260) NULL,
                ReadLatency BIGINT NOT NULL,
                WriteLatency BIGINT NOT NULL,
                OverallLatency BIGINT NOT NULL,
                AvgBytesPerRead BIGINT NOT NULL,
                AvgBytesPerWrite BIGINT NOT NULL,
                AvgBytesPerTransfer BIGINT NOT NULL
            ) ON [PRIMARY];
        END;

        INSERT INTO dbo.DriveLevelLatency
        (
            CollectionTime,
            Drive,
            VolumeMountPoint,
            ReadLatency,
            WriteLatency,
            OverallLatency,
            AvgBytesPerRead,
            AvgBytesPerWrite,
            AvgBytesPerTransfer
        )
        SELECT GETDATE(),
               tab.Drive,
               tab.volume_mount_point,
               CASE
                   WHEN tab.num_of_reads = 0 THEN
                       0
                   ELSE
               (tab.io_stall_read_ms / tab.num_of_reads)
               END,
               CASE
                   WHEN tab.num_of_writes = 0 THEN
                       0
                   ELSE
               (tab.io_stall_write_ms / tab.num_of_writes)
               END,
               CASE
                   WHEN
                   (
                       tab.num_of_reads = 0
                       AND tab.num_of_writes = 0
                   ) THEN
                       0
                   ELSE
               (tab.io_stall / (tab.num_of_reads + tab.num_of_writes))
               END,
               CASE
                   WHEN tab.num_of_reads = 0 THEN
                       0
                   ELSE
               (tab.num_of_bytes_read / tab.num_of_reads)
               END,
               CASE
                   WHEN tab.num_of_writes = 0 THEN
                       0
                   ELSE
               (tab.num_of_bytes_written / tab.num_of_writes)
               END,
               CASE
                   WHEN
                   (
                       tab.num_of_reads = 0
                       AND tab.num_of_writes = 0
                   ) THEN
                       0
                   ELSE
               ((tab.num_of_bytes_read + tab.num_of_bytes_written) / (tab.num_of_reads + tab.num_of_writes))
               END
        FROM
        (
            SELECT LEFT(UPPER(mf.physical_name), 2) AS "Drive",
                   SUM(vfs.num_of_reads) AS "num_of_reads",
                   SUM(vfs.io_stall_read_ms) AS "io_stall_read_ms",
                   SUM(vfs.num_of_writes) AS "num_of_writes",
                   SUM(vfs.io_stall_write_ms) AS "io_stall_write_ms",
                   SUM(vfs.num_of_bytes_read) AS "num_of_bytes_read",
                   SUM(vfs.num_of_bytes_written) AS "num_of_bytes_written",
                   SUM(vfs.io_stall) AS "io_stall",
                   vs.volume_mount_point
            FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
                INNER JOIN sys.master_files AS mf WITH (NOLOCK)
                    ON vfs.database_id = mf.database_id
                       AND vfs.file_id = mf.file_id
                CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.file_id) AS vs
            GROUP BY LEFT(UPPER(mf.physical_name), 2),
                     vs.volume_mount_point
        ) AS tab
        OPTION (RECOMPILE);
    END;

    -------------------------------------------------------------------------------
    -- Errorlog information
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'ErrorLog'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'ErrorLog'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'ErrorLog'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.ErrorLog') IS NULL
        BEGIN
            CREATE TABLE dbo.ErrorLog
            (
                CollectionTime DATETIME2(0) NOT NULL,
                LogDate DATETIME NOT NULL,
                ProcessInfo VARCHAR(64) NOT NULL,
                Text VARCHAR(MAX) NOT NULL
            ) ON [PRIMARY];
        END;

        IF OBJECT_ID('tempdb..#errorLog', 'U') IS NOT NULL
            DROP TABLE #errorLog;

        CREATE TABLE #errorLog
        (
            LogDate DATETIME NULL,
            ProcessInfo VARCHAR(64) NULL,
            Text VARCHAR(MAX) NULL
        );

        SET @t = 0;
        WHILE (@t < 5)
        BEGIN
            INSERT INTO #errorLog
            (
                LogDate,
                ProcessInfo,
                Text
            )
            EXEC sys.sp_readerrorlog @p1 = @t;
            SET @t += 1;
        END;

        INSERT INTO dbo.ErrorLog
        (
            CollectionTime,
            LogDate,
            ProcessInfo,
            Text
        )
        SELECT GETDATE(),
               a.LogDate,
               a.ProcessInfo,
               a.Text
        FROM #errorLog AS a
        WHERE EXISTS
        (
            SELECT *
            FROM #errorLog AS b
            WHERE (
                      b.Text LIKE 'Login succeeded%'
                      AND b.Text LIKE 'Log was backed up%'
                  )
                  AND a.LogDate = b.LogDate
                  AND a.ProcessInfo = b.ProcessInfo
        )
              AND a.LogDate >= DATEADD(HOUR, -1 * @Hours, GETDATE());
    END;

    -------------------------------------------------------------------------------
    -- Returns global trace flags that are enabled (Query 5) (Global Trace Flags)
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'GlobalTraceFlags'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'GlobalTraceFlags'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'GlobalTraceFlags'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.GlobalTraceFlags') IS NULL
        BEGIN
            CREATE TABLE dbo.GlobalTraceFlags
            (
                CollectionTime DATETIME2(0) NOT NULL,
                TraceFlag NVARCHAR(35) NOT NULL,
                Status BIT NOT NULL,
                Global BIT NOT NULL,
                Session BIT NOT NULL
            ) ON [PRIMARY];
        END;

        IF OBJECT_ID('tempdb..#tracestatus', 'U') IS NOT NULL
            DROP TABLE #tracestatus;

        CREATE TABLE #tracestatus
        (
            TraceFlag INT NOT NULL,
            Status INT NULL,
            Global BIT NULL,
            Session BIT NULL
        );

        INSERT INTO #tracestatus
        (
            TraceFlag,
            Status,
            Global,
            Session
        )
        EXEC ('DBCC TRACESTATUS (-1) WITH NO_INFOMSGS');

        INSERT INTO dbo.GlobalTraceFlags
        (
            CollectionTime,
            TraceFlag,
            Status,
            Global,
            Session
        )
        SELECT GETDATE(),
               TraceFlag,
               Status,
               Global,
               Session
        FROM #tracestatus;

        DROP TABLE #tracestatus;
    END;

    -------------------------------------------------------------------------------
    -- Hardware information from SQL Server 2019  (Query 17) (Hardware Info)
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'HardwareInfo'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'HardwareInfo'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'HardwareInfo'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.HardwareInfo') IS NULL
        BEGIN
            CREATE TABLE dbo.HardwareInfo
            (
                CollectionTime DATETIME2(0) NOT NULL,
                LogicalCPUCount INT NOT NULL,
                SchedulerCount INT NOT NULL,
                PhysicalMemoryMB BIGINT NOT NULL,
                MaxWorkersCount INT NOT NULL,
                SQLServerStartTime DATETIME NOT NULL,
                SQLServerUpTimeHours INT NOT NULL,
                VirtualMachineType NVARCHAR(60) NOT NULL--,
                --SQLMemoryModel NVARCHAR(60) NOT NULL
            ) ON [PRIMARY];
        END;

        INSERT INTO dbo.HardwareInfo
        (
            CollectionTime,
            LogicalCPUCount,
            SchedulerCount,
            PhysicalMemoryMB,
            MaxWorkersCount,
            SQLServerStartTime,
            SQLServerUpTimeHours,
            VirtualMachineType--,
            --SQLMemoryModel
        )
        SELECT GETDATE(),
               cpu_count,
               scheduler_count,
               physical_memory_kb / 1024,
               max_workers_count,
               sqlserver_start_time,
               DATEDIFF(HOUR, sqlserver_start_time, GETDATE()),
               virtual_machine_type_desc--,
               --sql_memory_model_desc
        FROM sys.dm_os_sys_info WITH (NOLOCK)
        OPTION (RECOMPILE);
    END;

    -------------------------------------------------------------------------------
    -- Identity Columns - Monitoring identity columns for room to grow
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'IdentityColumns'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'IdentityColumns'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'IdentityColumns'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.IdentityColumns') IS NULL
        BEGIN
            CREATE TABLE dbo.IdentityColumns
            (
                CollectionTime DATETIME2(0) NOT NULL,
                [Database] sysname NOT NULL,
                [Table] sysname NOT NULL,
                [Column] sysname NULL,
                Type sysname NOT NULL,
                [Identity] NUMERIC(18, 0) NULL,
                PercentFull NUMERIC(18, 2) NULL
            ) ON [PRIMARY];
        END;

        IF OBJECT_ID('tempdb..#IdentityColumns', 'U') IS NOT NULL
            DROP TABLE #IdentityColumns;

        CREATE TABLE #IdentityColumns
        (
            [Database] sysname NOT NULL,
            [Table] sysname NOT NULL,
            [Column] sysname NULL,
            Type sysname NOT NULL,
            [Identity] NUMERIC(18, 0) NULL,
            PercentFull NUMERIC(18, 2) NULL
        );

        EXEC sys.sp_MSforeachdb @command1 = 'USE ?; 
		    INSERT INTO #IdentityColumns
		    SELECT DB_NAME() AS [Database],	
			       t.name AS [Table],
			       c.name AS [Column],
			       ty.name AS [Type],
			       IDENT_CURRENT(t.name) AS [Identity],
			       100 * IDENT_CURRENT(t.name) / 2147483647 AS [PercentFull]
		    FROM [?].sys.tables t
		    JOIN [?].sys.columns c ON c.object_id = t.object_id
		    JOIN [?].sys.types ty ON ty.system_type_id = c.system_type_id
		    WHERE c.is_identity = 1
				    AND ty.name = ''int''
				    AND 100 * IDENT_CURRENT(t.name) / 2147483647 > 80 /* Change threshold here */
		    ORDER BY t.name;';

        INSERT INTO dbo.IdentityColumns
        (
            CollectionTime,
            [Database],
            [Table],
            [Column],
            Type,
            [Identity],
            PercentFull
        )
        SELECT GETDATE(),
               [Database],
               [Table],
               [Column],
               Type,
               [Identity],
               PercentFull
        FROM #IdentityColumns;
    END;

    -------------------------------------------------------------------------------
    -- Collect index usage statistics
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'IndexUsageStats'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'IndexUsageStats'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'IndexUsageStats'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.IndexUsageStats') IS NULL
        BEGIN
            CREATE TABLE dbo.IndexUsageStats
            (
                CollectionTime DATETIME2(0) NOT NULL,
                ServerName sysname NOT NULL,
                DatabaseName sysname NOT NULL,
                SchemaName sysname NOT NULL,
                TableName sysname NOT NULL,
                IndexName sysname NULL,
                UserSeeks BIGINT NOT NULL,
                UserScans BIGINT NOT NULL,
                UserLookups BIGINT NOT NULL,
                UserUpdates BIGINT NOT NULL,
                SystemSeeks BIGINT NOT NULL,
                SystemScans BIGINT NOT NULL,
                SystemLookups BIGINT NOT NULL,
                SystemUpdates BIGINT NOT NULL
            ) ON [PRIMARY];
        END;

        -- Get current stats for all online databases
        IF OBJECT_ID('tempdb..#dbList', 'U') IS NOT NULL
            DROP TABLE #dbList;

        SELECT database_id,
               name
        INTO #dbList
        FROM sys.databases
        WHERE state = 0
              AND database_id <> 2; -- Skips tempdb

        IF OBJECT_ID('tempdb..#IndexUsageStats', 'U') IS NOT NULL
            DROP TABLE #IndexUsageStats;

        CREATE TABLE #IndexUsageStats
        (
            ServerName sysname NOT NULL,
            DatabaseName sysname NOT NULL,
            SchemaName sysname NOT NULL,
            TableName sysname NOT NULL,
            IndexName sysname NULL,
            UserSeeks BIGINT NOT NULL,
            UserScans BIGINT NOT NULL,
            UserLookups BIGINT NOT NULL,
            UserUpdates BIGINT NOT NULL,
            SystemSeeks BIGINT NOT NULL,
            SystemScans BIGINT NOT NULL,
            SystemLookups BIGINT NOT NULL,
            SystemUpdates BIGINT NOT NULL
        );

        DECLARE @_dbID INT;
        DECLARE @_dbName sysname;

        WHILE (EXISTS (SELECT database_id FROM #dbList))
        BEGIN
            SELECT TOP (1)
                   @_dbID = database_id,
                   @_dbName = name
            FROM #dbList
            ORDER BY database_id;

            SET @tsql = N'INSERT INTO #IndexUsageStats
				SELECT
					@@SERVERNAME AS ServerName,
					''' + @_dbName + N''' AS DatabaseName,
					c.name AS SchemaName,
					o.name AS TableName,
					i.name AS IndexName,
					s.user_seeks AS UserSeeks,
					s.user_scans AS UserScans,
					s.user_lookups AS UserLookups,
					s.user_updates AS UserUpdates,
					s.system_seeks AS SystemSeeks,
					s.system_scans AS SystemScans,
					s.system_lookups AS SystemLookups,
					s.system_updates AS SystemUpdates
				FROM sys.dm_db_index_usage_stats s
				INNER JOIN ' + @_dbName + N'.sys.objects o ON s.object_id = o.object_id
				INNER JOIN ' + @_dbName + N'.sys.schemas c ON o.schema_id = c.schema_id
				INNER JOIN ' + @_dbName
                  + N'.sys.indexes i ON s.object_id = i.object_id and s.index_id = i.index_id
				WHERE s.database_id = ' + CONVERT(NVARCHAR(5), @_dbID) + N';';

            EXEC sys.sp_executesql @command = @tsql;

            DELETE FROM #dbList
            WHERE database_id = @_dbID;
        END;

        INSERT INTO dbo.IndexUsageStats
        (
            CollectionTime,
            ServerName,
            DatabaseName,
            SchemaName,
            TableName,
            IndexName,
            UserSeeks,
            UserScans,
            UserLookups,
            UserUpdates,
            SystemSeeks,
            SystemScans,
            SystemLookups,
            SystemUpdates
        )
        SELECT GETDATE(),
               t.ServerName,
               t.DatabaseName,
               t.SchemaName,
               t.TableName,
               t.IndexName,
               t.UserSeeks,
               t.UserScans,
               t.UserLookups,
               t.UserUpdates,
               t.SystemSeeks,
               t.SystemScans,
               t.SystemLookups,
               t.SystemUpdates
        FROM #IndexUsageStats AS t;
    END;

    -------------------------------------------------------------------------------
    -- Calculates average latency per read, per write, and per total input/output 
    -- for each database file  (Query 28) (IO Latency by File)
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'IOLatencyByFile'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'IOLatencyByFile'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'IOLatencyByFile'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.IOLatencyByFile') IS NULL
        BEGIN
            CREATE TABLE dbo.IOLatencyByFile
            (
                CollectionTime DATETIME2(0) NOT NULL,
                DatabaseName NVARCHAR(260) NULL,
                AverageReadLatencyMs NUMERIC(10, 1) NULL,
                AverageWriteLatencyMs NUMERIC(10, 1) NOT NULL,
                AverageIOLatencyMs NUMERIC(10, 1) NOT NULL,
                FileSizeMB DECIMAL(18, 2) NOT NULL,
                PhysicalName NVARCHAR(260) NOT NULL,
                Type NVARCHAR(60) NULL,
                IOStallReadMs BIGINT NOT NULL,
                NumberOfReads BIGINT NOT NULL,
                IOStallWriteMs BIGINT NOT NULL,
                NumberOfWrites BIGINT NOT NULL,
                IOStalls BIGINT NOT NULL,
                TotalIO BIGINT NOT NULL
            ) ON [PRIMARY];
        END;

        INSERT INTO dbo.IOLatencyByFile
        (
            CollectionTime,
            DatabaseName,
            AverageReadLatencyMs,
            AverageWriteLatencyMs,
            AverageIOLatencyMs,
            FileSizeMB,
            PhysicalName,
            Type,
            IOStallReadMs,
            NumberOfReads,
            IOStallWriteMs,
            NumberOfWrites,
            IOStalls,
            TotalIO
        )
        SELECT GETDATE(),
               DB_NAME(fs.database_id),
               CAST(fs.io_stall_read_ms / (1.0 + fs.num_of_reads) AS NUMERIC(10, 1)),
               CAST(fs.io_stall_write_ms / (1.0 + fs.num_of_writes) AS NUMERIC(10, 1)),
               CAST((fs.io_stall_read_ms + fs.io_stall_write_ms) / (1.0 + fs.num_of_reads + fs.num_of_writes) AS NUMERIC(10, 1)) AS "avg_io_latency_ms",
               CONVERT(DECIMAL(18, 2), mf.size / 128.0),
               mf.physical_name,
               mf.type_desc,
               fs.io_stall_read_ms,
               fs.num_of_reads,
               fs.io_stall_write_ms,
               fs.num_of_writes,
               fs.io_stall_read_ms + fs.io_stall_write_ms,
               fs.num_of_reads + fs.num_of_writes
        FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS fs
            INNER JOIN sys.master_files AS mf WITH (NOLOCK)
                ON fs.database_id = mf.database_id
                   AND fs.file_id = mf.file_id
        OPTION (RECOMPILE);
    END;

    -------------------------------------------------------------------------------
    -- Get I/O utilization by database (Query 35) (IO Usage By Database)
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'IOUsageByDatabase'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'IOUsageByDatabase'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'IOUsageByDatabase'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.IOUsageByDatabase') IS NULL
        BEGIN
            CREATE TABLE dbo.IOUsageByDatabase
            (
                CollectionTime DATETIME2(0) NOT NULL,
                IORank BIGINT NULL,
                DatabaseName sysname NOT NULL,
                TotalIOMB BIGINT NOT NULL,
                TotalIOPecentage DECIMAL(5, 2) NOT NULL,
                ReadIOMB DECIMAL(12, 2) NOT NULL,
                ReadIOPercentage DECIMAL(5, 2) NOT NULL,
                WriteIOMB DECIMAL(12, 2) NOT NULL,
                WriteIOPercentage DECIMAL(5, 2) NOT NULL
            ) ON [PRIMARY];
        END;

        WITH Aggregate_IO_Statistics
        AS (SELECT DB_NAME(DM_IO_STATS.database_id) AS "DatabaseName",
                   CAST(SUM(DM_IO_STATS.num_of_bytes_read + DM_IO_STATS.num_of_bytes_written) / 1048576 AS DECIMAL(12, 2)) AS "ioTotalMB",
                   CAST(SUM(DM_IO_STATS.num_of_bytes_read) / 1048576 AS DECIMAL(12, 2)) AS "ioReadMB",
                   CAST(SUM(DM_IO_STATS.num_of_bytes_written) / 1048576 AS DECIMAL(12, 2)) AS "ioWriteMB"
            FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS DM_IO_STATS
            GROUP BY DM_IO_STATS.database_id)
        INSERT INTO dbo.IOUsageByDatabase
        (
            CollectionTime,
            IORank,
            DatabaseName,
            TotalIOMB,
            TotalIOPecentage,
            ReadIOMB,
            ReadIOPercentage,
            WriteIOMB,
            WriteIOPercentage
        )
        SELECT GETDATE(),
               ROW_NUMBER() OVER (ORDER BY Aggregate_IO_Statistics.ioTotalMB DESC),
               Aggregate_IO_Statistics.DatabaseName,
               Aggregate_IO_Statistics.ioTotalMB,
               CAST(Aggregate_IO_Statistics.ioTotalMB / SUM(Aggregate_IO_Statistics.ioTotalMB) OVER () * 100.0 AS DECIMAL(5, 2)),
               Aggregate_IO_Statistics.ioReadMB,
               CAST(Aggregate_IO_Statistics.ioReadMB / SUM(Aggregate_IO_Statistics.ioReadMB) OVER () * 100.0 AS DECIMAL(5, 2)),
               Aggregate_IO_Statistics.ioWriteMB,
               CAST(Aggregate_IO_Statistics.ioWriteMB / SUM(Aggregate_IO_Statistics.ioWriteMB) OVER () * 100.0 AS DECIMAL(5, 2))
        FROM Aggregate_IO_Statistics
        OPTION (RECOMPILE);
    END;

    -------------------------------------------------------------------------------
    -- Look for I/O requests taking longer than 15 seconds in the six most recent 
    -- SQL Server Error Logs (Query 29) (IO Warnings)
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'IOWarnings'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'IOWarnings'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'IOWarnings'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.IOWarnings') IS NULL
        BEGIN
            CREATE TABLE dbo.IOWarnings
            (
                CollectionTime DATETIME2(0) NOT NULL,
                LogDate DATETIME NULL,
                ProcessInfo sysname NULL,
                LogText NVARCHAR(1000) NULL
            ) ON [PRIMARY];
        END;

        CREATE TABLE #IOWarningResults
        (
            LogDate DATETIME NULL,
            ProcessInfo sysname NULL,
            LogText NVARCHAR(1000) NULL
        );

        INSERT INTO #IOWarningResults
        EXEC sys.xp_readerrorlog 0, 1, N'taking longer than 15 seconds';

        INSERT INTO #IOWarningResults
        EXEC sys.xp_readerrorlog 1, 1, N'taking longer than 15 seconds';

        INSERT INTO #IOWarningResults
        EXEC sys.xp_readerrorlog 2, 1, N'taking longer than 15 seconds';

        INSERT INTO #IOWarningResults
        EXEC sys.xp_readerrorlog 3, 1, N'taking longer than 15 seconds';

        INSERT INTO #IOWarningResults
        EXEC sys.xp_readerrorlog 4, 1, N'taking longer than 15 seconds';

        INSERT INTO #IOWarningResults
        EXEC sys.xp_readerrorlog 5, 1, N'taking longer than 15 seconds';

        INSERT INTO dbo.IOWarnings
        (
            CollectionTime,
            LogDate,
            ProcessInfo,
            LogText
        )
        SELECT GETDATE(),
               LogDate,
               ProcessInfo,
               LogText
        FROM #IOWarningResults;

        DROP TABLE #IOWarningResults;
    END;

    -------------------------------------------------------------------------------
    -- Memory Clerk Usage for instance  (Query 46) (Memory Clerk Usage)
    -- Look for high value for CACHESTORE_SQLCP (Ad-hoc query plans)
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'MemoryClerkUsage'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'MemoryClerkUsage'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'MemoryClerkUsage'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.MemoryClerkUsage') IS NULL
        BEGIN
            CREATE TABLE dbo.MemoryClerkUsage
            (
                CollectionTime DATETIME2(0) NOT NULL,
                MemoryClerkType NVARCHAR(60) NOT NULL,
                MemoryUsageMB DECIMAL(15, 2) NOT NULL
            ) ON [PRIMARY];
        END;

        INSERT INTO dbo.MemoryClerkUsage
        (
            CollectionTime,
            MemoryClerkType,
            MemoryUsageMB
        )
        SELECT TOP (10)
               GETDATE(),
               mc.type,
               CAST((SUM(mc.pages_kb) / 1024.0) AS DECIMAL(15, 2))
        FROM sys.dm_os_memory_clerks AS mc WITH (NOLOCK)
        GROUP BY mc.type
        ORDER BY SUM(mc.pages_kb) DESC
        OPTION (RECOMPILE);
    END;

    -------------------------------------------------------------------------------
    -- Get information on location, time and size of any memory dumps from 
    -- SQL Server  (Query 21) (Memory Dump Info)
    -------------------------------------------------------------------------------

    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'MemoryDumpInfo'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'MemoryDumpInfo'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'MemoryDumpInfo'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.MemoryDumpInfo') IS NULL
        BEGIN
            CREATE TABLE dbo.MemoryDumpInfo
            (
                CollectionTime DATETIME2(0) NOT NULL,
                Filename NVARCHAR(256) NOT NULL,
                CreationTime DATETIMEOFFSET(7) NOT NULL,
                SizeMB BIGINT NOT NULL
            ) ON [PRIMARY];
        END;

        INSERT INTO dbo.MemoryDumpInfo
        (
            CollectionTime,
            Filename,
            CreationTime,
            SizeMB
        )
        SELECT GETDATE(),
               filename,
               creation_time,
               size_in_bytes / 1048576.0
        FROM sys.dm_server_memory_dumps WITH (NOLOCK)
        OPTION (RECOMPILE);
    END;

    -------------------------------------------------------------------------------
    -- SQL Server NUMA Node information  (Query 12) (SQL Server NUMA Info)
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'NUMAInfo'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'NUMAInfo'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'NUMAInfo'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.NUMAInfo') IS NULL
        BEGIN
            CREATE TABLE dbo.NUMAInfo
            (
                CollectionTime DATETIME2(0) NOT NULL,
                NodeID SMALLINT NOT NULL,
                NodeStateDescription NVARCHAR(256) NOT NULL,
                MemoryNodeID SMALLINT NOT NULL,
                ProcessorGroup SMALLINT NOT NULL,
                OnlineSchedulerCount SMALLINT NOT NULL,
                IdleSchedulerCount SMALLINT NOT NULL,
                ActiveWorkerCount INT NOT NULL,
                AverageLoadBalance INT NOT NULL,
                ResourceMonitorState BIT NOT NULL
            ) ON [PRIMARY];
        END;

        INSERT INTO dbo.NUMAInfo
        (
            CollectionTime,
            NodeID,
            NodeStateDescription,
            MemoryNodeID,
            ProcessorGroup,
            OnlineSchedulerCount,
            IdleSchedulerCount,
            ActiveWorkerCount,
            AverageLoadBalance,
            ResourceMonitorState
        )
        SELECT GETDATE(),
               node_id,
               node_state_desc,
               memory_node_id,
               processor_group,
               online_scheduler_count,
               idle_scheduler_count,
               active_worker_count,
               avg_load_balance,
               resource_monitor_state
        FROM sys.dm_os_nodes WITH (NOLOCK)
        WHERE node_state_desc <> N'ONLINE DAC'
        OPTION (RECOMPILE);
    END;

    -------------------------------------------------------------------------------
    -- Performance monitor counters
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'PerformanceCounters'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'PerformanceCounters'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'PerformanceCounters'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.PerformanceCounters') IS NULL
        BEGIN
            CREATE TABLE dbo.PerformanceCounters
            (
                CollectionTime DATETIME2(0) NOT NULL,
                Counter NVARCHAR(770) NOT NULL,
                Type INT NULL,
                Value DECIMAL(38, 2) NULL
            ) ON [PRIMARY];
        END;

        INSERT INTO dbo.PerformanceCounters
        (
            CollectionTime,
            Counter,
            Type,
            Value
        )
        SELECT GETDATE(),
               RTRIM(object_name) + N':' + RTRIM(counter_name) + N':' + RTRIM(instance_name),
               cntr_type,
               cntr_value
        FROM sys.dm_os_performance_counters
        WHERE counter_name IN ( 'Page life expectancy', 'Lazy writes/sec', 'Page reads/sec', 'Page writes/sec',
                                'Free Pages', 'Free list stalls/sec', 'User Connections', 'Lock Waits/sec',
                                'Number of Deadlocks/sec', 'Transactions/sec', 'Forwarded Records/sec',
                                'Index Searches/sec', 'Full Scans/sec', 'Batch Requests/sec', 'SQL Compilations/sec',
                                'SQL Re-Compilations/sec', 'Total Server Memory (KB)', 'Target Server Memory (KB)',
                                'Latch Waits/sec'
                              );
    END;

    -------------------------------------------------------------------------------
    -- Page Life Expectancy (PLE) value for each NUMA node in current instance 
    -- (Query 44) (PLE by NUMA Node)
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'PLEByNUMANode'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'PLEByNUMANode'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'PLEByNUMANode'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.PLEByNUMANode') IS NULL
        BEGIN
            CREATE TABLE dbo.PLEByNUMANode
            (
                CollectionTime DATETIME2(0) NOT NULL,
                ServerName NVARCHAR(128) NOT NULL,
                ObjectName NCHAR(128) NULL,
                InstanceName NCHAR(128) NULL,
                PageLifeExpectancy BIGINT NOT NULL
            ) ON [PRIMARY];
        END;

        INSERT INTO dbo.PLEByNUMANode
        (
            CollectionTime,
            ServerName,
            ObjectName,
            InstanceName,
            PageLifeExpectancy
        )
        SELECT GETDATE(),
               @@SERVERNAME,
               RTRIM(object_name),
               instance_name,
               cntr_value
        FROM sys.dm_os_performance_counters WITH (NOLOCK)
        WHERE object_name LIKE N'%Buffer Node%' -- Handles named instances
              AND counter_name = N'Page life expectancy'
        OPTION (RECOMPILE);
    END;

    -------------------------------------------------------------------------------
    -- SQL Server Process Address space info  (Query 6) (Process Memory)
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'ProcessMemory'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'ProcessMemory'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'ProcessMemory'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.ProcessMemory') IS NULL
        BEGIN
            CREATE TABLE dbo.ProcessMemory
            (
                CollectionTime DATETIME2(0) NOT NULL,
                SQLServerMemoryUsageMB BIGINT NOT NULL,
                SQLServerLockedPagesAllocationMB BIGINT NOT NULL,
                SQLServerLargePagesAllocationMB BIGINT NOT NULL,
                PageFaultCount BIGINT NOT NULL,
                MemoryUtilizationPercentage INT NOT NULL,
                AvailableCommitLimitKB BIGINT NOT NULL,
                ProcessPhysicalMemoryLow BIT NOT NULL,
                ProcessVirtualMemoryLow BIT NOT NULL
            ) ON [PRIMARY];
        END;

        INSERT INTO dbo.ProcessMemory
        (
            CollectionTime,
            SQLServerMemoryUsageMB,
            SQLServerLockedPagesAllocationMB,
            SQLServerLargePagesAllocationMB,
            PageFaultCount,
            MemoryUtilizationPercentage,
            AvailableCommitLimitKB,
            ProcessPhysicalMemoryLow,
            ProcessVirtualMemoryLow
        )
        SELECT GETDATE(),
               physical_memory_in_use_kb / 1024,
               locked_page_allocations_kb / 1024,
               large_page_allocations_kb / 1024,
               page_fault_count,
               memory_utilization_percentage,
               available_commit_limit_kb,
               process_physical_memory_low,
               process_virtual_memory_low
        FROM sys.dm_os_process_memory WITH (NOLOCK)
        OPTION (RECOMPILE);
    END;

    -------------------------------------------------------------------------------
    -- Ring Buffer Connectivity - Login Timers
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'RingBufferConnectivityLoginTimers'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'RingBufferConnectivityLoginTimers'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'RingBufferConnectivityLoginTimers'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.RingBufferConnectivityLoginTimers') IS NULL
        BEGIN
            CREATE TABLE dbo.RingBufferConnectivityLoginTimers
            (
                CollectionTime DATETIME2(0) NOT NULL,
                RecordSource VARCHAR(30) NULL,
                Spid INT NOT NULL,
                OSError INT NULL,
                SniConsumerError INT NOT NULL,
                State VARCHAR(30) NOT NULL,
                RecordTime VARCHAR(30) NOT NULL,
                TdsInputBufferError INT NULL,
                TdsOutputBufferError INT NULL,
                TdsInputBufferBytes INT NULL,
                TotalLoginTimeInMilliseconds INT NULL,
                LoginTaskEnqueuedInMilliseconds INT NULL,
                NetworkWritesInMilliseconds INT NULL,
                NetworkReadsInMilliseconds INT NULL,
                SslProcessingInMilliseconds INT NULL,
                SspiProcessingInMilliseconds INT NULL,
                LoginTriggerAndResourceGovernorProcessingInMilliseconds INT NULL
            ) ON [PRIMARY];
        END;

        INSERT INTO dbo.RingBufferConnectivityLoginTimers
        (
            CollectionTime,
            RecordSource,
            Spid,
            OSError,
            SniConsumerError,
            State,
            RecordTime,
            TdsInputBufferError,
            TdsOutputBufferError,
            TdsInputBufferBytes,
            TotalLoginTimeInMilliseconds,
            LoginTaskEnqueuedInMilliseconds,
            NetworkWritesInMilliseconds,
            NetworkReadsInMilliseconds,
            SslProcessingInMilliseconds,
            SspiProcessingInMilliseconds,
            LoginTriggerAndResourceGovernorProcessingInMilliseconds
        )
        SELECT GETDATE(),
               a.RecordSource,
               a.SPID,
               a.OSError,
               a.SniConsumerError,
               a.State,
               a.RecordTime,
               a.TdsInputBufferError,
               a.TdsOutputBufferError,
               a.TdsInputBufferBytes,
               a.TotalLoginTimeInMilliseconds,
               a.LoginTaskEnqueuedInMilliseconds,
               a.NetworkWritesInMilliseconds,
               a.NetworkReadsInMilliseconds,
               a.SslProcessingInMilliseconds,
               a.SspiProcessingInMilliseconds,
               a.LoginTriggerAndResourceGovernorProcessingInMilliseconds
        FROM
        (
            SELECT R.x.value('(//Record/ConnectivityTraceRecord/RecordType)[1]', 'varchar(30)') AS "RecordType",
                   R.x.value('(//Record/ConnectivityTraceRecord/RecordSource)[1]', 'varchar(30)') AS "RecordSource",
                   R.x.value('(//Record/ConnectivityTraceRecord/Spid)[1]', 'int') AS "SPID",
                   R.x.value('(//Record/ConnectivityTraceRecord/OSError)[1]', 'int') AS "OSError",
                   R.x.value('(//Record/ConnectivityTraceRecord/SniConsumerError)[1]', 'int') AS "SniConsumerError",
                   R.x.value('(//Record/ConnectivityTraceRecord/State)[1]', 'int') AS "State",
                   R.x.value('(//Record/ConnectivityTraceRecord/RecordTime)[1]', 'nvarchar(30)') AS "RecordTime",
                   R.x.value('(//Record/ConnectivityTraceRecord/TdsBuffersInformation/TdsInputBufferError)[1]', 'int') AS "TdsInputBufferError",
                   R.x.value('(//Record/ConnectivityTraceRecord/TdsBuffersInformation/TdsOutputBufferError)[1]', 'int') AS "TdsOutputBufferError",
                   R.x.value('(//Record/ConnectivityTraceRecord/TdsBuffersInformation/TdsInputBufferBytes)[1]', 'int') AS "TdsInputBufferBytes",
                   R.x.value('(//Record/ConnectivityTraceRecord/LoginTimers/TotalLoginTimeInMilliseconds)[1]', 'int') AS "TotalLoginTimeInMilliseconds",
                   R.x.value('(//Record/ConnectivityTraceRecord/LoginTimers/LoginTaskEnqueuedInMilliseconds)[1]', 'int') AS "LoginTaskEnqueuedInMilliseconds",
                   R.x.value('(//Record/ConnectivityTraceRecord/LoginTimers/NetworkWritesInMilliseconds)[1]', 'int') AS "NetworkWritesInMilliseconds",
                   R.x.value('(//Record/ConnectivityTraceRecord/LoginTimers/NetworkReadsInMilliseconds)[1]', 'int') AS "NetworkReadsInMilliseconds",
                   R.x.value('(//Record/ConnectivityTraceRecord/LoginTimers/SslProcessingInMilliseconds)[1]', 'int') AS "SslProcessingInMilliseconds",
                   R.x.value('(//Record/ConnectivityTraceRecord/LoginTimers/SspiProcessingInMilliseconds)[1]', 'int') AS "SspiProcessingInMilliseconds",
                   R.x.value(
                                '(//Record/ConnectivityTraceRecord/LoginTimers/LoginTriggerAndResourceGovernorProcessingInMilliseconds)[1]',
                                'int'
                            ) AS "LoginTriggerAndResourceGovernorProcessingInMilliseconds"
            FROM
            (
                SELECT CAST(record AS XML)
                FROM sys.dm_os_ring_buffers
                WHERE ring_buffer_type = 'RING_BUFFER_CONNECTIVITY'
            ) AS R(x)
        ) AS a
        WHERE a.RecordType = 'LoginTimers'
              AND CAST(a.RecordTime AS DATETIME) >= DATEADD(HOUR, -1 * @Hours, GETDATE());
    END;

    -------------------------------------------------------------------------------
    -- Ring Buffer Connectivity - Errors
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'RingBufferConnectivityErrors'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'RingBufferConnectivityErrors'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'RingBufferConnectivityErrors'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.RingBufferConnectivityErrors') IS NULL
        BEGIN
            CREATE TABLE dbo.RingBufferConnectivityErrors
            (
                CollectionTime DATETIME2(0) NOT NULL,
                RecordSource VARCHAR(30) NULL,
                Spid INT NOT NULL,
                OSError INT NULL,
                SniConsumerError INT NOT NULL,
                State VARCHAR(30) NOT NULL,
                RecordTime VARCHAR(30) NOT NULL,
                TdsInputBufferError INT NULL,
                TdsOutputBufferError INT NULL,
                TdsInputBufferBytes INT NULL,
                PhysicalConnectionIsKilled INT NULL,
                DisconnectDueToReadError INT NULL,
                NetworkErrorFoundInInputStream INT NULL,
                ErrorFoundBeforeLogin INT NULL,
                SessionIsKilled INT NULL,
                NormalDisconnect INT NULL
            ) ON [PRIMARY];
        END;

        INSERT INTO dbo.RingBufferConnectivityErrors
        (
            CollectionTime,
            RecordSource,
            Spid,
            OSError,
            SniConsumerError,
            State,
            RecordTime,
            TdsInputBufferError,
            TdsOutputBufferError,
            TdsInputBufferBytes,
            PhysicalConnectionIsKilled,
            DisconnectDueToReadError,
            NetworkErrorFoundInInputStream,
            ErrorFoundBeforeLogin,
            SessionIsKilled,
            NormalDisconnect
        )
        SELECT GETDATE(),
               a.RecordSource,
               a.SPID,
               a.OSError,
               a.SniConsumerError,
               a.State,
               a.RecordTime,
               a.TdsInputBufferError,
               a.TdsOutputBufferError,
               a.TdsInputBufferBytes,
               a.PhysicalConnectionIsKilled,
               a.DisconnectDueToReadError,
               a.NetworkErrorFoundInInputStream,
               a.ErrorFoundBeforeLogin,
               a.SessionIsKilled,
               a.NormalDisconnect
        FROM
        (
            SELECT R.x.value('(//Record/ConnectivityTraceRecord/RecordType)[1]', 'varchar(30)') AS "RecordType",
                   R.x.value('(//Record/ConnectivityTraceRecord/RecordSource)[1]', 'varchar(30)') AS "RecordSource",
                   R.x.value('(//Record/ConnectivityTraceRecord/Spid)[1]', 'int') AS "SPID",
                   R.x.value('(//Record/ConnectivityTraceRecord/OSError)[1]', 'int') AS "OSError",
                   R.x.value('(//Record/ConnectivityTraceRecord/SniConsumerError)[1]', 'int') AS "SniConsumerError",
                   R.x.value('(//Record/ConnectivityTraceRecord/State)[1]', 'int') AS "State",
                   R.x.value('(//Record/ConnectivityTraceRecord/RecordTime)[1]', 'nvarchar(30)') AS "RecordTime",
                   R.x.value('(//Record/ConnectivityTraceRecord/TdsBuffersInformation/TdsInputBufferError)[1]', 'int') AS "TdsInputBufferError",
                   R.x.value('(//Record/ConnectivityTraceRecord/TdsBuffersInformation/TdsOutputBufferError)[1]', 'int') AS "TdsOutputBufferError",
                   R.x.value('(//Record/ConnectivityTraceRecord/TdsBuffersInformation/TdsInputBufferBytes)[1]', 'int') AS "TdsInputBufferBytes",
                   R.x.value(
                                '(//Record/ConnectivityTraceRecord/TdsDisconnectFlags/PhysicalConnectionIsKilled)[1]',
                                'int'
                            ) AS "PhysicalConnectionIsKilled",
                   R.x.value('(//Record/ConnectivityTraceRecord/TdsDisconnectFlags/DisconnectDueToReadError)[1]', 'int') AS "DisconnectDueToReadError",
                   R.x.value(
                                '(//Record/ConnectivityTraceRecord/TdsDisconnectFlags/NetworkErrorFoundInInputStream)[1]',
                                'int'
                            ) AS "NetworkErrorFoundInInputStream",
                   R.x.value('(//Record/ConnectivityTraceRecord/TdsDisconnectFlags/ErrorFoundBeforeLogin)[1]', 'int') AS "ErrorFoundBeforeLogin",
                   R.x.value('(//Record/ConnectivityTraceRecord/TdsDisconnectFlags/SessionIsKilled)[1]', 'int') AS "SessionIsKilled",
                   R.x.value('(//Record/ConnectivityTraceRecord/TdsDisconnectFlags/NormalDisconnect)[1]', 'int') AS "NormalDisconnect"
            FROM
            (
                SELECT CAST(record AS XML)
                FROM sys.dm_os_ring_buffers
                WHERE ring_buffer_type = 'RING_BUFFER_CONNECTIVITY'
            ) AS R(x)
        ) AS a
        WHERE a.RecordType = 'Error'
              AND CAST(a.RecordTime AS DATETIME) >= DATEADD(HOUR, -1 * @Hours, GETDATE());
    END;

    -------------------------------------------------------------------------------
    -- Ring Buffer - Exceptions
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'RingBufferExceptions'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'RingBufferExceptions'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'RingBufferExceptions'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.RingBufferExceptions') IS NULL
        BEGIN
            CREATE TABLE dbo.RingBufferExceptions
            (
                CollectionTime DATETIME2(0) NOT NULL,
                TimeStamp VARCHAR(255) NULL,
                Error VARCHAR(255) NULL,
                Severity VARCHAR(255) NOT NULL,
                State VARCHAR(255) NOT NULL,
                Description NVARCHAR(255) NOT NULL,
                IsUserDefinedError INT NOT NULL,
                RecordID BIGINT NOT NULL,
                Type VARCHAR(30) NOT NULL,
                RecordTime VARCHAR(30) NULL
            ) ON [PRIMARY];
        END;

        INSERT INTO dbo.RingBufferExceptions
        (
            CollectionTime,
            TimeStamp,
            Error,
            Severity,
            State,
            Description,
            IsUserDefinedError,
            RecordID,
            Type,
            RecordTime
        )
        SELECT GETDATE(),
               DATEADD(ms, (rbf.timestamp - tme.ms_ticks), GETDATE()) AS "TimeStamp",
               CAST(rbf.record AS XML).value('(//Exception//Error)[1]', 'varchar(255)') AS "Error",
               CAST(rbf.record AS XML).value('(//Exception/Severity)[1]', 'varchar(255)') AS "Severity",
               CAST(rbf.record AS XML).value('(//Exception/State)[1]', 'varchar(255)') AS "State",
               msg.description,
               CAST(rbf.record AS XML).value('(//Exception/UserDefined)[1]', 'int') AS "IsUserDefinedError",
               CAST(rbf.record AS XML).value('(//Record/@id)[1]', 'bigint') AS "RecordID",
               CAST(rbf.record AS XML).value('(//Record/@type)[1]', 'varchar(30)') AS "Type",
               CAST(rbf.record AS XML).value('(//Record/@time)[1]', 'int') AS "RecordTime"
        FROM sys.dm_os_ring_buffers AS rbf
            CROSS JOIN sys.dm_os_sys_info AS tme
            CROSS JOIN sys.sysmessages AS msg
        WHERE rbf.ring_buffer_type = 'RING_BUFFER_EXCEPTION'
              AND msg.error = CAST(rbf.record AS XML).value('(//Exception//Error)[1]', 'varchar(500)')
              AND msg.msglangid = 1033
              AND DATEADD(ms, (rbf.timestamp - tme.ms_ticks), GETDATE()) >= DATEADD(HOUR, -1 * @Hours, GETDATE());
    END;

    -------------------------------------------------------------------------------
    -- Ring Buffer - Resource Monitor
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'RingBufferResourceMonitor'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'RingBufferResourceMonitor'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'RingBufferResourceMonitor'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.RingBufferResourceMonitor') IS NULL
        BEGIN
            CREATE TABLE dbo.RingBufferResourceMonitor
            (
                CollectionTime DATETIME2(0) NOT NULL,
                NotificationTime DATETIME NULL,
                NotificationType VARCHAR(30) NULL,
                MemoryUtilizationPercentage BIGINT NOT NULL,
                NodeID BIGINT NOT NULL,
                ProcessIndicator INT NOT NULL,
                SystemIndicator INT NOT NULL,
                Effect1Type VARCHAR(30) NOT NULL,
                Effect1State VARCHAR(30) NOT NULL,
                Effect1Reserved INT NULL,
                Effect1 BIGINT NOT NULL,
                Effect2Type VARCHAR(30) NOT NULL,
                Effect2State VARCHAR(30) NOT NULL,
                Effect2Reserved INT NULL,
                Effect2 BIGINT NOT NULL,
                Effect3Type VARCHAR(30) NOT NULL,
                Effect3State VARCHAR(30) NOT NULL,
                Effect3Reserved INT NULL,
                Effect3 BIGINT NOT NULL,
                SQLReservedMemoryKB BIGINT NOT NULL,
                SQLCommittedMemoryKB BIGINT NOT NULL,
                SQLAWEMemory BIGINT NOT NULL,
                SinglePagesMemory BIGINT NULL,
                MultiplePagesMemory BIGINT NULL,
                TotalPhysicalMemoryKB BIGINT NOT NULL,
                AvailablePhysicalMemoryKB BIGINT NOT NULL,
                TotalPageFileKB BIGINT NOT NULL,
                AvailablePageFileKB BIGINT NOT NULL,
                TotalVirtualAddressSpaceKB BIGINT NOT NULL,
                AvailableVirtualAddressSpaceKB BIGINT NOT NULL,
                RecordID BIGINT NOT NULL,
                Type VARCHAR(30) NULL,
                RecordTime BIGINT NOT NULL
            ) ON [PRIMARY];
        END;

        INSERT INTO dbo.RingBufferResourceMonitor
        (
            CollectionTime,
            NotificationTime,
            NotificationType,
            MemoryUtilizationPercentage,
            NodeID,
            ProcessIndicator,
            SystemIndicator,
            Effect1Type,
            Effect1State,
            Effect1Reserved,
            Effect1,
            Effect2Type,
            Effect2State,
            Effect2Reserved,
            Effect2,
            Effect3Type,
            Effect3State,
            Effect3Reserved,
            Effect3,
            SQLReservedMemoryKB,
            SQLCommittedMemoryKB,
            SQLAWEMemory,
            SinglePagesMemory,
            MultiplePagesMemory,
            TotalPhysicalMemoryKB,
            AvailablePhysicalMemoryKB,
            TotalPageFileKB,
            AvailablePageFileKB,
            TotalVirtualAddressSpaceKB,
            AvailableVirtualAddressSpaceKB,
            RecordID,
            Type,
            RecordTime
        )
        SELECT GETDATE() AS "CollectionTime",
               DATEADD(ms, (rbf.timestamp - tme.ms_ticks), GETDATE()) AS "NotificationTime",
               CAST(rbf.record AS XML).value('(//Record/ResourceMonitor/Notification)[1]', 'varchar(30)') AS "NotificationType",
               CAST(rbf.record AS XML).value('(//Record/MemoryRecord/MemoryUtilization)[1]', 'bigint') AS "MemoryUtilizationPercentage",
               CAST(rbf.record AS XML).value('(//Record/MemoryNode/@id)[1]', 'bigint') AS "NodeID",
               CAST(rbf.record AS XML).value('(//Record/ResourceMonitor/IndicatorsProcess)[1]', 'int') AS "ProcessIndicator",
               CAST(rbf.record AS XML).value('(//Record/ResourceMonitor/IndicatorsSystem)[1]', 'int') AS "SystemIndicator",
               CAST(rbf.record AS XML).value('(//Record/ResourceMonitor/Effect/@type)[1]', 'varchar(30)') AS "Effect1Type",
               CAST(rbf.record AS XML).value('(//Record/ResourceMonitor/Effect/@state)[1]', 'varchar(30)') AS "Effect1State",
               CAST(rbf.record AS XML).value('(//Record/ResourceMonitor/Effect/@reversed)[1]', 'int') AS "Effect1Reserved",
               CAST(rbf.record AS XML).value('(//Record/ResourceMonitor/Effect)[1]', 'bigint') AS "Effect1",
               CAST(rbf.record AS XML).value('(//Record/ResourceMonitor/Effect[2]/@type)[1]', 'varchar(30)') AS "Effect2Type",
               CAST(rbf.record AS XML).value('(//Record/ResourceMonitor/Effect[2]/@state)[1]', 'varchar(30)') AS "Effect2State",
               CAST(rbf.record AS XML).value('(//Record/ResourceMonitor/Effect[2]/@reversed)[1]', 'int') AS "Effect2Reserved",
               CAST(rbf.record AS XML).value('(//Record/ResourceMonitor/Effect)[2]', 'bigint') AS "Effect2",
               CAST(rbf.record AS XML).value('(//Record/ResourceMonitor/Effect[3]/@type)[1]', 'varchar(30)') AS "Effect3Type",
               CAST(rbf.record AS XML).value('(//Record/ResourceMonitor/Effect[3]/@state)[1]', 'varchar(30)') AS "Effect3State",
               CAST(rbf.record AS XML).value('(//Record/ResourceMonitor/Effect[3]/@reversed)[1]', 'int') AS "Effect3Reserved",
               CAST(rbf.record AS XML).value('(//Record/ResourceMonitor/Effect)[3]', 'bigint') AS "Effect3",
               CAST(rbf.record AS XML).value('(//Record/MemoryNode/ReservedMemory)[1]', 'bigint') AS "SQLReservedMemoryKB",
               CAST(rbf.record AS XML).value('(//Record/MemoryNode/CommittedMemory)[1]', 'bigint') AS "SQLCommittedMemoryKB",
               CAST(rbf.record AS XML).value('(//Record/MemoryNode/AWEMemory)[1]', 'bigint') AS "SQLAWEMemory",
               CAST(rbf.record AS XML).value('(//Record/MemoryNode/SinglePagesMemory)[1]', 'bigint') AS "SinglePagesMemory",
               CAST(rbf.record AS XML).value('(//Record/MemoryNode/MultiplePagesMemory)[1]', 'bigint') AS "MultiplePagesMemory",
               CAST(rbf.record AS XML).value('(//Record/MemoryRecord/TotalPhysicalMemory)[1]', 'bigint') AS "TotalPhysicalMemoryKB",
               CAST(rbf.record AS XML).value('(//Record/MemoryRecord/AvailablePhysicalMemory)[1]', 'bigint') AS "AvailablePhysicalMemoryKB",
               CAST(rbf.record AS XML).value('(//Record/MemoryRecord/TotalPageFile)[1]', 'bigint') AS "TotalPageFileKB",
               CAST(rbf.record AS XML).value('(//Record/MemoryRecord/AvailablePageFile)[1]', 'bigint') AS "AvailablePageFileKB",
               CAST(rbf.record AS XML).value('(//Record/MemoryRecord/TotalVirtualAddressSpace)[1]', 'bigint') AS "TotalVirtualAddressSpaceKB",
               CAST(rbf.record AS XML).value('(//Record/MemoryRecord/AvailableVirtualAddressSpace)[1]', 'bigint') AS "AvailableVirtualAddressSpaceKB",
               CAST(rbf.record AS XML).value('(//Record/@id)[1]', 'bigint') AS "RecordID",
               CAST(rbf.record AS XML).value('(//Record/@type)[1]', 'varchar(30)') AS "Type",
               CAST(rbf.record AS XML).value('(//Record/@time)[1]', 'bigint') AS "RecordTime"
        FROM sys.dm_os_ring_buffers AS rbf
            CROSS JOIN sys.dm_os_sys_info AS tme
        WHERE rbf.ring_buffer_type = 'RING_BUFFER_RESOURCE_MONITOR'
              AND DATEADD(ms, (rbf.timestamp - tme.ms_ticks), GETDATE()) >= DATEADD(HOUR, -1 * @Hours, GETDATE());
    END;

    -------------------------------------------------------------------------------
    -- Ring Buffer - Scheduler Monitor
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'RingBufferSchedulerMonitor'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'RingBufferSchedulerMonitor'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'RingBufferSchedulerMonitor'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.RingBufferSchedulerMonitor') IS NULL
        BEGIN
            CREATE TABLE dbo.RingBufferSchedulerMonitor
            (
                CollectionTime DATETIME2(0) NOT NULL,
                NotificationTime DATETIME NOT NULL,
                ProcessUtilization INT NOT NULL,
                SystemIdlePercentage INT NOT NULL,
                UserModeTime BIGINT NOT NULL,
                KernelModeTime BIGINT NOT NULL,
                PageFaults BIGINT NOT NULL,
                WorkingSetDelta BIGINT NOT NULL,
                MemoryUtilizationPercentageWorkingSet BIGINT NOT NULL,
                RecordTime BIGINT NOT NULL
            ) ON [PRIMARY];
        END;

        INSERT INTO dbo.RingBufferSchedulerMonitor
        (
            CollectionTime,
            NotificationTime,
            ProcessUtilization,
            SystemIdlePercentage,
            UserModeTime,
            KernelModeTime,
            PageFaults,
            WorkingSetDelta,
            MemoryUtilizationPercentageWorkingSet,
            RecordTime
        )
        SELECT GETDATE() AS "CollectionTime",
               DATEADD(ms, a.RecordTime - sys.ms_ticks, GETDATE()) AS "NotificationTime",
               a.ProcessUtilization,
               a.SystemIdlePercentage,
               a.UserModeTime,
               a.KernelModeTime,
               a.PageFaults,
               a.WorkingSetDelta,
               a.MemoryUtilizationPercentageWorkingSet,
               a.RecordTime
        FROM
        (
            SELECT R.x.value('(//Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS "ProcessUtilization",
                   R.x.value('(//Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS "SystemIdlePercentage",
                   R.x.value('(//Record/SchedulerMonitorEvent/SystemHealth/UserModeTime) [1]', 'bigint') AS "UserModeTime",
                   R.x.value('(//Record/SchedulerMonitorEvent/SystemHealth/KernelModeTime) [1]', 'bigint') AS "KernelModeTime",
                   R.x.value('(//Record/SchedulerMonitorEvent/SystemHealth/PageFaults) [1]', 'bigint') AS "PageFaults",
                   R.x.value('(//Record/SchedulerMonitorEvent/SystemHealth/WorkingSetDelta) [1]', 'bigint') / 1024 AS "WorkingSetDelta",
                   R.x.value('(//Record/SchedulerMonitorEvent/SystemHealth/MemoryUtilization) [1]', 'bigint') AS "MemoryUtilizationPercentageWorkingSet",
                   R.x.value('(//Record/@time)[1]', 'bigint') AS "RecordTime"
            FROM
            (
                SELECT CAST(record AS XML)
                FROM sys.dm_os_ring_buffers
                WHERE ring_buffer_type = 'RING_BUFFER_SCHEDULER_MONITOR'
            ) AS R(x)
        ) AS a
            CROSS JOIN sys.dm_os_sys_info AS sys
        WHERE DATEADD(ms, a.RecordTime - sys.ms_ticks, GETDATE()) >= DATEADD(HOUR, -1 * @Hours, GETDATE());
    END;

    -------------------------------------------------------------------------------
    -- Ring Buffer - Security Errors
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'RingBufferSecurityErrors'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'RingBufferSecurityErrors'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'RingBufferSecurityErrors'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.RingBufferSecurityErrors') IS NULL
        BEGIN
            CREATE TABLE dbo.RingBufferSecurityErrors
            (
                CollectionTime DATETIME2(0) NOT NULL,
                NotificationTime DATETIME NOT NULL,
                Spid BIGINT NOT NULL,
                ErrorCode VARCHAR(255) NULL,
                CallingAPIName VARCHAR(255) NULL,
                APIName VARCHAR(255) NULL,
                RecordID BIGINT NULL,
                Type VARCHAR(30) NULL,
                RecordTime BIGINT NULL
            ) ON [PRIMARY];
        END;

        INSERT INTO dbo.RingBufferSecurityErrors
        (
            CollectionTime,
            NotificationTime,
            Spid,
            ErrorCode,
            CallingAPIName,
            APIName,
            RecordID,
            Type,
            RecordTime
        )
        SELECT GETDATE(),
               DATEADD(ms, rbf.timestamp - tme.ms_ticks, GETDATE()) AS "NotificationTime",
               CAST(rbf.record AS XML).value('(//SPID)[1]', 'bigint') AS "SPID",
               CAST(rbf.record AS XML).value('(//ErrorCode)[1]', 'varchar(255)') AS "ErrorCode",
               CAST(rbf.record AS XML).value('(//CallingAPIName)[1]', 'varchar(255)') AS "CallingAPIName",
               CAST(rbf.record AS XML).value('(//APIName)[1]', 'varchar(255)') AS "APIName",
               CAST(rbf.record AS XML).value('(//Record/@id)[1]', 'bigint') AS "RecordID",
               CAST(rbf.record AS XML).value('(//Record/@type)[1]', 'varchar(30)') AS "Type",
               CAST(rbf.record AS XML).value('(//Record/@time)[1]', 'bigint') AS "RecordTime"
        FROM sys.dm_os_ring_buffers AS rbf
            CROSS JOIN sys.dm_os_sys_info AS tme
        WHERE rbf.ring_buffer_type = 'RING_BUFFER_SECURITY_ERROR'
              AND DATEADD(ms, rbf.timestamp - tme.ms_ticks, GETDATE()) >= DATEADD(HOUR, -1 * @Hours, GETDATE());
    END;

    -------------------------------------------------------------------------------
    -- Server principals
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'ServerPrincipals'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'ServerPrincipals'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'ServerPrincipals'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.ServerPrincipals') IS NULL
        BEGIN
            CREATE TABLE dbo.ServerPrincipals
            (
                CollectionTime DATETIME2(0) NOT NULL,
                Name sysname NOT NULL,
                SID VARBINARY(85) NULL,
                Type NVARCHAR(60) NOT NULL,
                IsDisabled BIT NULL,
                CreateDate DATETIME NOT NULL,
                ModifyDate DATETIME NOT NULL,
                DefaultDatabaseName sysname NULL,
                DefaultLanguageName sysname NULL,
                CredentialID INT NULL,
                OwningPrincipalID INT NULL,
                IsFixedRole BIT NOT NULL
            ) ON [PRIMARY];
        END;

        INSERT INTO dbo.ServerPrincipals
        (
            CollectionTime,
            Name,
            SID,
            Type,
            IsDisabled,
            CreateDate,
            ModifyDate,
            DefaultDatabaseName,
            DefaultLanguageName,
            CredentialID,
            OwningPrincipalID,
            IsFixedRole
        )
        SELECT GETDATE(),
               name,
               sid,
               type_desc,
               is_disabled,
               create_date,
               modify_date,
               default_database_name,
               default_language_name,
               credential_id,
               owning_principal_id,
               is_fixed_role
        FROM sys.server_principals
        WHERE Name NOT LIKE '##%';
    END;

    -------------------------------------------------------------------------------
    -- Get selected server properties (Query 3) (Server Properties)
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'ServerProperties'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'ServerProperties'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'ServerProperties'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.ServerProperties') IS NULL
        BEGIN
            CREATE TABLE dbo.ServerProperties
            (
                CollectionTime DATETIME2(0) NOT NULL,
                MachineName SQL_VARIANT NOT NULL,
                ServerName SQL_VARIANT NOT NULL,
                Instance SQL_VARIANT NULL,
                IsClustered SQL_VARIANT NOT NULL,
                ComputerNamePhysicalNetBIOS SQL_VARIANT NOT NULL,
                Edition SQL_VARIANT NOT NULL,
                ProductLevel SQL_VARIANT NULL,
                ProductUpdateLevel SQL_VARIANT NULL,
                ProductVersion SQL_VARIANT NULL,
                ProductMajorVersion SQL_VARIANT NULL,
                ProductMinorVersion SQL_VARIANT NULL,
                ProductBuild SQL_VARIANT NULL,
                ProductBuildType SQL_VARIANT NULL,
                ProductUpdateReference SQL_VARIANT NOT NULL,
                ProcessID SQL_VARIANT NOT NULL,
                Collation SQL_VARIANT NOT NULL,
                IsFullTextInstalled SQL_VARIANT NOT NULL,
                IsIntegratedSecurityOnly SQL_VARIANT NOT NULL,
                FilestreamConfiguredLevel SQL_VARIANT NOT NULL,
                IsHadrEnabled SQL_VARIANT NOT NULL,
                HadrManagerStatus SQL_VARIANT NOT NULL,
                InstanceDefaultDataPath SQL_VARIANT NOT NULL,
                InstanceDefaultLogPath SQL_VARIANT NOT NULL,
                InstanceDefaultBackupPath SQL_VARIANT NULL,
                BuildCLRVersion SQL_VARIANT NOT NULL,
                IsXTPSupported SQL_VARIANT NULL,
                IsPolybaseInstalled SQL_VARIANT NULL,
                IsRServicesInstalled SQL_VARIANT NULL,
                IsTempdbMetadataMemoryOptimized SQL_VARIANT NULL
            ) ON [PRIMARY];
        END;

        INSERT INTO dbo.ServerProperties
        (
            CollectionTime,
            MachineName,
            ServerName,
            Instance,
            IsClustered,
            ComputerNamePhysicalNetBIOS,
            Edition,
            ProductLevel,
            ProductUpdateLevel,
            ProductVersion,
            ProductMajorVersion,
            ProductMinorVersion,
            ProductBuild,
            ProductBuildType,
            ProductUpdateReference,
            ProcessID,
            Collation,
            IsFullTextInstalled,
            IsIntegratedSecurityOnly,
            FilestreamConfiguredLevel,
            IsHadrEnabled,
            HadrManagerStatus,
            InstanceDefaultDataPath,
            InstanceDefaultLogPath,
            InstanceDefaultBackupPath,
            BuildCLRVersion,
            IsXTPSupported,
            IsPolybaseInstalled,
            IsRServicesInstalled,
            IsTempdbMetadataMemoryOptimized
        )
        SELECT GETDATE() AS "CollectionTime",
               SERVERPROPERTY('MachineName'),
               SERVERPROPERTY('ServerName'),
               SERVERPROPERTY('InstanceName'),
               SERVERPROPERTY('IsClustered'),
               SERVERPROPERTY('ComputerNamePhysicalNetBIOS'),
               SERVERPROPERTY('Edition'),
               SERVERPROPERTY('ProductLevel'),           -- What servicing branch (RTM/SP/CU)
               SERVERPROPERTY('ProductUpdateLevel'),     -- Within a servicing branch, what CU# is applied
               SERVERPROPERTY('ProductVersion'),
               SERVERPROPERTY('ProductMajorVersion'),
               SERVERPROPERTY('ProductMinorVersion'),
               SERVERPROPERTY('ProductBuild'),
               SERVERPROPERTY('ProductBuildType'),       -- Is this a GDR or OD hotfix (NULL if on a CU build)
               SERVERPROPERTY('ProductUpdateReference'), -- KB article number that is applicable for this build
               SERVERPROPERTY('ProcessID'),
               SERVERPROPERTY('Collation'),
               SERVERPROPERTY('IsFullTextInstalled'),
               SERVERPROPERTY('IsIntegratedSecurityOnly'),
               SERVERPROPERTY('FilestreamConfiguredLevel'),
               SERVERPROPERTY('IsHadrEnabled'),
               SERVERPROPERTY('HadrManagerStatus'),
               SERVERPROPERTY('InstanceDefaultDataPath'),
               SERVERPROPERTY('InstanceDefaultLogPath'),
               SERVERPROPERTY('InstanceDefaultBackupPath'),
               SERVERPROPERTY('BuildClrVersion'),
               SERVERPROPERTY('IsXTPSupported'),
               SERVERPROPERTY('IsPolybaseInstalled'),
               SERVERPROPERTY('IsAdvancedAnalyticsInstalled'),
               SERVERPROPERTY('IsTempdbMetadataMemoryOptimized');
    END;

    -------------------------------------------------------------------------------
    -- List all server triggers
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'ServerTriggers'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'ServerTriggers'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'ServerTriggers'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.ServerTriggers') IS NULL
        BEGIN
            CREATE TABLE dbo.ServerTriggers
            (
                CollectionTime DATETIME2(0) NOT NULL,
                TriggerName sysname NOT NULL,
                Class NVARCHAR(30) NOT NULL,
                Type NVARCHAR(30) NOT NULL,
                Status NVARCHAR(30) NOT NULL,
                Definition NVARCHAR(MAX) NULL,
                CreateDate DATETIME2(0) NULL,
                ModifyDate DATETIME2(0) NULL
            ) ON [PRIMARY];
        END;

        DECLARE @sql NVARCHAR(MAX) = N'';
        SET @sql
            = N'USE master; 
				SELECT GETDATE(),
					trg.[name],
					trg.parent_class_desc,
					CASE
						WHEN trg.[type] = ''TA'' THEN
							''Assembly (CLR) trigger''
						WHEN trg.[type] = ''TR'' THEN
							''SQL trigger''
						ELSE
							''''
					END,
					CASE
						WHEN trg.is_disabled = 1 THEN
							''[Disabled]''
						ELSE
							''[Active]''
					END,
					OBJECT_DEFINITION(trg.object_id),
					trg.create_date,
					trg.modify_date
				FROM sys.server_triggers trg;';

        INSERT INTO dbo.ServerTriggers
        (
            CollectionTime,
            TriggerName,
            Class,
            Type,
            Status,
            Definition,
            CreateDate,
            ModifyDate
        )
        EXEC sys.sp_executesql @command = @sql;
    END;

    -------------------------------------------------------------------------------
    -- SQL Server Services information (Query 7) (SQL Server Services Info)
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'ServicesInfo'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'ServicesInfo'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'ServicesInfo'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.ServicesInfo') IS NULL
        BEGIN
            CREATE TABLE dbo.ServicesInfo
            (
                CollectionTime DATETIME2(0) NOT NULL,
                ServiceName NVARCHAR(256) NOT NULL,
                ProcessID INT NOT NULL,
                StartupTypeDescription NVARCHAR(256) NULL,
                StatusDescription NVARCHAR(256) NULL,
                LastStartupTime DATETIMEOFFSET(7) NULL,
                ServiceAccount NVARCHAR(256) NOT NULL,
                IsClustered NVARCHAR(1) NOT NULL,
                ClusterNodeName NVARCHAR(256) NULL,
                Filename NVARCHAR(256) NOT NULL--,
                --InstantFileInitializationEnabled NVARCHAR(256) NOT NULL
            ) ON [PRIMARY];
        END;

        INSERT INTO dbo.ServicesInfo
        (
            CollectionTime,
            ServiceName,
            ProcessID,
            StartupTypeDescription,
            StatusDescription,
            LastStartupTime,
            ServiceAccount,
            IsClustered,
            ClusterNodeName,
            Filename--,
            --InstantFileInitializationEnabled
        )
        SELECT GETDATE(),
               servicename,
               process_id,
               startup_type_desc,
               status_desc,
               last_startup_time,
               service_account,
               is_clustered,
               cluster_nodename,
               filename--,
               --instant_file_initialization_enabled
        FROM sys.dm_server_services WITH (NOLOCK)
        OPTION (RECOMPILE);
    END;

    -------------------------------------------------------------------------------
    -- Statistics information on all databases
    -------------------------------------------------------------------------------
    --IF (
    --       (
    --           @Checks IS NULL
    --           AND @SkipChecks IS NULL
    --       )
    --       OR
    --       (
    --           EXISTS
    --(
    --    SELECT 1
    --    FROM @_Checks
    --    WHERE [Check] = 'StatisticsInfo'
    --)
    --           AND NOT EXISTS
    --(
    --    SELECT 1
    --    FROM @_SkipChecks
    --    WHERE [Check] = 'StatisticsInfo'
    --)
    --       )
    --       OR (NOT EXISTS
    --(
    --    SELECT 1
    --    FROM @_SkipChecks
    --    WHERE [Check] = 'StatisticsInfo'
    --)
    --          )
    --   )
    --BEGIN
    --    IF OBJECT_ID('dbo.StatisticsInfo') IS NULL
    --    BEGIN
    --        CREATE TABLE dbo.StatisticsInfo
    --        (
    --            CollectionTime DATETIME2(0) NOT NULL,
    --            DatabaseName sysname NOT NULL,
    --            SchemaName sysname NOT NULL,
    --            TableName sysname NOT NULL,
    --            StatisticID INT NOT NULL,
    --            StatisticName NVARCHAR(4000) NULL,
    --            StatisticType NVARCHAR(60) NULL,
    --            IsTemporary BIT NOT NULL,
    --            IsFiltered BIT NOT NULL,
    --            ColumnName NVARCHAR(MAX) NULL,
    --            FilterDefinition NVARCHAR(4000) NULL,
    --            LastUpdated DATETIME2 NULL,
    --            Rows BIGINT NULL,
    --            RowsSampled BIGINT NULL,
    --            HistogramSteps INT NULL,
    --            RowsUnfiltered BIGINT NULL,
    --            RowsModified BIGINT NULL
    --        ) ON [PRIMARY];
    --    END;

    --    IF OBJECT_ID('tempdb..#StatisticsInfo') IS NOT NULL
    --        DROP TABLE #StatisticsInfo;

    --    IF OBJECT_ID('tempdb..#ColumnList') IS NOT NULL
    --        DROP TABLE #ColumnList;

    --    CREATE TABLE #StatisticsInfo
    --    (
    --        DatabaseName sysname NOT NULL,
    --        SchemaName sysname NOT NULL,
    --        TableName sysname NOT NULL,
    --        StatisticID INT NOT NULL,
    --        StatisticName NVARCHAR(4000) NULL,
    --        StatisticType NVARCHAR(60) NULL,
    --        IsTemporary BIT NOT NULL,
    --        IsFiltered BIT NOT NULL,
    --        ColumnName NVARCHAR(MAX) NULL,
    --        FilterDefinition NVARCHAR(4000) NULL,
    --        LastUpdated DATETIME2 NULL,
    --        Rows BIGINT NULL,
    --        RowsSampled BIGINT NULL,
    --        HistogramSteps INT NULL,
    --        RowsUnfiltered BIGINT NULL,
    --        RowsModified BIGINT NULL
    --    );

    --    EXEC sys.sp_MSforeachdb @command1 = 'USE ?;
	   --     INSERT INTO #StatisticsInfo
    --        SELECT 
    --            DB_NAME() AS DatabaseName, 
    --            ss.[name] AS SchemaName,
    --            obj.[name] AS TableName,
    --            stat.[stats_id] AS StatisticID,
    --            stat.[name] AS StatisticsName,
    --            CASE
    --                WHEN stat.[auto_created] = 0 AND stat.[user_created] = 0 THEN
    --                    ''Index Statistic''
    --                WHEN stat.[auto_created] = 0 AND stat.[user_created] = 1 THEN
    --                    ''User Created''
    --                WHEN stat.[auto_created] = 1 AND stat.[user_created] = 0 THEN
    --                    ''Auto Created''
    --                WHEN stat.[auto_created] = 1 AND stat.[user_created] = 1 THEN
    --                    ''Updated stats available in Secondary''
    --            END AS StatisticType,
    --            stat.[is_temporary] AS IsTemporary,
    --            stat.[has_filter] AS IsFiltered,
    --            c.[name] AS ColumnName,
    --            stat.[filter_definition] AS FilterDefinition,
    --            sp.[last_updated] AS LastUpdated,
    --            sp.[rows] AS [Rows],
    --            sp.[rows_sampled] AS RowsSampled,
    --            sp.[steps] AS HistogramSteps,
    --            sp.[unfiltered_rows] AS RowsUnfiltered,
    --            sp.[modification_counter] AS RowsModified
    --        FROM [?].sys.[objects] AS obj
    --        INNER JOIN [?].sys.[schemas] ss ON obj.[schema_id] = ss.[schema_id]
    --        INNER JOIN [?].sys.[stats] stat ON stat.[object_id] = obj.[object_id]
    --        JOIN [?].sys.[stats_columns] sc ON sc.[object_id] = stat.[object_id] AND sc.[stats_id] = stat.[stats_id]
    --        JOIN [?].sys.columns c ON c.[object_id] = sc.[object_id] AND c.[column_id] = sc.[column_id]
    --        CROSS APPLY [?].sys.dm_db_stats_properties(stat.[object_id], stat.stats_id) AS sp
    --        WHERE obj.[is_ms_shipped] = 0
    --        ORDER BY ss.[name], obj.[name], stat.[name];';

    --    SELECT t.SchemaName,
    --           t.TableName,
    --           t.StatisticID,
    --           STUFF(
    --           (
    --               SELECT ',' + s.ColumnName
    --               FROM #StatisticsInfo AS s
    --               WHERE s.SchemaName = t.SchemaName
    --                     AND s.TableName = t.TableName
    --                     AND s.StatisticID = t.StatisticID
    --               FOR XML PATH('')
    --           ), 1, 1, '') AS "ColumnList"
    --    INTO #ColumnList
    --    FROM #StatisticsInfo AS t
    --    GROUP BY t.SchemaName,
    --             t.TableName,
    --             t.StatisticID;

    --    INSERT INTO dbo.StatisticsInfo
    --    (
    --        CollectionTime,
    --        DatabaseName,
    --        SchemaName,
    --        TableName,
    --        StatisticID,
    --        StatisticName,
    --        StatisticType,
    --        IsTemporary,
    --        ColumnName,
    --        IsFiltered,
    --        FilterDefinition,
    --        LastUpdated,
    --        Rows,
    --        RowsSampled,
    --        HistogramSteps,
    --        RowsUnfiltered,
    --        RowsModified
    --    )
    --    SELECT DISTINCT
    --           GETDATE(),
    --           SI.DatabaseName,
    --           SI.SchemaName,
    --           SI.TableName,
    --           SI.StatisticID,
    --           SI.StatisticName,
    --           SI.StatisticType,
    --           SI.IsTemporary,
    --           CL.ColumnList,
    --           SI.IsFiltered,
    --           SI.FilterDefinition,
    --           SI.LastUpdated,
    --           SI.Rows,
    --           SI.RowsSampled,
    --           SI.HistogramSteps,
    --           SI.RowsUnfiltered,
    --           SI.RowsModified
    --    FROM #StatisticsInfo AS SI
    --        INNER JOIN #ColumnList AS CL
    --            ON SI.SchemaName = CL.SchemaName
    --               AND SI.TableName = CL.TableName
    --               AND SI.StatisticID = CL.StatisticID;
    --END;

    -------------------------------------------------------------------------------
    -- Look at Suspect Pages table (Query 22) (Suspect Pages)
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'SuspectPages'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'SuspectPages'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'SuspectPages'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.SuspectPages') IS NULL
        BEGIN
            CREATE TABLE dbo.SuspectPages
            (
                CollectionTime DATETIME2(0) NOT NULL,
                DatabaseName NVARCHAR(128) NOT NULL,
                FileID INT NOT NULL,
                PageID BIGINT NOT NULL,
                EventType INT NOT NULL,
                ErrorCount INT NOT NULL,
                LastUpdatePage DATETIME NOT NULL,
            ) ON [PRIMARY];
        END;

        INSERT INTO dbo.SuspectPages
        (
            CollectionTime,
            DatabaseName,
            FileID,
            PageID,
            EventType,
            ErrorCount,
            LastUpdatePage
        )
        SELECT GETDATE(),
               DB_NAME(database_id),
               file_id,
               page_id,
               event_type,
               error_count,
               last_update_date
        FROM msdb.dbo.suspect_pages WITH (NOLOCK)
        OPTION (RECOMPILE);
    END;

    -------------------------------------------------------------------------------
    -- Good basic information about OS memory amounts and state 
    -- (Query 13) (System Memory)
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'SystemMemory'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'SystemMemory'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'SystemMemory'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.SystemMemory') IS NULL
        BEGIN
            CREATE TABLE dbo.SystemMemory
            (
                CollectionTime DATETIME2(0) NOT NULL,
                PhysicalMemoryMB BIGINT NOT NULL,
                AvailableMemoryMB BIGINT NOT NULL,
                PageFileCommitLimitMB BIGINT NOT NULL,
                PhysicalPageFileSizeMB BIGINT NOT NULL,
                AvailablePageFileMB BIGINT NOT NULL,
                SystemCacheMB BIGINT NOT NULL,
                SystemMemoryState NVARCHAR(256) NOT NULL
            ) ON [PRIMARY];
        END;

        INSERT INTO dbo.SystemMemory
        (
            CollectionTime,
            PhysicalMemoryMB,
            AvailableMemoryMB,
            PageFileCommitLimitMB,
            PhysicalPageFileSizeMB,
            AvailablePageFileMB,
            SystemCacheMB,
            SystemMemoryState
        )
        SELECT GETDATE(),
               total_physical_memory_kb / 1024,
               available_physical_memory_kb / 1024,
               total_page_file_kb / 1024,
               total_page_file_kb / 1024 - total_physical_memory_kb / 1024,
               available_page_file_kb / 1024,
               system_cache_kb / 1024,
               system_memory_state_desc
        FROM sys.dm_os_sys_memory WITH (NOLOCK)
        OPTION (RECOMPILE);
    END;

    -------------------------------------------------------------------------------
    -- Isolate top waits for server instance since last restart or wait statistics 
    -- clear (Query 38) (Top Waits)
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'TopWaits'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'TopWaits'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'TopWaits'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.TopWaits') IS NULL
        BEGIN
            CREATE TABLE dbo.TopWaits
            (
                CollectionTime DATETIME2(0) NOT NULL,
                WaitType NVARCHAR(60) NOT NULL,
                WaitPercentage DECIMAL(5, 2) NOT NULL,
                AvgWaitSec DECIMAL(16, 4) NOT NULL,
                AvgResSec DECIMAL(5, 2) NULL,
                AvgSigSec DECIMAL(16, 4) NULL,
                WaitSec DECIMAL(16, 2) NULL,
                ResourceSec DECIMAL(16, 2) NULL,
                SignalSec DECIMAL(16, 2) NULL,
                WaitCount BIGINT NOT NULL,
                HelpInfoURL XML NULL
            ) ON [PRIMARY];
        END;

        WITH Waits
        AS (SELECT wait_type,
                   wait_time_ms / 1000.0 AS "WaitS",
                   (wait_time_ms - signal_wait_time_ms) / 1000.0 AS "ResourceS",
                   signal_wait_time_ms / 1000.0 AS "SignalS",
                   waiting_tasks_count AS "WaitCount",
                   100.0 * wait_time_ms / SUM(wait_time_ms) OVER () AS "Percentage",
                   ROW_NUMBER() OVER (ORDER BY wait_time_ms DESC) AS "RowNum"
            FROM sys.dm_os_wait_stats WITH (NOLOCK)
            WHERE wait_type NOT IN ( N'BROKER_EVENTHANDLER', N'BROKER_RECEIVE_WAITFOR', N'BROKER_TASK_STOP',
                                     N'BROKER_TO_FLUSH', N'BROKER_TRANSMITTER', N'CHECKPOINT_QUEUE', N'CHKPT',
                                     N'CLR_AUTO_EVENT', N'CLR_MANUAL_EVENT', N'CLR_SEMAPHORE', N'CXCONSUMER',
                                     N'DBMIRROR_DBM_EVENT', N'DBMIRROR_EVENTS_QUEUE', N'DBMIRROR_WORKER_QUEUE',
                                     N'DBMIRRORING_CMD', N'DIRTY_PAGE_POLL', N'DISPATCHER_QUEUE_SEMAPHORE',
                                     N'EXECSYNC', N'FSAGENT', N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'FT_IFTSHC_MUTEX',
                                     N'HADR_CLUSAPI_CALL', N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
                                     N'HADR_LOGCAPTURE_WAIT', N'HADR_NOTIFICATION_DEQUEUE', N'HADR_TIMER_TASK',
                                     N'HADR_WORK_QUEUE', N'KSOURCE_WAKEUP', N'LAZYWRITER_SLEEP', N'LOGMGR_QUEUE',
                                     N'MEMORY_ALLOCATION_EXT', N'ONDEMAND_TASK_QUEUE', N'PARALLEL_REDO_DRAIN_WORKER',
                                     N'PARALLEL_REDO_LOG_CACHE', N'PARALLEL_REDO_TRAN_LIST',
                                     N'PARALLEL_REDO_WORKER_SYNC', N'PARALLEL_REDO_WORKER_WAIT_WORK',
                                     N'PREEMPTIVE_HADR_LEASE_MECHANISM', N'PREEMPTIVE_SP_SERVER_DIAGNOSTICS',
                                     N'PREEMPTIVE_OS_LIBRARYOPS', N'PREEMPTIVE_OS_COMOPS', N'PREEMPTIVE_OS_CRYPTOPS',
                                     N'PREEMPTIVE_OS_PIPEOPS', N'PREEMPTIVE_OS_AUTHENTICATIONOPS',
                                     N'PREEMPTIVE_OS_GENERICOPS', N'PREEMPTIVE_OS_VERIFYTRUST',
                                     N'PREEMPTIVE_OS_FILEOPS', N'PREEMPTIVE_OS_DEVICEOPS',
                                     N'PREEMPTIVE_OS_QUERYREGISTRY', N'PREEMPTIVE_OS_WRITEFILE',
                                     N'PREEMPTIVE_OS_WRITEFILEGATHER', N'PREEMPTIVE_XE_CALLBACKEXECUTE',
                                     N'PREEMPTIVE_XE_DISPATCHER', N'PREEMPTIVE_XE_GETTARGETSTATE',
                                     N'PREEMPTIVE_XE_SESSIONCOMMIT', N'PREEMPTIVE_XE_TARGETINIT',
                                     N'PREEMPTIVE_XE_TARGETFINALIZE', N'PWAIT_ALL_COMPONENTS_INITIALIZED',
                                     N'PWAIT_DIRECTLOGCONSUMER_GETNEXT', N'PWAIT_EXTENSIBILITY_CLEANUP_TASK',
                                     N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP', N'QDS_ASYNC_QUEUE',
                                     N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP', N'REQUEST_FOR_DEADLOCK_SEARCH',
                                     N'RESOURCE_QUEUE', N'SERVER_IDLE_CHECK', N'SLEEP_BPOOL_FLUSH', N'SLEEP_DBSTARTUP',
                                     N'SLEEP_DCOMSTARTUP', N'SLEEP_MASTERDBREADY', N'SLEEP_MASTERMDREADY',
                                     N'SLEEP_MASTERUPGRADED', N'SLEEP_MSDBSTARTUP', N'SLEEP_SYSTEMTASK', N'SLEEP_TASK',
                                     N'SLEEP_TEMPDBSTARTUP', N'SNI_HTTP_ACCEPT', N'SOS_WORK_DISPATCHER',
                                     N'SP_SERVER_DIAGNOSTICS_SLEEP', N'SQLTRACE_BUFFER_FLUSH',
                                     N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP', N'SQLTRACE_WAIT_ENTRIES',
                                     N'STARTUP_DEPENDENCY_MANAGER', N'WAIT_FOR_RESULTS', N'WAITFOR',
                                     N'WAITFOR_TASKSHUTDOWN', N'WAIT_XTP_HOST_WAIT', N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG',
                                     N'WAIT_XTP_CKPT_CLOSE', N'WAIT_XTP_RECOVERY', N'XE_BUFFERMGR_ALLPROCESSED_EVENT',
                                     N'XE_DISPATCHER_JOIN', N'XE_DISPATCHER_WAIT', N'XE_LIVE_TARGET_TVF',
                                     N'XE_TIMER_EVENT'
                                   )
                  AND waiting_tasks_count > 0)
        INSERT INTO dbo.TopWaits
        (
            CollectionTime,
            WaitType,
            WaitPercentage,
            AvgWaitSec,
            AvgResSec,
            AvgSigSec,
            WaitSec,
            ResourceSec,
            SignalSec,
            WaitCount,
            HelpInfoURL
        )
        SELECT GETDATE(),
               MAX(W1.wait_type),
               CAST(MAX(W1.Percentage) AS DECIMAL(5, 2)),
               CAST((MAX(W1.WaitS) / MAX(W1.WaitCount)) AS DECIMAL(16, 4)),
               CAST((MAX(W1.ResourceS) / MAX(W1.WaitCount)) AS DECIMAL(16, 4)),
               CAST((MAX(W1.SignalS) / MAX(W1.WaitCount)) AS DECIMAL(16, 4)),
               CAST(MAX(W1.WaitS) AS DECIMAL(16, 2)),
               CAST(MAX(W1.ResourceS) AS DECIMAL(16, 2)),
               CAST(MAX(W1.SignalS) AS DECIMAL(16, 2)),
               MAX(W1.WaitCount),
               CAST(N'https://www.sqlskills.com/help/waits/' + W1.wait_type AS XML)
        FROM Waits AS W1
            INNER JOIN Waits AS W2
                ON W2.RowNum <= W1.RowNum
        GROUP BY W1.RowNum,
                 W1.wait_type
        HAVING SUM(W2.Percentage) - MAX(W1.Percentage) < 99 -- percentage threshold
        OPTION (RECOMPILE);
    END;

    -------------------------------------------------------------------------------
    -- Get total buffer usage by database for current instance 
    -- (Query 36) (Total Buffer Usage by Database)
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'TotalBufferUsageByDatabase'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'TotalBufferUsageByDatabase'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'TotalBufferUsageByDatabase'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.TotalBufferUsageByDatabase') IS NULL
        BEGIN
            CREATE TABLE dbo.TotalBufferUsageByDatabase
            (
                CollectionTime DATETIME2(0) NOT NULL,
                BufferPoolRank BIGINT NULL,
                DatabaseName sysname NOT NULL,
                CachedSizeMB DECIMAL(10, 2) NOT NULL,
                BufferPoolPercent DECIMAL(5, 2) NOT NULL
            ) ON [PRIMARY];
        END;

        WITH AggregateBufferPoolUsage
        AS (SELECT DB_NAME(database_id) AS "DatabaseName",
                   CAST(COUNT(*) * 8 / 1024.0 AS DECIMAL(10, 2)) AS "CachedSize"
            FROM sys.dm_os_buffer_descriptors WITH (NOLOCK)
            WHERE database_id <> 32767 -- ResourceDB
            GROUP BY DB_NAME(database_id))
        INSERT INTO dbo.TotalBufferUsageByDatabase
        (
            CollectionTime,
            BufferPoolRank,
            DatabaseName,
            CachedSizeMB,
            BufferPoolPercent
        )
        SELECT GETDATE(),
               ROW_NUMBER() OVER (ORDER BY AggregateBufferPoolUsage.CachedSize DESC) AS "BufferPoolRank",
               AggregateBufferPoolUsage.DatabaseName,
               AggregateBufferPoolUsage.CachedSize,
               CAST(AggregateBufferPoolUsage.CachedSize / SUM(AggregateBufferPoolUsage.CachedSize) OVER () * 100.0 AS DECIMAL(5, 2))
        FROM AggregateBufferPoolUsage
        OPTION (RECOMPILE);
    END;

    -------------------------------------------------------------------------------
    -- SQL and OS Version information for current instance 
    -- (Query 1) (Version Info)
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'VersionInfo'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'VersionInfo'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'VersionInfo'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.VersionInfo') IS NULL
        BEGIN
            CREATE TABLE dbo.VersionInfo
            (
                CollectionTime DATETIME2(0) NOT NULL,
                ServerName NVARCHAR(100) NOT NULL,
                SQLServerAndOSVersionInfo NVARCHAR(MAX) NOT NULL
            ) ON [PRIMARY];
        END;

        INSERT INTO dbo.VersionInfo
        (
            CollectionTime,
            ServerName,
            SQLServerAndOSVersionInfo
        )
        SELECT GETDATE(),
               @@SERVERNAME,
               @@VERSION;
    END;

    -------------------------------------------------------------------------------
    -- Volume info for all LUNS that have database files on the current instance 
    -- (Query 26) (Volume Info)
    -------------------------------------------------------------------------------
    IF (
           (
               @Checks IS NULL
               AND @SkipChecks IS NULL
           )
           OR
           (
               EXISTS
    (
        SELECT 1
        FROM @_Checks
        WHERE [Check] = 'VolumeInfo'
    )
               AND NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'VolumeInfo'
    )
           )
           OR (NOT EXISTS
    (
        SELECT 1
        FROM @_SkipChecks
        WHERE [Check] = 'VolumeInfo'
    )
              )
       )
    BEGIN
        IF OBJECT_ID('dbo.VolumeInfo') IS NULL
        BEGIN
            CREATE TABLE dbo.VolumeInfo
            (
                CollectionTime DATETIME2(0) NOT NULL,
                VolumeMountPoint NVARCHAR(256) NULL,
                FileSystemType NVARCHAR(256) NULL,
                LogicalVolumeName NVARCHAR(256) NULL,
                TotalSizeGB NVARCHAR(256) NULL,
                AvailableSizeGB DECIMAL(18, 2) NOT NULL,
                SpaceFreePercentage DECIMAL(18, 2) NOT NULL,
                SupportsCompression TINYINT NULL,
                IsCompressed TINYINT NULL,
                SupportsSparseFiles TINYINT NULL,
                SupportsAlternateStreams TINYINT NULL
            ) ON [PRIMARY];
        END;

        INSERT INTO dbo.VolumeInfo
        (
            CollectionTime,
            VolumeMountPoint,
            FileSystemType,
            LogicalVolumeName,
            TotalSizeGB,
            AvailableSizeGB,
            SpaceFreePercentage,
            SupportsCompression,
            IsCompressed,
            SupportsSparseFiles,
            SupportsAlternateStreams
        )
        SELECT DISTINCT
               GETDATE(),
               vs.volume_mount_point,
               vs.file_system_type,
               vs.logical_volume_name,
               CONVERT(DECIMAL(18, 2), vs.total_bytes / 1073741824.0),
               CONVERT(DECIMAL(18, 2), vs.available_bytes / 1073741824.0),
               CONVERT(DECIMAL(18, 2), vs.available_bytes * 1. / vs.total_bytes * 100.),
               vs.supports_compression,
               vs.is_compressed,
               vs.supports_sparse_files,
               vs.supports_alternate_streams
        FROM sys.master_files AS f WITH (NOLOCK)
            CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id) AS vs
        OPTION (RECOMPILE);
    END;

END;