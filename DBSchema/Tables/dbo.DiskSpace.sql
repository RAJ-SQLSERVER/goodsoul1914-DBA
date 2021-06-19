CREATE TABLE [dbo].[DiskSpace]
(
[CheckDate] [datetime2] (7) NULL,
[ComputerName] [nvarchar] (max) NULL,
[Name] [nvarchar] (max) NULL,
[Label] [nvarchar] (max) NULL,
[Capacity] [bigint] NULL,
[Free] [bigint] NULL,
[PercentFree] [float] NULL,
[BlockSize] [int] NULL,
[FileSystem] [nvarchar] (max) NULL,
[Type] [nvarchar] (max) NULL,
[IsSqlDisk] [nvarchar] (max) NULL,
[Server] [nvarchar] (max) NULL,
[DriveType] [nvarchar] (max) NULL,
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
) TEXTIMAGE_
GO
ALTER TABLE [dbo].[DiskSpace] ADD CONSTRAINT [DF_DiskSpace_CheckDate] DEFAULT (getdate ()) FOR [CheckDate]
GO
