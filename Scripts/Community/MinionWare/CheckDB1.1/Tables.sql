
IF OBJECT_ID('tempdb..#dbname') IS NOT NULL
BEGIN
	DROP TABLE #dbname;
END
GO

SELECT	DB_NAME() AS dbname
INTO	#dbname;

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO


IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'CheckDBDebug' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[CheckDBDebug](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[DBName] [nvarchar](400) NULL,
	[OpName] [varchar](50) NULL,
	[SPName] [varchar](50) NULL,
	[StepName] [varchar](100) NULL,
	[StepValue] [varchar](max) NULL
)
END
GO

IF EXISTS(SELECT * FROM sys.columns 
            WHERE (Name = N'DBName') AND Object_ID = Object_ID(N'Minion.CheckDBDebug'))
BEGIN
	ALTER TABLE Minion.CheckDBDebug ALTER COLUMN [DBName] NVARCHAR(400) ;  
END
GO
-----------------------BEGIN CheckDBDebugSnapshotCreate----------------------

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'CheckDBDebugSnapshotCreate' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[CheckDBDebugSnapshotCreate](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[CurrentDateTime] [datetime] NULL,
	[DBName] [nvarchar](400) NULL,
	[SnapshotDBName] [varchar](400) NULL,
	[SPName] [varchar](100) NULL,
	[SnapshotCompareBegin] [datetime] NULL,
	[SnapshotRetMins] [tinyint] NULL,
	[SnapshotDelta] [int] NULL,
	[DeleteCurrentSnapshot] [bit] NULL,
	[CreateNewSnapshot] [bit] NULL,
	[Thread] [tinyint] NULL,
	[SnapshotCreationOwner] [tinyint] NULL,
	[CheckDBCmd] [varchar](max) NULL
)
END
GO

IF EXISTS(SELECT * FROM sys.columns 
            WHERE (Name = N'CheckDBCMD') AND Object_ID = Object_ID(N'Minion.CheckDBDebugSnapshotCreate'))
BEGIN
	EXEC sp_rename 'Minion.CheckDBDebugSnapshotCreate.CheckDBCMD', 'CheckDBCmd', 'COLUMN';
	WAITFOR DELAY '00:00:03'; --Give it a chance to show up in the system tables.
END
GO

-----------------------END CheckDBDebugSnapshotCreate------------------------

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'CheckDBDebugSnapshotThreads' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[CheckDBDebugSnapshotThreads](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[CurrentDateTime] [datetime] NULL,
	[RunType] [varchar](100) NULL,
	[DBName] [nvarchar](400) NULL,
	[SnapshotDBName] [nvarchar](400) NULL,
	[SPName] [varchar](100) NULL,
	[SnapshotCompareBegin] [datetime] NULL,
	[SnapshotRetMins] [tinyint] NULL,
	[SnapshotDelta] [int] NULL,
	[DeleteCurrentSnapshot] [bit] NULL,
	[CreateNewSnapshot] [bit] NULL,
	[Thread] [tinyint] NULL,
	[SnapshotCreationOwner] [tinyint] NULL
)
END
GO


IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'CheckDBLog' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[CheckDBLog](
	[ID] [BIGINT] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [DATETIME] NULL,
	[STATUS] [VARCHAR](MAX) NULL,
	[DBType] [VARCHAR](6) NULL,
	[OpName] [VARCHAR](50) NULL,
	[NumConcurrentOps] [TINYINT] NULL,
	[DBInternalThreads] [TINYINT] NULL,
	[NumDBsOnServer] [INT] NULL,
	[NumDBsProcessed] [INT] NULL,
	[RotationLimiter] [VARCHAR](50) NULL,
	[RotationLimiterMetric] [VARCHAR](10) NULL,
	[RotationMetricValue] [INT] NULL,
	[TimeLimitInMins] [INT] NULL,
	[ExecutionEndDateTime] [DATETIME] NULL,
	[ExecutionRunTimeInSecs] [FLOAT] NULL,
	[BatchPreCodeStartDateTime] [DATETIME] NULL,
	[BatchPostCodeStartDateTime] [DATETIME] NULL,
	[BatchPreCode] [VARCHAR](MAX) NULL,
	[BatchPostCode] [VARCHAR](MAX) NULL,
	[Schemas] [VARCHAR](MAX) NULL,
	[Tables] [VARCHAR](MAX) NULL,
	[IncludeDBs] [VARCHAR](MAX) NULL,
	[ExcludeDBs] [VARCHAR](MAX) NULL,
	[RegexDBsIncluded] [VARCHAR](MAX) NULL,
	[RegexDBsExcluded] [VARCHAR](MAX) NULL
)
END
GO

IF EXISTS(SELECT * FROM sys.columns 
            WHERE (Name = N'NumConcurrentProcesses') AND Object_ID = Object_ID(N'Minion.CheckDBLog'))
BEGIN
	EXEC sp_rename 'Minion.CheckDBLog.NumConcurrentProcesses', 'NumConcurrentOps', 'COLUMN'; 
END
GO

---------------------BEGIN CheckDBLogDetails--------------------
IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'CheckDBLogDetails' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[CheckDBLogDetails](
	[ID] [BIGINT] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [DATETIME] NULL,
	[STATUS] [NVARCHAR](MAX) NULL,
	[PctComplete] [TINYINT] NULL,
	[DBName] [NVARCHAR](400) NULL,
	[CheckDBName] [NVARCHAR](400) NULL,
	[ServerLabel] [VARCHAR](400) NULL,
	[NETBIOSName] [VARCHAR](400) NULL,
	[IsRemote] [BIT] NULL,
	[PreferredServer] [VARCHAR](150) NULL,
	[PreferredDBName] [NVARCHAR](400) NULL,
	[RemoteCheckDBMode] VARCHAR(25),
	[RemoteRestoreMode] VARCHAR(50),
	[IsClustered] [BIT] NULL,
	[IsInAG] [BIT] NULL,
	[IsPrimaryReplica] [BIT] NULL,
	[DBType] [VARCHAR](6) NULL,
	[OpName] [VARCHAR](25) NULL,
	[SchemaName] [NVARCHAR](400) NULL,
	[TableName] [NVARCHAR](400) NULL,
	[IndexName] [NVARCHAR](400) NULL,
	[IndexID] [BIGINT] NULL,
	[IndexType] [VARCHAR](50) NULL,
	[GroupOrder] [INT] NULL,
	[GroupDBOrder] [INT] NULL,
	[SizeInMB] [FLOAT] NULL,
	[TimeLimitInMins] [INT] NULL,
	[EstimatedTimeInSecs] [INT] NULL,
	[EstimatedKBperMS] [FLOAT] NULL,
	[LastOpTimeInSecs] [INT] NULL,
	[IncludeRemoteInTimeLimit] [INT] NULL,
	[OpBeginTime] [DATETIME] NULL,
	[OpEndTime] [DATETIME] NULL,
	[OpRunTimeInSecs] [FLOAT] NULL,
	[CustomSnapshot] [BIT] NULL,
	[MaxSnapshotSizeInKB] [FLOAT] NULL,
	[CheckDBCmd] [NVARCHAR](MAX) NULL,
	[AllocationErrors] [INT] NULL,
	[ConsistencyErrors] [INT] NULL,
	[NoIndex] [BIT] NULL,
	[RepairOption] [VARCHAR](50) NULL,
	[RepairOptionAgree] [BIT] NULL,
	[WithRollback] [VARCHAR](50) NULL,
	[AllErrorMsgs] [BIT] NULL,
	[ExtendedLogicalChecks] [BIT] NULL,
	[NoInfoMsgs] [BIT] NULL,
	[IsTabLock] [BIT] NULL,
	[IntegrityCheckLevel] [VARCHAR](50) NULL,
	[DisableDOP] [BIT] NULL,
	[LockDBMode] [VARCHAR](50) NULL,
	[ResultMode] [VARCHAR](50) NULL,
	[HistRetDays] [INT] NULL,
	[PushToMinion] [BIT] NULL,
	[MinionTriggerPath] [VARCHAR](1000) NULL,
	[AutoRepair] [VARCHAR](50) NULL,
	[AutoRepairTime] [VARCHAR](25) NULL,
	[LastCheckDateTime] [DATETIME] NULL,
	[LastCheckResult] [NVARCHAR](MAX) NULL,
	[DBPreCodeStartDateTime] [DATETIME] NULL,
	[DBPreCodeEndDateTime] [DATETIME] NULL,
	[DBPreCodeTimeInSecs] [INT] NULL,
	[DBPreCode] [NVARCHAR](MAX) NULL,
	[DBPostCodeStartDateTime] [DATETIME] NULL,
	[DBPostCodeEndDateTime] [DATETIME] NULL,
	[DBPostCodeTimeInSecs] [INT] NULL,
	[DBPostCode] [NVARCHAR](MAX) NULL,
	[TablePreCodeStartDateTime] [DATETIME] NULL,
	[TablePreCodeEndDateTime] [DATETIME] NULL,
	[TablePreCodeTimeInSecs] [INT] NULL,
	[TablePreCode] [NVARCHAR](MAX) NULL,
	[TablePostCodeStartDateTime] [DATETIME] NULL,
	[TablePostCodeEndDateTime] [DATETIME] NULL,
	[TablePostCodeTimeInSecs] [INT] NULL,
	[TablePostCode] [NVARCHAR](MAX) NULL,
	[StmtPrefix] [NVARCHAR](500) NULL,
	[StmtSuffix] [NVARCHAR](500) NULL,
	[ProcessingThread] [TINYINT] NULL,
	[Warnings] [NVARCHAR](MAX) NULL
)
END
GO

IF EXISTS(SELECT * FROM sys.columns 
            WHERE (Name = N'MaxSnapshotSizeInMB') AND Object_ID = Object_ID(N'Minion.CheckDBLogDetails'))
BEGIN
	EXEC sp_rename 'Minion.CheckDBLogDetails.MaxSnapshotSizeInMB', 'MaxSnapshotSizeInKB', 'COLUMN'; 
END
GO
---------------------END CheckDBLogDetails----------------------

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'CheckDBResult' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[CheckDBResult](
	[ExecutionDateTime] [DATETIME] NULL,
	[DBName] [NVARCHAR](400) NULL,
	[BeginTime] [DATETIME] NULL,
	[EndTime] [DATETIME] NULL,
	[Error] [INT] NULL,
	[Level] [INT] NULL,
	[State] [INT] NULL,
	[MessageText] [VARCHAR](7000) NULL,
	[RepairLevel] [NVARCHAR](50) NULL,
	[Status] [INT] NULL,
	[DbId] [INT] NULL,
	[DbFragId] [INT] NULL,
	[ObjectId] [BIGINT] NULL,
	[IndexID] [INT] NULL,
	[PartitionId] [BIGINT] NULL,
	[AllocUnitId] [BIGINT] NULL,
	[RidDBId] [BIGINT] NULL,
	[RidPruId] [BIGINT] NULL,
	[File] [INT] NULL,
	[Page] [BIGINT] NULL,
	[Slot] [BIGINT] NULL,
	[RefDbId] [INT] NULL,
	[RefPruId] [INT] NULL,
	[RefFile] [INT] NULL,
	[RefPage] [BIGINT] NULL,
	[RefSlot] [BIGINT] NULL,
	[Allocation] [INT] NULL
)

CREATE CLUSTERED INDEX [ClustExecDBName] ON [Minion].[CheckDBResult]
(
	[ExecutionDateTime] ASC,
	[DBName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
END
GO


IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'CheckDBRotationDBs' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[CheckDBRotationDBs](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[DBName] [nvarchar](400) NULL,
	[OpName] [varchar](50) NULL
)
END
GO

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'CheckDBRotationTables' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[CheckDBRotationTables](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[DBName] [nvarchar](400) NULL,
	[SchemaName] [nvarchar](400) NULL,
	[TableName] [nvarchar](400) NULL,
	[OpName] [nvarchar](50) NULL
)
END
GO

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'CheckDBSettingsAutoThresholds' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[CheckDBSettingsAutoThresholds](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DBName] [nvarchar](400) NULL,
	[ThresholdMethod] [varchar](20) NULL,
	[ThresholdType] [varchar](20) NULL,
	[ThresholdMeasure] [varchar](5) NULL,
	[ThresholdValue] [int] NULL,
	[IsActive] [bit] NULL,
	[Comment] [varchar](2000) NULL
)
END
GO

----------------------------BEGIN CheckDBSettingsDB---------------------------
IF EXISTS(SELECT * FROM sys.columns 
            WHERE (Name = N'InternalThreads') AND Object_ID = Object_ID(N'Minion.CheckDBSettingsDB'))
BEGIN

	ALTER TABLE [Minion].[CheckDBSettingsDB] DROP CONSTRAINT [CheckDBSettingsDB_InternalThreads];
	ALTER TABLE [Minion].[CheckDBSettingsDB] DROP CONSTRAINT [DF_CheckDBSettingsDB_InternalThreads];

	EXEC sp_rename 'Minion.CheckDBSettingsDB.InternalThreads', 'DBInternalThreads', 'COLUMN';
	WAITFOR DELAY '00:00:03'; --Give it a chance to show up in the system tables.
END
GO

IF EXISTS(SELECT * FROM sys.columns 
            WHERE (Name = N'LogLoc') AND Object_ID = Object_ID(N'Minion.CheckDBSettingsDB'))
BEGIN
	EXEC sp_rename 'Minion.CheckDBSettingsDB.LogLoc', 'PushToMinion', 'COLUMN';
	WAITFOR DELAY '00:00:03'; --Give it a chance to show up in the system tables.
END
GO

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'CheckDBSettingsDB' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[CheckDBSettingsDB](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[DBName] [NVARCHAR](400) NOT NULL,
	[Port] [INT] NULL,
	[OpLevel] [VARCHAR](50) NULL,
	[OpName] [VARCHAR](50) NULL,
	[Exclude] [BIT] NULL,
	[GroupOrder] [INT] NULL,
	[GroupDBOrder] [INT] NULL,
	[NoIndex] [BIT] NULL,
	[RepairOption] [VARCHAR](50) NULL,
	[RepairOptionAgree] [BIT] NULL,
	[WithRollback] [VARCHAR](50) NULL,
	[AllErrorMsgs] [BIT] NULL,
	[ExtendedLogicalChecks] [BIT] NULL,
	[NoInfoMsgs] [BIT] NULL,
	[IsTabLock] [BIT] NULL,
	[IntegrityCheckLevel] [VARCHAR](50) NULL,
	[DisableDOP] [BIT] NULL,
	[IsRemote] [BIT] NULL,
	[IncludeRemoteInTimeLimit] [BIT] NULL,
	[PreferredServer] [VARCHAR](150) NULL,
	[PreferredServerPort] [INT] NULL,
	[PreferredDBName] [NVARCHAR](400) NULL,
	[RemoteJobName] [NVARCHAR](400) NULL,
	[RemoteCheckDBMode] [VARCHAR](25) NULL,
	[RemoteRestoreMode] [VARCHAR](50) NULL,
	[DropRemoteDB] [BIT] NULL,
	[DropRemoteJob] [BIT] NULL,
	[LockDBMode] [VARCHAR](50) NULL,
	[ResultMode] [VARCHAR](50) NULL,
	[HistRetDays] [INT] NULL,
	[PushToMinion] [BIT] NULL,
	[MinionTriggerPath] [VARCHAR](1000) NULL,
	[AutoRepair] [VARCHAR](50) NULL,
	[AutoRepairTime] [VARCHAR](25) NULL,
	[DefaultSchema] [VARCHAR](200) NULL,
	[DBPreCode] [NVARCHAR](MAX) NULL,
	[DBPostCode] [NVARCHAR](MAX) NULL,
	[TablePreCode] [NVARCHAR](MAX) NULL,
	[TablePostCode] [NVARCHAR](MAX) NULL,
	[StmtPrefix] [NVARCHAR](500) NULL,
	[StmtSuffix] [NVARCHAR](500) NULL,
	[DBInternalThreads] [TINYINT] NULL,
	[DefaultTimeEstimateMins] [INT] NULL,
	[LogSkips] [BIT] NULL,
	[BeginTime] [VARCHAR](20) NULL,
	[EndTime] [VARCHAR](20) NULL,
	[DayOfWeek] [VARCHAR](15) NULL,
	[IsActive] [BIT] NULL,
	[Comment] [VARCHAR](1000) NULL
)

ALTER TABLE [Minion].[CheckDBSettingsDB] ADD  CONSTRAINT [DF_CheckDBSettingsDB_InternalThreads]  DEFAULT ((1)) FOR [DBInternalThreads]
ALTER TABLE [Minion].[CheckDBSettingsDB]  WITH CHECK ADD  CONSTRAINT [CheckDBSettingsDB_InternalThreads] CHECK  (([DBInternalThreads]>=(1)))
ALTER TABLE [Minion].[CheckDBSettingsDB] CHECK CONSTRAINT [CheckDBSettingsDB_InternalThreads]
END
GO




----------------------------END CheckDBSettingsDB-----------------------------

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'CheckDBSettingsTable' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[CheckDBSettingsTable](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[DBName] [NVARCHAR](400) NULL,
	[SchemaName] [NVARCHAR](400) NULL,
	[TableName] [NVARCHAR](400) NULL,
	[IndexName] [NVARCHAR](400) NULL,
	[Exclude] [BIT] NULL,
	[GroupOrder] [INT] NULL,
	[GroupTableOrder] [INT] NULL,
	[DefaultTimeEstimateMins] [INT] NULL,
	[PreferredServer] [VARCHAR](150) NULL,
	[TableOrderType] [VARCHAR](50) NULL,
	[NoIndex] [BIT] NULL,
	[RepairOption] [VARCHAR](50) NULL,
	[RepairOptionAgree] [BIT] NULL,
	[AllErrorMsgs] [BIT] NULL,
	[ExtendedLogicalChecks] [BIT] NULL,
	[NoInfoMsgs] [BIT] NULL,
	[IsTabLock] [BIT] NULL,
	[ResultMode] [VARCHAR](50) NULL,
	[IntegrityCheckLevel] [VARCHAR](50) NULL,
	[HistRetDays] [INT] NULL,
	[TablePreCode] [NVARCHAR](MAX) NULL,
	[TablePostCode] [NVARCHAR](MAX) NULL,
	[StmtPrefix] [NVARCHAR](500) NULL,
	[StmtSuffix] [NVARCHAR](500) NULL,
	[BeginTime] [VARCHAR](20) NULL,
	[EndTime] [VARCHAR](20) NULL,
	[DayOfWeek] [VARCHAR](15) NULL,
	[IsActive] [BIT] NULL,
	[Comment] [VARCHAR](2000) NULL
)
END
GO

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'CheckDBSettingsRotation' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[CheckDBSettingsRotation](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[DBName] [nvarchar](400) NULL,
	[OpName] [varchar](50) NULL,
	[RotationLimiter] [varchar](50) NULL,
	[RotationLimiterMetric] [varchar](10) NULL,
	[RotationMetricValue] [int] NULL,
	[RotationPeriodInDays] [int] NULL,
	[IsActive] [bit] NULL,
	[Comment] [varchar](1000) NULL
)
END
GO

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'CheckDBRotationDBsReload' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[CheckDBRotationDBsReload](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[DBName] [nvarchar](400) NULL,
	[OpName] [varchar](50) NULL,
	[IsTail] [bit] NULL
)
END
GO

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'CheckDBRotationTablesReload' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[CheckDBRotationTablesReload](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[DBName] [nvarchar](400) NULL,
	[SchemaName] [nvarchar](400) NULL,
	[TableName] [nvarchar](400) NULL,
	[OpName] [varchar](50) NULL,
	[IsTail] [bit] NULL
)
END
GO

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'CheckDBSettingsSnapshot' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[CheckDBSettingsSnapshot](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[DBName] [NVARCHAR](400) NULL,
	[OpName] [VARCHAR](50) NULL,
	[CustomSnapshot] [BIT] NULL,
	[SnapshotRetMins] [INT] NULL,
	[SnapshotRetDeviation] [INT] NULL,
	[DeleteFinalSnapshot] [BIT] NULL,
	[SnapshotFailAction] [VARCHAR](50) NULL,
	[BeginTime] [VARCHAR](20) NULL,
	[EndTime] [VARCHAR](20) NULL,
	[DayOfWeek] [VARCHAR](15) NULL,
	[IsActive] [BIT] NULL,
	[Comment] [VARCHAR](2000) NULL
)
END
GO


IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'CheckDBSnapshotPath' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[CheckDBSnapshotPath](
	[ID] [BIGINT] IDENTITY(1,1) NOT NULL,
	[DBName] [NVARCHAR](400) NOT NULL,
	[OpName] [VARCHAR](50) NULL,
	[FileName] [VARCHAR](400) NULL,
	[SnapshotDrive] [VARCHAR](100) NULL,
	[SnapshotPath] [VARCHAR](1000) NULL,
	[ServerLabel] [VARCHAR](150) NULL,
	[PathOrder] [INT] NULL,
	[IsActive] [BIT] NULL,
	[Comment] [VARCHAR](2000) NULL
)
ALTER TABLE [Minion].[CheckDBSnapshotPath] ADD  CONSTRAINT [DF__CheckDB__PathO__145C0A3F]  DEFAULT ((1)) FOR [PathOrder]
END
GO

--------------------------BEGIN CheckDBSnapshotLog-------------------

IF EXISTS(SELECT * FROM sys.columns 
            WHERE (Name = N'MaxSizeInMB') AND Object_ID = Object_ID(N'Minion.CheckDBSnapshotLog'))
BEGIN
	DROP TABLE Minion.CheckDBSnapshotLog;
END
GO

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'CheckDBSnapshotLog' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[CheckDBSnapshotLog](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [DATETIME] NULL,
	[OpName] [VARCHAR](50) NULL,
	[DBName] [NVARCHAR](400) NULL,
	[SnapshotDBName] [NVARCHAR](400) NULL,
	[FileID] [INT] NULL,
	[TypeDesc] [VARCHAR](25) NULL,
	[Name] [VARCHAR](200) NULL,
	[PhysicalName] [VARCHAR](8000) NULL,
	[Size] [BIGINT] NULL,
	[IsReadOnly] [BIT] NULL,
	[IsSparse] [BIT] NULL,
	[SnapshotDrive] [VARCHAR](100) NULL,
	[SnapshotPath] [VARCHAR](1000) NULL,
	[FullPath] [VARCHAR](8000) NULL,
	[ServerLabel] [VARCHAR](150) NULL,
	[PathOrder] [INT] NULL,
	[Cmd] [NVARCHAR](MAX) NULL,
	[SizeInKB] BIGINT NULL,
	[MaxSizeInKB] BIGINT NULL
)
END
GO

--------------------------END CheckDBSnapshotLog---------------------

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'CheckDBTableSnapshotQueue' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[CheckDBTableSnapshotQueue](
	[ExecutionDateTime] [datetime] NULL,
	[DBName] [nvarchar](400) NULL,
	[LatestSnapshotDateTime] [datetime] NULL,
	[SnapshotDBName] [varchar](400) NULL,
	[Owner] [tinyint] NULL
)
END
GO


IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'CheckDBThreadQueue' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[CheckDBThreadQueue](
	[ID] [smallint] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[DBName] [nvarchar](400) NULL,
	[OpName] [varchar](50) NULL,
	[DBInternalThreads] [tinyint] NULL,
	[IsReadOnly] [bit] NULL,
	[StateDesc] [varchar](50) NULL,
	[CheckDBGroupOrder] [int] NULL,
	[CheckDBOrder] [int] NULL,
	[Processing] [bit] NULL,
	[ProcessingThread] [tinyint] NULL
)
END
GO

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'Work' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[Work](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[Module] [varchar](20) NULL,
	[DBName] [nvarchar](400) NOT NULL,
	[BackupType] [varchar](20) NULL,
	[Param] [varchar](100) NULL,
	[SPName] [varchar](100) NULL,
	[Value] [varchar](max) NULL
)
END
GO

-------------------------BEGIN CheckDBCheckTableResult----------------------------
IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'CheckDBCheckTableResult' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[CheckDBCheckTableResult](
	[ExecutionDateTime] [datetime] NULL,
	[DBName] [nvarchar](400) NULL,
	[SchemaName] [varchar](400) NULL,
	[TableName] [nvarchar](400) NULL,
	[IndexName] [nvarchar](400) NULL,
	[IndexType] [varchar](50) NULL,
	[BeginTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[Error] [int] NULL,
	[Level] [int] NULL,
	[State] [int] NULL,
	[MessageText] [varchar](7000) NULL,
	[RepairLevel] [nvarchar](50) NULL,
	[Status] [int] NULL,
	[DbId] [int] NULL,
	[DbFragId] [int] NULL,
	[ObjectId] [bigint] NULL,
	[IndexID] [int] NULL,
	[PartitionId] [bigint] NULL,
	[AllocUnitId] [bigint] NULL,
	[RidDBId] [int] NULL,
	[RidPruId] [int] NULL,
	[File] [int] NULL,
	[Page] [bigint] NULL,
	[Slot] [bigint] NULL,
	[RefDbId] [int] NULL,
	[RefPruId] [int] NULL,
	[RefFile] [bigint] NULL,
	[RefPage] [bigint] NULL,
	[RefSlot] [bigint] NULL,
	[Allocation] [int] NULL
)
END
GO

IF EXISTS (SELECT name FROM sys.objects WHERE name = 'CheckTableResult' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
	DROP TABLE [Minion].[CheckTableResult]
END
GO

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'CheckDBDebug' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[CheckDBDebug](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[DBName] [nvarchar](400) NULL,
	[OpName] [varchar](50) NULL,
	[SPName] [varchar](50) NULL,
	[StepName] [varchar](100) NULL,
	[StepValue] [varchar](max) NULL
)
END
GO

-------------------------END CheckDBCheckTableResult------------------------------

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'CheckDBSettingsServer' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[CheckDBSettingsServer](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DBType] [varchar](6) NULL,
	[OpName] [varchar](20) NULL,
	[Day] [varchar](50) NULL,
	[ReadOnly] [tinyint] NULL,
	[BeginTime] [varchar](20) NOT NULL,
	[EndTime] [varchar](20) NOT NULL,
	[MaxForTimeframe] [int] NULL,
	[FrequencyMins] [int] NULL,
	[CurrentNumOps] [int] NULL,
	[NumConcurrentOps] [tinyint] NULL,
	[DBInternalThreads] [tinyint] NULL,
	[TimeLimitInMins] [int] NULL,
	[LastRunDateTime] [datetime] NULL,
	[Include] [nvarchar](2000) NULL,
	[Exclude] [nvarchar](2000) NULL,
	[Schemas] [nvarchar](2000) NULL,
	[Tables] [nvarchar](2000) NULL,
	[BatchPreCode] [varchar](max) NULL,
	[BatchPostCode] [varchar](max) NULL,
	[Debug] [bit] NULL,
	[FailJobOnError] [bit] NULL,
	[FailJobOnWarning] [bit] NULL,
	[IsActive] [bit] NULL,
	[Comment] [varchar](2000) NULL,
 CONSTRAINT [PK_CheckDBSettingsServer] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
)
ALTER TABLE [Minion].[CheckDBSettingsServer]  WITH CHECK ADD  CONSTRAINT [CK_CheckDBBeginTimeFormat] CHECK  (([BeginTime] like '[2][0-3]:[0-5][0-9]:[0-5][0-9]' OR [BeginTime] like '[2][0-3]:[0-5][0-9]:[0-5][0-9]:[0-9][0-9][0-9]' OR [BeginTime] like '[0-1][0-9]:[0-5][0-9]:[0-5][0-9]' OR [BeginTime] like '[0-1][0-9]:[0-5][0-9]:[0-5][0-9]:[0-9][0-9][0-9]' OR [BeginTime] IS NULL))
ALTER TABLE [Minion].[CheckDBSettingsServer] CHECK CONSTRAINT [CK_CheckDBBeginTimeFormat]
ALTER TABLE [Minion].[CheckDBSettingsServer]  WITH CHECK ADD  CONSTRAINT [CK_CheckDBEndTimeFormat] CHECK  (([EndTime] like '[2][0-3]:[0-5][0-9]:[0-5][0-9]' OR [EndTime] like '[2][0-3]:[0-5][0-9]:[0-5][0-9]:[0-9][0-9][0-9]' OR [EndTime] like '[0-1][0-9]:[0-5][0-9]:[0-5][0-9]' OR [EndTime] like '[0-1][0-9]:[0-5][0-9]:[0-5][0-9]:[0-9][0-9][0-9]' OR [EndTime] IS NULL))
ALTER TABLE [Minion].[CheckDBSettingsServer] CHECK CONSTRAINT [CK_CheckDBEndTimeFormat]
END
GO

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'CheckDBSettingsRemoteThresholds' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[CheckDBSettingsRemoteThresholds](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DBName] [nvarchar](400) NULL,
	[ThresholdType] [varchar](20) NULL,
	[ThresholdMeasure] [varchar](5) NULL,
	[ThresholdValue] [int] NULL,
	[IsActive] [bit] NULL,
	[Comment] [varchar](2000) NULL
)
END
GO
IF EXISTS(SELECT * FROM sys.columns 
            WHERE (Name = N'DBName') AND Object_ID = Object_ID(N'Minion.CheckDBSettingsRemoteThresholds'))
BEGIN
	ALTER TABLE Minion.CheckDBSettingsRemoteThresholds ALTER COLUMN [DBName] NVARCHAR(400) NULL;  
END
GO

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'CheckDBCheckTableThreadQueue' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[CheckDBCheckTableThreadQueue](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [DATETIME] NULL,
	[DBName] [NVARCHAR](400) NULL,
	[SchemaName] [VARCHAR](400) NULL,
	[TableName] [VARCHAR](400) NULL,
	[IndexName] [VARCHAR](400) NULL,
	[Exclude] [BIT] NULL,
	[GroupOrder] [INT] NULL,
	[GroupDBOrder] [INT] NULL,
	[TimeEstimateSecs] [INT] NULL,
	[SizeInMB] [FLOAT] NULL,
	[EstimatedKBperMS] [FLOAT] NULL,
	[LastOpTimeInSecs] [INT] NULL,
	[NoIndex] [BIT] NULL,
	[RepairOption] [VARCHAR](50) NULL,
	[RepairOptionAgree] [BIT] NULL,
	[AllErrorMsgs] [BIT] NULL,
	[ExtendedLogicalChecks] [BIT] NULL,
	[NoInfoMsgs] [BIT] NULL,
	[IsTabLock] [BIT] NULL,
	[ResultMode] [VARCHAR](50) NULL,
	[IntegrityCheckLevel] [VARCHAR](50) NULL,
	[HistRetDays] [INT] NULL,
	[TablePreCode] [VARCHAR](MAX) NULL,
	[TablePostCode] [VARCHAR](MAX) NULL,
	[StmtPrefix] [NVARCHAR](500) NULL,
	[StmtSuffix] [NVARCHAR](500) NULL,
	[PreferredServer] [VARCHAR](150) NULL,
	[Processing] [BIT] NULL,
	[ProcessingThread] [TINYINT] NULL
)
END
GO
IF EXISTS(SELECT * FROM sys.columns 
            WHERE (Name = N'DBName') AND Object_ID = Object_ID(N'Minion.CheckDBCheckTableThreadQueue'))
BEGIN
	ALTER TABLE Minion.CheckDBCheckTableThreadQueue ALTER COLUMN [DBName] NVARCHAR(400) NULL;  
END
GO



IF EXISTS (SELECT name FROM sys.objects WHERE name = 'CheckDBTableSizeTemp' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
	DROP TABLE Minion.CheckDBTableSizeTemp;
END
GO
IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'CheckDBTableSizeTemp' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[CheckDBTableSizeTemp](
	[ExecutionDateTime] [datetime] NULL,
	[DBName] [nvarchar](400) NULL,
	[SchemaName] [sysname] NULL,
	[TableName] [sysname] NOT NULL,
	[RowCT] [bigint] NULL,
	[TotalSpaceKB] [numeric](20, 1) NULL,
	[UsedSpaceKB] [bigint] NULL,
	[UnusedSpaceKB] [bigint] NULL
)
END
GO


SET ANSI_PADDING OFF
GO
