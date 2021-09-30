USE [master];
GO

IF DATABASEPROPERTYEX (N'DBMaint2012', N'Version') > 0
BEGIN
	ALTER DATABASE [DBMaint2012] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [DBMaint2012];
END
GO

-- Create the database to use
CREATE DATABASE [DBMaint2012] ON PRIMARY (
    NAME = N'DBMaint2012_data',
    FILENAME = N'D:\Pluralsight\DBMaint2012_data.mdf')
LOG ON (
    NAME = N'DBMaint2012_log',
    FILENAME = N'D:\Pluralsight\DBMaint2012_log.ldf',
    SIZE = 5MB,
    FILEGROWTH = 1MB);
GO

-- Look at the VLFs
DBCC LOGINFO (N'DBMaint2012');
GO

-- Detach the database
EXEC sp_detach_db @dbname = N'DBMaint2012';
GO

-- Delete the log file

-- Attach the database again
CREATE DATABASE [DBMaint2012] ON (
    FILENAME = N'D:\Pluralsight\DBMaint2012_data.mdf')
FOR ATTACH;
GO

-- Look at the VLFs
DBCC LOGINFO (N'DBMaint2012');
GO

-- Now with two transaction log files
USE [master];
GO

IF DATABASEPROPERTYEX (N'DBMaint2012', N'Version') > 0
BEGIN
	ALTER DATABASE [DBMaint2012] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [DBMaint2012];
END
GO

-- Create the database to use
CREATE DATABASE [DBMaint2012] ON PRIMARY (
    NAME = N'DBMaint2012_data',
    FILENAME = N'D:\Pluralsight\DBMaint2012_data.mdf')
LOG ON (
    NAME = N'DBMaint2012_log',
    FILENAME = N'D:\Pluralsight\DBMaint2012_log.ldf',
    SIZE = 5MB,
    FILEGROWTH = 1MB), (
    NAME = N'DBMaint2012_log2',
    FILENAME = N'D:\Pluralsight\DBMaint2012_log2.ldf',
    SIZE = 5MB,
    FILEGROWTH = 1MB)
GO

-- Look at the VLFs
DBCC LOGINFO (N'DBMaint2012');
GO

-- Detach the database
EXEC sp_detach_db @dbname = N'DBMaint2012';
GO

-- Delete the log file

-- Attach the database again
CREATE DATABASE [DBMaint2012] ON (
    FILENAME = N'D:\Pluralsight\DBMaint2012_data.mdf')
FOR ATTACH;
GO

-- Try the other syntax
CREATE DATABASE [DBMaint2012] ON (
    FILENAME = N'D:\Pluralsight\DBMaint2012_data.mdf')
FOR ATTACH_REBUILD_LOG;
GO

-- Look at the VLFs
DBCC LOGINFO (N'DBMaint2012');
GO
