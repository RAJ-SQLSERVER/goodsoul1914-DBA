CREATE DATABASE DBA CONTAINMENT = NONE ON PRIMARY (
	NAME = N'DBA',
	FILENAME = N'D:\MSSQL\Data\DBA.mdf',
	SIZE = 1048576KB,
	FILEGROWTH = 262144KB
) LOG ON (
	NAME = N'DBA_log',
	FILENAME = N'D:\MSSQL\Logs\DBA_log.ldf',
	SIZE = 262144KB,
	FILEGROWTH = 65536KB
);

GO

USE DBA;
GO
/****** Object:  Table [dbo].[DefaultTraceEntries]    Script Date: 12-6-2021 14:30:10 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE dbo.DefaultTraceEntries (
    SqlInstance     NVARCHAR(MAX) NULL,
    LoginName       NVARCHAR(MAX) NULL,
    HostName        NVARCHAR(MAX) NULL,
    DatabaseName    NVARCHAR(MAX) NULL,
    ApplicationName NVARCHAR(MAX) NULL,
    StartTime       DATETIME2(7)  NULL,
    TextData        NVARCHAR(MAX) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
GO
/****** Object:  View [dbo].[vwDefaultTrace]    Script Date: 12-6-2021 14:30:10 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE VIEW dbo.vwDefaultTrace
AS
    SELECT StartTime,
           SqlInstance,
           LoginName,
           HostName,
           DatabaseName,
           ApplicationName,
           TextData
    FROM dbo.DefaultTraceEntries
    WHERE (ApplicationName NOT LIKE 'dbatools%')
          AND (ApplicationName NOT LIKE 'oversight')
          AND (ApplicationName NOT LIKE 'Red Gate Software%')
          AND (TextData NOT LIKE '%DBCC %')
          AND (TextData NOT LIKE 'No STATS:%')
          AND (TextData NOT LIKE 'Login failed%')
          AND (TextData NOT LIKE 'dbcc show_stat%')
          AND (TextData NOT LIKE 'RESTORE DATABASE%');
GO
/****** Object:  Table [dbo].[ErrorLogs]    Script Date: 12-6-2021 14:30:10 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE dbo.ErrorLogs (
    ComputerName NVARCHAR(MAX) NULL,
    InstanceName NVARCHAR(MAX) NULL,
    SqlInstance  NVARCHAR(MAX) NULL,
    LogDate      DATETIME2(7)  NULL,
    Source       NVARCHAR(MAX) NULL,
    Text         NVARCHAR(MAX) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
GO
/****** Object:  View [dbo].[vwErrorLogLatest]    Script Date: 12-6-2021 14:30:10 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE VIEW dbo.vwErrorLogLatest
AS
    SELECT SqlInstance,
           Text,
           COUNT (*) AS Count
    FROM dbo.ErrorLogs
    WHERE (Text NOT LIKE 'Login succeeded for %')
          AND (Text NOT LIKE 'Log was backed up%')
          AND (Text NOT LIKE 'Log was restored.%')
          AND (Text NOT LIKE 'BACKUP DATABASE successfully%')
          AND (Text NOT LIKE 'RESTORE DATABASE successfully%')
          AND (Text NOT LIKE 'Database backed up.%')
          AND (Text NOT LIKE 'Database was restored%')
          AND (Text NOT LIKE 'Restore is complete %')
          AND (Text NOT LIKE '%without errors%')
          AND (Text NOT LIKE '%0 errors%')
          AND (Text NOT LIKE 'Starting up database%')
          AND (Text NOT LIKE 'Parallel redo is %')
          AND (Text NOT LIKE 'This instance of SQL Server%')
          AND (Text NOT LIKE 'Error: %, Severity:%')
          AND (Text NOT LIKE 'Setting database option %')
          AND (Text NOT LIKE 'Recovery is writing a checkpoint%')
          AND (Text NOT LIKE 'Process ID % was killed by hostname %')
          AND (Text NOT LIKE 'The database % is marked RESTORING and is in a state that does not allow recovery to be run.')
          AND (Text NOT LIKE '%informational message only%')
          AND (Text NOT LIKE 'I/O is frozen on database%')
          AND (Text NOT LIKE 'I/O was resumed on database%')
          AND (Text NOT LIKE 'The error log has been reinitialized%')
          AND LogDate >= DATEADD (D, -1, GETDATE ())
    GROUP BY SqlInstance,
             Text;
GO
/****** Object:  View [dbo].[vwDefaultTraceLatest]    Script Date: 12-6-2021 14:30:10 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE VIEW dbo.vwDefaultTraceLatest
AS
    SELECT StartTime,
           SqlInstance,
           LoginName,
           HostName,
           DatabaseName,
           ApplicationName,
           TextData
    FROM dbo.DefaultTraceEntries
    WHERE (ApplicationName NOT LIKE 'dbatools%')
          AND (ApplicationName NOT LIKE 'oversight')
          AND (ApplicationName NOT LIKE 'Red Gate Software%')
          AND (TextData NOT LIKE '%DBCC %')
          AND (TextData NOT LIKE 'No STATS:%')
          AND (TextData NOT LIKE 'Login failed%')
          AND (TextData NOT LIKE 'dbcc show_stat%')
          AND (TextData NOT LIKE 'RESTORE DATABASE%')
          AND StartTime >= DATEADD (D, -1, GETDATE ());
GO
/****** Object:  Table [dbo].[DiskSpeedTests]    Script Date: 12-6-2021 14:30:10 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE dbo.DiskSpeedTests (
    CheckDate             DATETIME2(7)   NULL,
    SqlInstance           NVARCHAR(MAX)  NULL,
    [Database]            NVARCHAR(MAX)  NULL,
    SizeGB                DECIMAL(38, 5) NULL,
    FileName              NVARCHAR(MAX)  NULL,
    FileID                SMALLINT       NULL,
    FileType              NVARCHAR(MAX)  NULL,
    DiskLocation          NVARCHAR(MAX)  NULL,
    Reads                 BIGINT         NULL,
    AverageReadStall      INT            NULL,
    ReadPerformance       NVARCHAR(MAX)  NULL,
    Writes                BIGINT         NULL,
    AverageWriteStall     INT            NULL,
    WritePerformance      NVARCHAR(MAX)  NULL,
    [Avg Overall Latency] BIGINT         NULL,
    [Avg Bytes/Read]      BIGINT         NULL,
    [Avg Bytes/Write]     BIGINT         NULL,
    [Avg Bytes/Transfer]  BIGINT         NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
GO
/****** Object:  View [dbo].[vwDiskSpeedTestsLatest]    Script Date: 12-6-2021 14:30:10 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE VIEW dbo.vwDiskSpeedTestsLatest
AS
    SELECT SqlInstance,
           [Database],
           FileName,
           DiskLocation,
           Reads,
           AverageReadStall,
           Writes,
           AverageWriteStall,
           [Avg Overall Latency]
    FROM dbo.DiskSpeedTests
    WHERE CheckDate >= DATEADD (DAY, -1, GETDATE ())
          AND (
              ReadPerformance NOT IN ( 'OK', 'Very Good' )
              OR (WritePerformance NOT IN ( 'OK', 'Very Good' ))
          );
GO
/****** Object:  Table [dbo].[DiskSpace]    Script Date: 12-6-2021 14:30:10 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE dbo.DiskSpace (
    CheckDate    DATETIME2(7)  NULL,
    ComputerName NVARCHAR(MAX) NULL,
    Name         NVARCHAR(MAX) NULL,
    Label        NVARCHAR(MAX) NULL,
    Capacity     BIGINT        NULL,
    Free         BIGINT        NULL,
    PercentFree  FLOAT         NULL,
    BlockSize    INT           NULL,
    FileSystem   NVARCHAR(MAX) NULL,
    Type         NVARCHAR(MAX) NULL,
    IsSqlDisk    NVARCHAR(MAX) NULL,
    Server       NVARCHAR(MAX) NULL,
    DriveType    NVARCHAR(MAX) NULL,
    SizeInBytes  FLOAT         NULL,
    FreeInBytes  FLOAT         NULL,
    SizeInKB     FLOAT         NULL,
    FreeInKB     FLOAT         NULL,
    SizeInMB     FLOAT         NULL,
    FreeInMB     FLOAT         NULL,
    SizeInGB     FLOAT         NULL,
    FreeInGB     FLOAT         NULL,
    SizeInTB     FLOAT         NULL,
    FreeInTB     FLOAT         NULL,
    SizeInPB     FLOAT         NULL,
    FreeInPB     FLOAT         NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
GO
/****** Object:  View [dbo].[vwDiskSpaceLatest]    Script Date: 12-6-2021 14:30:10 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE VIEW dbo.vwDiskSpaceLatest
AS
    SELECT ComputerName,
           Name,
           Label,
           Capacity,
           Free,
           PercentFree,
           BlockSize,
           FileSystem,
           DriveType,
           SizeInBytes,
           FreeInBytes,
           SizeInKB,
           FreeInKB,
           SizeInMB,
           FreeInMB,
           SizeInGB,
           FreeInGB,
           SizeInTB,
           FreeInTB,
           SizeInPB,
           FreeInPB
    FROM DBA.dbo.DiskSpace
    WHERE CheckDate >= DATEADD (D, -1, GETDATE ())
          AND (FreeInGB <= 5 AND PercentFree <= 10)
          AND Label <> 'Page file';
GO
/****** Object:  Table [dbo].[SqlInstances]    Script Date: 12-6-2021 14:30:10 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE dbo.SqlInstances (
    Timestamp      DATETIME2(7) NULL,
    ComputerName   VARCHAR(255) NULL,
    SqlInstance    VARCHAR(255) NULL,
    SqlEdition     VARCHAR(255) NULL,
    SqlVersion     VARCHAR(255) NULL,
    ProcessorInfo  VARCHAR(50)  NULL,
    PhysicalMemory VARCHAR(50)  NULL,
    Scan           BIT          NULL,
    Owner          VARCHAR(255) NULL
) ON [PRIMARY];
GO
/****** Object:  View [dbo].[vwSqlInstances]    Script Date: 12-6-2021 14:30:10 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE VIEW dbo.vwSqlInstances
AS
    SELECT SqlInstance,
           SqlEdition,
           SqlVersion,
           ProcessorInfo,
           PhysicalMemory,
           Scan,
           Owner,
           CONVERT (NVARCHAR(30), Timestamp, 120) AS UpdatedAt
    FROM dbo.SqlInstances;
GO
/****** Object:  Table [dbo].[ServerLogins]    Script Date: 12-6-2021 14:30:10 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE dbo.ServerLogins (
    CheckDate                 DATETIME2(7)   NULL,
    ComputerName              NVARCHAR(MAX)  NULL,
    InstanceName              NVARCHAR(MAX)  NULL,
    SqlInstance               NVARCHAR(MAX)  NULL,
    LastLogin                 NVARCHAR(MAX)  NULL,
    AsymmetricKey             NVARCHAR(MAX)  NULL,
    Certificate               NVARCHAR(MAX)  NULL,
    CreateDate                DATETIME2(7)   NULL,
    Credential                NVARCHAR(MAX)  NULL,
    DateLastModified          DATETIME2(7)   NULL,
    DefaultDatabase           NVARCHAR(MAX)  NULL,
    DenyWindowsLogin          BIT            NULL,
    HasAccess                 BIT            NULL,
    ID                        INT            NULL,
    IsDisabled                BIT            NULL,
    IsLocked                  BIT            NULL,
    IsPasswordExpired         BIT            NULL,
    IsSystemObject            BIT            NULL,
    LoginType                 NVARCHAR(MAX)  NULL,
    MustChangePassword        BIT            NULL,
    PasswordExpirationEnabled BIT            NULL,
    PasswordHashAlgorithm     NVARCHAR(MAX)  NULL,
    PasswordPolicyEnforced    BIT            NULL,
    Sid                       VARBINARY(MAX) NULL,
    WindowsLoginAccessType    NVARCHAR(MAX)  NULL,
    Name                      NVARCHAR(MAX)  NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
GO
/****** Object:  View [dbo].[vwServerLoginsLatest]    Script Date: 12-6-2021 14:30:10 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE VIEW dbo.vwServerLoginsLatest
AS
    SELECT SqlInstance,
           Name,
           LoginType,
           LastLogin,
           CreateDate,
           DateLastModified,
           DefaultDatabase,
           DenyWindowsLogin,
           HasAccess,
           IsDisabled,
           IsLocked,
           IsPasswordExpired,
           IsSystemObject,
           MustChangePassword,
           PasswordExpirationEnabled,
           PasswordPolicyEnforced,
           WindowsLoginAccessType
    FROM DBA.dbo.ServerLogins
    WHERE Name NOT LIKE 'NT %'
          AND Name NOT LIKE '##%'
          AND CheckDate >= DATEADD (DAY, -1, GETDATE ());
GO
/****** Object:  Table [dbo].[DatabaseRoleMembers]    Script Date: 12-6-2021 14:30:10 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE dbo.DatabaseRoleMembers (
    CheckDate      DATETIME2(7)  NULL,
    ComputerName   NVARCHAR(MAX) NULL,
    InstanceName   NVARCHAR(MAX) NULL,
    SqlInstance    NVARCHAR(MAX) NULL,
    [Database]     NVARCHAR(MAX) NULL,
    Role           NVARCHAR(MAX) NULL,
    UserName       NVARCHAR(MAX) NULL,
    Login          NVARCHAR(MAX) NULL,
    IsSystemObject BIT           NULL,
    LoginType      NVARCHAR(MAX) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
GO
/****** Object:  View [dbo].[vwDatabaseRoleMembersLatest]    Script Date: 12-6-2021 14:30:10 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE VIEW dbo.vwDatabaseRoleMembersLatest
AS
    SELECT CheckDate,
           SqlInstance,
           [Database],
           Role,
           UserName,
           Login,
           LoginType
    FROM DBA.dbo.DatabaseRoleMembers
    WHERE CheckDate >= DATEADD (DAY, -1, GETDATE ())
          AND UserName NOT LIKE '##%'
          AND UserName <> 'MS_DataCollectorInternalUser'
          AND UserName <> 'AllSchemaOwner';
GO
/****** Object:  Table [dbo].[ServerRoleMembers]    Script Date: 12-6-2021 14:30:10 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE dbo.ServerRoleMembers (
    CheckDate    DATETIME2(7)  NULL,
    ComputerName NVARCHAR(MAX) NULL,
    InstanceName NVARCHAR(MAX) NULL,
    SqlInstance  NVARCHAR(MAX) NULL,
    [Database]   NVARCHAR(MAX) NULL,
    Role         NVARCHAR(MAX) NULL,
    Name         NVARCHAR(MAX) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
GO
/****** Object:  View [dbo].[vwServerRoleMembersLatest]    Script Date: 12-6-2021 14:30:10 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE VIEW dbo.vwServerRoleMembersLatest
AS
    SELECT CheckDate,
           SqlInstance,
           Role,
           Name
    FROM dbo.ServerRoleMembers
    WHERE (CheckDate >= DATEADD (DAY, -1, GETDATE ()));
GO
/****** Object:  Table [dbo].[Databases]    Script Date: 12-6-2021 14:30:10 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE dbo.Databases (
    CheckDate               DATETIME2(7)  NULL,
    SqlInstance             NVARCHAR(MAX) NULL,
    Name                    NVARCHAR(MAX) NULL,
    SizeMB                  FLOAT         NULL,
    Compatibility           NVARCHAR(MAX) NULL,
    LastFullBackup          DATETIME2(7)  NULL,
    LastDiffBackup          DATETIME2(7)  NULL,
    LastLogBackup           DATETIME2(7)  NULL,
    ActiveConnections       INT           NULL,
    Collation               NVARCHAR(MAX) NULL,
    ContainmentType         NVARCHAR(MAX) NULL,
    CreateDate              DATETIME2(7)  NULL,
    DataSpaceUsage          FLOAT         NULL,
    FilestreamDirectoryName NVARCHAR(MAX) NULL,
    IndexSpaceUsage         FLOAT         NULL,
    LogReuseWaitStatus      NVARCHAR(MAX) NULL,
    PageVerify              NVARCHAR(MAX) NULL,
    PrimaryFilePath         NVARCHAR(MAX) NULL,
    ReadOnly                BIT           NULL,
    RecoveryModel           NVARCHAR(MAX) NULL,
    Size                    FLOAT         NULL,
    SnapshotIsolationState  NVARCHAR(MAX) NULL,
    SpaceAvailable          FLOAT         NULL,
    MaxDop                  INT           NULL,
    ServerVersion           NVARCHAR(MAX) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
GO
/****** Object:  View [dbo].[vwDatabasesLatest]    Script Date: 12-6-2021 14:30:10 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE VIEW dbo.vwDatabasesLatest
AS
    SELECT SqlInstance,
           Name,
           SizeMB,
           DataSpaceUsage / 1024 AS DataSpaceUsageMB,
           IndexSpaceUsage / 1024 AS IndexSpaceUsageMB,
           SpaceAvailable / 1024 AS SpaceAvailableMB,
           LogReuseWaitStatus,
           LastFullBackup,
           LastDiffBackup,
           LastLogBackup,
           RecoveryModel,
           SnapshotIsolationState,
           ActiveConnections,
           Collation,
           ContainmentType,
           CreateDate,
           FilestreamDirectoryName,
           PageVerify,
           PrimaryFilePath,
           ReadOnly,
           MaxDop,
           ServerVersion
    FROM dbo.Databases
    WHERE (CheckDate >= DATEADD (DAY, -1, GETDATE ()));
GO
/****** Object:  Table [dbo].[DatabaseSpace]    Script Date: 12-6-2021 14:30:10 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE dbo.DatabaseSpace (
    CheckDate          DATETIME2(7)  NULL,
    ComputerName       NVARCHAR(MAX) NULL,
    InstanceName       NVARCHAR(MAX) NULL,
    SqlInstance        NVARCHAR(MAX) NULL,
    [Database]         NVARCHAR(MAX) NULL,
    FileName           NVARCHAR(MAX) NULL,
    FileGroup          NVARCHAR(MAX) NULL,
    PhysicalName       NVARCHAR(MAX) NULL,
    FileType           NVARCHAR(MAX) NULL,
    UsedSpace          BIGINT        NULL,
    FreeSpace          BIGINT        NULL,
    FileSize           BIGINT        NULL,
    PercentUsed        FLOAT         NULL,
    AutoGrowth         BIGINT        NULL,
    AutoGrowType       NVARCHAR(MAX) NULL,
    SpaceUntilMaxSize  BIGINT        NULL,
    AutoGrowthPossible BIGINT        NULL,
    UnusableSpace      BIGINT        NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
GO
/****** Object:  View [dbo].[vwDatabaseSpaceLatest]    Script Date: 12-6-2021 14:30:10 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE VIEW dbo.vwDatabaseSpaceLatest
AS
    SELECT SqlInstance,
           [Database],
           FileName,
           FileGroup,
           PhysicalName,
           FileType,
           FileSize / 1024 AS FileSizeKB,
           UsedSpace / 1024 AS UsedSpaceKB,
           FreeSpace / 1024 AS FreeSpaceKB,
           PercentUsed,
           AutoGrowth,
           AutoGrowType
    FROM dbo.DatabaseSpace
    WHERE (CheckDate >= DATEADD (DAY, -1, GETDATE ()));
GO
/****** Object:  View [dbo].[vwNoRecentFullBackup]    Script Date: 12-6-2021 14:30:10 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE VIEW dbo.vwNoRecentFullBackup
AS
    SELECT SqlInstance,
           Name,
           LastFullBackup
    FROM dbo.Databases
    WHERE CheckDate >= DATEADD (DAY, -1, GETDATE ())
          AND (LastFullBackup <= DATEADD (DAY, -2, GETDATE ()))
          AND (SqlInstance LIKE 'GP%')
          AND (SqlInstance NOT IN ( 'GPWOSQL02', 'GPPIICIXSQL01', 'GPMVISION01', 'GPAX4HSQL01', 'GPAX4HHIS01' ))
          AND (Name NOT IN ( 'tempdb', 'model' ));
GO
/****** Object:  View [dbo].[vwNoRecentLogBackup]    Script Date: 12-6-2021 14:30:10 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE VIEW dbo.vwNoRecentLogBackup
AS
    SELECT SqlInstance,
           Name,
           LastLogBackup
    FROM dbo.Databases
    WHERE CheckDate >= DATEADD (DAY, -1, GETDATE ())
          AND (LastLogBackup <= DATEADD (DAY, -2, GETDATE ()))
          AND RecoveryModel <> 'Simple'
          AND (SqlInstance LIKE 'GP%')
          AND (SqlInstance NOT IN ( 'GPWOSQL02', 'GPPIICIXSQL01', 'GPMVISION01', 'GPAX4HSQL01', 'GPAX4HHIS01' ))
          AND (Name NOT IN ( 'tempdb', 'model' ));

GO
/****** Object:  Table [dbo].[CPURingBuffers]    Script Date: 12-6-2021 14:30:10 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE dbo.CPURingBuffers (
    ComputerName            NVARCHAR(MAX) NULL,
    InstanceName            NVARCHAR(MAX) NULL,
    SqlInstance             NVARCHAR(MAX) NULL,
    RecordId                INT           NULL,
    EventTime               DATETIME2(7)  NULL,
    SQLProcessUtilization   INT           NULL,
    OtherProcessUtilization INT           NULL,
    SystemIdle              INT           NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
GO
/****** Object:  View [dbo].[vwHighCPUUtilizationLatestGrouped]    Script Date: 12-6-2021 14:30:10 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE VIEW dbo.vwHighCPUUtilizationLatestGrouped
AS
    SELECT SqlInstance,
           COUNT (*) AS Count
    FROM dbo.CPURingBuffers
    WHERE (SQLProcessUtilization > 80)
          AND (EventTime >= DATEADD (D, -1, GETDATE ()))
    GROUP BY SqlInstance;
GO
/****** Object:  View [dbo].[vwNewServerLoginsLatest]    Script Date: 12-6-2021 14:30:10 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE VIEW dbo.vwNewServerLoginsLatest
AS
    SELECT SqlInstance,
           Name,
           LoginType AS Type,
           DefaultDatabase,
           DenyWindowsLogin,
           IsDisabled,
           IsLocked,
           IsPasswordExpired,
           MustChangePassword,
           PasswordExpirationEnabled,
           PasswordPolicyEnforced
    FROM dbo.vwServerLoginsLatest
    WHERE (CreateDate >= DATEADD (DAY, -1, GETDATE ()));
GO
/****** Object:  Table [dbo].[FailedJobHistory]    Script Date: 12-6-2021 14:30:10 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE dbo.FailedJobHistory (
    InstanceID       INT              NULL,
    SqlMessageID     INT              NULL,
    Message          NVARCHAR(MAX)    NULL,
    StepID           INT              NULL,
    StepName         NVARCHAR(MAX)    NULL,
    SqlSeverity      INT              NULL,
    JobID            UNIQUEIDENTIFIER NULL,
    JobName          NVARCHAR(MAX)    NULL,
    RunStatus        INT              NULL,
    RunDate          DATETIME2(7)     NULL,
    RunDuration      INT              NULL,
    OperatorEmailed  NVARCHAR(MAX)    NULL,
    OperatorNetsent  NVARCHAR(MAX)    NULL,
    OperatorPaged    NVARCHAR(MAX)    NULL,
    RetriesAttempted INT              NULL,
    Server           NVARCHAR(MAX)    NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
GO
/****** Object:  View [dbo].[vwFailedAgentJobsLatest]    Script Date: 12-6-2021 14:30:10 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE VIEW dbo.vwFailedAgentJobsLatest
AS
    SELECT Server,
           RunDate,
           JobName,
           StepID,
           StepName,
           RunDuration,
           SqlMessageID,
           SqlSeverity,
           Message,
           OperatorEmailed
    FROM dbo.FailedJobHistory
    WHERE (RunDate >= DATEADD (DAY, -1, GETDATE ()))
          AND (StepName <> '(Job outcome)');
GO
/****** Object:  View [dbo].[vwHighCPUUtilization]    Script Date: 12-6-2021 14:30:10 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE VIEW dbo.vwHighCPUUtilization
AS
    SELECT SqlInstance,
           RecordId,
           EventTime,
           SQLProcessUtilization,
           OtherProcessUtilization,
           SystemIdle
    FROM dbo.CPURingBuffers
    WHERE (SQLProcessUtilization > 80);
GO
/****** Object:  View [dbo].[vwAllScannedSqlInstances]    Script Date: 12-6-2021 14:30:10 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE VIEW dbo.vwAllScannedSqlInstances
AS
    SELECT SqlInstance FROM DBA.dbo.SqlInstances WHERE Scan = 1;
GO
/****** Object:  Table [dbo].[LastBackupTests]    Script Date: 12-6-2021 14:30:10 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE dbo.LastBackupTests (
    SourceServer   NVARCHAR(MAX) NULL,
    TestServer     NVARCHAR(MAX) NULL,
    [Database]     NVARCHAR(MAX) NULL,
    FileExists     BIT           NULL,
    Size           BIGINT        NULL,
    RestoreResult  NVARCHAR(MAX) NULL,
    DbccResult     NVARCHAR(MAX) NULL,
    RestoreStart   NVARCHAR(MAX) NULL,
    RestoreEnd     NVARCHAR(MAX) NULL,
    RestoreElapsed NVARCHAR(MAX) NULL,
    DbccMaxDop     INT           NULL,
    DbccStart      NVARCHAR(MAX) NULL,
    DbccEnd        NVARCHAR(MAX) NULL,
    DbccElapsed    NVARCHAR(MAX) NULL,
    BackupDates    NVARCHAR(MAX) NULL,
    BackupFiles    NVARCHAR(MAX) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
GO
/****** Object:  Table [dbo].[SqlAudit]    Script Date: 12-6-2021 14:30:10 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE dbo.SqlAudit (
    event_time                     DATETIME2(7)  NULL,
    sequence_number                INT           NULL,
    action_id                      VARCHAR(4)    NULL,
    succeeded                      BIT           NOT NULL,
    permission_bitmask             BIGINT        NOT NULL,
    is_column_permission           BIT           NOT NULL,
    session_id                     SMALLINT      NOT NULL,
    server_principal_id            INT           NULL,
    database_principal_id          INT           NULL,
    target_server_principal_id     INT           NULL,
    target_database_principal_id   INT           NULL,
    object_id                      BIGINT        NULL,
    class_type                     VARCHAR(10)   NULL,
    session_server_principal_name  NVARCHAR(100) NULL,
    server_principal_name          NVARCHAR(100) NULL,
    server_principal_sid           NVARCHAR(100) NULL,
    database_principal_name        NVARCHAR(100) NULL,
    target_server_principal_name   NVARCHAR(100) NULL,
    target_server_principal_sid    NVARCHAR(100) NULL,
    target_database_principal_name NVARCHAR(100) NULL,
    server_instance_name           NVARCHAR(100) NULL,
    database_name                  NVARCHAR(100) NULL,
    schema_name                    NVARCHAR(100) NULL,
    object_name                    NVARCHAR(100) NULL,
    statement                      NVARCHAR(MAX) NULL,
    additional_information         NVARCHAR(500) NULL,
    file_name                      NVARCHAR(500) NULL,
    audit_file_offset              BIGINT        NULL,
    user_defined_event_id          INT           NULL,
    user_defined_information       NVARCHAR(100) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
GO
ALTER TABLE dbo.DatabaseRoleMembers
ADD CONSTRAINT DF_DatabaseRoleMembers_CheckDate
    DEFAULT (GETDATE ()) FOR CheckDate;
GO
ALTER TABLE dbo.Databases
ADD CONSTRAINT DF_Databases_CheckDate_1
    DEFAULT (GETDATE ()) FOR CheckDate;
GO
ALTER TABLE dbo.DatabaseSpace
ADD CONSTRAINT DF_DatabaseSpace_CheckDate
    DEFAULT (GETDATE ()) FOR CheckDate;
GO
ALTER TABLE dbo.DiskSpace
ADD CONSTRAINT DF_DiskSpace_CheckDate
    DEFAULT (GETDATE ()) FOR CheckDate;
GO
ALTER TABLE dbo.DiskSpeedTests
ADD CONSTRAINT DF_DiskSpeedTests_CheckDate
    DEFAULT (GETDATE ()) FOR CheckDate;
GO
ALTER TABLE dbo.ServerLogins
ADD CONSTRAINT DF_ServerLogins_CheckDate
    DEFAULT (GETDATE ()) FOR CheckDate;
GO
ALTER TABLE dbo.ServerRoleMembers
ADD CONSTRAINT DF_ServerRoleMembers_CheckDate
    DEFAULT (GETDATE ()) FOR CheckDate;
GO
ALTER TABLE dbo.SqlInstances
ADD CONSTRAINT DF_SqlInstances_Timestamp
    DEFAULT (GETDATE ()) FOR Timestamp;
GO
EXEC sys.sp_addextendedproperty @name = N'MS_DiagramPane1',
                                @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Databases"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 400
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
',
                                @level0type = N'SCHEMA',
                                @level0name = N'dbo',
                                @level1type = N'VIEW',
                                @level1name = N'vwDatabasesLatest';
GO
EXEC sys.sp_addextendedproperty @name = N'MS_DiagramPaneCount',
                                @value = 1,
                                @level0type = N'SCHEMA',
                                @level0name = N'dbo',
                                @level1type = N'VIEW',
                                @level1name = N'vwDatabasesLatest';
GO
EXEC sys.sp_addextendedproperty @name = N'MS_DiagramPane1',
                                @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "DatabaseSpace"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 235
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
',
                                @level0type = N'SCHEMA',
                                @level0name = N'dbo',
                                @level1type = N'VIEW',
                                @level1name = N'vwDatabaseSpaceLatest';
GO
EXEC sys.sp_addextendedproperty @name = N'MS_DiagramPaneCount',
                                @value = 1,
                                @level0type = N'SCHEMA',
                                @level0name = N'dbo',
                                @level1type = N'VIEW',
                                @level1name = N'vwDatabaseSpaceLatest';
GO
EXEC sys.sp_addextendedproperty @name = N'MS_DiagramPane1',
                                @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "DefaultTraceEntries"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 220
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
',
                                @level0type = N'SCHEMA',
                                @level0name = N'dbo',
                                @level1type = N'VIEW',
                                @level1name = N'vwDefaultTrace';
GO
EXEC sys.sp_addextendedproperty @name = N'MS_DiagramPaneCount',
                                @value = 1,
                                @level0type = N'SCHEMA',
                                @level0name = N'dbo',
                                @level1type = N'VIEW',
                                @level1name = N'vwDefaultTrace';
GO
EXEC sys.sp_addextendedproperty @name = N'MS_DiagramPane1',
                                @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "FailedJobHistory"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 219
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
',
                                @level0type = N'SCHEMA',
                                @level0name = N'dbo',
                                @level1type = N'VIEW',
                                @level1name = N'vwFailedAgentJobsLatest';
GO
EXEC sys.sp_addextendedproperty @name = N'MS_DiagramPaneCount',
                                @value = 1,
                                @level0type = N'SCHEMA',
                                @level0name = N'dbo',
                                @level1type = N'VIEW',
                                @level1name = N'vwFailedAgentJobsLatest';
GO
EXEC sys.sp_addextendedproperty @name = N'MS_DiagramPane1',
                                @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "CPURingBuffers"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 250
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
',
                                @level0type = N'SCHEMA',
                                @level0name = N'dbo',
                                @level1type = N'VIEW',
                                @level1name = N'vwHighCPUUtilization';
GO
EXEC sys.sp_addextendedproperty @name = N'MS_DiagramPaneCount',
                                @value = 1,
                                @level0type = N'SCHEMA',
                                @level0name = N'dbo',
                                @level1type = N'VIEW',
                                @level1name = N'vwHighCPUUtilization';
GO
EXEC sys.sp_addextendedproperty @name = N'MS_DiagramPane1',
                                @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "vwServerLoginsLatest"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 271
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
',
                                @level0type = N'SCHEMA',
                                @level0name = N'dbo',
                                @level1type = N'VIEW',
                                @level1name = N'vwNewServerLoginsLatest';
GO
EXEC sys.sp_addextendedproperty @name = N'MS_DiagramPaneCount',
                                @value = 1,
                                @level0type = N'SCHEMA',
                                @level0name = N'dbo',
                                @level1type = N'VIEW',
                                @level1name = N'vwNewServerLoginsLatest';
GO
EXEC sys.sp_addextendedproperty @name = N'MS_DiagramPane1',
                                @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "SqlInstances"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 263
               Right = 215
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
',
                                @level0type = N'SCHEMA',
                                @level0name = N'dbo',
                                @level1type = N'VIEW',
                                @level1name = N'vwSqlInstances';
GO
EXEC sys.sp_addextendedproperty @name = N'MS_DiagramPaneCount',
                                @value = 1,
                                @level0type = N'SCHEMA',
                                @level0name = N'dbo',
                                @level1type = N'VIEW',
                                @level1name = N'vwSqlInstances';
GO
