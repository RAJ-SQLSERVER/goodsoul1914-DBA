-- Demo script for How Much Log in a Full Backup

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
	[c2] VARCHAR (100));
GO

-- And perform a full backup
BACKUP DATABASE [Company]
TO DISK = N'D:\Pluralsight\Company_Full1.bak'
WITH
	INIT,
	NAME = N'Company Full';
GO

-- Now examine some data about the backup
RESTORE HEADERONLY FROM DISK = N'D:\Pluralsight\Company_Full1.bak';
GO

-- And from the backup history table in msdb
SELECT
	[name],
	[checkpoint_lsn],
	[first_lsn],
	[last_lsn]
FROM [msdb].[dbo].[backupset]
WHERE [database_name] = 'Company';
GO

-- Now go to the second window and start a transaction

-- Back in this window...

-- Now add some more data
SET NOCOUNT ON;
INSERT INTO [RandomData] VALUES
	('Random transaction');
GO 1000

-- And perform another full backup
BACKUP DATABASE [Company]
TO DISK = N'D:\Pluralsight\Company_Full2.bak'
WITH
	INIT,
	NAME = N'Company Full with active transaction';
GO

-- Look in the backup history table in msdb again
SELECT
	[name],
	[checkpoint_lsn],
	[first_lsn],
	[last_lsn]
FROM [msdb].[dbo].[backupset]
WHERE [database_name] = 'Company';
GO

-- Don't forget to clean up by committing the transaction in
-- the other window