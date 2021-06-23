CREATE TABLE [dbo].[SqlInstances]
(
[Timestamp] [datetime2] (7) NULL,
[ComputerName] [varchar] (255) NULL,
[SqlInstance] [varchar] (255) NULL,
[SqlEdition] [varchar] (255) NULL,
[SqlVersion] [varchar] (255) NULL,
[ProcessorInfo] [varchar] (50) NULL,
[PhysicalMemory] [varchar] (50) NULL,
[Scan] [bit] NULL,
[Owner] [varchar] (255) NULL
)
GO
ALTER TABLE [dbo].[SqlInstances] ADD CONSTRAINT [DF_SqlInstances_Timestamp] DEFAULT (getdate ()) FOR [Timestamp]
GO
CREATE NONCLUSTERED INDEX [FI_SqlInstances_Scan] ON [dbo].[SqlInstances] ([ComputerName], [SqlInstance]) WHERE ([Scan]= (1))
GO
