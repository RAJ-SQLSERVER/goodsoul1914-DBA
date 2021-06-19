CREATE TABLE [dbo].[DatabaseSpace]
(
[CheckDate] [datetime2] (7) NULL,
[ComputerName] [nvarchar] (max) NULL,
[InstanceName] [nvarchar] (max) NULL,
[SqlInstance] [nvarchar] (max) NULL,
[Database] [nvarchar] (max) NULL,
[FileName] [nvarchar] (max) NULL,
[FileGroup] [nvarchar] (max) NULL,
[PhysicalName] [nvarchar] (max) NULL,
[FileType] [nvarchar] (max) NULL,
[UsedSpace] [bigint] NULL,
[FreeSpace] [bigint] NULL,
[FileSize] [bigint] NULL,
[PercentUsed] [float] NULL,
[AutoGrowth] [bigint] NULL,
[AutoGrowType] [nvarchar] (max) NULL,
[SpaceUntilMaxSize] [bigint] NULL,
[AutoGrowthPossible] [bigint] NULL,
[UnusableSpace] [bigint] NULL
) TEXTIMAGE_
GO
ALTER TABLE [dbo].[DatabaseSpace] ADD CONSTRAINT [DF_DatabaseSpace_CheckDate] DEFAULT (getdate ()) FOR [CheckDate]
GO
