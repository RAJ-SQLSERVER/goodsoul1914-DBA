USE [master];
GO

IF DATABASEPROPERTYEX (N'DBMaint2012', N'Version') > 0
BEGIN
	ALTER DATABASE [DBMaint2012] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [DBMaint2012];
END
GO

-- Create the database with no filegrowth allowed
CREATE DATABASE [DBMaint2012] ON PRIMARY (
    NAME = N'DBMaint2012_data',
    FILENAME = N'D:\Pluralsight\DBMaint2012_data.mdf')
LOG ON (
    NAME = N'DBMaint2012_log',
    FILENAME = N'D:\Pluralsight\DBMaint2012_log.ldf',
    SIZE = 5MB,
    FILEGROWTH = 0);
GO

USE [DBMaint2012];
GO
SET NOCOUNT ON;
GO

-- Make sure the database is in the FULL
-- recovery model
ALTER DATABASE [DBMaint2012] SET RECOVERY FULL;
GO

BACKUP DATABASE [DBMaint2012] TO
	DISK = N'D:\Pluralsight\DBMaint2012.bck'
	WITH INIT;
GO

-- Create a table that will grow very
-- quickly and generate lots of transaction
-- log
CREATE TABLE [BigRows] (
	[c1] INT IDENTITY,
	[c2] CHAR (8000) DEFAULT 'a');
GO

-- Insert some rows to fill the first
-- two VLFs and start on the third
INSERT INTO [BigRows] DEFAULT VALUES;
GO 300

-- Now start an explicit transaction which
-- will hold VLF 3 and onwards active
BEGIN TRAN
INSERT INTO [BigRows] DEFAULT VALUES;
GO

-- Now add some more rows that will fill
-- up VLFs 3 and 4
INSERT INTO [BigRows] DEFAULT VALUES;
GO 300 

-- What does the log look like?
DBCC LOGINFO;
GO

-- What's causing the log to not be cleared?
SELECT [log_reuse_wait_desc]
	FROM [master].[sys].[databases]
	WHERE [name] = N'DBMaint2012';
GO

-- So let's do one
BACKUP LOG [DBMaint2012] TO
	DISK = N'D:\Pluralsight\DBMaint2012_log.bck'
	WITH STATS;
GO

SELECT [log_reuse_wait_desc]
	FROM [master].[sys].[databases]
	WHERE [name] = N'DBMaint2012';
GO

DBCC LOGINFO;
GO

-- Now that log can wrap around