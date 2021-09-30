-- Demo script for Differential Backup Sizes

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

-- Delete everything from the backup history table
-- Do not do this on a production system!
USE [msdb];
GO

DECLARE @today DATETIME = GETDATE ();
EXEC sp_delete_backuphistory @oldest_date = @today;
GO

USE [Company];
GO

-- Create a table
CREATE TABLE [RandomData] (
	[c1] INT IDENTITY,
	[c2] CHAR (8000) DEFAULT 'filler');
GO

-- Now add some data
SET NOCOUNT ON;
INSERT INTO [RandomData] DEFAULT VALUES;
GO 1000

-- Perform a full backup
BACKUP DATABASE [Company]
TO DISK = N'D:\Pluralsight\Company_Full1.bak'
WITH
	INIT,
	NAME = N'Company Full';
GO

-- Perform a differential backup
BACKUP DATABASE [Company]
TO DISK = N'D:\Pluralsight\Company_Diff1.bak'
WITH
	INIT,
	NAME = N'Company Differential: No changes',
	DIFFERENTIAL;
GO

-- Examine the backup history table in msdb to
-- see the backup sizes
SELECT 
	[name],
	[backup_size]
FROM [msdb].[dbo].[backupset]
WHERE [database_name] = 'Company';
GO

-- Now update 100 rows in the table
UPDATE [RandomData]
SET [c2] = 'Updated'
WHERE [c1] < 101;
GO

-- Perform another differential backup
BACKUP DATABASE [Company]
TO DISK = N'D:\Pluralsight\Company_Diff2.bak'
WITH
	INIT,
	NAME = N'Company Differential: 1-100 rows updated',
	DIFFERENTIAL;
GO

-- How big is it?
SELECT 
	[name],
	[backup_size]
FROM [msdb].[dbo].[backupset]
WHERE [database_name] = 'Company';
GO

-- Now update another 100 rows in the table
UPDATE [RandomData]
SET [c2] = 'Updated'
WHERE [c1] > 100 AND [c1] < 201;
GO

-- Perform another differential backup
BACKUP DATABASE [Company]
TO DISK = N'D:\Pluralsight\Company_Diff3.bak'
WITH
	INIT,
	NAME = N'Company Differential: 1-200 rows updated',
	DIFFERENTIAL;
GO

-- How big is it?
SELECT 
	[name],
	[backup_size]
FROM [msdb].[dbo].[backupset]
WHERE [database_name] = 'Company';
GO

-- Differential backups are cumulative!

-- What about if we update the same rows again?
UPDATE [RandomData]
SET [c2] = 'Updated Again'
WHERE [c1] > 100 AND [c1] < 201;
GO

-- Perform another differential backup
BACKUP DATABASE [Company]
TO DISK = N'D:\Pluralsight\Company_Diff4.bak'
WITH
	INIT,
	NAME = N'Company Differential: 101-200 rows updated again',
	DIFFERENTIAL;
GO

-- How big is it?
SELECT 
	[name],
	[backup_size]
FROM [msdb].[dbo].[backupset]
WHERE [database_name] = 'Company';
GO

-- The extents were *already* marked as changed

-- What about an update that gets rolled back?
BEGIN TRANSACTION;
GO

UPDATE [RandomData]
SET [c2] = 'Updated'
WHERE [c1] > 200 AND [c1] < 301;
GO

ROLLBACK TRANSACTION;
GO

-- Perform another differential backup
BACKUP DATABASE [Company]
TO DISK = N'D:\Pluralsight\Company_Diff5.bak'
WITH
	INIT,
	NAME = N'Company Differential: 201-300 rows updated and rolled back',
	DIFFERENTIAL;
GO

-- How big is it?
SELECT 
	[name],
	[backup_size]
FROM [msdb].[dbo].[backupset]
WHERE [database_name] = 'Company';
GO

-- The extents were changed, so have to be backed up

-- Script to report how much data has changed since the
-- last full backup: http://bit.ly/2wsRIFr

-- 2017+ has column in sys.dm_db_file_space_usage that tracks
-- number of extents changed since the last full backup