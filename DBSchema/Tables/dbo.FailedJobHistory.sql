CREATE TABLE [dbo].[FailedJobHistory]
(
[InstanceID] [int] NULL,
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
[OperatorEmailed] [nvarchar] (max) NULL,
[OperatorNetsent] [nvarchar] (max) NULL,
[OperatorPaged] [nvarchar] (max) NULL,
[RetriesAttempted] [int] NULL,
[Server] [nvarchar] (max) NULL
) TEXTIMAGE_
GO
