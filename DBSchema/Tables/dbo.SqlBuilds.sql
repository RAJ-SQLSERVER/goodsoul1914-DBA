CREATE TABLE [dbo].[SqlBuilds]
(
[BuildNumber] [int] NULL,
[Version] [nvarchar] (255) NULL,
[Release] [int] NULL,
[Type] [nvarchar] (255) NULL,
[CU] [nvarchar] (255) NULL,
[EndOfSupport] [nvarchar] (255) NULL,
[IsSP] [bit] NULL,
[IsCU] [bit] NULL,
[IsLatestSP] [bit] NULL,
[IsLatestCU] [bit] NULL,
[KBRef] [nvarchar] (255) NULL
)
GO
