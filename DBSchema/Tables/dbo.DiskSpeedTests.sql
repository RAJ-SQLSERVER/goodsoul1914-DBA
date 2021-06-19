CREATE TABLE [dbo].[DiskSpeedTests]
(
[CheckDate] [datetime2] (7) NULL,
[SqlInstance] [nvarchar] (max) NULL,
[Database] [nvarchar] (max) NULL,
[SizeGB] [decimal] (38, 5) NULL,
[FileName] [nvarchar] (max) NULL,
[FileID] [smallint] NULL,
[FileType] [nvarchar] (max) NULL,
[DiskLocation] [nvarchar] (max) NULL,
[Reads] [bigint] NULL,
[AverageReadStall] [int] NULL,
[ReadPerformance] [nvarchar] (max) NULL,
[Writes] [bigint] NULL,
[AverageWriteStall] [int] NULL,
[WritePerformance] [nvarchar] (max) NULL,
[Avg Overall Latency] [bigint] NULL,
[Avg Bytes/Read] [bigint] NULL,
[Avg Bytes/Write] [bigint] NULL,
[Avg Bytes/Transfer] [bigint] NULL
) TEXTIMAGE_
GO
ALTER TABLE [dbo].[DiskSpeedTests] ADD CONSTRAINT [DF_DiskSpeedTests_CheckDate] DEFAULT (getdate ()) FOR [CheckDate]
GO
