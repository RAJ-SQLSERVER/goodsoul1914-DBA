-- Demo script for Backup Integrity demo

USE [master];
GO

IF DATABASEPROPERTYEX (N'Company', N'Version') > 0
BEGIN
	ALTER DATABASE [Company] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [Company];
END
GO

-- Create the database
CREATE DATABASE [Company] ON PRIMARY (
    NAME = N'Company',
    FILENAME = N'D:\Pluralsight\Company.mdf')
LOG ON (
    NAME = N'Company_log',
    FILENAME = N'D:\Pluralsight\Company_log.ldf');
GO

-- Create a table that will grow large quickly
USE [Company]
GO

CREATE TABLE [RandomData] (
	[c1] INT IDENTITY,
	[c2] CHAR (8000) DEFAULT 'a');
GO
SET NOCOUNT ON;
GO

INSERT INTO [RandomData] DEFAULT VALUES;
GO 1000

-- Examine the pages
DBCC IND (N'Company', N'RandomData', -1);
GO

-- Corrupt one of them
ALTER DATABASE [Company] SET SINGLE_USER;
GO
DBCC WRITEPAGE (N'Company', 1, 307, 0, 2, 0x0000, 1);
GO
ALTER DATABASE [Company] SET MULTI_USER;
GO

-- See the corruption
SELECT * FROM [Company].[dbo].[RandomData];
GO

-- Create a backup
BACKUP DATABASE [Company]
TO DISK = N'C:\Pluralsight\CompanyFullNoChecksum.bak'
WITH
	INIT,
	NAME = N'Company Full';
GO

-- Didn't find the corruption so use CHECKSUM
BACKUP DATABASE [Company]
TO DISK = N'C:\Pluralsight\CompanyFullChecksum.bak'
WITH
	INIT,
	NAME = N'Company Full Checksum',
	CHECKSUM;
GO

-- Force it
BACKUP DATABASE [Company]
TO DISK = N'C:\Pluralsight\CompanyFullChecksum.bak'
WITH
	INIT,
	NAME = N'Company Full Checksum',
	CHECKSUM,
	CONTINUE_AFTER_ERROR;
GO

-- Check validity of the original backup
RESTORE VERIFYONLY
FROM DISK = N'C:\Pluralsight\CompanyFullNoChecksum.bak';
GO

-- And the forced backup...
RESTORE VERIFYONLY
FROM DISK = N'C:\Pluralsight\CompanyFullChecksum.bak';
GO

-- What about using WITH CHECKSUM?
RESTORE VERIFYONLY
FROM DISK = N'C:\Pluralsight\CompanyFullChecksum.bak'
WITH CHECKSUM;
GO

-- Doesn't matter because we forced it.
-- What about the "good" backup?
RESTORE VERIFYONLY
FROM DISK = N'C:\Pluralsight\CompanyFullNoChecksum.bak'
WITH CHECKSUM;
GO

-- What about restoring the forced backup?
USE [master];
GO

RESTORE DATABASE [Company]
FROM DISK = N'C:\Pluralsight\CompanyFullChecksum.bak'
WITH REPLACE, CHECKSUM;
GO

-- Force it...
RESTORE DATABASE [Company]
FROM DISK = N'C:\Pluralsight\CompanyFullChecksum.bak'
WITH REPLACE, CHECKSUM, CONTINUE_AFTER_ERROR;
GO

-- Still broken but at least you have the rest of the data...
SELECT * FROM [Company].[dbo].[RandomData];
GO
