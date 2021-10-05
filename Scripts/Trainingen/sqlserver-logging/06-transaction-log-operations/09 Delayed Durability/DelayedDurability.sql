-- Use a USB stick for the log file
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
    FILENAME = N'C:\Pluralsight\SlowLogFile_data.mdf')
LOG ON (
    NAME = N'SlowLogFile_log',
    FILENAME = N'H:\SlowLogFile_log.ldf',
    SIZE = 64MB,
    FILEGROWTH = 16MB);
GO

ALTER DATABASE [SlowLogFile] SET RECOVERY SIMPLE;
ALTER DATABASE [SlowLogFile] SET DELAYED_DURABILITY = DISABLED;
GO

USE [SlowLogFile];
GO

CREATE TABLE BadKeyTable (
	[c1] INT,
    [c2] DATETIME,
	[c3] CHAR (100));
CREATE CLUSTERED INDEX [BadKeyTable_CL] ON
	[BadKeyTable] ([c1]);
GO

INSERT INTO BadKeyTable VALUES (1, GETDATE (), 'a');
INSERT INTO BadKeyTable VALUES (2, GETDATE (), 'b');
INSERT INTO BadKeyTable VALUES (3, GETDATE (), 'c');
GO

-- Fire up 50 clients and watch log flushes per sec
-- and transactions per sec in perfmon

-- Change log flushing

ALTER DATABASE [SlowLogFile] SET DELAYED_DURABILITY = FORCED;
GO

-- And watch the difference!