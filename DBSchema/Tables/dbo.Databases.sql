CREATE TABLE [dbo].[Databases]
(
[CheckDate] [datetime2] (7) NULL,
[SqlInstance] [nvarchar] (max) NULL,
[Name] [nvarchar] (max) NULL,
[SizeMB] [float] NULL,
[Compatibility] [nvarchar] (max) NULL,
[LastFullBackup] [datetime2] (7) NULL,
[LastDiffBackup] [datetime2] (7) NULL,
[LastLogBackup] [datetime2] (7) NULL,
[ActiveConnections] [int] NULL,
[Collation] [nvarchar] (max) NULL,
[ContainmentType] [nvarchar] (max) NULL,
[CreateDate] [datetime2] (7) NULL,
[DataSpaceUsage] [float] NULL,
[FilestreamDirectoryName] [nvarchar] (max) NULL,
[IndexSpaceUsage] [float] NULL,
[LogReuseWaitStatus] [nvarchar] (max) NULL,
[PageVerify] [nvarchar] (max) NULL,
[PrimaryFilePath] [nvarchar] (max) NULL,
[ReadOnly] [bit] NULL,
[RecoveryModel] [nvarchar] (max) NULL,
[Size] [float] NULL,
[SnapshotIsolationState] [nvarchar] (max) NULL,
[SpaceAvailable] [float] NULL,
[MaxDop] [int] NULL,
[ServerVersion] [nvarchar] (max) NULL
) TEXTIMAGE_
GO
ALTER TABLE [dbo].[Databases] ADD CONSTRAINT [DF_Databases_CheckDate_1] DEFAULT (getdate ()) FOR [CheckDate]
GO
CREATE NONCLUSTERED INDEX [IX_Databases_LastFullBackup_LastLogBackup] ON [dbo].[Databases] ([LastFullBackup], [LastLogBackup]) INCLUDE ([CheckDate],[SqlInstance],[Name],[RecoveryModel],[LogReuseWaitStatus])
GO
