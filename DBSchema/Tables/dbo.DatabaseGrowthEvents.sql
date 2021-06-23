CREATE TABLE [dbo].[DatabaseGrowthEvents]
(
[SqlInstance] [nvarchar] (max) NULL,
[DatabaseName] [nvarchar] (max) NULL,
[Filename] [nvarchar] (max) NULL,
[Duration] [int] NULL,
[StartTime] [datetime2] (7) NULL,
[EndTime] [datetime2] (7) NULL,
[ChangeInSize] [decimal] (38, 5) NULL,
[ApplicationName] [nvarchar] (max) NULL,
[HostName] [nvarchar] (max) NULL,
[SessionLoginName] [nvarchar] (max) NULL
) TEXTIMAGE_
GO
CREATE NONCLUSTERED INDEX [IX_DatabaseGrowthEvents_StartTime] ON [dbo].[DatabaseGrowthEvents] ([StartTime]) INCLUDE ([SqlInstance],[DatabaseName])
GO
