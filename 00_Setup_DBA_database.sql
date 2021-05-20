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

USE [DBA]
GO
	/****** Object:  Table [dbo].[DiskSpeedTests]    Script Date: 11-5-2021 14:35:35 ******/
SET
	ANSI_NULLS ON
GO
SET
	QUOTED_IDENTIFIER ON
GO
	CREATE TABLE [dbo].[DiskSpeedTests] (
		[CheckDate] [datetime2](7) NULL,
		[SqlInstance] [nvarchar](max) NULL,
		[Database] [nvarchar](max) NULL,
		[SizeGB] [decimal](38, 5) NULL,
		[FileName] [nvarchar](max) NULL,
		[FileID] [smallint] NULL,
		[FileType] [nvarchar](max) NULL,
		[DiskLocation] [nvarchar](max) NULL,
		[Reads] [bigint] NULL,
		[AverageReadStall] [int] NULL,
		[ReadPerformance] [nvarchar](max) NULL,
		[Writes] [bigint] NULL,
		[AverageWriteStall] [int] NULL,
		[WritePerformance] [nvarchar](max) NULL,
		[Avg Overall Latency] [bigint] NULL,
		[Avg Bytes/Read] [bigint] NULL,
		[Avg Bytes/Write] [bigint] NULL,
		[Avg Bytes/Transfer] [bigint] NULL
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
	/****** Object:  View [dbo].[vwDiskSpeedTestsLatest]    Script Date: 11-5-2021 14:35:35 ******/
SET
	ANSI_NULLS ON
GO
SET
	QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwDiskSpeedTestsLatest] AS
SELECT
	SqlInstance,
	[Database],
	SizeGB,
	FileName,
	DiskLocation,
	Reads,
	AverageReadStall,
	ReadPerformance,
	Writes,
	AverageWriteStall,
	WritePerformance,
	[Avg Overall Latency],
	[Avg Bytes/Read],
	[Avg Bytes/Write],
	[Avg Bytes/Transfer]
FROM
	DBA.dbo.DiskSpeedTests
WHERE
	CheckDate >= GETDATE () - 1
GO
	/****** Object:  Table [dbo].[FailedJobHistory]    Script Date: 11-5-2021 14:35:35 ******/
SET
	ANSI_NULLS ON
GO
SET
	QUOTED_IDENTIFIER ON
GO
	CREATE TABLE [dbo].[FailedJobHistory] (
		[InstanceID] [int] NULL,
		[SqlMessageID] [int] NULL,
		[Message] [nvarchar](max) NULL,
		[StepID] [int] NULL,
		[StepName] [nvarchar](max) NULL,
		[SqlSeverity] [int] NULL,
		[JobID] [uniqueidentifier] NULL,
		[JobName] [nvarchar](max) NULL,
		[RunStatus] [int] NULL,
		[RunDate] [datetime2](7) NULL,
		[RunDuration] [int] NULL,
		[OperatorEmailed] [nvarchar](max) NULL,
		[OperatorNetsent] [nvarchar](max) NULL,
		[OperatorPaged] [nvarchar](max) NULL,
		[RetriesAttempted] [int] NULL,
		[Server] [nvarchar](max) NULL
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
	/****** Object:  View [dbo].[vwFailedAgentJobsLatest]    Script Date: 11-5-2021 14:35:35 ******/
SET
	ANSI_NULLS ON
GO
SET
	QUOTED_IDENTIFIER ON
GO
	CREATE VIEW [dbo].[vwFailedAgentJobsLatest] AS
SELECT
	Server,
	RunDate,
	JobName,
	StepID,
	StepName,
	RunDuration,
	SqlMessageID,
	SqlSeverity,
	Message,
	OperatorEmailed
FROM
	dbo.FailedJobHistory
WHERE
	(RunDate >= DATEADD(DAY, - 1, GETDATE()))
	AND (StepName <> '(Job outcome)')
GO
	/****** Object:  Table [dbo].[ErrorLogs]    Script Date: 11-5-2021 14:35:35 ******/
SET
	ANSI_NULLS ON
GO
SET
	QUOTED_IDENTIFIER ON
GO
	CREATE TABLE [dbo].[ErrorLogs] (
		[ComputerName] [nvarchar](max) NULL,
		[InstanceName] [nvarchar](max) NULL,
		[SqlInstance] [nvarchar](max) NULL,
		[LogDate] [datetime2](7) NULL,
		[Source] [nvarchar](max) NULL,
		[Text] [nvarchar](max) NULL
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
	/****** Object:  View [dbo].[vwErrorLogs]    Script Date: 11-5-2021 14:35:35 ******/
SET
	ANSI_NULLS ON
GO
SET
	QUOTED_IDENTIFIER ON
GO
	CREATE VIEW [dbo].[vwErrorLogs] AS
SELECT
	SqlInstance,
	LogDate,
	Source,
	Text
FROM
	dbo.ErrorLogs
WHERE
	(Text NOT LIKE 'Login succeeded for %')
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
	AND (
		Text NOT LIKE 'Recovery is writing a checkpoint%'
	)
	AND (
		Text NOT LIKE 'Process ID % was killed by hostname %'
	)
	AND (
		Text NOT LIKE 'The database % is marked RESTORING and is in a state that does not allow recovery to be run.'
	)
	AND (Text NOT LIKE '%informational message only%')
	AND (Text NOT LIKE 'I/O is frozen on database%')
	AND (Text NOT LIKE 'I/O was resumed on database%')
	AND (
		Text NOT LIKE 'The error log has been reinitialized%'
	)
GO
	/****** Object:  Table [dbo].[CPURingBuffers]    Script Date: 11-5-2021 14:35:35 ******/
SET
	ANSI_NULLS ON
GO
SET
	QUOTED_IDENTIFIER ON
GO
	CREATE TABLE [dbo].[CPURingBuffers] (
		[ComputerName] [nvarchar](max) NULL,
		[InstanceName] [nvarchar](max) NULL,
		[SqlInstance] [nvarchar](max) NULL,
		[RecordId] [int] NULL,
		[EventTime] [datetime2](7) NULL,
		[SQLProcessUtilization] [int] NULL,
		[OtherProcessUtilization] [int] NULL,
		[SystemIdle] [int] NULL
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
	/****** Object:  View [dbo].[vwHighCPUUtilization]    Script Date: 11-5-2021 14:35:35 ******/
SET
	ANSI_NULLS ON
GO
SET
	QUOTED_IDENTIFIER ON
GO
	CREATE VIEW [dbo].[vwHighCPUUtilization] AS
SELECT
	SqlInstance,
	RecordId,
	EventTime,
	SQLProcessUtilization,
	OtherProcessUtilization,
	SystemIdle
FROM
	DBA.dbo.CPURingBuffers
WHERE
	SQLProcessUtilization > 50
GO
	/****** Object:  View [dbo].[vwRecentIOBottlenecks]    Script Date: 11-5-2021 14:35:35 ******/
SET
	ANSI_NULLS ON
GO
SET
	QUOTED_IDENTIFIER ON
GO
	CREATE VIEW [dbo].[vwRecentIOBottlenecks] AS
SELECT
	CheckDate,
	SqlInstance,
	[Database],
	SizeGB,
	FileName,
	FileID,
	DiskLocation,
	Reads,
	AverageReadStall,
	ReadPerformance,
	Writes,
	AverageWriteStall,
	WritePerformance,
	[Avg Overall Latency],
	[Avg Bytes/Read],
	[Avg Bytes/Write],
	[Avg Bytes/Transfer]
FROM
	DBA.dbo.DiskSpeedTests
WHERE
	ReadPerformance NOT IN ('OK', 'Very Good')
	OR WritePerformance NOT IN ('OK', 'Very Good')
	AND CheckDate >= DATEADD(DAY, -1, GETDATE())
GO
	/****** Object:  View [dbo].[vwAllScannedSqlInstances]    Script Date: 11-5-2021 14:35:35 ******/
SET
	ANSI_NULLS ON
GO
SET
	QUOTED_IDENTIFIER ON
GO
	CREATE VIEW [dbo].[vwAllScannedSqlInstances] AS
SELECT
	SqlInstance
FROM
	DBA.dbo.SqlInstances
WHERE
	Scan = 1;

GO
	/****** Object:  Table [dbo].[Certificates]    Script Date: 11-5-2021 14:35:35 ******/
SET
	ANSI_NULLS ON
GO
SET
	QUOTED_IDENTIFIER ON
GO
	CREATE TABLE [dbo].[Certificates] (
		[PSComputerName] [nvarchar](max) NULL,
		[DnsNameList] [nvarchar](max) NULL,
		[NotAfter] [datetime2](7) NULL,
		[NotBefore] [datetime2](7) NULL,
		[HasPrivateKey] [bit] NULL,
		[SerialNumber] [nvarchar](max) NULL,
		[Version] [int] NULL,
		[Issuer] [nvarchar](max) NULL,
		[Subject] [nvarchar](max) NULL
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
	/****** Object:  Table [dbo].[Databases]    Script Date: 11-5-2021 14:35:35 ******/
SET
	ANSI_NULLS ON
GO
SET
	QUOTED_IDENTIFIER ON
GO
	CREATE TABLE [dbo].[Databases] (
		[CheckDate] [datetime] NOT NULL,
		[BackupStatus] [nvarchar](max) NULL,
		[ComputerName] [nvarchar](max) NULL,
		[InstanceName] [nvarchar](max) NULL,
		[SqlInstance] [nvarchar](max) NULL,
		[LastRead] [nvarchar](max) NULL,
		[LastWrite] [nvarchar](max) NULL,
		[SizeMB] [float] NULL,
		[Compatibility] [nvarchar](max) NULL,
		[LastFullBackup] [datetime2](7) NULL,
		[LastDiffBackup] [datetime2](7) NULL,
		[LastLogBackup] [datetime2](7) NULL,
		[Parent] [nvarchar](max) NULL,
		[ActiveConnections] [int] NULL,
		[AnsiNullDefault] [bit] NULL,
		[AnsiNullsEnabled] [bit] NULL,
		[AnsiPaddingEnabled] [bit] NULL,
		[AnsiWarningsEnabled] [bit] NULL,
		[ArithmeticAbortEnabled] [bit] NULL,
		[AutoClose] [bit] NULL,
		[AutoCreateIncrementalStatisticsEnabled] [bit] NULL,
		[AutoCreateStatisticsEnabled] [bit] NULL,
		[AutoShrink] [bit] NULL,
		[AutoUpdateStatisticsAsync] [bit] NULL,
		[AutoUpdateStatisticsEnabled] [bit] NULL,
		[AvailabilityDatabaseSynchronizationState] [nvarchar](max) NULL,
		[AvailabilityGroupName] [nvarchar](max) NULL,
		[BrokerEnabled] [bit] NULL,
		[CaseSensitive] [bit] NULL,
		[ChangeTrackingAutoCleanUp] [bit] NULL,
		[ChangeTrackingEnabled] [bit] NULL,
		[ChangeTrackingRetentionPeriod] [int] NULL,
		[ChangeTrackingRetentionPeriodUnits] [nvarchar](max) NULL,
		[CloseCursorsOnCommitEnabled] [bit] NULL,
		[Collation] [nvarchar](max) NULL,
		[CompatibilityLevel] [nvarchar](max) NULL,
		[ConcatenateNullYieldsNull] [bit] NULL,
		[ContainmentType] [nvarchar](max) NULL,
		[CreateDate] [datetime2](7) NULL,
		[DatabaseGuid] [uniqueidentifier] NULL,
		[DatabaseSnapshotBaseName] [nvarchar](max) NULL,
		[DataSpaceUsage] [float] NULL,
		[DateCorrelationOptimization] [bit] NULL,
		[DboLogin] [bit] NULL,
		[DefaultFileGroup] [nvarchar](max) NULL,
		[DefaultFileStreamFileGroup] [nvarchar](max) NULL,
		[DefaultFullTextCatalog] [nvarchar](max) NULL,
		[DefaultSchema] [nvarchar](max) NULL,
		[DelayedDurability] [nvarchar](max) NULL,
		[EncryptionEnabled] [bit] NULL,
		[FilestreamDirectoryName] [nvarchar](max) NULL,
		[FilestreamNonTransactedAccess] [nvarchar](max) NULL,
		[HasFileInCloud] [bit] NULL,
		[HasMemoryOptimizedObjects] [bit] NULL,
		[HonorBrokerPriority] [bit] NULL,
		[ID] [int] NULL,
		[IndexSpaceUsage] [float] NULL,
		[IsAccessible] [bit] NULL,
		[IsDatabaseSnapshot] [bit] NULL,
		[IsDatabaseSnapshotBase] [bit] NULL,
		[IsDbAccessAdmin] [bit] NULL,
		[IsDbBackupOperator] [bit] NULL,
		[IsDbDatareader] [bit] NULL,
		[IsDbDatawriter] [bit] NULL,
		[IsDbDdlAdmin] [bit] NULL,
		[IsDbDenyDatareader] [bit] NULL,
		[IsDbDenyDatawriter] [bit] NULL,
		[IsDbOwner] [bit] NULL,
		[IsDbSecurityAdmin] [bit] NULL,
		[IsFullTextEnabled] [bit] NULL,
		[IsMailHost] [bit] NULL,
		[IsManagementDataWarehouse] [bit] NULL,
		[IsMirroringEnabled] [bit] NULL,
		[IsParameterizationForced] [bit] NULL,
		[IsReadCommittedSnapshotOn] [bit] NULL,
		[IsSqlDw] [bit] NULL,
		[IsSystemObject] [bit] NULL,
		[IsUpdateable] [bit] NULL,
		[LastBackupDate] [datetime2](7) NULL,
		[LastDifferentialBackupDate] [datetime2](7) NULL,
		[LastGoodCheckDbTime] [datetime2](7) NULL,
		[LastLogBackupDate] [datetime2](7) NULL,
		[LocalCursorsDefault] [bit] NULL,
		[LogReuseWaitStatus] [nvarchar](max) NULL,
		[MemoryAllocatedToMemoryOptimizedObjectsInKB] [float] NULL,
		[MemoryUsedByMemoryOptimizedObjectsInKB] [float] NULL,
		[MirroringFailoverLogSequenceNumber] [decimal](38, 5) NULL,
		[MirroringID] [uniqueidentifier] NULL,
		[MirroringPartner] [nvarchar](max) NULL,
		[MirroringPartnerInstance] [nvarchar](max) NULL,
		[MirroringRedoQueueMaxSize] [int] NULL,
		[MirroringRoleSequence] [int] NULL,
		[MirroringSafetyLevel] [nvarchar](max) NULL,
		[MirroringSafetySequence] [int] NULL,
		[MirroringStatus] [nvarchar](max) NULL,
		[MirroringTimeout] [int] NULL,
		[MirroringWitness] [nvarchar](max) NULL,
		[MirroringWitnessStatus] [nvarchar](max) NULL,
		[NestedTriggersEnabled] [bit] NULL,
		[NumericRoundAbortEnabled] [bit] NULL,
		[Owner] [nvarchar](max) NULL,
		[PageVerify] [nvarchar](max) NULL,
		[PrimaryFilePath] [nvarchar](max) NULL,
		[QuotedIdentifiersEnabled] [bit] NULL,
		[ReadOnly] [bit] NULL,
		[RecoveryForkGuid] [uniqueidentifier] NULL,
		[RecoveryModel] [nvarchar](max) NULL,
		[RecursiveTriggersEnabled] [bit] NULL,
		[RemoteDataArchiveCredential] [nvarchar](max) NULL,
		[RemoteDataArchiveEnabled] [bit] NULL,
		[RemoteDataArchiveEndpoint] [nvarchar](max) NULL,
		[RemoteDataArchiveLinkedServer] [nvarchar](max) NULL,
		[RemoteDataArchiveUseFederatedServiceAccount] [bit] NULL,
		[RemoteDatabaseName] [nvarchar](max) NULL,
		[ReplicationOptions] [nvarchar](max) NULL,
		[ServiceBrokerGuid] [uniqueidentifier] NULL,
		[Size] [float] NULL,
		[SnapshotIsolationState] [nvarchar](max) NULL,
		[SpaceAvailable] [float] NULL,
		[Status] [nvarchar](max) NULL,
		[TargetRecoveryTime] [int] NULL,
		[TransformNoiseWords] [bit] NULL,
		[Trustworthy] [bit] NULL,
		[TwoDigitYearCutoff] [int] NULL,
		[UserAccess] [nvarchar](max) NULL,
		[UserName] [nvarchar](max) NULL,
		[Version] [int] NULL,
		[AzureEdition] [nvarchar](max) NULL,
		[AzureServiceObjective] [nvarchar](max) NULL,
		[IsDbManager] [bit] NULL,
		[IsLoginManager] [bit] NULL,
		[IsSqlDwEdition] [bit] NULL,
		[MaxSizeInBytes] [float] NULL,
		[TemporalHistoryRetentionEnabled] [bit] NULL,
		[Events] [nvarchar](max) NULL,
		[ExecutionManager] [nvarchar](max) NULL,
		[DatabaseEngineType] [nvarchar](max) NULL,
		[DatabaseEngineEdition] [nvarchar](max) NULL,
		[Name] [nvarchar](max) NULL,
		[WarnOnRename] [bit] NULL,
		[DatabaseOwnershipChaining] [bit] NULL,
		[CatalogCollation] [nvarchar](max) NULL,
		[ExtendedProperties] [nvarchar](max) NULL,
		[DatabaseOptions] [nvarchar](max) NULL,
		[QueryStoreOptions] [nvarchar](max) NULL,
		[Synonyms] [nvarchar](max) NULL,
		[Sequences] [nvarchar](max) NULL,
		[Tables] [nvarchar](max) NULL,
		[DatabaseScopedCredentials] [nvarchar](max) NULL,
		[StoredProcedures] [nvarchar](max) NULL,
		[Assemblies] [nvarchar](max) NULL,
		[ExternalLibraries] [nvarchar](max) NULL,
		[UserDefinedTypes] [nvarchar](max) NULL,
		[UserDefinedAggregates] [nvarchar](max) NULL,
		[FullTextCatalogs] [nvarchar](max) NULL,
		[FullTextStopLists] [nvarchar](max) NULL,
		[SearchPropertyLists] [nvarchar](max) NULL,
		[SecurityPolicies] [nvarchar](max) NULL,
		[DatabaseScopedConfigurations] [nvarchar](max) NULL,
		[ExternalDataSources] [nvarchar](max) NULL,
		[ExternalFileFormats] [nvarchar](max) NULL,
		[Certificates] [nvarchar](max) NULL,
		[ColumnMasterKeys] [nvarchar](max) NULL,
		[ColumnEncryptionKeys] [nvarchar](max) NULL,
		[SymmetricKeys] [nvarchar](max) NULL,
		[AsymmetricKeys] [nvarchar](max) NULL,
		[DatabaseEncryptionKey] [nvarchar](max) NULL,
		[ExtendedStoredProcedures] [nvarchar](max) NULL,
		[UserDefinedFunctions] [nvarchar](max) NULL,
		[Views] [nvarchar](max) NULL,
		[Users] [nvarchar](max) NULL,
		[DatabaseAuditSpecifications] [nvarchar](max) NULL,
		[Schemas] [nvarchar](max) NULL,
		[Roles] [nvarchar](max) NULL,
		[ApplicationRoles] [nvarchar](max) NULL,
		[LogFiles] [nvarchar](max) NULL,
		[FileGroups] [nvarchar](max) NULL,
		[PlanGuides] [nvarchar](max) NULL,
		[Defaults] [nvarchar](max) NULL,
		[Rules] [nvarchar](max) NULL,
		[UserDefinedDataTypes] [nvarchar](max) NULL,
		[UserDefinedTableTypes] [nvarchar](max) NULL,
		[XmlSchemaCollections] [nvarchar](max) NULL,
		[PartitionFunctions] [nvarchar](max) NULL,
		[PartitionSchemes] [nvarchar](max) NULL,
		[ActiveDirectory] [nvarchar](max) NULL,
		[MasterKey] [nvarchar](max) NULL,
		[Triggers] [nvarchar](max) NULL,
		[DefaultLanguage] [nvarchar](max) NULL,
		[DefaultFullTextLanguage] [nvarchar](max) NULL,
		[ServiceBroker] [nvarchar](max) NULL,
		[MaxDop] [int] NULL,
		[MaxDopForSecondary] [nvarchar](max) NULL,
		[LegacyCardinalityEstimation] [nvarchar](max) NULL,
		[LegacyCardinalityEstimationForSecondary] [nvarchar](max) NULL,
		[ParameterSniffing] [nvarchar](max) NULL,
		[ParameterSniffingForSecondary] [nvarchar](max) NULL,
		[QueryOptimizerHotfixes] [nvarchar](max) NULL,
		[QueryOptimizerHotfixesForSecondary] [nvarchar](max) NULL,
		[IsVarDecimalStorageFormatSupported] [bit] NULL,
		[IsVarDecimalStorageFormatEnabled] [bit] NULL,
		[ParentCollection] [nvarchar](max) NULL,
		[Urn] [nvarchar](max) NULL,
		[Properties] [nvarchar](max) NULL,
		[ServerVersion] [nvarchar](max) NULL,
		[UserData] [nvarchar](max) NULL,
		[State] [nvarchar](max) NULL,
		[IsDesignMode] [bit] NULL
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
	/****** Object:  Table [dbo].[DatabaseUsers]    Script Date: 11-5-2021 14:35:35 ******/
SET
	ANSI_NULLS ON
GO
SET
	QUOTED_IDENTIFIER ON
GO
	CREATE TABLE [dbo].[DatabaseUsers] (
		[CheckDate] [datetime2](7) NULL,
		[ComputerName] [nvarchar](max) NULL,
		[InstanceName] [nvarchar](max) NULL,
		[SqlInstance] [nvarchar](max) NULL,
		[Database] [nvarchar](max) NULL,
		[Parent] [nvarchar](max) NULL,
		[AsymmetricKey] [nvarchar](max) NULL,
		[AuthenticationType] [nvarchar](max) NULL,
		[Certificate] [nvarchar](max) NULL,
		[CreateDate] [datetime2](7) NULL,
		[DateLastModified] [datetime2](7) NULL,
		[DefaultSchema] [nvarchar](max) NULL,
		[HasDBAccess] [bit] NULL,
		[ID] [int] NULL,
		[IsSystemObject] [bit] NULL,
		[Login] [nvarchar](max) NULL,
		[LoginType] [nvarchar](max) NULL,
		[Sid] [varbinary](max) NULL,
		[UserType] [nvarchar](max) NULL,
		[Name] [nvarchar](max) NULL
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
	/****** Object:  Table [dbo].[DefaultTraceEntries]    Script Date: 11-5-2021 14:35:35 ******/
SET
	ANSI_NULLS ON
GO
SET
	QUOTED_IDENTIFIER ON
GO
	CREATE TABLE [dbo].[DefaultTraceEntries] (
		[SqlInstance] [nvarchar](max) NULL,
		[LoginName] [nvarchar](max) NULL,
		[HostName] [nvarchar](max) NULL,
		[DatabaseName] [nvarchar](max) NULL,
		[ApplicationName] [nvarchar](max) NULL,
		[StartTime] [datetime2](7) NULL,
		[TextData] [nvarchar](max) NULL
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
	/****** Object:  Table [dbo].[DiskSpace]    Script Date: 11-5-2021 14:35:35 ******/
SET
	ANSI_NULLS ON
GO
SET
	QUOTED_IDENTIFIER ON
GO
	CREATE TABLE [dbo].[DiskSpace] (
		[CheckDate] [datetime2](7) NULL,
		[ComputerName] [nvarchar](max) NULL,
		[Name] [nvarchar](max) NULL,
		[Label] [nvarchar](max) NULL,
		[Capacity] [bigint] NULL,
		[Free] [bigint] NULL,
		[PercentFree] [float] NULL,
		[BlockSize] [int] NULL,
		[FileSystem] [nvarchar](max) NULL,
		[Type] [nvarchar](max) NULL,
		[IsSqlDisk] [nvarchar](max) NULL,
		[Server] [nvarchar](max) NULL,
		[DriveType] [nvarchar](max) NULL,
		[SizeInBytes] [float] NULL,
		[FreeInBytes] [float] NULL,
		[SizeInKB] [float] NULL,
		[FreeInKB] [float] NULL,
		[SizeInMB] [float] NULL,
		[FreeInMB] [float] NULL,
		[SizeInGB] [float] NULL,
		[FreeInGB] [float] NULL,
		[SizeInTB] [float] NULL,
		[FreeInTB] [float] NULL,
		[SizeInPB] [float] NULL,
		[FreeInPB] [float] NULL
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
	/****** Object:  Table [dbo].[LastBackupTests]    Script Date: 11-5-2021 14:35:35 ******/
SET
	ANSI_NULLS ON
GO
SET
	QUOTED_IDENTIFIER ON
GO
	CREATE TABLE [dbo].[LastBackupTests] (
		[SourceServer] [nvarchar](max) NULL,
		[TestServer] [nvarchar](max) NULL,
		[Database] [nvarchar](max) NULL,
		[FileExists] [bit] NULL,
		[Size] [bigint] NULL,
		[RestoreResult] [nvarchar](max) NULL,
		[DbccResult] [nvarchar](max) NULL,
		[RestoreStart] [nvarchar](max) NULL,
		[RestoreEnd] [nvarchar](max) NULL,
		[RestoreElapsed] [nvarchar](max) NULL,
		[DbccMaxDop] [int] NULL,
		[DbccStart] [nvarchar](max) NULL,
		[DbccEnd] [nvarchar](max) NULL,
		[DbccElapsed] [nvarchar](max) NULL,
		[BackupDates] [nvarchar](max) NULL,
		[BackupFiles] [nvarchar](max) NULL
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
	/****** Object:  Table [dbo].[ServerLogins]    Script Date: 11-5-2021 14:35:35 ******/
SET
	ANSI_NULLS ON
GO
SET
	QUOTED_IDENTIFIER ON
GO
	CREATE TABLE [dbo].[ServerLogins] (
		[CheckDate] [datetime2](7) NULL,
		[ComputerName] [nvarchar](max) NULL,
		[InstanceName] [nvarchar](max) NULL,
		[SqlInstance] [nvarchar](max) NULL,
		[LastLogin] [nvarchar](max) NULL,
		[AsymmetricKey] [nvarchar](max) NULL,
		[Certificate] [nvarchar](max) NULL,
		[CreateDate] [datetime2](7) NULL,
		[Credential] [nvarchar](max) NULL,
		[DateLastModified] [datetime2](7) NULL,
		[DefaultDatabase] [nvarchar](max) NULL,
		[DenyWindowsLogin] [bit] NULL,
		[HasAccess] [bit] NULL,
		[ID] [int] NULL,
		[IsDisabled] [bit] NULL,
		[IsLocked] [bit] NULL,
		[IsPasswordExpired] [bit] NULL,
		[IsSystemObject] [bit] NULL,
		[LoginType] [nvarchar](max) NULL,
		[MustChangePassword] [bit] NULL,
		[PasswordExpirationEnabled] [bit] NULL,
		[PasswordHashAlgorithm] [nvarchar](max) NULL,
		[PasswordPolicyEnforced] [bit] NULL,
		[Sid] [varbinary](max) NULL,
		[WindowsLoginAccessType] [nvarchar](max) NULL,
		[Name] [nvarchar](max) NULL
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE
	[dbo].[Databases]
ADD
	CONSTRAINT [DF_Databases_CheckDate] DEFAULT (getdate()) FOR [CheckDate]
GO
ALTER TABLE
	[dbo].[DatabaseUsers]
ADD
	CONSTRAINT [DF_DatabaseUsers_CheckDate] DEFAULT (getdate()) FOR [CheckDate]
GO
ALTER TABLE
	[dbo].[DiskSpace]
ADD
	CONSTRAINT [DF_DiskSpace_CheckDate] DEFAULT (getdate()) FOR [CheckDate]
GO
ALTER TABLE
	[dbo].[DiskSpeedTests]
ADD
	CONSTRAINT [DF_DiskSpeedTests_CheckDate] DEFAULT (getdate()) FOR [CheckDate]
GO
ALTER TABLE
	[dbo].[ServerLogins]
ADD
	CONSTRAINT [DF_ServerLogins_CheckDate] DEFAULT (getdate()) FOR [CheckDate]
GO
	/****** Object:  StoredProcedure [dbo].[usp_CreateDiskSpaceReport]    Script Date: 11-5-2021 14:35:35 ******/
SET
	ANSI_NULLS ON
GO
SET
	QUOTED_IDENTIFIER ON
GO
	CREATE PROCEDURE [dbo].[usp_CreateDiskSpaceReport] @profile_name sysname,
	@recipients VARCHAR(MAX) AS BEGIN DECLARE @subj VARCHAR(200),
	@body NVARCHAR(MAX),
	@xml NVARCHAR(MAX);

-- Create a temp table
IF OBJECT_ID ('tempdb.dbo.#DiskSpace') IS NOT NULL DROP TABLE #DiskSpace;
CREATE TABLE tempdb.dbo.#DiskSpace
(
	ComputerName VARCHAR(100) NOT NULL,
	Name VARCHAR(50) NULL,
	Label NVARCHAR(255) NULL,
	Capacity BIGINT NULL,
	Free BIGINT NULL,
	PercentFree DECIMAL(5, 2) NULL,
	BlockSize INT NULL,
	FileSystem NVARCHAR(50),
	TYPE NVARCHAR(255)
);

-- Store all applicable errorlog entries in a temp table
INSERT INTO
	#DiskSpace
SELECT
	ComputerName,
	Name,
	Label,
	Capacity,
	Free,
	PercentFree,
	BlockSize,
	FileSystem,
	TYPE
FROM
	DBA.dbo.DiskSpace AS el
WHERE
	(CheckDate >= DATEADD (DAY, -1, GETDATE ()))
	AND (
		PercentFree < 2.5
		AND FreeinGB < 2
	)
	AND Label <> 'Page file'
	AND TYPE <> 'RemovableDisk'
ORDER BY
	ComputerName,
	Name;

--SELECT * FROM #DiskSpace;
-------------------------------------------------------------------------------
-- SQL Server Diskspace Report
-------------------------------------------------------------------------------
SELECT
	@subj = CONCAT (@ @SERVERNAME, ' - SQL Server diskspace report');

SET
	@body = N '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
			<html>
				<head>
					<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
					<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
					<style>
						table, td {  
							border: 2px solid #bada55;  
							border-collapse: collapse; 
							font-size: 14px;  
							vertical-align: top;
							width: 100%;
							table-layout: auto !important;
						}  

						table td{
							white-space: nowrap;  /** added **/
						}

						th {
							background-color: #bada55;
							color: white;
							width: auto !important;
						}

						table td:last-child{
							width:100%;
						}
					</style>
				</head>
				<body>  
					<p>(This mail was sent by the procedure ''' + DB_NAME () + N'.' + OBJECT_SCHEMA_NAME (@ @PROCID) + N'.' + OBJECT_NAME (@ @PROCID) + N'' ')</p>               
					<p>The table below contains the latest SQL Server Diskspace Report.</p>
					<h2>SQL Server Diskspace Report</h2>
					<table border="1" cellpadding="2">               
						<thead> 
						<tr> 
							<th> ComputerName </th> 							
							<th> Drive </th>
							<th> Label </th>
							<th> Capacity </th>
							<th> Free </th>
							<th> Percent Free </th>
							<th> BlockSize </th>
							<th> FileSystem </th>
							<th> Type </th>
						</tr> 
					</thead>';

SET
	@xml = CAST(
		(
			SELECT
				ComputerName AS td,
				'',
				Name AS td,
				'',
				Label AS td,
				'',
				Capacity AS td,
				'',
				Free AS td,
				'',
				PercentFree AS td,
				'',
				BlockSize AS td,
				'',
				FileSystem AS td,
				'',
				TYPE AS td,
				''
			FROM
				#DiskSpace
			ORDER BY
				ComputerName FOR XML PATH ('tr'),
				ELEMENTS
		) AS NVARCHAR(MAX)
	);

SET
	@body = @body + @xml + N'</table></body></html>';

EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile_name,
@recipients = @recipients,
@subject = @subj,
@body = @body,
@body_format = 'HTML';

END;

GO
	/****** Object:  StoredProcedure [dbo].[usp_ProcessErrorLogs]    Script Date: 11-5-2021 14:35:35 ******/
SET
	ANSI_NULLS ON
GO
SET
	QUOTED_IDENTIFIER ON
GO
	CREATE PROCEDURE [dbo].[usp_ProcessErrorLogs] @profile_name sysname,
	@recipients VARCHAR(MAX) AS BEGIN DECLARE @subj VARCHAR(200),
	@body NVARCHAR(MAX),
	@xml NVARCHAR(MAX);

-- Create a temp table
IF OBJECT_ID ('tempdb.dbo.#SQLErrorLog') IS NOT NULL DROP TABLE #SQLErrorLog;
CREATE TABLE tempdb.dbo.#SQLErrorLog
(
	SQLInstance VARCHAR(100) NOT NULL,
	Text NVARCHAR(4000) NULL,
	[Count] INT NULL
);

-- Store all applicable errorlog entries in a temp table
INSERT INTO
	#SQLErrorLog
	(SQLInstance, Text, [Count])
SELECT
	SqlInstance,
	Text,
	COUNT(*) AS Number
FROM
	DBA.dbo.ErrorLogs AS el
WHERE
	(LogDate >= DATEADD (DAY, -1, GETDATE ()))
	AND Text NOT LIKE ('%(c)%')
	AND Text NOT LIKE ('%Microsoft SQL Server%')
	AND Text NOT LIKE ('%All rights reserved%')
	AND Text NOT LIKE ('%Server is listening%')
	AND Text NOT LIKE ('%Database Mirroring endpoint%')
	AND Text NOT LIKE ('%SQL Trace ID 1%')
	AND Text NOT LIKE ('%Service Broker%')
	AND Text NOT LIKE ('%Software Usage Metrics%')
	AND Text NOT LIKE ('%Authentication mode is MIXED%')
	AND Text NOT LIKE ('%backed up%')
	AND Text NOT LIKE ('%Server local connection provider%')
	AND Text NOT LIKE ('%Server process ID%')
	AND Text NOT LIKE ('%changed from 0 to 0%')
	AND Text NOT LIKE ('%I/O is frozen on database%')
	AND Text NOT LIKE ('%I/O was resumed on database%')
	AND Text NOT LIKE ('%informational message%')
	AND Text NOT LIKE ('%Log was restored%')
	AND Text NOT LIKE ('%Starting up database%')
	AND Text NOT LIKE ('%BACKUP DATABASE successfully processed%')
	AND Text NOT LIKE (
		'%BACKUP DATABASE WITH DIFFERENTIAL successfully processed%'
	)
	AND Text NOT LIKE ('%Setting database option % to % for database%')
	AND Text NOT LIKE ('%The tempdb database has % data file(s)%')
	AND Text NOT LIKE ('%SSPI handshake failed%')
	AND Text NOT LIKE ('%Login succeeded%')
	AND Text NOT LIKE ('%found 0 errors%')
	AND Text NOT LIKE ('%finished without errors%')
	AND Text NOT LIKE ('%Error: %, Severity: %, State: %')
	AND Text NOT LIKE ('%Log was backed up%')
	AND Text NOT LIKE ('%Parallel redo is shutdown%')
	AND Text NOT LIKE ('%Parallel redo is started%')
	AND Text NOT LIKE ('%RESTORE DATABASE successfully processed %')
	AND Text NOT LIKE ('%Restore is complete on database%')
	AND Text NOT LIKE ('%Login failed for user ''UltimoLogin''%')
	AND Text NOT LIKE ('%The database ''%'' is marked RESTORING%')
	AND Text NOT LIKE (
		'%The operating system returned the error ''21(The device is not ready.)''%'
	)
	AND Text NOT LIKE (
		'%Filegroup MultimediaFileStream in database % is unavailable%'
	)
	AND Text NOT LIKE (
		'%Process ID % was killed by hostname %, host process ID %.'
	)
GROUP BY
	SqlInstance,
	Text
ORDER BY
	SqlInstance;

--SELECT * FROM #SQLErrorLog;
-------------------------------------------------------------------------------
-- Unusual SQL Server Agentlog entries
-------------------------------------------------------------------------------
SELECT
	@subj = CONCAT (@ @SERVERNAME, ' - SQL Server Errorlog entries');

SET
	@body = N '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
			<html>
				<head>
					<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
					<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
					<style>
						table, td {  
							border: 2px solid #bada55;  
							border-collapse: collapse; 
							font-size: 14px;  
							vertical-align: top;
							width: 100%;
							table-layout: auto !important;
						}  

						table td{
							white-space: nowrap;  /** added **/
						}

						th {
							background-color: #bada55;
							color: white;
							width: auto !important;
						}

						table td:last-child{
							width:100%;
						}
					</style>
				</head>
				<body>  
					<p>(This mail was sent by the procedure ''' + DB_NAME () + N'.' + OBJECT_SCHEMA_NAME (@ @PROCID) + N'.' + OBJECT_NAME (@ @PROCID) + N'' ')</p>               
					<p>The table below contains SQL Error Log entries recorded during the last 24 hours.</p>
					<h2>SQL Server Errorlogs</h2>
					<table border="1" cellpadding="2">               
						<thead> 
						<tr> 
							<th> SqlInstance </th> 							
							<th> Text </th>
							<th> Count </th>
						</tr> 
					</thead>';

SET
	@xml = CAST(
		(
			SELECT
				SQLInstance AS td,
				'',
				Text AS td,
				'',
				Count AS td,
				''
			FROM
				#SQLErrorLog
			ORDER BY
				SQLInstance,
				[Count] DESC FOR XML PATH ('tr'),
				ELEMENTS
		) AS NVARCHAR(MAX)
	);

SET
	@body = @body + @xml + N'</table></body></html>';

EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile_name,
@recipients = @recipients,
@subject = @subj,
@body = @body,
@body_format = 'HTML';

END;

GO
	/****** Object:  StoredProcedure [dbo].[usp_ProcessFailedAgentJobs]    Script Date: 11-5-2021 14:35:35 ******/
SET
	ANSI_NULLS ON
GO
SET
	QUOTED_IDENTIFIER ON
GO
	CREATE PROCEDURE [dbo].[usp_ProcessFailedAgentJobs] @profile_name sysname,
	@recipients VARCHAR(MAX) AS BEGIN DECLARE @subj VARCHAR(200),
	@body NVARCHAR(MAX),
	@xml NVARCHAR(MAX);

-- Create a temp table
IF OBJECT_ID ('tempdb.dbo.#SQLAgentLog') IS NOT NULL DROP TABLE #SQLAgentLog;
CREATE TABLE #SQLAgentLog
(
	SQLInstance VARCHAR(100) NOT NULL,
	RunDate VARCHAR(20) NOT NULL,
	JobName NVARCHAR(200) NOT NULL,
	StepName NVARCHAR(200) NOT NULL,
	RunDuration INT NOT NULL,
	LogText NVARCHAR(4000) NULL
);

-- Store all applicable agentlog entries in a temp table
INSERT INTO
	#SQLAgentLog
	(
		SQLInstance,
		RunDate,
		JobName,
		StepName,
		RunDuration,
		LogText
	)
SELECT
	Server,
	RunDate,
	JobName,
	StepName,
	RunDuration,
	Message
FROM
	DBA.dbo.FailedJobHistory
WHERE
	(RunDate >= DATEADD (DAY, -1, GETDATE ()))
	AND StepName <> '(Job outcome)'
ORDER BY
	Server,
	RunDate DESC;

-------------------------------------------------------------------------------
-- Unusual SQL Server Agentlog entries
-------------------------------------------------------------------------------
SELECT
	@subj = CONCAT (@ @SERVERNAME, ' - SQL Server Agentlog entries');

SET
	@body = N '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
			<html>
				<head>
					<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
					<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
					<style>
						table, td {  
							border: 2px solid #bada55;  
							border-collapse: collapse; 
							font-size: 14px;  
							vertical-align: top;
							width: 100%;
							table-layout: auto !important;
						}  

						table td{
							white-space: nowrap;  /** added **/
						}

						th {
							background-color: #bada55;
							color: white;
							width: auto !important;
						}

						table td:last-child{
							width:100%;
						}
					</style>
				</head>
				<body>  
					<p>(This mail was sent by the procedure ''' + DB_NAME () + N'.' + OBJECT_SCHEMA_NAME (@ @PROCID) + N'.' + OBJECT_NAME (@ @PROCID) + N'' ')</p>               
					<p>The table below contains SQL Agent Log entries recorded during the last 24 hours.</p>
					<h2>SQL Server Agentlogs</h2>
					<table border="1" cellpadding="2">               
						<thead> 
						<tr> 
							<th> SqlInstance </th> 
							<th> Date </th> 
							<th> JobName </th> 
							<th> StepName </th> 
							<th> Duration </th> 
							<th> Text </th> 
						</tr> 
					</thead>';

SET
	@xml = CAST(
		(
			SELECT
				SQLInstance AS td,
				'',
				CONVERT (CHAR(30), RunDate, 21) AS td,
				'',
				JobName AS td,
				'',
				StepName AS td,
				'',
				RunDuration AS td,
				'',
				LogText AS td,
				''
			FROM
				#SQLAgentLog
			ORDER BY
				SQLInstance,
				RunDate DESC FOR XML PATH ('tr'),
				ELEMENTS
		) AS NVARCHAR(MAX)
	);

SET
	@body = @body + @xml + N'</table></body></html>';

EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile_name,
@recipients = @recipients,
@subject = @subj,
@body = @body,
@body_format = 'HTML';

END;

GO
	/****** Object:  StoredProcedure [dbo].[usp_ShowCPUUtilization]    Script Date: 11-5-2021 14:35:35 ******/
SET
	ANSI_NULLS ON
GO
SET
	QUOTED_IDENTIFIER ON
GO
	CREATE PROC [dbo].[usp_ShowCPUUtilization] @SqlInstance VARCHAR(255),
	@NumDays INT = 7 AS BEGIN
SET
	NOCOUNT ON;

SELECT
	tbl.SqlInstance,
	tbl.RecordId,
	tbl.EventTime,
	tbl.SQLProcessUtilization,
	tbl.OtherProcessUtilization
FROM
	(
		SELECT
			*,
			ROW_NUMBER () OVER (
				PARTITION BY c.RecordId
				ORDER BY
					c.EventTime
			) AS num
		FROM
			dbo.CPURingBuffers AS c
		WHERE
			SqlInstance = @SqlInstance
			AND c.EventTime >= DATEADD (DAY, - @NumDays, GETDATE ())
	) AS tbl
WHERE
	num = 1
ORDER BY
	tbl.EventTime DESC;

END;

GO