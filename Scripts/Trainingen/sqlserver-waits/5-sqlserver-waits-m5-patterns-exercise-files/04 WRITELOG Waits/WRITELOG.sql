USE [master];
GO

IF DATABASEPROPERTYEX (N'SlowLogFile', N'Version') > 0
BEGIN
	ALTER DATABASE [SlowLogFile] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [SlowLogFile];
END
GO

-- Create the database with the log file on a USB stick

CREATE DATABASE [SlowLogFile] ON PRIMARY (
    NAME = 'SlowLogFile_data',
    FILENAME = N'D:\Pluralsight\SlowLogFile_data.mdf')
LOG ON (
    NAME = 'SlowLogFile_log',
    FILENAME = N'G:\SlowLogFile_log.ldf',
    --FILENAME = N'C:\Pluralsight\SlowLogFile_log.ldf',
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

-- Clear wait stats in WaitStats1.sql

-- Now start the workload by double-clicking the
-- file C:\Pluralsight\Add50Clients.cmd

-- Examine output from WaitingTasks.sql
-- Examine output from WaitStats1.sql

-- Now stop the workload by double-clicking the
-- file C:\Pluralsight\StopWorkload.cmd

-- Set up the test again using C:

-- Clear wait stats in WaitStats2.sql

-- Now start the workload by double-clicking the
-- file C:\Pluralsight\Add50Clients.cmd

-- Examine output from WaitingTasks.sql
-- Examine output from WaitStats2.sql

-- Now stop the workload by double-clicking the
-- file C:\Pluralsight\StopWorkload.cmd

-- Clean up
USE [master];
GO

IF DATABASEPROPERTYEX (N'HotSpot', N'Version') > 0
BEGIN
	ALTER DATABASE [SlowLogFile] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [SlowLogFile];
END
GO