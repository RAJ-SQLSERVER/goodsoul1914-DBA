USE [master];
GO

IF DATABASEPROPERTYEX(N'DBMaint2012', N'Version') > 0
BEGIN
	ALTER DATABASE [DBMaint2012]

	SET SINGLE_USER
	WITH

	ROLLBACK IMMEDIATE;

	DROP DATABASE [DBMaint2012];
END
GO

-- Create the database to use
CREATE DATABASE [DBMaint2012] ON PRIMARY (
	NAME = N'DBMaint2012_data',
	FILENAME = N'D:\Pluralsight\DBMaint2012_data.mdf'
	) LOG ON (
	NAME = N'DBMaint2012_log',
	FILENAME = N'D:\Pluralsight\DBMaint2012_log.ldf',
	SIZE = 512 KB,
	FILEGROWTH = 1 MB
	);
GO

USE [DBMaint2012];
GO

-- Create a table that will grow very
-- quickly and generate lots of transaction
-- log
CREATE TABLE [BigRows] (
	[c1] INT IDENTITY,
	[c2] CHAR(8000) DEFAULT 'a'
	);
GO

-- Make sure the database is in FULL
-- recovery model
ALTER DATABASE [DBMaint2012]

SET RECOVERY FULL;
GO

BACKUP DATABASE [DBMaint2012] TO DISK = N'D:\Pluralsight\DBMaint2012.bck'
WITH INIT,
	STATS;
GO

-- Cause a bunch of log growth
SET NOCOUNT ON;
GO

INSERT INTO [BigRows] DEFAULT
VALUES;GO 30000

-- This will take a while...
-- How many VLFs do we have?
DBCC LOGINFO(N'DBMaint2012');
GO

-- Shrink the log
DBCC SHRINKFILE (2);
GO

-- Backup the log to allow log clearing
BACKUP LOG [DBMaint2012] TO DISK = N'D:\Pluralsight\DBMaint2012_log.bck'
WITH STATS;
GO

-- Shrink the log again.. does it go down?
-- If not, do another backup and re-shrink
DBCC SHRINKFILE (2);
GO

-- Now grow it manually and set auto growth
ALTER DATABASE [DBMaint2012] MODIFY FILE (
	NAME = N'DBMaint2012_Log',
	SIZE = 100 MB,
	FILEGROWTH = 20 MB
	);
GO

-- And check VLFs again
DBCC LOGINFO(N'DBMaint2012');
GO


