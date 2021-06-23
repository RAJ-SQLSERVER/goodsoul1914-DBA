CREATE TABLE [dbo].[ErrorLogs]
(
[ComputerName] [nvarchar] (max) NULL,
[InstanceName] [nvarchar] (max) NULL,
[SqlInstance] [nvarchar] (max) NULL,
[LogDate] [datetime2] (7) NULL,
[Source] [nvarchar] (max) NULL,
[Text] [nvarchar] (max) NULL
) TEXTIMAGE_
GO
CREATE NONCLUSTERED INDEX [IX_ErrorLogs_LogDate] ON [dbo].[ErrorLogs] ([LogDate]) INCLUDE ([SqlInstance],[Text])
GO
