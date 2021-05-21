
DECLARE @JobOwner VARCHAR(100)
SET @JobOwner = 'sa'





--------------------------------------------------------------------------------------------------------
---------------------------------BEGIN CREATE DATABASE MASTER KEY---------------------------------------
--------------------------------------------------------------------------------------------------------
DECLARE @DBCertExists BIT;
SET @DBCertExists = (SELECT COUNT(*) FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
IF @DBCertExists = 0
	BEGIN
		CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'M1n10nStrongPa$$w0rd!@#$!@#$';
	END
--------------------------------------------------------------------------------------------------------
---------------------------------END CREATE DATABASE MASTER KEY-----------------------------------------
--------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------
---------------------------------BEGIN CREATE Encryption Certificate------------------------------------
--------------------------------------------------------------------------------------------------------
DECLARE @EncryptionCertExists BIT;
SET @EncryptionCertExists = (SELECT COUNT(*) FROM sys.certificates WHERE name = 'MinionEncrypt')
IF @EncryptionCertExists = 0
	BEGIN
		CREATE CERTIFICATE MinionEncrypt WITH SUBJECT = 'Cert used to encrypt/decrypt data in the Minion procedures.';
	END
--------------------------------------------------------------------------------------------------------
---------------------------------END CREATE Encryption Certificate--------------------------------------
--------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------
---------------------------------BEGIN CREATE Symmetric Key---------------------------------------------
--------------------------------------------------------------------------------------------------------
DECLARE @SymmetricKeyExists BIT;
SET @SymmetricKeyExists = (SELECT COUNT(*) FROM sys.symmetric_keys WHERE name = 'MinionKey')
IF @SymmetricKeyExists = 0
	BEGIN
		CREATE SYMMETRIC KEY MinionKey
		WITH ALGORITHM = AES_128 
		ENCRYPTION BY CERTIFICATE MinionEncrypt;
	END
--------------------------------------------------------------------------------------------------------
---------------------------------END CREATE Symmetric Key-----------------------------------------------
--------------------------------------------------------------------------------------------------------

IF OBJECT_ID('tempdb..#dbname') IS NOT NULL
BEGIN
	DROP TABLE #dbname;
END

IF OBJECT_ID('tempdb..#JobOwner') IS NOT NULL
BEGIN
	DROP TABLE #JobOwner;
END

CREATE TABLE #JobOwner (JobOwner VARCHAR(100))
INSERT #JobOwner(JobOwner)
VALUES (@JobOwner);


IF OBJECT_ID('tempdb..#BackupSettingsExists') IS NOT NULL
BEGIN
	DROP TABLE #BackupSettingsExists;
END

IF OBJECT_ID('tempdb..#BackupTuningThresholdsExists') IS NOT NULL
BEGIN
	DROP TABLE #BackupTuningThresholdsExists;
END

IF OBJECT_ID('tempdb..#dbname') IS NOT NULL
BEGIN
	DROP TABLE #dbname;
END


SELECT	DB_NAME() AS dbname
INTO	#dbname;

SET NOCOUNT ON;


IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'BackupSettings' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
SELECT 0 AS BackupSettingsExists
INTO #BackupSettingsExists;

CREATE TABLE [Minion].[BackupSettings](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DBName] [sysname] NOT NULL,
	[Port] [int] NULL,
	[BackupType] [varchar](20) NULL,
	[Exclude] [bit] NULL,
	[GroupOrder] [int] NULL,
	[GroupDBOrder] [int] NULL,
	[Mirror] [bit] NULL,
	[DelFileBefore] [bit] NULL,
	[DelFileBeforeAgree] [bit] NULL,
	[LogLoc] [varchar](25) NULL,
	[HistRetDays] [smallint] NULL,
	[MinionTriggerPath] [varchar](1000) NULL,
	[DBPreCode] [nvarchar](max) NULL,
	[DBPostCode] [nvarchar](max) NULL,
	[PushToMinion] [bit] NULL,
	[DynamicTuning] [bit] NULL,
	[Verify] [varchar](20) NULL,
	[PreferredServer] [varchar](150) NULL,
	[ShrinkLogOnLogBackup] [bit] NULL,
	[ShrinkLogThresholdInMB] [int] NULL,
	[ShrinkLogSizeInMB] [int] NULL,
	[MinSizeForDiffInGB] [bigint] NULL,
	[DiffReplaceAction] [varchar](4) NULL,
	[LogProgress] [bit] NULL,
	[FileAction] [varchar](10) NULL,
	[FileActionTime] [varchar](25) NULL,
	[Encrypt] [bit] NULL,
	[Name] [varchar](128) NULL,
	[ExpireDateInHrs] [int] NULL,
	[RetainDays] [smallint] NULL,
	[Descr] [varchar](255) NULL,
	[Checksum] [bit] NULL,
	[Init] [bit] NULL,
	[Format] [bit] NULL,
	[CopyOnly] [bit] NULL,
	[Skip] [bit] NULL,
	[BackupErrorMgmt] [varchar](50) NULL,
	[MediaName] [varchar](128) NULL,
	[MediaDescription] [varchar](255) NULL,
	[IsActive] [bit] NULL,
	[Comment] [varchar](2000) NULL
) 

END



IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'DBMaintDBGroups' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[DBMaintDBGroups](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Action] [varchar](10) NULL,
	[MaintType] [varchar](20) NULL,
	[GroupName] [varchar](200) NULL,
	[GroupDef] [varchar](400) NULL,
	[Escape] [char](1) NULL,
	[IsActive] [bit] NULL,
	[Comment] [varchar](2000) NULL
) 
END




IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'BackupEncryption' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[BackupEncryption](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DBName] [sysname] NOT NULL,
	[BackupType] [varchar](20) NULL,
	[CertType] [varchar](50) NULL,
	[CertName] [varchar](100) NULL,
	[EncrAlgorithm] [varchar](20) NULL,
	[ThumbPrint] [varbinary](32) NULL,
	[IsActive] [bit] NULL
)
END

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'BackupFiles' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[BackupFiles](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[Op] [varchar](20) NULL,
	[Status] [varchar](max) NULL,
	[DBName] [sysname] NOT NULL,
	[ServerLabel] [varchar](150) NULL,
	[NETBIOSName] [varchar](128) NULL,
	[BackupType] [varchar](20) NULL,
	[BackupLocType] [varchar](20) NULL,
	[BackupDrive] [varchar](100) NULL,
	[BackupPath] [varchar](1000) NULL,
	[FullPath] [varchar](4000) NULL,
	[FullFileName] [varchar](8000) NULL,
	[FileName] [varchar](500) NULL,
	[DateLogic] [varchar](100) NULL,
	[Extension] [varchar](5) NULL,
	[RetHrs] [int] NULL,
	[IsMirror] [bit] NULL,
	[ToBeDeleted] [datetime] NULL,
	[DeleteDateTime] [datetime] NULL,
	[IsDeleted] [bit] NULL,
	[IsArchive] [bit] NULL,
	[BackupSizeInMB] [numeric](15, 3) NULL,
	[BackupName] [varchar](100) NULL,
	[BackupDescription] [varchar](1000) NULL,
	[ExpirationDate] [datetime] NULL,
	[Compressed] [bit] NULL,
	[POSITION] [tinyint] NULL,
	[DeviceType] [tinyint] NULL,
	[UserName] [varchar](100) NULL,
	[DatabaseName] [sysname] NULL,
	[DatabaseVersion] [int] NULL,
	[DatabaseCreationDate] [datetime] NULL,
	[BackupSizeInBytes] [bigint] NULL,
	[FirstLSN] [varchar](100) NULL,
	[LastLSN] [varchar](100) NULL,
	[CheckpointLSN] [varchar](100) NULL,
	[DatabaseBackupLSN] [varchar](100) NULL,
	[BackupStartDate] [datetime] NULL,
	[BackupFinishDate] [datetime] NULL,
	[SortOrder] [int] NULL,
	[CODEPAGE] [int] NULL,
	[UnicodeLocaleId] [int] NULL,
	[UnicodeComparisonStyle] [int] NULL,
	[CompatibilityLevel] [int] NULL,
	[SoftwareVendorId] [int] NULL,
	[SoftwareVersionMajor] [int] NULL,
	[SoftwareVersionMinor] [int] NULL,
	[SovtwareVersionBuild] [int] NULL,
	[MachineName] [varchar](100) NULL,
	[Flags] [int] NULL,
	[BindingID] [varchar](100) NULL,
	[RecoveryForkID] [varchar](100) NULL,
	[COLLATION] [varchar](100) NULL,
	[FamilyGUID] [varchar](100) NULL,
	[HasBulkLoggedData] [bit] NULL,
	[IsSnapshot] [bit] NULL,
	[IsReadOnly] [bit] NULL,
	[IsSingleUser] [bit] NULL,
	[HasBackupChecksums] [bit] NULL,
	[IsDamaged] [bit] NULL,
	[BeginsLogChain] [bit] NULL,
	[HasIncompleteMeatdata] [bit] NULL,
	[IsForceOffline] [bit] NULL,
	[IsCopyOnly] [bit] NULL,
	[FirstRecoveryForkID] [varchar](100) NULL,
	[ForkPointLSN] [varchar](100) NULL,
	[RecoveryModel] [varchar](15) NULL,
	[DifferentialBaseLSN] [varchar](100) NULL,
	[DifferentialBaseGUID] [varchar](100) NULL,
	[BackupTypeDescription] [varchar](25) NULL,
	[BackupSetGUID] [varchar](100) NULL,
	[CompressedBackupSize] [bigint] NULL,
	[CONTAINMENT] [tinyint] NULL
) 
END

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'BackupLog' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[BackupLog](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[STATUS] [varchar](max) NULL,
	[DBType] [varchar](6) NULL,
	[BackupType] [varchar](20) NULL,
	[StmtOnly] [bit] NULL,
	[NumDBsOnServer] [int] NULL,
	[NumDBsProcessed] [int] NULL,
	[TotalBackupSizeInMB] [float] NULL,
	[ReadOnly] [tinyint] NULL,
	[ExecutionEndDateTime] [datetime] NULL,
	[ExecutionRunTimeInSecs] [float] NULL,
	[BatchPreCode] [varchar](max) NULL,
	[BatchPostCode] [varchar](max) NULL,
	[BatchPreCodeStartDateTime] [datetime] NULL,
	[BatchPreCodeEndDateTime] [datetime] NULL,
	[BatchPreCodeTimeInSecs] [int] NULL,
	[BatchPostCodeStartDateTime] [datetime] NULL,
	[BatchPostCodeEndDateTime] [datetime] NULL,
	[BatchPostCodeTimeInSecs] [int] NULL,
	[IncludeDBs] [varchar](max) NULL,
	[ExcludeDBs] [varchar](max) NULL,
	[RegexDBsIncluded] [varchar](max) NULL,
	[RegexDBsExcluded] [varchar](max) NULL,
	[Warnings] [varchar](max) NULL
) 
END


IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'BackupLogDetails' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[BackupLogDetails](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[STATUS] [varchar](max) NULL,
	[PctComplete] [tinyint] NULL,
	[DBName] [sysname] NULL,
	[ServerLabel] [varchar](128) NULL,
	[NETBIOSName] [varchar](128) NULL,
	[IsClustered] [bit] NULL,
	[IsInAG] [bit] NULL,
	[IsPrimaryReplica] [bit] NULL,
	[DBType] [varchar](6) NULL,
	[BackupType] [varchar](20) NULL,
	[BackupStartDateTime] [datetime] NULL,
	[BackupEndDateTime] [datetime] NULL,
	[BackupTimeInSecs] [float] NULL,
	[MBPerSec] [float] NULL,
	[BackupCmd] [varchar](max) NULL,
	[SizeInMB] [float] NULL,
	[StmtOnly] [bit] NULL,
	[READONLY] [tinyint] NULL,
	[BackupGroupOrder] [int] NULL,
	[BackupGroupDBOrder] [int] NULL,
	[NumberOfFiles] [tinyint] NULL,
	[Buffercount] [int] NULL,
	[MaxTransferSize] [bigint] NULL,
	[MemoryLimitInMB] [bigint] NULL,
	[TotalBufferSpaceInMB] [bigint] NULL,
	[FileSystemIOAlignInKB] [int] NULL,
	[SetsOfBuffers] [tinyint] NULL,
	[Verify] [varchar](20) NULL,
	[Compression] [bit] NULL,
	[FileAction] [varchar](20) NULL,
	[FileActionTime] [varchar](25) NULL,
	[FileActionBeginDateTime] [datetime] NULL,
	[FileActionEndDateTime] [datetime] NULL,
	[FileActionTimeInSecs] [int] NULL,
	[UnCompressedBackupSizeMB] [int] NULL,
	[CompressedBackupSizeMB] [int] NULL,
	[CompressionRatio] [float] NULL,
	[COMPRESSIONPct] [numeric](20, 1) NULL,
	[BackupRetHrs] [tinyint] NULL,
	[BackupLogging] [varchar](25) NULL,
	[BackupLoggingRetDays] [smallint] NULL,
	[DelFileBefore] [bit] NULL,
	[DBPreCode] [nvarchar](max) NULL,
	[DBPostCode] [nvarchar](max) NULL,
	[DBPreCodeStartDateTime] [datetime] NULL,
	[DBPreCodeEndDateTime] [datetime] NULL,
	[DBPreCodeTimeInSecs] [int] NULL,
	[DBPostCodeStartDateTime] [datetime] NULL,
	[DBPostCodeEndDateTime] [datetime] NULL,
	[DBPostCodeTimeInSecs] [int] NULL,
	[IncludeDBs] [varchar](max) NULL,
	[ExcludeDBs] [varchar](max) NULL,
	[RegexDBsExcluded] [varchar](max) NULL,
	[Verified] [bit] NULL,
	[VerifyStartDateTime] [datetime] NULL,
	[VerifyEndDateTime] [datetime] NULL,
	[VerifyTimeInSecs] [int] NULL,
	[IsInit] [bit] NULL,
	[IsFormat] [bit] NULL,
	[IsCheckSum] [bit] NULL,
	[BlockSize] [bigint] NULL,
	[Descr] [varchar](255) NULL,
	[IsCopyOnly] [bit] NULL,
	[IsSkip] [bit] NULL,
	[BackupName] [varchar](255) NULL,
	[BackupErrorMgmt] [varchar](50) NULL,
	[MediaName] [varchar](128) NULL,
	[MediaDescription] [varchar](255) NULL,
	[ExpireDateInHrs] [int] NULL,
	[RetainDays] [smallint] NULL,
	[MirrorBackup] [bit] NULL,
	[DynamicTuning] [bit] NULL,
	[ShrinkLogOnLogBackup] [bit] NULL,
	[ShrinkLogThresholdInMB] [int] NULL,
	[ShrinkLogSizeInMB] [int] NULL,
	[PreBackupLogSizeInMB] [float] NULL,
	[PreBackupLogUsedPct] [float] NULL,
	[PostBackupLogSizeInMB] [float] NULL,
	[PostBackupLogUsedPct] [int] NULL,
	[PreBackupLogReuseWait] [varchar](100) NULL,
	[PostBackupLogReuseWait] [varchar](100) NULL,
	[VLFs] [bigint] NULL,
	[FileList] [varchar](max) NULL,
	[IsTDE] [bit] NULL,
	[BackupCert] [bit] NULL,
	[CertPword] [varbinary](max) NULL,
	[IsEncryptedBackup] [bit] NULL,
	[BackupEncryptionCertName] [nchar](100) NULL,
	[BackupEncryptionAlgorithm] [varchar](20) NULL,
	[BackupEncryptionCertThumbPrint] [varbinary](32) NULL,
	[DeleteFilesStartDateTime] [datetime] NULL,
	[DeleteFilesEndDateTime] [datetime] NULL,
	[DeleteFilesTimeInSecs] [int] NULL,
	[Warnings] [varchar](max) NULL
)
END

--------------------------------BEGIN BackupSettingsPath------------------------------
IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'BackupSettingsPath' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN --BackupSettingsPath
CREATE TABLE [Minion].[BackupSettingsPath](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[DBName] [sysname] NOT NULL,
	[IsMirror] [bit] NULL,
	[BackupType] [varchar](20) NULL,
	[BackupLocType] [varchar](20) NULL,
	[BackupDrive] [varchar](100) NULL,
	[BackupPath] [varchar](1000) NULL,
	[FileName] [varchar](500) NULL,
	[FileExtension] [varchar](50) NULL,
	[ServerLabel] [varchar](150) NULL,
	[RetHrs] [int] NULL,
	[FileActionMethod] [varchar](25) NULL,
	[FileActionMethodFlags] [varchar](100) NULL,
	[PathOrder] [int] NULL,
	[IsActive] [bit] NULL,
	[AzureCredential] [varchar](100) NULL,
	[Comment] [varchar](2000) NULL
)
END --BackupSettingsPath

IF NOT EXISTS(SELECT * FROM sys.columns 
            WHERE (Name = N'FileName' OR Name = N'FileExtension') AND Object_ID = Object_ID(N'Minion.BackupSettingsPath'))
BEGIN --FileName
		BEGIN TRANSACTION
		SET QUOTED_IDENTIFIER ON
		SET ARITHABORT ON
		SET NUMERIC_ROUNDABORT OFF
		SET CONCAT_NULL_YIELDS_NULL ON
		SET ANSI_NULLS ON
		SET ANSI_PADDING ON
		SET ANSI_WARNINGS ON

		CREATE TABLE [Minion].[Tmp_BackupSettingsPath](
		[ID] [bigint] IDENTITY(1,1) NOT NULL,
		[DBName] [sysname] NOT NULL,
		[IsMirror] [bit] NULL,
		[BackupType] [varchar](20) NULL,
		[BackupLocType] [varchar](20) NULL,
		[BackupDrive] [varchar](100) NULL,
		[BackupPath] [varchar](1000) NULL,
		[FileName] [varchar](500) NULL,
		[FileExtension] [varchar](50) NULL,
		[ServerLabel] [varchar](150) NULL,
		[RetHrs] [int] NULL,
		[FileActionMethod] [varchar](25) NULL,
		[FileActionMethodFlags] [varchar](100) NULL,
		[PathOrder] [int] NULL,
		[IsActive] [bit] NULL,
		[AzureCredential] [varchar](100) NULL,
		[Comment] [varchar](2000) NULL
)

ALTER TABLE Minion.Tmp_BackupSettingsPath SET (LOCK_ESCALATION = TABLE)

SET IDENTITY_INSERT Minion.Tmp_BackupSettingsPath ON

IF EXISTS(SELECT * FROM Minion.BackupSettingsPath)
	 EXEC('INSERT INTO Minion.Tmp_BackupSettingsPath (ID, DBName, IsMirror, BackupType, BackupLocType, BackupDrive, BackupPath, FileName, FileExtension, ServerLabel, RetHrs, FileActionMethod, FileActionMethodFlags, PathOrder, IsActive, AzureCredential, Comment)
		SELECT ID, DBName, IsMirror, BackupType, BackupLocType, BackupDrive, BackupPath, NULL AS FileName, NULL AS FileExtension, ServerLabel, RetHrs, FileActionMethod, FileActionMethodFlags, PathOrder, IsActive, AzureCredential, Comment FROM Minion.BackupSettingsPath WITH (HOLDLOCK TABLOCKX)')

SET IDENTITY_INSERT Minion.Tmp_BackupSettingsPath OFF

DROP TABLE Minion.BackupSettingsPath

EXECUTE sp_rename N'Minion.Tmp_BackupSettingsPath', N'BackupSettingsPath', 'OBJECT' 
COMMIT

END --FileName

IF NOT EXISTS (SELECT 
			OBJECT_NAME(OBJECT_ID) AS NameofConstraint
			,SCHEMA_NAME(schema_id) AS SchemaName
			,OBJECT_NAME(parent_object_id) AS TableName
			,type_desc AS ConstraintType
			FROM sys.objects
			WHERE type_desc LIKE '%CONSTRAINT'
			AND OBJECT_NAME(OBJECT_ID)='DF__BackupSet__isMir__1367E606')
		BEGIN
			ALTER TABLE [Minion].[BackupSettingsPath] ADD  CONSTRAINT [DF__BackupSet__isMir__1367E606]  DEFAULT ((0)) FOR [IsMirror];
		END

IF NOT EXISTS (SELECT 
			OBJECT_NAME(OBJECT_ID) AS NameofConstraint
			,SCHEMA_NAME(schema_id) AS SchemaName
			,OBJECT_NAME(parent_object_id) AS TableName
			,type_desc AS ConstraintType
			FROM sys.objects
			WHERE type_desc LIKE '%CONSTRAINT'
			AND OBJECT_NAME(OBJECT_ID)='DF__BackupSet__PathO__145C0A3F')
		BEGIN
			ALTER TABLE [Minion].[BackupSettingsPath] ADD  CONSTRAINT [DF__BackupSet__PathO__145C0A3F]  DEFAULT ((0)) FOR [PathOrder];
		END
--------------------------------END BackupSettingsPath--------------------------------

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'BackupTuningThresholds' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
SELECT 0 AS BackupTuningThresholdsExists
INTO #BackupTuningThresholdsExists;

CREATE TABLE [Minion].[BackupTuningThresholds](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[DBName] [sysname] NOT NULL,
	[BackupType] [varchar](20) NULL,
	[SpaceType] [varchar](20) NULL,
	[ThresholdMeasure] [char](2) NULL,
	[ThresholdValue] [bigint] NULL,
	[NumberOfFiles] [tinyint] NULL,
	[Buffercount] [smallint] NULL,
	[MaxTransferSize] [bigint] NULL,
	[Compression] [bit] NULL,
	[BlockSize] [bigint] NULL,
	[BeginTime] [varchar](20) NULL,
	[EndTime] [varchar](20) NULL,
	[DayOfWeek] [varchar](15) NULL,
	[IsActive] [bit] NULL,
	[Comment] [varchar](2000) NULL
)
END

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'CK_Thresholds_BeginTimeFormat')
BEGIN
	ALTER TABLE [Minion].[BackupTuningThresholds]  WITH NOCHECK ADD  CONSTRAINT [CK_Thresholds_BeginTimeFormat] CHECK  (([BeginTime] LIKE '[2][0-3]:[0-5][0-9]:[0-5][0-9]' OR [BeginTime] LIKE '[2][0-3]:[0-5][0-9]:[0-5][0-9]:[0-9][0-9][0-9]' OR [BeginTime] LIKE '[0-1][0-9]:[0-5][0-9]:[0-5][0-9]' OR [BeginTime] LIKE '[0-1][0-9]:[0-5][0-9]:[0-5][0-9]:[0-9][0-9][0-9]' OR [BeginTime] IS NULL))
END

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'CK_Thresholds_EndTimeFormat')
BEGIN
	ALTER TABLE [Minion].[BackupTuningThresholds]  WITH NOCHECK ADD  CONSTRAINT [CK_Thresholds_EndTimeFormat] CHECK  (([EndTime] LIKE '[2][0-3]:[0-5][0-9]:[0-5][0-9]' OR [EndTime] LIKE '[2][0-3]:[0-5][0-9]:[0-5][0-9]:[0-9][0-9][0-9]' OR [EndTime] LIKE '[0-1][0-9]:[0-5][0-9]:[0-5][0-9]' OR [EndTime] LIKE '[0-1][0-9]:[0-5][0-9]:[0-5][0-9]:[0-9][0-9][0-9]' OR [EndTime] IS NULL))
END

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'CK_Thresholds_EndTimeFormat')
BEGIN
	ALTER TABLE [Minion].[BackupTuningThresholds] CHECK CONSTRAINT [CK_Thresholds_EndTimeFormat]
END

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'DBMaintRegexLookup' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[DBMaintRegexLookup](
	[Action] [VARCHAR](10) NULL,
	[MaintType] [VARCHAR](20) NULL,
	[Regex] [NVARCHAR](2000) NULL
)
END


IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'SyncCmds' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[SyncCmds](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[Module] [varchar](50) NULL,
	[Status] [varchar](max) NULL,
	[ObjectName] [sysname] NOT NULL,
	[Op] [varchar](50) NULL,
	[Cmd] [nvarchar](max) NULL,
	[Pushed] [bit] NULL,
	[Attempts] [bigint] NULL,
	[ErroredServers] [varchar](8000) NULL
)
END


IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'SyncServer' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[SyncServer](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Module] [varchar](50) NULL,
	[DBName] [sysname] NOT NULL,
	[SyncServerName] [varchar](1000) NULL,
	[SyncDBName] [sysname] NOT NULL,
	[Port] [int] NULL,
	[ConnectionTimeoutInSecs] [int] NULL
) 
END

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'SyncErrorCmds' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[SyncErrorCmds](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[SyncServerName] [varchar](140) NULL,
	[SyncDBName] [varchar](140) NULL,
	[Port] [varchar](10) NULL,
	[SyncCmdID] [bigint] NULL,
	[STATUS] [varchar](max) NULL,
	[LastAttemptDateTime] [datetime] NULL
) 
END


IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'Work' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[Work](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[Module] [varchar](20) NULL,
	[DBName] [sysname] NOT NULL,
	[BackupType] [varchar](20) NULL,
	[Param] [varchar](100) NULL,
	[SPName] [varchar](100) NULL,
	[Value] [varchar](max) NULL
) 
END

--------------------BEGIN BackupSettingsServer-------------------------------
IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'BackupSettingsServer' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[BackupSettingsServer](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DBType] [varchar](6) NULL,
	[BackupType] [varchar](20) NULL,
	[Day] [varchar](10) NULL,
	[ReadOnly] [tinyint] NULL,
	[BeginTime] [varchar](20) NOT NULL,
	[EndTime] [varchar](20) NOT NULL,
	[MaxForTimeframe] [int] NULL,
	[FrequencyMins] [int] NULL,
	[CurrentNumBackups] [int] NULL,
	[NumConcurrentBackups] [tinyint] NULL,
	[LastRunDateTime] [datetime] NULL,
	[Include] [varchar](2000) NULL,
	[Exclude] [varchar](2000) NULL,
	[SyncSettings] [bit] NULL,
	[SyncLogs] [bit] NULL,
	[BatchPreCode] [varchar](max) NULL,
	[BatchPostCode] [varchar](max) NULL,
	[Debug] [bit] NULL,
	FailJobOnError bit NULL,
	FailJobOnWarning bit NULL,
	[IsActive] [bit] NULL,
	[Comment] [varchar](2000) NULL,
 CONSTRAINT [PK_BackupSettingsServer] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

END

ALTER TABLE [Minion].[BackupSettingsServer]
ALTER COLUMN [Day] varchar(50)

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'CK_BeginTimeFormat')
BEGIN
	ALTER TABLE [Minion].[BackupSettingsServer]  WITH CHECK ADD  CONSTRAINT [CK_BeginTimeFormat] CHECK  (([BeginTime] like '[2][0-3]:[0-5][0-9]:[0-5][0-9]' OR [BeginTime] like '[2][0-3]:[0-5][0-9]:[0-5][0-9]:[0-9][0-9][0-9]' OR [BeginTime] like '[0-1][0-9]:[0-5][0-9]:[0-5][0-9]' OR [BeginTime] like '[0-1][0-9]:[0-5][0-9]:[0-5][0-9]:[0-9][0-9][0-9]' OR [BeginTime] IS NULL))
END

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'CK_BeginTimeFormat')
BEGIN
	ALTER TABLE [Minion].[BackupSettingsServer] CHECK CONSTRAINT [CK_BeginTimeFormat]
END

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'CK_EndTimeFormat')
BEGIN
	ALTER TABLE [Minion].[BackupSettingsServer]  WITH CHECK ADD  CONSTRAINT [CK_EndTimeFormat] CHECK  (([EndTime] like '[2][0-3]:[0-5][0-9]:[0-5][0-9]' OR [EndTime] like '[2][0-3]:[0-5][0-9]:[0-5][0-9]:[0-9][0-9][0-9]' OR [EndTime] like '[0-1][0-9]:[0-5][0-9]:[0-5][0-9]' OR [EndTime] like '[0-1][0-9]:[0-5][0-9]:[0-5][0-9]:[0-9][0-9][0-9]' OR [EndTime] IS NULL))
END

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'CK_EndTimeFormat')
BEGIN
	ALTER TABLE [Minion].[BackupSettingsServer] CHECK CONSTRAINT [CK_EndTimeFormat]
END

IF NOT EXISTS(SELECT * FROM sys.columns 
            WHERE (Name = N'FrequencyMins' OR Name = N'FailJobOnError' OR Name = N'FailJobOnWarning') AND Object_ID = Object_ID(N'Minion.BackupSettingsServer'))
BEGIN --FrequencyMins
		BEGIN TRANSACTION
		SET QUOTED_IDENTIFIER ON
		SET ARITHABORT ON
		SET NUMERIC_ROUNDABORT OFF
		SET CONCAT_NULL_YIELDS_NULL ON
		SET ANSI_NULLS ON
		SET ANSI_PADDING ON
		SET ANSI_WARNINGS ON

CREATE TABLE Minion.Tmp_BackupSettingsServer
	(
	ID int NOT NULL IDENTITY (1, 1),
	DBType varchar(6) NULL,
	BackupType varchar(20) NULL,
	Day varchar(50) NULL,
	ReadOnly tinyint NULL,
	BeginTime varchar(20) NOT NULL,
	EndTime varchar(20) NOT NULL,
	MaxForTimeframe int NULL,
	FrequencyMins int NULL,
	CurrentNumBackups int NULL,
	NumConcurrentBackups tinyint NULL,
	LastRunDateTime datetime NULL,
	Include varchar(2000) NULL,
	Exclude varchar(2000) NULL,
	SyncSettings bit NULL,
	SyncLogs bit NULL,
	BatchPreCode varchar(MAX) NULL,
	BatchPostCode varchar(MAX) NULL,
	Debug bit NULL,
	FailJobOnError bit NULL,
	FailJobOnWarning bit NULL,
	IsActive bit NULL,
	Comment varchar(2000) NULL
	)  ON [PRIMARY]
	 TEXTIMAGE_ON [PRIMARY]

ALTER TABLE Minion.Tmp_BackupSettingsServer SET (LOCK_ESCALATION = TABLE)

SET IDENTITY_INSERT Minion.Tmp_BackupSettingsServer ON

IF EXISTS(SELECT * FROM Minion.BackupSettingsServer)
	 EXEC('INSERT INTO Minion.Tmp_BackupSettingsServer (ID, DBType, BackupType, Day, ReadOnly, BeginTime, EndTime, MaxForTimeframe, CurrentNumBackups, NumConcurrentBackups, LastRunDateTime, Include, Exclude, SyncSettings, SyncLogs, BatchPreCode, BatchPostCode, Debug, IsActive, Comment)
		SELECT ID, DBType, BackupType, Day, ReadOnly, BeginTime, EndTime, MaxForTimeframe, CurrentNumBackups, NumConcurrentBackups, LastRunDateTime, Include, Exclude, SyncSettings, SyncLogs, BatchPreCode, BatchPostCode, Debug, IsActive, Comment FROM Minion.BackupSettingsServer WITH (HOLDLOCK TABLOCKX)')

SET IDENTITY_INSERT Minion.Tmp_BackupSettingsServer OFF

DROP TABLE Minion.BackupSettingsServer

EXECUTE sp_rename N'Minion.Tmp_BackupSettingsServer', N'BackupSettingsServer', 'OBJECT' 

ALTER TABLE Minion.BackupSettingsServer ADD CONSTRAINT
	PK_BackupSettingsServer PRIMARY KEY CLUSTERED 
	(
	ID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

ALTER TABLE Minion.BackupSettingsServer ADD CONSTRAINT
	CK_BeginTimeFormat CHECK (([BeginTime] like '[2][0-3]:[0-5][0-9]:[0-5][0-9]' OR [BeginTime] like '[2][0-3]:[0-5][0-9]:[0-5][0-9]:[0-9][0-9][0-9]' OR [BeginTime] like '[0-1][0-9]:[0-5][0-9]:[0-5][0-9]' OR [BeginTime] like '[0-1][0-9]:[0-5][0-9]:[0-5][0-9]:[0-9][0-9][0-9]' OR [BeginTime] IS NULL))

ALTER TABLE Minion.BackupSettingsServer ADD CONSTRAINT
	CK_EndTimeFormat CHECK (([EndTime] like '[2][0-3]:[0-5][0-9]:[0-5][0-9]' OR [EndTime] like '[2][0-3]:[0-5][0-9]:[0-5][0-9]:[0-9][0-9][0-9]' OR [EndTime] like '[0-1][0-9]:[0-5][0-9]:[0-5][0-9]' OR [EndTime] like '[0-1][0-9]:[0-5][0-9]:[0-5][0-9]:[0-9][0-9][0-9]' OR [EndTime] IS NULL))

COMMIT

END --FrequencyMins



--------------------END BackupSettingsServer-------------------------------

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'BackupCert' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[BackupCert](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CertType] [varchar](50) NULL,
	[CertPword] [varbinary](max) NULL,
	[BackupCert] [bit] NULL
) 
END

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'BackupHeaderOnlyWork' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[BackupHeaderOnlyWork](
	[ExecutionDateTime] [datetime] NULL,
	[DBName] [sysname] NULL,
	[BT] [varchar](20) NULL,
	[BackupName] [varchar](100) NULL,
	[BackupDescription] [varchar](1000) NULL,
	[BackupType] [tinyint] NULL,
	[ExpirationDate] [datetime] NULL,
	[Compressed] [bit] NULL,
	[POSITION] [tinyint] NULL,
	[DeviceType] [tinyint] NULL,
	[UserName] [varchar](100) NULL,
	[ServerLabel] [varchar](100) NULL,
	[DatabaseName] [varchar](100) NULL,
	[DatabaseVersion] [int] NULL,
	[DatabaseCreationDate] [datetime] NULL,
	[BackupSize] [bigint] NULL,
	[FirstLSN] [varchar](100) NULL,
	[LastLSN] [varchar](100) NULL,
	[CheckpointLSN] [varchar](100) NULL,
	[DatabaseBackupLSN] [varchar](100) NULL,
	[BackupStartDate] [datetime] NULL,
	[BackupFinishDate] [datetime] NULL,
	[SortOrder] [int] NULL,
	[CODEPAGE] [int] NULL,
	[UnicodeLocaleId] [int] NULL,
	[UnicodeComparisonStyle] [int] NULL,
	[CompatibilityLevel] [int] NULL,
	[SoftwareVendorId] [int] NULL,
	[SoftwareVersionMajor] [int] NULL,
	[SoftwareVersionMinor] [int] NULL,
	[SovtwareVersionBuild] [int] NULL,
	[MachineName] [varchar](100) NULL,
	[Flags] [int] NULL,
	[BindingID] [varchar](100) NULL,
	[RecoveryForkID] [varchar](100) NULL,
	[COLLATION] [varchar](100) NULL,
	[FamilyGUID] [varchar](100) NULL,
	[HasBulkLoggedData] [bit] NULL,
	[IsSnapshot] [bit] NULL,
	[IsReadOnly] [bit] NULL,
	[IsSingleUser] [bit] NULL,
	[HasBackupChecksums] [bit] NULL,
	[IsDamaged] [bit] NULL,
	[BeginsLogChain] [bit] NULL,
	[HasIncompleteMeatdata] [bit] NULL,
	[IsForceOffline] [bit] NULL,
	[IsCopyOnly] [bit] NULL,
	[FirstRecoveryForkID] [varchar](100) NULL,
	[ForkPointLSN] [varchar](100) NULL,
	[RecoveryModel] [varchar](15) NULL,
	[DifferentialBaseLSN] [varchar](100) NULL,
	[DifferentialBaseGUID] [varchar](100) NULL,
	[BackupTypeDescription] [varchar](25) NULL,
	[BackupSetGUID] [varchar](100) NULL,
	[CompressedBackupSize] [bigint] NULL,
	[CONTAINMENT] [tinyint] NULL,
	[KeyAlgorithm] nvarchar(32) NULL,
	[EncryptorThumbprint] varbinary(20) NULL,
	[EncryptorType] nvarchar(32) NULL
) 
END
------Add new cols if they don't exist.
IF NOT EXISTS(SELECT * FROM sys.columns 
            WHERE Name = N'KeyAlgorithm' AND Object_ID = Object_ID(N'Minion.BackupHeaderOnlyWork'))
BEGIN
ALTER TABLE Minion.BackupHeaderOnlyWork
Add 
    [KeyAlgorithm] nvarchar(32) NULL,
	[EncryptorThumbprint] varbinary(20) NULL,
	[EncryptorType] nvarchar(32) NULL
END


IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'BackupDebug' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[BackupDebug](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [DATETIME] NULL,
	[DBName] [NVARCHAR](400) NULL,
	[BackupType] [VARCHAR](50) NULL,
	[SPName] [VARCHAR](50) NULL,
	[StepName] [VARCHAR](100) NULL,
	[StepValue] [VARCHAR](MAX) NULL
) 
END
GO

IF EXISTS(SELECT * FROM sys.columns 
            WHERE (Name = N'DBName') AND Object_ID = Object_ID(N'Minion.BackupDebug'))
BEGIN
	ALTER TABLE Minion.BackupDebug ALTER COLUMN [DBName] NVARCHAR(400) NULL;  
END
GO


IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'BackupDebugLogDetails' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[BackupDebugLogDetails](
	[ID] [BIGINT] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [DATETIME] NULL,
	[STATUS] [VARCHAR](MAX) NULL,
	[DBName] [NVARCHAR](400) NULL,
	[BackupType] [VARCHAR](20) NULL,
	[StepName] [VARCHAR](100) NULL
) 
END
GO
IF EXISTS(SELECT * FROM sys.columns 
            WHERE (Name = N'DBName') AND Object_ID = Object_ID(N'Minion.BackupDebugLogDetails'))
BEGIN
	ALTER TABLE Minion.BackupDebugLogDetails ALTER COLUMN [DBName] NVARCHAR(400) NULL;  
END
GO

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'BackupRestoreSettingsPath' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[BackupRestoreSettingsPath](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DBName] [nvarchar](400) NULL,
	[ServerName] [varchar](400) NULL,
	[RestoreType] [varchar](15) NULL,
	[FileType] [varchar](10) NULL,
	[TypeName] [varchar](400) NULL,
	[RestoreDrive] [varchar](100) NULL,
	[RestorePath] [varchar](1000) NULL,
	[RestoreFileName] [varchar](500) NULL,
	[RestoreFileExtension] [varchar](50) NULL,
	[BackupLocation] [varchar](8000) NULL,
	[RestoreDBName] [varchar](400) NULL,
	[ServerLabel] [varchar](100) NULL,
	[PathOrder] [int] NULL,
	[IsActive] [bit] NULL,
	[Comment] [varchar](2000) NULL
)
END
GO
IF EXISTS(SELECT * FROM sys.columns 
            WHERE (Name = N'DBName') AND Object_ID = Object_ID(N'Minion.BackupRestoreSettingsPath'))
BEGIN
	ALTER TABLE Minion.BackupRestoreSettingsPath ALTER COLUMN [DBName] NVARCHAR(400) NULL;  
END
GO

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'BackupRestoreTuningThresholds' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[BackupRestoreTuningThresholds](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ServerName] [varchar](400) NULL,
	[DBName] [sysname] NOT NULL,
	[RestoreType] [varchar](20) NULL,
	[SpaceType] [varchar](20) NULL,
	[ThresholdMeasure] [char](2) NULL,
	[ThresholdValue] [bigint] NULL,
	[Buffercount] [smallint] NULL,
	[MaxTransferSize] [bigint] NULL,
	[BlockSize] [bigint] NULL,
	[Replace] [bit] NULL,
	[WithFlags] [varchar](1000) NULL,
	[BeginTime] [varchar](20) NULL,
	[EndTime] [varchar](20) NULL,
	[DayOfWeek] [varchar](15) NULL,
	[IsActive] [bit] NULL,
	[Comment] [varchar](2000) NULL
)

ALTER TABLE [Minion].[BackupRestoreTuningThresholds]  WITH NOCHECK ADD  CONSTRAINT [CK_RThresholds_BeginTimeFormat] CHECK  (([BeginTime] like '[2][0-3]:[0-5][0-9]:[0-5][0-9]' OR [BeginTime] like '[2][0-3]:[0-5][0-9]:[0-5][0-9]:[0-9][0-9][0-9]' OR [BeginTime] like '[0-1][0-9]:[0-5][0-9]:[0-5][0-9]' OR [BeginTime] like '[0-1][0-9]:[0-5][0-9]:[0-5][0-9]:[0-9][0-9][0-9]' OR [BeginTime] IS NULL))
ALTER TABLE [Minion].[BackupRestoreTuningThresholds] CHECK CONSTRAINT [CK_RThresholds_BeginTimeFormat]
ALTER TABLE [Minion].[BackupRestoreTuningThresholds]  WITH NOCHECK ADD  CONSTRAINT [CK_RThresholds_EndTimeFormat] CHECK  (([EndTime] like '[2][0-3]:[0-5][0-9]:[0-5][0-9]' OR [EndTime] like '[2][0-3]:[0-5][0-9]:[0-5][0-9]:[0-9][0-9][0-9]' OR [EndTime] like '[0-1][0-9]:[0-5][0-9]:[0-5][0-9]' OR [EndTime] like '[0-1][0-9]:[0-5][0-9]:[0-5][0-9]:[0-9][0-9][0-9]' OR [EndTime] IS NULL))
ALTER TABLE [Minion].[BackupRestoreTuningThresholds] CHECK CONSTRAINT [CK_RThresholds_EndTimeFormat]
END

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'BackupRestoreFileListOnlyTemp' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[BackupRestoreFileListOnlyTemp](
	[DBName] [NVARCHAR](400) NULL,
	[LogicalName] [VARCHAR](255) NULL,
	[PhysicalName] [VARCHAR](512) NULL,
	[Type] [CHAR](1) NULL,
	[FileGroupName] [VARCHAR](128) NULL,
	[Size] [NUMERIC](38, 0) NULL,
	[MaxSize] [NUMERIC](38, 0) NULL,
	[FileId] [BIGINT] NULL,
	[CreateLSN] [NUMERIC](38, 0) NULL,
	[DropLSN] [NUMERIC](38, 0) NULL,
	[UniqueID] [UNIQUEIDENTIFIER] NULL,
	[ReadOnlyLSN] [NUMERIC](38, 0) NULL,
	[ReadWriteLSN] [NUMERIC](38, 0) NULL,
	[BackupSizeInBytes] [BIGINT] NULL,
	[SourceBlockSize] [BIGINT] NULL,
	[FileGroupId] [BIGINT] NULL,
	[LogGroupGUID] [UNIQUEIDENTIFIER] NULL,
	[DifferentialBaseLSN] [NUMERIC](38, 0) NULL,
	[DifferentialBaseGUID] [UNIQUEIDENTIFIER] NULL,
	[IsReadOnly] [INT] NULL,
	[IsPresent] [INT] NULL,
	[TDEThumbprint] [VARBINARY](32) NULL,
	[SnapshotURL] NVARCHAR(1000) NULL,
	[FilePath] [VARCHAR](8000) NULL,
	[FileName] [VARCHAR](400) NULL,
	[Extension] [VARCHAR](50) NULL
)
END
GO
IF EXISTS(SELECT * FROM sys.columns 
            WHERE (Name = N'DBName') AND Object_ID = Object_ID(N'Minion.BackupRestoreFileListOnlyTemp'))
BEGIN
	ALTER TABLE Minion.BackupRestoreFileListOnlyTemp ALTER COLUMN [DBName] NVARCHAR(400) NULL;  
END
GO


IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'DBMaintInlineTokens' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[DBMaintInlineTokens](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[DynamicName] [VARCHAR](100) NULL,
	[ParseMethod] [VARCHAR](1000) NULL,
	[IsCustom] [BIT] NULL,
	[Definition] [VARCHAR](1000) NULL,
	[IsActive] [BIT] NULL,
	[Comment] [VARCHAR](1000) NULL,
 CONSTRAINT [ukInlineTokensActive] UNIQUE NONCLUSTERED 
(
	[DynamicName] ASC,
	[IsActive] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
)
END
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
-----------------------Indexes---------------------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------

IF NOT EXISTS (SELECT *  FROM sys.indexes  WHERE name='clustID' 
    AND object_id = OBJECT_ID('Minion.BackupFiles'))
BEGIN
	CREATE UNIQUE CLUSTERED INDEX [clustID] ON [Minion].[BackupFiles]
	(
		[ID] ASC
	)
END

IF NOT EXISTS (SELECT *  FROM sys.indexes  WHERE name='nonExecutionDateTime' 
    AND object_id = OBJECT_ID('Minion.BackupFiles'))
BEGIN
	CREATE NONCLUSTERED INDEX [nonExecutionDateTime] ON [Minion].[BackupFiles]
	(
		[ExecutionDateTime] ASC,
		[IsDeleted] ASC,
		[DBName] ASC
	)
	INCLUDE ( 	[ID],
		[BackupType],
		[FullFileName],
		[IsMirror]) WITH (PAD_INDEX = ON, FILLFACTOR = 90)
END

IF NOT EXISTS (SELECT *  FROM sys.indexes  WHERE name='nonDeletedDBName' 
    AND object_id = OBJECT_ID('Minion.BackupFiles'))
BEGIN
	CREATE NONCLUSTERED INDEX [nonDeletedDBName] ON [Minion].[BackupFiles]
	(
		[IsDeleted] ASC,
		[DBName] ASC,
		[IsArchive] ASC,
		[ID] ASC
	)
	INCLUDE ( 	
		[ExecutionDateTime],
		[Op],
		[BackupType],
		[FullFileName],
		[IsMirror],
		[BackupSizeInMB]) WITH (PAD_INDEX = ON, FILLFACTOR = 90)
END

IF NOT EXISTS (SELECT *  FROM sys.indexes  WHERE name='clustID' 
    AND object_id = OBJECT_ID('Minion.BackupLogDetails'))
BEGIN
	CREATE UNIQUE CLUSTERED INDEX [clustID] ON [Minion].[BackupLogDetails]
	(
		[ID] ASC
	)
END

IF NOT EXISTS (SELECT *  FROM sys.indexes  WHERE name='nonExecutionDateTime' 
    AND object_id = OBJECT_ID('Minion.BackupLogDetails'))
BEGIN
	CREATE NONCLUSTERED INDEX [nonExecutionDateTime] ON [Minion].[BackupLogDetails]
	(
		[ExecutionDateTime] ASC,
		[DBName] ASC,
		[BackupType] ASC
	)

END

IF NOT EXISTS (SELECT *  FROM sys.indexes  WHERE name='clustID' 
    AND object_id = OBJECT_ID('Minion.BackupLog'))
BEGIN
	CREATE UNIQUE CLUSTERED INDEX [clustID] ON [Minion].[BackupLog]
	(
		[ID] ASC
	)
END

IF NOT EXISTS (SELECT *  FROM sys.indexes  WHERE name='nonExecutionDateTime' 
    AND object_id = OBJECT_ID('Minion.BackupLog'))
BEGIN
CREATE NONCLUSTERED INDEX [nonExecutionDateTime] ON [Minion].[BackupLog]
(
	[ExecutionDateTime] ASC,
	[DBType] ASC,
	[BackupType] ASC
)

END



