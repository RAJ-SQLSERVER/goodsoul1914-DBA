CREATE TABLE [dbo].[FailedJobHistory]
(
[SqlMessageID] [int] NULL,
[Message] [nvarchar] (max) NULL,
[StepID] [int] NULL,
[StepName] [nvarchar] (max) NULL,
[SqlSeverity] [int] NULL,
[JobID] [uniqueidentifier] NULL,
[JobName] [nvarchar] (max) NULL,
[RunStatus] [int] NULL,
[RunDate] [datetime2] (7) NULL,
[RunDuration] [int] NULL,
[RetriesAttempted] [int] NULL,
[Server] [nvarchar] (max) NULL
) TEXTIMAGE_
GO
CREATE NONCLUSTERED INDEX [IX_FailedJobHistory_RunDate] ON [dbo].[FailedJobHistory] ([RunDate]) INCLUDE ([Server],[JobName],[StepID],[StepName],[RunDuration],[SqlMessageID],[SqlSeverity],[Message])
GO
