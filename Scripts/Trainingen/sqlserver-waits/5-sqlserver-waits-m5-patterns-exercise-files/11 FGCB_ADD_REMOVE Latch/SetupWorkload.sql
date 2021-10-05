USE [master];
GO

IF DATABASEPROPERTYEX (N'PageSplit', N'Version') > 0
BEGIN
	ALTER DATABASE [PageSplit] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [PageSplit];
END
GO

CREATE DATABASE [PageSplit] ON PRIMARY (
    NAME = N'PageSplit_data',
    FILENAME = N'D:\Pluralsight\PageSplit_data.mdf')
LOG ON (
    NAME = N'PageSplit_log',
    FILENAME = N'C:\Pluralsight\PageSplit_log.ldf',
    SIZE = 2MB,
    FILEGROWTH = 256KB);
GO

ALTER DATABASE [PageSplit] SET RECOVERY SIMPLE;
GO

USE [PageSplit];
GO

CREATE TABLE [PageSplitTable] (
	[c1] UNIQUEIDENTIFIER DEFAULT NEWID () ROWGUIDCOL,
	[c2] DATETIME DEFAULT GETDATE (),
	[c3] CHAR (400) DEFAULT 'a');
CREATE CLUSTERED INDEX [PageSplitTable_CL] ON
	[PageSplitTable] ([c1]);
GO