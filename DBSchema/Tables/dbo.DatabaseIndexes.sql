CREATE TABLE [dbo].[DatabaseIndexes]
(
[CheckDate] [datetime2] (7) NULL,
[ComputerName] [nvarchar] (max) NULL,
[InstanceName] [nvarchar] (max) NULL,
[SqlInstance] [nvarchar] (max) NULL,
[Database] [nvarchar] (max) NULL,
[Object] [nvarchar] (max) NULL,
[Index] [nvarchar] (max) NULL,
[IndexType] [nvarchar] (max) NULL,
[Statistics] [nvarchar] (max) NULL,
[KeyColumns] [nvarchar] (max) NULL,
[IncludeColumns] [nvarchar] (max) NULL,
[FilterDefinition] [nvarchar] (max) NULL,
[DataCompression] [nvarchar] (max) NULL,
[IndexReads] [bigint] NULL,
[IndexUpdates] [bigint] NULL,
[Size] [bigint] NULL,
[IndexRows] [bigint] NULL,
[IndexLookups] [bigint] NULL,
[MostRecentlyUsed] [datetime2] (7) NULL,
[StatsSampleRows] [bigint] NULL,
[StatsRowMods] [bigint] NULL,
[HistogramSteps] [int] NULL,
[StatsLastUpdated] [datetime2] (7) NULL,
[IndexFragInPercent] [float] NULL
) TEXTIMAGE_
GO
ALTER TABLE [dbo].[DatabaseIndexes] ADD CONSTRAINT [DF_DatabaseIndexes_CheckDate] DEFAULT (getdate ()) FOR [CheckDate]
GO
