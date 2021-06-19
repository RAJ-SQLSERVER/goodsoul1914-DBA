CREATE TABLE [dbo].[LastBackupTests]
(
[SourceServer] [nvarchar] (max) NULL,
[TestServer] [nvarchar] (max) NULL,
[Database] [nvarchar] (max) NULL,
[FileExists] [bit] NULL,
[Size] [bigint] NULL,
[RestoreResult] [nvarchar] (max) NULL,
[DbccResult] [nvarchar] (max) NULL,
[RestoreStart] [nvarchar] (max) NULL,
[RestoreEnd] [nvarchar] (max) NULL,
[RestoreElapsed] [nvarchar] (max) NULL,
[DbccMaxDop] [int] NULL,
[DbccStart] [nvarchar] (max) NULL,
[DbccEnd] [nvarchar] (max) NULL,
[DbccElapsed] [nvarchar] (max) NULL,
[BackupDates] [nvarchar] (max) NULL,
[BackupFiles] [nvarchar] (max) NULL
) TEXTIMAGE_
GO
