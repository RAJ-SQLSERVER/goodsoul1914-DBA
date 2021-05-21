




SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'HELPObjectDetail' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[HELPObjectDetail](
	[ObjectID] [int] NULL,
	[DetailName] [varchar](100) NULL,
	[Position] [smallint] NULL,
	[DetailType] [sysname] NULL,
	[DetailHeader] [varchar](100) NULL,
	[DetailText] [varchar](max) NULL,
	[DataType] [varchar](20) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END

IF NOT EXISTS (SELECT name FROM sys.objects WHERE name = 'HELPObjects' AND SCHEMA_Name(schema_id) = 'Minion')
BEGIN
CREATE TABLE [Minion].[HELPObjects](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Module] [varchar](50) NULL,
	[ObjectName] [varchar](100) NULL,
	[ObjectType] [varchar](100) NULL,
	[MinionVersion] [float] NULL,
	[GlobalPosition] [int] NULL,
 CONSTRAINT [PK__Objects__3214EC27E83D3C4F] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END

-----If HELP is still in the old format, drop the unwanted cols.
IF EXISTS(SELECT * FROM sys.columns 
            WHERE (Name = N'precision') AND Object_ID = Object_ID(N'Minion.HELPObjectDetail'))

BEGIN --HelpObjects
SET NUMERIC_ROUNDABORT OFF
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL Serializable
BEGIN TRANSACTION

ALTER TABLE [Minion].[HELPObjectDetail] DROP CONSTRAINT [FK_ObjectDetail_Objects_ID];

ALTER TABLE [Minion].[HELPObjects] DROP CONSTRAINT [PK__Objects__3214EC27E83D3C4F]
ALTER TABLE [Minion].[HELPObjectDetail] DROP COLUMN GlobalPosition;
ALTER TABLE [Minion].[HELPObjectDetail] DROP COLUMN max_length;
ALTER TABLE [Minion].[HELPObjectDetail] DROP COLUMN [precision];
ALTER TABLE [Minion].[HELPObjectDetail] DROP COLUMN scale;
ALTER TABLE [Minion].[HELPObjectDetail] DROP COLUMN is_nullable;

ALTER TABLE [Minion].[HELPObjects] DROP COLUMN Synopsis;
ALTER TABLE [Minion].[HELPObjects] DROP COLUMN Descript;

ALTER TABLE [Minion].[HELPObjects] ADD CONSTRAINT [PK__Objects__3214EC27E83D3C4F] PRIMARY KEY CLUSTERED  ([ID])
ALTER TABLE [Minion].[HELPObjectDetail]  WITH CHECK ADD  CONSTRAINT [FK_ObjectDetail_Objects_ID] FOREIGN KEY([ObjectID])
REFERENCES [Minion].[HELPObjects] ([ID])
ALTER TABLE [Minion].[HELPObjectDetail] CHECK CONSTRAINT [FK_ObjectDetail_Objects_ID]




COMMIT TRANSACTION
END --HelpObjects
