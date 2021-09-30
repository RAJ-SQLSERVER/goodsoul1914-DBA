-- Create a slow drive.. using a USB stick as G:
USE [master];
GO

IF DATABASEPROPERTYEX (N'SlowLogFile', N'Version') > 0
BEGIN
	ALTER DATABASE [SlowLogFile] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [SlowLogFile];
END
GO


CREATE DATABASE [SlowLogFile] ON PRIMARY (
    NAME = N'SlowLogFile_data',
    FILENAME = N'D:\Pluralsight\SlowLogFile_data.mdf')
LOG ON (
    NAME = N'SlowLogFile_log',
    FILENAME = N'G:\SlowLogFile_log.ldf',
    SIZE = 5MB,
    FILEGROWTH = 1MB);
GO

ALTER DATABASE [SlowLogFile] SET RECOVERY SIMPLE;
GO

USE [SlowLogFile];
GO

CREATE TABLE [BadKeyTable] (
	[c1] UNIQUEIDENTIFIER DEFAULT NEWID () ROWGUIDCOL,
    [c2] DATETIME DEFAULT GETDATE (),
	[c3] CHAR (400) DEFAULT 'a');
CREATE CLUSTERED INDEX [BadKeyTable_CL] ON
	[BadKeyTable] ([c1]);
CREATE NONCLUSTERED INDEX [BadKeyTable_NCL] ON
	[BadKeyTable] ([c2]);
GO


