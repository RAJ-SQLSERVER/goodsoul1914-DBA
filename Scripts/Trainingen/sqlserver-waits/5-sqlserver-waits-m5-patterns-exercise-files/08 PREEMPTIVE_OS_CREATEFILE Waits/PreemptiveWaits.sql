USE [master];
GO

IF DATABASEPROPERTYEX (N'FSWaits', N'Version') > 0
BEGIN
	ALTER DATABASE [FSWaits] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [FSWaits];
END
GO

CREATE DATABASE [FSWaits] ON PRIMARY (
    NAME = N'FSWaits_data',
    FILENAME = N'D:\Pluralsight\FSWaits_data.mdf'),
FILEGROUP [FileStreamFileGroup] CONTAINS FILESTREAM
  ( NAME = N'FSWaitsDocuments',
    FILENAME = N'C:\Pluralsight\Documents')
LOG ON (
    NAME = N'FSWaits_log',
    FILENAME = N'C:\Pluralsight\FSWaits_log.ldf',
    SIZE = 5MB,
    FILEGROWTH = 1MB);
GO

-- Create a table with a FILESTREAM column
USE [FSWaits];
GO

CREATE TABLE [FileStreamTest1] (
	[DocId]		UNIQUEIDENTIFIER ROWGUIDCOL NOT NULL UNIQUE,
	[DocName]	VARCHAR (25),
	[Document]	VARBINARY(MAX) FILESTREAM);
GO

-- Clear wait stats in WaitStats1.sql

-- Loop creating files
SET NOCOUNT ON;
GO
WHILE (1=1)
BEGIN
	INSERT INTO [FileStreamTest1] VALUES
		(NEWID (),
		'MyDoc',
		CAST ('SQLskills' AS VARBINARY (MAX)));
END;
GO

-- Examine waits in WaitingTasks.sql
-- Examine waits in WaitStats1.sql

-- Stop the test

-- Clear waits in WaitStats1.sql

USE [master];
GO

IF DATABASEPROPERTYEX (N'FSWaits', N'Version') > 0
BEGIN
	ALTER DATABASE [FSWaits] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [FSWaits];
END
GO

-- Examine waits in WaitStats1.sql