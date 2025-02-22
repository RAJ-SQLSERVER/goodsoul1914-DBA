CREATE TABLE [dbo].[CPURingBuffers]
(
[ComputerName] [nvarchar] (max) NULL,
[InstanceName] [nvarchar] (max) NULL,
[SqlInstance] [nvarchar] (max) NULL,
[RecordId] [int] NULL,
[EventTime] [datetime2] (7) NULL,
[SQLProcessUtilization] [int] NULL,
[OtherProcessUtilization] [int] NULL,
[SystemIdle] [int] NULL
) TEXTIMAGE_
GO
CREATE NONCLUSTERED INDEX [IX_CPURingBuffers_SQLProcessUtilization] ON [dbo].[CPURingBuffers] ([SQLProcessUtilization]) INCLUDE ([SqlInstance],[EventTime])
GO
