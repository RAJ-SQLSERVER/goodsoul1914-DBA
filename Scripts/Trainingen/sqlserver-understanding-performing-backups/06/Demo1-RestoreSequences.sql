-- Demo script for Restore Sequences demo

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

-- Create a table that will grow large quickly
USE [Company];
GO

CREATE TABLE [RandomData] (
	[c1] INT IDENTITY,
	[c2] CHAR (8000) DEFAULT 'a');
GO
SET NOCOUNT ON;
GO

INSERT INTO [RandomData] DEFAULT VALUES;
GO 1000

-- And take Sunday full backup
BACKUP DATABASE [Company]
TO DISK = N'D:\Pluralsight\Company_Full_Sunday.bak'
WITH
	INIT,
	NAME = N'Company Full Sunday';
GO

-- Now add more data, hourly log backups
-- and 6-hr differential backups for Monday
DECLARE @count    INT;
DECLARE @filename VARCHAR (200);
DECLARE @name     VARCHAR (200);

SELECT @count = 1;

WHILE @count < 25
BEGIN
	INSERT INTO [RandomData] DEFAULT VALUES;

	SELECT @name = N'Company Log Monday ' + CONVERT (NVARCHAR, @count);
	SELECT @filename = N'D:\Pluralsight\Company_Log_Monday_' 
	    + CONVERT (NVARCHAR, @count) + N'.bak';
	
	BACKUP LOG [Company]
	TO DISK = @filename
	WITH
		INIT,
		NAME = @name;

	IF (@count % 6 = 0)
	BEGIN
		SELECT @name = N'Company Differential Monday ' + CONVERT (NVARCHAR, @count / 6);
	    SELECT @filename = N'D:\Pluralsight\Company_Diff_Monday_'
		    + CONVERT (NVARCHAR, @count / 6) + N'.bak';
		
		BACKUP DATABASE [Company]
		TO DISK = @filename
		WITH
			INIT,
		    DIFFERENTIAL,
			NAME = @name;
	END

	SELECT @count = @count + 1;

	WAITFOR DELAY '00:00:01';
END
GO
	
-- Now add more data and hourly log backups for Tuesday,
-- but we crash just after the 3am backup
DECLARE @name     VARCHAR (200);
DECLARE @filename VARCHAR (200);
DECLARE @count    INT;

SELECT @count = 1;

WHILE @count < 4
BEGIN
	INSERT INTO [RandomData] DEFAULT VALUES;

	SELECT @name = N'Company Log Tuesday ' + CONVERT (NVARCHAR, @count);
	SELECT @filename = N'D:\Pluralsight\Company_Log_Tuesday_' 
	    + CONVERT (NVARCHAR, @count) + N'.bak';

	BACKUP LOG [Company]
	TO DISK = @filename
	WITH
		INIT,
	    NAME = @name;

	SELECT @count = @count + 1;

	WAITFOR DELAY '00:00:01';
END
GO
	
-- Now we simulate a disaster
USE [master]
GO
DROP DATABASE [Company];
GO

-- Now we have to restore. What backups do we have?

-- We need the most recent full backup, the most recent
-- differential backup, and then all the log backups after
-- that.

-- What backups do we have?
SELECT
	[backup_start_date],
	(CASE [type]
		WHEN N'D' THEN N'Full'
		WHEN N'I' THEN N'Diff'
		WHEN N'L' THEN N'Log'
		ELSE N'Unknown'
	END) AS N'Type',
	[name],
	[first_lsn], 
	[last_lsn]
FROM
	[msdb].[dbo].[backupset]
WHERE
	[database_name] = N'Company'
ORDER BY
	[backup_start_date];
GO

-- Now do the restore
USE [master];
GO

-- Start with the most recent full backup
RESTORE DATABASE [Company]
FROM DISK = N'D:\Pluralsight\Company_Full_Sunday.bak'
WITH NORECOVERY, REPLACE;

-- Then the most recent differential backup
RESTORE DATABASE [Company]
FROM DISK =	N'D:\Pluralsight\Company_Diff_Monday_4.bak'
WITH NORECOVERY;

-- And finally all the log backups after that
RESTORE DATABASE [Company]
FROM DISK =	N'D:\Pluralsight\Company_Log_Tuesday_1.bak'
WITH NORECOVERY;
GO

RESTORE DATABASE [Company]
FROM DISK =	N'D:\Pluralsight\Company_Log_Tuesday_2.bak'
WITH NORECOVERY;
GO

RESTORE DATABASE [Company]
FROM DISK = N'D:\Pluralsight\Company_Log_Tuesday_3.bak'
WITH NORECOVERY;
GO

RESTORE DATABASE [Company] WITH RECOVERY;
GO

-- Now suppose Monday's last diff is bad...

-- What backups do we have?
SELECT
	[backup_start_date],
	(CASE [type]
		WHEN N'D' THEN N'Full'
		WHEN N'I' THEN N'Diff'
		WHEN N'L' THEN N'Log'
		ELSE N'Unknown'
	END) AS N'Type',
	[name],
	[first_lsn], 
	[last_lsn]
FROM
	[msdb].[dbo].[backupset]
WHERE
	[database_name] = N'Company'
ORDER BY
	[backup_start_date];
GO

-- Restore sequence becomes:

-- Start with the most recent full backup
RESTORE DATABASE [Company]
FROM DISK = N'D:\Pluralsight\Company_Full_Sunday.bak'
WITH NORECOVERY, REPLACE;

-- Then the most recent good differential backup
RESTORE DATABASE [Company]
FROM DISK =	N'D:\Pluralsight\Company_Diff_Monday_3.bak'
WITH NORECOVERY;

-- The Monday log backups after that
RESTORE DATABASE [Company]
FROM DISK =	N'D:\Pluralsight\Company_Log_Monday_19.bak'
WITH NORECOVERY;
GO

RESTORE DATABASE [Company]
FROM DISK =	N'D:\Pluralsight\Company_Log_Monday_20.bak'
WITH NORECOVERY;
GO

RESTORE DATABASE [Company]
FROM DISK =	N'D:\Pluralsight\Company_Log_Monday_21.bak'
WITH NORECOVERY;
GO

RESTORE DATABASE [Company]
FROM DISK =	N'D:\Pluralsight\Company_Log_Monday_22.bak'
WITH NORECOVERY;
GO

RESTORE DATABASE [Company]
FROM DISK =	N'D:\Pluralsight\Company_Log_Monday_23.bak'
WITH NORECOVERY;
GO

RESTORE DATABASE [Company]
FROM DISK =	N'D:\Pluralsight\Company_Log_Monday_24.bak'
WITH NORECOVERY;
GO

-- And finally all the log backups after that
RESTORE DATABASE [Company]
FROM DISK =	N'D:\Pluralsight\Company_Log_Tuesday_1.bak'
WITH NORECOVERY;
GO

RESTORE DATABASE [Company]
FROM DISK =	N'D:\Pluralsight\Company_Log_Tuesday_2.bak'
WITH NORECOVERY;
GO

RESTORE DATABASE [Company]
FROM DISK = N'D:\Pluralsight\Company_Log_Tuesday_3.bak'
WITH NORECOVERY;
GO

RESTORE DATABASE [Company] WITH RECOVERY;
GO
