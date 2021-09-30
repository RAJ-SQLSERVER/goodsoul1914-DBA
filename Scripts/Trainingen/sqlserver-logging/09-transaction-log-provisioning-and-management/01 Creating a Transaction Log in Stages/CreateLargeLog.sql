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
    SIZE = 32GB,
    FILEGROWTH = 256MB);
GO

-- This will take a few minutes...

-- Examine VLFs
DBCC LOGINFO (N'DBMaint2012'); 
GO 

-- Better method is to do it in stages

-- Drop and recreate with 8GB log
IF DATABASEPROPERTYEX (N'DBMaint2012', N'Version') > 0
BEGIN
	ALTER DATABASE [DBMaint2012] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [DBMaint2012];
END
GO

CREATE DATABASE [DBMaint2012] ON PRIMARY (
    NAME = N'DBMaint2012_data',
    FILENAME = N'D:\Pluralsight\DBMaint2012_data.mdf')
LOG ON (
    NAME = N'DBMaint2012_log',
    FILENAME = N'D:\Pluralsight\DBMaint2012_log.ldf',
    SIZE = 8GB,
    FILEGROWTH = 256MB);
GO

-- This will take about a minute...

-- Examine VLFs
DBCC LOGINFO (N'DBMaint2012'); 
GO

-- Now grow it 3 times in 8GB steps
ALTER DATABASE [DBMaint2012]
MODIFY FILE ( 
    NAME = N'DBMaint2012_log', 
    SIZE = 16GB);

ALTER DATABASE [DBMaint2012]
MODIFY FILE ( 
    NAME = N'DBMaint2012_log', 
    SIZE = 24GB);

ALTER DATABASE [DBMaint2012]
MODIFY FILE ( 
    NAME = N'DBMaint2012_log', 
    SIZE = 32GB);
GO

-- This will take a few minutes...

-- Examine VLFs
DBCC LOGINFO (N'DBMaint2012'); 
GO