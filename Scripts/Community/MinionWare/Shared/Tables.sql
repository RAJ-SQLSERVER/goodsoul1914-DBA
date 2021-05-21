
IF OBJECT_ID('tempdb..#dbname') IS NOT NULL
BEGIN
	DROP TABLE #dbname;
END

SELECT	DB_NAME() AS dbname
INTO	#dbname;

EXEC sp_configure 'show', 1
GO
RECONFIGURE
GO

EXEC sp_configure 'xp_cmdshell', 1
GO
RECONFIGURE
GO

EXEC sp_configure 'show', 0
GO
RECONFIGURE
GO

IF SCHEMA_ID('Minion') IS NULL 
	BEGIN
		EXEC ('CREATE SCHEMA Minion')
	END


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO


IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'Work' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[Work](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[Module] [varchar](20) NULL,
	[DBName] [nvarchar](400) NOT NULL,
	[BackupType] [varchar](20) NULL,
	[Param] [varchar](100) NULL,
	[SPName] [varchar](100) NULL,
	[Value] [varchar](max) NULL
)
END


IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'DBMaintRegexLookup' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[DBMaintRegexLookup](
	[Action] [varchar](10) NULL,
	[MaintType] [varchar](20) NULL,
	[Regex] [nvarchar](2000) NULL
)
END

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'DBMaintDBSizeTemp' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[DBMaintDBSizeTemp](
	[DBName] [varchar](200) NULL,
	[Size] [float] NULL,
	[SpaceUsed] [float] NULL,
	[DataSpaceUsed] [float] NULL,
	[IndexSpaceUsed] [float] NULL
) ON [PRIMARY]
END

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'DBMaintInlineTokens' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[DBMaintInlineTokens](
	[ID] [INT] IDENTITY(1,1) NOT NULL,
	[DynamicName] [VARCHAR](100) NULL,
	[ParseMethod] [VARCHAR](1000) NULL,
	[IsCustom] [BIT] NULL,
	[Definition] [VARCHAR](1000) NULL,
	[IsActive] [BIT] NULL,
	[Comment] [VARCHAR](1000) NULL,
 CONSTRAINT [ukInlineTokensActive] UNIQUE NONCLUSTERED 
(
	[DynamicName] ASC,
	[IsActive] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
)
END

SET ANSI_PADDING OFF
GO
