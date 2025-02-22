SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'DBMaintDBGroups' and SCHEMA_NAME(schema_id) = 'Minion')
CREATE TABLE [Minion].[DBMaintDBGroups](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Action] [varchar](10) NULL,
	[MaintType] [varchar](20) NULL,
	[GroupName] [varchar](200) NULL,
	[GroupDef] [varchar](400) NULL,
	[Escape] [char](1) NULL,
	[IsActive] [bit] NULL,
	[Comment] [varchar](2000) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Minion].[DBMaintRegexLookup]    Script Date: 2/23/2017 2:34:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'DBMaintRegexLookup' and SCHEMA_NAME(schema_id) = 'Minion')
CREATE TABLE [Minion].[DBMaintRegexLookup](
	[Action] [varchar](10) NULL,
	[MaintType] [varchar](20) NULL,
	[Regex] [nvarchar](2000) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Minion].[HELPObjectDetail]    Script Date: 2/23/2017 2:34:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'HELPObjectDetail' and SCHEMA_NAME(schema_id) = 'Minion')
CREATE TABLE  [Minion].[HELPObjectDetail](
	[ObjectID] [int] NULL,
	[DetailName] [varchar](100) NULL,
	[GlobalPosition] [smallint] NULL,
	[Position] [smallint] NULL,
	[DetailType] [sysname] NULL,
	[DetailHeader] [varchar](100) NULL,
	[DetailText] [varchar](max) NULL,
	[DataType] [varchar](20) NULL,
	[DetailTextHTML] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Minion].[HELPObjects]    Script Date: 2/23/2017 2:34:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'HELPObjects' and SCHEMA_NAME(schema_id) = 'Minion')
CREATE TABLE  [Minion].[HELPObjects](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Module] [varchar](50) NULL,
	[ObjectName] [varchar](100) NULL,
	[ObjectType] [varchar](100) NULL,
	[MinionVersion] [float] NULL,
	[GlobalPosition] [int] NULL,
 CONSTRAINT [PK__Objects__3214EC27E83D3C4F] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 95) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Minion].[IndexMaintLog]    Script Date: 2/23/2017 2:34:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'IndexMaintLog' and SCHEMA_NAME(schema_id) = 'Minion')
CREATE TABLE  [Minion].[IndexMaintLog](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[Status] [nvarchar](max) NULL,
	[DBName] [nvarchar](400) NOT NULL,
	[Tables] [varchar](7) NULL,
	[RunPrepped] [bit] NULL,
	[PrepOnly] [bit] NULL,
	[ReorgMode] [varchar](7) NULL,
	[NumTablesProcessed] [int] NULL,
	[NumIndexesProcessed] [int] NULL,
	[NumIndexesRebuilt] [int] NULL,
	[NumIndexesReorged] [int] NULL,
	[RecoveryModelChanged] [bit] NULL,
	[RecoveryModelCurrent] [varchar](12) NULL,
	[RecoveryModelReindex] [varchar](12) NULL,
	[SQLVersion] [varchar](20) NULL,
	[SQLEdition] [varchar](50) NULL,
	[DBPreCode] [nvarchar](max) NULL,
	[DBPostCode] [nvarchar](max) NULL,
	[DBPreCodeBeginDateTime] [datetime] NULL,
	[DBPreCodeEndDateTime] [datetime] NULL,
	[DBPostCodeBeginDateTime] [datetime] NULL,
	[DBPostCodeEndDateTime] [datetime] NULL,
	[DBPreCodeRunTimeInSecs] [int] NULL,
	[DBPostCodeRunTimeInSecs] [int] NULL,
	[ExecutionFinishTime] [datetime] NULL,
	[ExecutionRunTimeInSecs] [int] NULL,
	[IncludeDBs] [nvarchar](max) NULL,
	[ExcludeDBs] [nvarchar](max) NULL,
	[RegexDBsIncluded] [nvarchar](max) NULL,
	[RegexDBsExcluded] [nvarchar](max) NULL,
	[Warnings] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO


SET ANSI_PADDING OFF
GO
/****** Object:  Table [Minion].[IndexMaintLogDetails]    Script Date: 2/23/2017 2:34:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'IndexMaintLogDetails' and SCHEMA_NAME(schema_id) = 'Minion')
CREATE TABLE  [Minion].[IndexMaintLogDetails](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NOT NULL,
	[Status] [varchar](max) NULL,
	[DBName] [nvarchar](400) NULL,
	[TableID] [bigint] NULL,
	[SchemaName] [nvarchar](400) NULL,
	[TableName] [nvarchar](400) NULL,
	[IndexID] [int] NULL,
	[IndexName] [nvarchar](400) NULL,
	[IndexTypeDesc] [varchar](50) NULL,
	[IndexScanMode] [varchar](25) NULL,
	[Op] [varchar](10) NULL,
	[ONLINEopt] [varchar](3) NULL,
	[ReorgThreshold] [tinyint] NULL,
	[RebuildThreshold] [tinyint] NULL,
	[FILLFACTORopt] [tinyint] NULL,
	[PadIndex] [varchar](3) NULL,
	[FragLevel] [tinyint] NULL,
	[Stmt] [nvarchar](1000) NULL,
	[ReindexGroupOrder] [int] NULL,
	[ReindexOrder] [int] NULL,
	[PreCode] [nvarchar](max) NULL,
	[PostCode] [nvarchar](max) NULL,
	[OpBeginDateTime] [datetime] NULL,
	[OpEndDateTime] [datetime] NULL,
	[OpRunTimeInSecs] [int] NULL,
	[TableRowCTBeginDateTime] [datetime] NULL,
	[TableRowCTEndDateTime] [datetime] NULL,
	[TableRowCTTimeInSecs] [int] NULL,
	[TableRowCT] [bigint] NULL,
	[PostFragBeginDateTime] [datetime] NULL,
	[PostFragEndDateTime] [datetime] NULL,
	[PostFragTimeInSecs] [int] NULL,
	[PostFragLevel] [tinyint] NULL,
	[UpdateStatsBeginDateTime] [datetime] NULL,
	[UpdateStatsEndDateTime] [datetime] NULL,
	[UpdateStatsTimeInSecs] [int] NULL,
	[UpdateStatsStmt] [nvarchar](1000) NULL,
	[PreCodeBeginDateTime] [datetime] NULL,
	[PreCodeEndDateTime] [datetime] NULL,
	[PreCodeRunTimeInSecs] [int] NULL,
	[PostCodeBeginDateTime] [datetime] NULL,
	[PostCodeEndDateTime] [datetime] NULL,
	[PostCodeRunTimeInSecs] [bigint] NULL,
	[UserSeeks] [bigint] NULL,
	[UserScans] [bigint] NULL,
	[UserLookups] [bigint] NULL,
	[UserUpdates] [bigint] NULL,
	[LastUserSeek] [datetime] NULL,
	[LastUserScan] [datetime] NULL,
	[LastUserLookup] [datetime] NULL,
	[LastUserUpdate] [datetime] NULL,
	[SystemSeeks] [bigint] NULL,
	[SystemScans] [bigint] NULL,
	[SystemLookups] [bigint] NULL,
	[SystemUpdates] [bigint] NULL,
	[LastSystemSeek] [datetime] NULL,
	[LastSystemScan] [datetime] NULL,
	[LastSystemLookup] [datetime] NULL,
	[LastSystemUpdate] [datetime] NULL,
	[Warnings] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

SET ANSI_PADDING OFF
GO
/****** Object:  Table [Minion].[IndexMaintSettingsServer]    Script Date: 2/23/2017 2:34:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'IndexMaintSettingsServer' and SCHEMA_NAME(schema_id) = 'Minion')
CREATE TABLE  [Minion].[IndexMaintSettingsServer](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DBType] [varchar](6) NULL,
	[IndexOption] [varchar](100) NULL,
	[ReorgMode] [varchar](7) NULL,
	[RunPrepped] [bit] NULL,
	[PrepOnly] [bit] NULL,
	[Day] [varchar](50) NULL,
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
	[BatchPreCode] [nvarchar](max) NULL,
	[BatchPostCode] [nvarchar](max) NULL,
	[Debug] [bit] NULL,
	[FailJobOnError] [bit] NULL,
	[FailJobOnWarning] [bit] NULL,
	[IsActive] [bit] NULL,
	[Comment] [varchar](2000) NULL,
 CONSTRAINT [PK_IndexMaintSettingsServer] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Minion].[IndexPhysicalStats]    Script Date: 2/23/2017 2:34:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'IndexPhysicalStats' and SCHEMA_NAME(schema_id) = 'Minion')
CREATE TABLE  [Minion].[IndexPhysicalStats](
	[ExecutionDateTime] [datetime] NULL,
	[IndexScanMode] [varchar](25) NULL,
	[DBName] [nvarchar](400) NOT NULL,
	[SchemaName] [nvarchar](400) NOT NULL,
	[TableName] [nvarchar](400) NOT NULL,
	[IndexName] [nvarchar](400) NOT NULL,
	[database_id] [smallint] NULL,
	[object_id] [int] NULL,
	[index_id] [int] NULL,
	[partition_number] [int] NULL,
	[index_type_desc] [nvarchar](60) NULL,
	[alloc_unit_type_desc] [nvarchar](60) NULL,
	[index_depth] [tinyint] NULL,
	[index_level] [tinyint] NULL,
	[avg_fragmentation_in_percent] [float] NULL,
	[fragment_count] [bigint] NULL,
	[avg_fragment_size_in_pages] [float] NULL,
	[page_count] [bigint] NULL,
	[avg_page_space_used_in_percent] [float] NULL,
	[record_count] [bigint] NULL,
	[ghost_record_count] [bigint] NULL,
	[version_ghost_record_count] [bigint] NULL,
	[min_record_size_in_bytes] [int] NULL,
	[max_record_size_in_bytes] [int] NULL,
	[avg_record_size_in_bytes] [float] NULL,
	[forwarded_record_count] [bigint] NULL,
	[compressed_page_count] [bigint] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Minion].[IndexSettingsDB]    Script Date: 2/23/2017 2:34:53 PM ******/
------------------------------------------------------------------------------------
-- Upgrading from 1.1 xyz
------------------------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sys.objects
    WHERE name = 'IndexSettingsDB'
          AND SCHEMA_NAME(schema_id) = 'Minion'
)
   AND (
           (
               SELECT MAX(MinionVersion)
               FROM Minion.HELPObjects
               WHERE Module = 'Reindex'
           ) = 1.1
           OR NOT EXISTS
(
    SELECT *
    FROM sys.columns
    WHERE name = 'Port'
          AND OBJECT_NAME(object_id) = 'IndexSettingsDB'
)
       )
BEGIN

    BEGIN TRANSACTION;
    SET QUOTED_IDENTIFIER ON;
    SET ARITHABORT ON;
    SET NUMERIC_ROUNDABORT OFF;
    SET CONCAT_NULL_YIELDS_NULL ON;
    SET ANSI_NULLS ON;
    SET ANSI_PADDING ON;
    SET ANSI_WARNINGS ON;
    COMMIT;

    BEGIN TRANSACTION;

    CREATE TABLE Minion.Tmp_IndexSettingsDB
    (
        ID INT NOT NULL IDENTITY(1, 1),
        DBName sysname NOT NULL,
        Port INT NULL,
        Exclude BIT NULL,
        ReindexGroupOrder TINYINT NULL,
        ReindexOrder INT NULL,
        ReorgThreshold TINYINT NULL,
        RebuildThreshold TINYINT NULL,
        FILLFACTORopt TINYINT NULL,
        PadIndex VARCHAR(3) NULL,
        ONLINEopt VARCHAR(3) NULL,
        SortInTempDB VARCHAR(3) NULL,
        MAXDOPopt TINYINT NULL,
        DataCompression VARCHAR(50) NULL,
        GetRowCT BIT NULL,
        GetPostFragLevel BIT NULL,
        UpdateStatsOnDefrag BIT NULL,
        StatScanOption VARCHAR(25) NULL,
        IgnoreDupKey VARCHAR(3) NULL,
        StatsNoRecompute VARCHAR(3) NULL,
        AllowRowLocks VARCHAR(3) NULL,
        AllowPageLocks VARCHAR(3) NULL,
        WaitAtLowPriority BIT NULL,
        MaxDurationInMins INT NULL,
        AbortAfterWait VARCHAR(20) NULL,
        PushToMinion BIT NULL,
        LogIndexPhysicalStats BIT NULL,
        IndexScanMode VARCHAR(25) NULL,
        DBPreCode NVARCHAR(MAX) NULL,
        DBPostCode NVARCHAR(MAX) NULL,
        TablePreCode NVARCHAR(MAX) NULL,
        TablePostCode NVARCHAR(MAX) NULL,
        LogProgress BIT NULL,
        LogRetDays SMALLINT NULL,
        LogLoc VARCHAR(25) NULL,
        MinionTriggerPath VARCHAR(1000) NULL,
        RecoveryModel VARCHAR(12) NULL,
        IncludeUsageDetails BIT NULL
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];

    ALTER TABLE Minion.Tmp_IndexSettingsDB SET (LOCK_ESCALATION = TABLE);

    SET IDENTITY_INSERT Minion.Tmp_IndexSettingsDB ON;

    IF EXISTS (SELECT * FROM Minion.IndexSettingsDB)
        EXEC ('INSERT INTO Minion.Tmp_IndexSettingsDB (ID, DBName, Exclude, ReindexGroupOrder, ReindexOrder, ReorgThreshold, RebuildThreshold, FILLFACTORopt, PadIndex, ONLINEopt, SortInTempDB, MAXDOPopt, DataCompression, GetRowCT, GetPostFragLevel, UpdateStatsOnDefrag, StatScanOption, IgnoreDupKey, StatsNoRecompute, AllowRowLocks, AllowPageLocks, WaitAtLowPriority, MaxDurationInMins, AbortAfterWait, PushToMinion, LogIndexPhysicalStats, IndexScanMode, DBPreCode, DBPostCode, TablePreCode, TablePostCode, LogProgress, LogRetDays, LogLoc, MinionTriggerPath, RecoveryModel, IncludeUsageDetails)
		SELECT ID, DBName, Exclude, ReindexGroupOrder, ReindexOrder, ReorgThreshold, RebuildThreshold, FILLFACTORopt, PadIndex, ONLINEopt, SortInTempDB, MAXDOPopt, DataCompression, GetRowCT, GetPostFragLevel, UpdateStatsOnDefrag, StatScanOption, IgnoreDupKey, StatsNoRecompute, AllowRowLocks, AllowPageLocks, WaitAtLowPriority, MaxDurationInMins, AbortAfterWait, PushToMinion, LogIndexPhysicalStats, IndexScanMode, DBPreCode, DBPostCode, TablePreCode, TablePostCode, LogProgress, LogRetDays, LogLoc, MinionTriggerPath, RecoveryModel, IncludeUsageDetails FROM Minion.IndexSettingsDB WITH (HOLDLOCK TABLOCKX)');

    SET IDENTITY_INSERT Minion.Tmp_IndexSettingsDB OFF;

    DROP TABLE Minion.IndexSettingsDB;

    EXECUTE sp_rename N'Minion.Tmp_IndexSettingsDB',
        N'IndexSettingsDB',
        'OBJECT';

    ALTER TABLE Minion.IndexSettingsDB
    ADD CONSTRAINT ckRebuildGTReorg CHECK ((
                                              [RebuildThreshold] > [ReorgThreshold]
                                          ));

    COMMIT;
END;

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------



------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'IndexSettingsDB' and SCHEMA_NAME(schema_id) = 'Minion')
CREATE TABLE  [Minion].[IndexSettingsDB](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DBName] [nvarchar](400) NOT NULL,
	[Port] [int] NULL,
	[Exclude] [bit] NULL,
	[ReindexGroupOrder] [tinyint] NULL,
	[ReindexOrder] [int] NULL,
	[ReorgThreshold] [tinyint] NULL,
	[RebuildThreshold] [tinyint] NULL,
	[FILLFACTORopt] [tinyint] NULL,
	[PadIndex] [varchar](3) NULL,
	[ONLINEopt] [varchar](3) NULL,
	[SortInTempDB] [varchar](3) NULL,
	[MAXDOPopt] [tinyint] NULL,
	[DataCompression] [varchar](50) NULL,
	[GetRowCT] [bit] NULL,
	[GetPostFragLevel] [bit] NULL,
	[UpdateStatsOnDefrag] [bit] NULL,
	[StatScanOption] [varchar](25) NULL,
	[IgnoreDupKey] [varchar](3) NULL,
	[StatsNoRecompute] [varchar](3) NULL,
	[AllowRowLocks] [varchar](3) NULL,
	[AllowPageLocks] [varchar](3) NULL,
	[WaitAtLowPriority] [bit] NULL,
	[MaxDurationInMins] [int] NULL,
	[AbortAfterWait] [varchar](20) NULL,
	[PushToMinion] [bit] NULL,
	[LogIndexPhysicalStats] [bit] NULL,
	[IndexScanMode] [varchar](25) NULL,
	[DBPreCode] [nvarchar](max) NULL,
	[DBPostCode] [nvarchar](max) NULL,
	[TablePreCode] [nvarchar](max) NULL,
	[TablePostCode] [nvarchar](max) NULL,
	[LogProgress] [bit] NULL,
	[LogRetDays] [smallint] NULL,
	[MinionTriggerPath] [varchar](1000) NULL,
	[RecoveryModel] [varchar](12) NULL,
	[IncludeUsageDetails] [bit] NULL,
	[StmtPrefix] [nvarchar](500) NULL,
	[StmtSuffix] [nvarchar](500) NULL,
	[RebuildHeap] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Minion].[IndexSettingsTable]    Script Date: 2/23/2017 2:34:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'IndexSettingsTable' and SCHEMA_NAME(schema_id) = 'Minion')
CREATE TABLE  [Minion].[IndexSettingsTable](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DBName] [nvarchar](400) NOT NULL,
	[SchemaName] [nvarchar](400) NOT NULL,
	[TableName] [nvarchar](400) NOT NULL,
	[Exclude] [bit] NULL,
	[ReindexGroupOrder] [int] NULL,
	[ReindexOrder] [int] NULL,
	[ReorgThreshold] [tinyint] NULL,
	[RebuildThreshold] [tinyint] NULL,
	[FILLFACTORopt] [tinyint] NULL,
	[PadIndex] [varchar](3) NULL,
	[ONLINEopt] [varchar](3) NULL,
	[SortInTempDB] [varchar](3) NULL,
	[MAXDOPopt] [tinyint] NULL,
	[DataCompression] [varchar](50) NULL,
	[GetRowCT] [bit] NULL,
	[GetPostFragLevel] [bit] NULL,
	[UpdateStatsOnDefrag] [bit] NULL,
	[StatScanOption] [varchar](25) NULL,
	[IgnoreDupKey] [varchar](3) NULL,
	[StatsNoRecompute] [varchar](3) NULL,
	[AllowRowLocks] [varchar](3) NULL,
	[AllowPageLocks] [varchar](3) NULL,
	[WaitAtLowPriority] [bit] NULL,
	[MaxDurationInMins] [int] NULL,
	[AbortAfterWait] [varchar](20) NULL,
	[PushToMinion] [bit] NULL,
	[LogIndexPhysicalStats] [bit] NULL,
	[IndexScanMode] [varchar](25) NULL,
	[TablePreCode] [nvarchar](max) NULL,
	[TablePostCode] [nvarchar](max) NULL,
	[LogProgress] [bit] NULL,
	[LogRetDays] [smallint] NULL,
	[PartitionReindex] [bit] NULL,
	[isLOB] [bit] NULL,
	[TableType] [char](1) NULL,
	[IncludeUsageDetails] [bit] NULL,
	[StmtPrefix] [nvarchar](500) NULL,
	[StmtSuffix] [nvarchar](500) NULL,
	[RebuildHeap] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Minion].[IndexTableFrag]    Script Date: 2/23/2017 2:34:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'IndexTableFrag' and SCHEMA_NAME(schema_id) = 'Minion')
CREATE TABLE  [Minion].[IndexTableFrag](
	[ExecutionDateTime] [datetime] NOT NULL,
	[DBName] [nvarchar](400) NOT NULL,
	[DBID] [int] NOT NULL,
	[TableID] [bigint] NOT NULL,
	[SchemaName] [nvarchar](400) NOT NULL,
	[TableName] [nvarchar](400) NOT NULL,
	[IndexName] [nvarchar](400) NOT NULL,
	[IndexID] [bigint] NOT NULL,
	[IndexType] [tinyint] NULL,
	[IndexTypeDesc] [nvarchar](120) NULL,
	[IsDisabled] [bit] NULL,
	[IsHypothetical] [bit] NULL,
	[avg_fragmentation_in_percent] [float] NULL,
	[ReorgThreshold] [tinyint] NULL,
	[RebuildThreshold] [tinyint] NULL,
	[FILLFACTORopt] [tinyint] NULL,
	[PadIndex] [varchar](3) NULL,
	[ONLINEopt] [varchar](3) NULL,
	[SortInTempDB] [varchar](3) NULL,
	[MAXDOPopt] [tinyint] NULL,
	[DataCompression] [varchar](50) NULL,
	[GetRowCT] [bit] NULL,
	[GetPostFragLevel] [bit] NULL,
	[UpdateStatsOnDefrag] [bit] NULL,
	[StatScanOption] [varchar](25) NULL,
	[IgnoreDupKey] [varchar](3) NULL,
	[StatsNoRecompute] [varchar](3) NULL,
	[AllowRowLocks] [varchar](3) NULL,
	[AllowPageLocks] [varchar](3) NULL,
	[WaitAtLowPriority] [bit] NULL,
	[MaxDurationInMins] [int] NULL,
	[AbortAfterWait] [varchar](20) NULL,
	[LogProgress] [bit] NULL,
	[LogRetDays] [smallint] NULL,
	[PushToMinion] [bit] NULL,
	[LogIndexPhysicalStats] [bit] NULL,
	[IndexScanMode] [varchar](25) NULL,
	[TablePreCode] [nvarchar](max) NULL,
	[TablePostCode] [nvarchar](max) NULL,
	[Prepped] [bit] NULL,
	[ReindexGroupOrder] [int] NULL,
	[ReindexOrder] [int] NULL,
	[StmtPrefix] [nvarchar](500) NULL,
	[StmtSuffix] [nvarchar](500) NULL,
	[RebuildHeap] [bit] NULL,
 CONSTRAINT [PK_IndexTableFrag] PRIMARY KEY CLUSTERED 
(
	[ExecutionDateTime] ASC,
	[DBName] ASC,
	[TableID] ASC,
	[IndexID] ASC
)WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO

---------------------------------------------------------------------
---------------------------------------------------------------------
---------------------------------------------------------------------

IF EXISTS
(
    SELECT *
    FROM sys.foreign_keys
    WHERE name = 'FK_ObjectDetail_Objects_ID'
          AND OBJECT_NAME(parent_object_id) = 'HELPObjectDetail'
          AND SCHEMA_NAME(schema_id) = 'Minion'
)
    ALTER TABLE [Minion].[HELPObjectDetail]
    DROP CONSTRAINT [FK_ObjectDetail_Objects_ID];

ALTER TABLE [Minion].[HELPObjectDetail]  WITH CHECK ADD  CONSTRAINT [FK_ObjectDetail_Objects_ID] 
FOREIGN KEY([ObjectID])
REFERENCES [Minion].[HELPObjects] ([ID])
GO
---------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sys.check_constraints
    WHERE name = 'CK_IndexMaintBeginTimeFormat'
          AND OBJECT_NAME(parent_object_id) = 'IndexMaintSettingsServer'
          AND SCHEMA_NAME(schema_id) = 'Minion'
)
    ALTER TABLE [Minion].[IndexMaintSettingsServer]
    DROP CONSTRAINT [CK_IndexMaintBeginTimeFormat];

ALTER TABLE [Minion].[IndexMaintSettingsServer]  WITH CHECK ADD  CONSTRAINT [CK_IndexMaintBeginTimeFormat] CHECK  (([BeginTime] like '[2][0-3]:[0-5][0-9]:[0-5][0-9]' OR [BeginTime] like '[2][0-3]:[0-5][0-9]:[0-5][0-9]:[0-9][0-9][0-9]' OR [BeginTime] like '[0-1][0-9]:[0-5][0-9]:[0-5][0-9]' OR [BeginTime] like '[0-1][0-9]:[0-5][0-9]:[0-5][0-9]:[0-9][0-9][0-9]' OR [BeginTime] IS NULL))
GO
ALTER TABLE [Minion].[IndexMaintSettingsServer] CHECK CONSTRAINT [CK_IndexMaintBeginTimeFormat]
GO
---------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sys.check_constraints
    WHERE name = 'CK_IndexMaintEndTimeFormat'
          AND OBJECT_NAME(parent_object_id) = 'IndexMaintSettingsServer'
          AND SCHEMA_NAME(schema_id) = 'Minion'
)
	ALTER TABLE [Minion].[IndexMaintSettingsServer] DROP CONSTRAINT [CK_IndexMaintEndTimeFormat];
ALTER TABLE [Minion].[IndexMaintSettingsServer]  WITH CHECK ADD  CONSTRAINT [CK_IndexMaintEndTimeFormat] CHECK  (([EndTime] like '[2][0-3]:[0-5][0-9]:[0-5][0-9]' OR [EndTime] like '[2][0-3]:[0-5][0-9]:[0-5][0-9]:[0-9][0-9][0-9]' OR [EndTime] like '[0-1][0-9]:[0-5][0-9]:[0-5][0-9]' OR [EndTime] like '[0-1][0-9]:[0-5][0-9]:[0-5][0-9]:[0-9][0-9][0-9]' OR [EndTime] IS NULL))
GO
ALTER TABLE [Minion].[IndexMaintSettingsServer] CHECK CONSTRAINT [CK_IndexMaintEndTimeFormat]
GO
---------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sys.check_constraints
    WHERE name = 'ckRebuildGTReorg'
          AND OBJECT_NAME(parent_object_id) = 'IndexSettingsDB'
          AND SCHEMA_NAME(schema_id) = 'Minion'
)
ALTER TABLE [Minion].[IndexSettingsDB] DROP CONSTRAINT [ckRebuildGTReorg];
ALTER TABLE [Minion].[IndexSettingsDB]  WITH CHECK ADD  CONSTRAINT [ckRebuildGTReorg] CHECK  (([RebuildThreshold]>[ReorgThreshold]))
GO
ALTER TABLE [Minion].[IndexSettingsDB] CHECK CONSTRAINT [ckRebuildGTReorg]
GO
---------------------------------------------------------------------
IF EXISTS
(
    SELECT *
    FROM sys.check_constraints
    WHERE name = 'ckRbuildGTReorgTable'
          AND OBJECT_NAME(parent_object_id) = 'IndexSettingsTable'
          AND SCHEMA_NAME(schema_id) = 'Minion'
)
	ALTER TABLE [Minion].[IndexSettingsTable] DROP CONSTRAINT [ckRbuildGTReorgTable];
ALTER TABLE [Minion].[IndexSettingsTable]  WITH CHECK ADD  CONSTRAINT [ckRbuildGTReorgTable] CHECK  (([RebuildThreshold]>[ReorgThreshold]))
GO
ALTER TABLE [Minion].[IndexSettingsTable] CHECK CONSTRAINT [ckRbuildGTReorgTable]
GO


-----------------------------------------------------
-- Add/remove columns as needed:
IF EXISTS ( SELECT * FROM sys.columns AS c
	JOIN sys.objects AS o ON o.object_id = c.object_id
	WHERE c.name = 'LogLoc'
          AND o.name = 'IndexSettingsDB'
	  AND SCHEMA_NAME(o.schema_id) = 'Minion' )
  ALTER TABLE Minion.IndexSettingsDB DROP COLUMN LogLoc;

-- IndexSettingsDB:
IF NOT EXISTS ( SELECT * FROM sys.columns AS c
	JOIN sys.objects AS o ON o.object_id = c.object_id
	WHERE c.name = 'StmtPrefix'
          AND o.name = 'IndexSettingsDB'
	  AND SCHEMA_NAME(o.schema_id) = 'Minion' )
ALTER TABLE Minion.IndexSettingsDB ADD StmtPrefix nvarchar (500);

IF NOT EXISTS ( SELECT * FROM sys.columns AS c
	JOIN sys.objects AS o ON o.object_id = c.object_id
	WHERE c.name = 'StmtSuffix'
          AND o.name = 'IndexSettingsDB'
	  AND SCHEMA_NAME(o.schema_id) = 'Minion' )
ALTER TABLE Minion.IndexSettingsDB ADD StmtSuffix nvarchar (500);

IF NOT EXISTS ( SELECT * FROM sys.columns AS c
	JOIN sys.objects AS o ON o.object_id = c.object_id
	WHERE c.name = 'RebuildHeap'
          AND o.name = 'IndexSettingsDB'
	  AND SCHEMA_NAME(o.schema_id) = 'Minion' )
ALTER TABLE Minion.IndexSettingsDB ADD RebuildHeap BIT NULL;




-- IndexSettingsTable:
IF NOT EXISTS ( SELECT * FROM sys.columns AS c
	JOIN sys.objects AS o ON o.object_id = c.object_id
	WHERE c.name = 'StmtPrefix'
          AND o.name = 'IndexSettingsTable'
	  AND SCHEMA_NAME(o.schema_id) = 'Minion' )
ALTER TABLE Minion.IndexSettingsTable ADD StmtPrefix nvarchar (500);

IF NOT EXISTS ( SELECT * FROM sys.columns AS c
	JOIN sys.objects AS o ON o.object_id = c.object_id
	WHERE c.name = 'StmtSuffix'
          AND o.name = 'IndexSettingsTable'
	  AND SCHEMA_NAME(o.schema_id) = 'Minion' )
ALTER TABLE Minion.IndexSettingsTable ADD StmtSuffix nvarchar (500);

IF NOT EXISTS ( SELECT * FROM sys.columns AS c
	JOIN sys.objects AS o ON o.object_id = c.object_id
	WHERE c.name = 'RebuildHeap'
          AND o.name = 'IndexSettingsTable'
	  AND SCHEMA_NAME(o.schema_id) = 'Minion' )
ALTER TABLE Minion.IndexSettingsTable ADD RebuildHeap BIT NULL;



-- IndexTableFrag:
IF NOT EXISTS ( SELECT * FROM sys.columns AS c
	JOIN sys.objects AS o ON o.object_id = c.object_id
	WHERE c.name = 'StmtPrefix'
          AND o.name = 'IndexTableFrag'
	  AND SCHEMA_NAME(o.schema_id) = 'Minion' )
ALTER TABLE Minion.IndexTableFrag ADD StmtPrefix nvarchar (500);

IF NOT EXISTS ( SELECT * FROM sys.columns AS c
	JOIN sys.objects AS o ON o.object_id = c.object_id
	WHERE c.name = 'StmtSuffix'
          AND o.name = 'IndexTableFrag'
	  AND SCHEMA_NAME(o.schema_id) = 'Minion' )
ALTER TABLE Minion.IndexTableFrag ADD StmtSuffix nvarchar (500);

IF NOT EXISTS ( SELECT * FROM sys.columns AS c
	JOIN sys.objects AS o ON o.object_id = c.object_id
	WHERE c.name = 'RebuildHeap'
          AND o.name = 'IndexTableFrag'
	  AND SCHEMA_NAME(o.schema_id) = 'Minion' )
ALTER TABLE Minion.IndexTableFrag ADD RebuildHeap BIT NULL;

-----------------------------------------------------
-- Alter existing columns:


IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'nonExecDateDBName' AND OBJECT_NAME(object_id) = 'IndexMaintLogDetails')
    DROP INDEX [nonExecDateDBName] ON [Minion].[IndexMaintLogDetails] ; -- This gets recreated in Indexes.sql
GO
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'nonExecDateDBName2' AND OBJECT_NAME(object_id) = 'IndexMaintLogDetails')
    DROP INDEX [nonExecDateDBName2] ON [Minion].[IndexMaintLogDetails] ; -- This gets recreated in Indexes.sql
GO
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'nonExecDateDBName' AND OBJECT_NAME(object_id) = 'IndexTableFrag')
    DROP INDEX [nonExecDateDBName] ON [Minion].[IndexTableFrag] ; -- This gets recreated in Indexes.sql
GO
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'PK_IndexTableFrag' AND OBJECT_NAME(object_id) = 'IndexTableFrag')
    ALTER TABLE [Minion].[IndexTableFrag] DROP CONSTRAINT PK_IndexTableFrag;
GO
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'ixIndexMaintLogDate' AND OBJECT_NAME(object_id) = 'IndexMaintLog')
    DROP INDEX ixIndexMaintLogDate ON [Minion].IndexMaintLog;
GO
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'nonExecDateDBNameLogDet' AND OBJECT_NAME(object_id) = 'IndexMaintLogDetails')
    DROP INDEX nonExecDateDBNameLogDet ON [Minion].IndexMaintLogDetails;
GO
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'nonDBNameTableID' AND OBJECT_NAME(object_id) = 'IndexTableFrag')
    DROP INDEX nonDBNameTableID ON [Minion].IndexTableFrag;
GO

ALTER TABLE Minion.HELPObjectDetail ALTER COLUMN DetailType sysname NULL;

ALTER TABLE Minion.IndexMaintLog ALTER COLUMN DBName nvarchar(400) NOT NULL;
ALTER TABLE Minion.IndexMaintLog ALTER COLUMN ExcludeDBs nvarchar(max) NULL;
ALTER TABLE Minion.IndexMaintLog ALTER COLUMN IncludeDBs nvarchar(max) NULL;
ALTER TABLE Minion.IndexMaintLog ALTER COLUMN RegexDBsExcluded nvarchar(max) NULL;
ALTER TABLE Minion.IndexMaintLog ALTER COLUMN RegexDBsIncluded nvarchar(max) NULL;
ALTER TABLE Minion.IndexMaintLog ALTER COLUMN Status nvarchar(max) NULL;
ALTER TABLE Minion.IndexMaintLog ALTER COLUMN Warnings nvarchar(max) NULL;

ALTER TABLE Minion.IndexMaintLogDetails ALTER COLUMN DBName nvarchar(400) NULL;
ALTER TABLE Minion.IndexMaintLogDetails ALTER COLUMN IndexName nvarchar(400) NULL;
ALTER TABLE Minion.IndexMaintLogDetails ALTER COLUMN PostCode nvarchar(max) NULL;
ALTER TABLE Minion.IndexMaintLogDetails ALTER COLUMN PreCode nvarchar(max) NULL;
ALTER TABLE Minion.IndexMaintLogDetails ALTER COLUMN SchemaName nvarchar(400) NULL;
ALTER TABLE Minion.IndexMaintLogDetails ALTER COLUMN TableName nvarchar(400) NULL;
ALTER TABLE Minion.IndexMaintLogDetails ALTER COLUMN UpdateStatsStmt nvarchar(1000) NULL;
ALTER TABLE Minion.IndexMaintLogDetails ALTER COLUMN Warnings nvarchar(max) NULL;

ALTER TABLE Minion.IndexPhysicalStats ALTER COLUMN DBName nvarchar(400) NOT NULL;
ALTER TABLE Minion.IndexPhysicalStats ALTER COLUMN IndexName nvarchar(400) NOT NULL;
ALTER TABLE Minion.IndexPhysicalStats ALTER COLUMN SchemaName nvarchar(400) NOT NULL;
ALTER TABLE Minion.IndexPhysicalStats ALTER COLUMN TableName nvarchar(400) NOT NULL;

ALTER TABLE Minion.IndexSettingsDB ALTER COLUMN DBName nvarchar(400) NOT NULL;

ALTER TABLE Minion.IndexSettingsTable ALTER COLUMN DBName nvarchar(400) NOT NULL;
ALTER TABLE Minion.IndexSettingsTable ALTER COLUMN SchemaName nvarchar(400) NOT NULL;
ALTER TABLE Minion.IndexSettingsTable ALTER COLUMN TableName nvarchar(400) NOT NULL;
ALTER TABLE Minion.IndexSettingsTable ALTER COLUMN TablePostCode nvarchar(max) NULL;
ALTER TABLE Minion.IndexSettingsTable ALTER COLUMN TablePreCode nvarchar(max) NULL;

ALTER TABLE Minion.IndexTableFrag ALTER COLUMN DBName nvarchar(400) NOT NULL;
ALTER TABLE Minion.IndexTableFrag ALTER COLUMN IndexName nvarchar(400) NOT NULL;
ALTER TABLE Minion.IndexTableFrag ALTER COLUMN SchemaName nvarchar(400) NOT NULL;
ALTER TABLE Minion.IndexTableFrag ALTER COLUMN TableName nvarchar(400) NOT NULL;

ALTER TABLE Minion.IndexTableFrag ADD CONSTRAINT [PK_IndexTableFrag] PRIMARY KEY CLUSTERED 
(
	[ExecutionDateTime] ASC,
	[DBName] ASC,
	[TableID] ASC,
	[IndexID] ASC
);
