-- Demo script for Using COPY_ONLY demo

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

-- Create a table
USE [Company];
GO

CREATE TABLE [RandomData] (
	[c1] INT IDENTITY,
	[c2] VARCHAR (100));
GO

INSERT INTO [RandomData] VALUES
	('Initial data: transaction 1');
GO

-- And perform a full backup
BACKUP DATABASE [Company]
TO DISK = N'D:\Pluralsight\Company_Full.bak'
WITH
	INIT,
	NAME = N'Company Full';
GO

-- Now add some more data and perform a differential backup
INSERT INTO [RandomData] VALUES
	('Transaction 2');
INSERT INTO [RandomData] VALUES
	('Transaction 3');
GO

BACKUP DATABASE [Company]
TO DISK = N'D:\Pluralsight\Company_Diff1.bak'
WITH
	INIT,
	DIFFERENTIAL,
	NAME = N'Company Differential 1';
GO

-- And more data
INSERT INTO [RandomData] VALUES
	('Transaction 4');
INSERT INTO [RandomData] VALUES
	('Transaction 5');
GO

-- Someone performs an out-of-band full backup
-- but this time with the COPY_ONLY option
BACKUP DATABASE [Company]
TO DISK = N'D:\Pluralsight\Company_Full_For_Dev.bak'
WITH
	INIT,
	NAME = N'Quick full backup for dev',
	COPY_ONLY;
GO

-- And perform another differential backup
BACKUP DATABASE [Company]
TO DISK = N'D:\Pluralsight\Company_Diff2.bak'
WITH
	INIT,
	DIFFERENTIAL,
	NAME = N'Company Differential 2';
GO

-- Simulate corruption that destroys the database
USE [master];
GO

DROP DATABASE [Company];
GO

-- We have a full backup and two differentials - so latest differential
-- Restore the full backup
RESTORE DATABASE [Company]
FROM DISK = N'D:\Pluralsight\Company_Full.bak'
WITH REPLACE, NORECOVERY;
GO

-- And the differential backup 2
RESTORE DATABASE [Company]
FROM DISK = N'D:\Pluralsight\Company_Diff2.bak'
WITH NORECOVERY;

-- And finalize the restore sequence
RESTORE DATABASE [Company] WITH RECOVERY;
GO

-- More info...
SELECT 
	[backup_start_date],
	(CASE [type]
		WHEN N'D' THEN N'Full'
		WHEN N'I' THEN N'Diff'
		WHEN N'L' THEN N'Log'
		ELSE N'Unknown'
	END) AS N'Type',
	[name],
	[backup_set_uuid],
	[differential_base_guid],
	[first_lsn], 
	[last_lsn]
FROM
	[msdb].[dbo].[backupset]
WHERE
	[database_name] = N'Company'
ORDER BY
	[backup_start_date];
GO