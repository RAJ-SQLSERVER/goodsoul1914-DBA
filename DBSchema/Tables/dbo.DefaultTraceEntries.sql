CREATE TABLE [dbo].[DefaultTraceEntries]
(
[SqlInstance] [nvarchar] (max) NULL,
[LoginName] [nvarchar] (max) NULL,
[HostName] [nvarchar] (max) NULL,
[DatabaseName] [nvarchar] (max) NULL,
[ApplicationName] [nvarchar] (max) NULL,
[StartTime] [datetime2] (7) NULL,
[TextData] [nvarchar] (max) NULL
) TEXTIMAGE_
GO
