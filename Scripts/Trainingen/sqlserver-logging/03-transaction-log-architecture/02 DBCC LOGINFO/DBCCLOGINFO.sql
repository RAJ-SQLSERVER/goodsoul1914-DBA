USE [master];
GO

IF DATABASEPROPERTYEX (N'DBMaint2012', N'Version') > 0
BEGIN
	ALTER DATABASE [DBMaint2012] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [DBMaint2012];
END
GO


-- Create a database
CREATE DATABASE [DBMaint2012] ON PRIMARY (
    NAME = N'DBMaint2012_data',
    FILENAME = N'D:\Pluralsight\DBMaint2012_data.mdf')
LOG ON (
    NAME = N'DBMaint2012_log',
    FILENAME = N'D:\Pluralsight\DBMaint2012_log.ldf',
    SIZE = 10MB,
    FILEGROWTH = 10MB);
GO

-- Examine the size of the log
DBCC SQLPERF (LOGSPACE);
GO

-- Examine the VLF structure of the log
DBCC LOGINFO (N'DBMaint2012');
GO

-- Increase the log file size
ALTER DATABASE [DBMaint2012] MODIFY FILE (
    NAME = N'DBMaint2012_log',
    SIZE = 20MB);
GO

-- Examine the size of the log
DBCC SQLPERF (LOGSPACE);
GO

-- Examine the VLF structure of the log
DBCC LOGINFO (N'DBMaint2012');
GO