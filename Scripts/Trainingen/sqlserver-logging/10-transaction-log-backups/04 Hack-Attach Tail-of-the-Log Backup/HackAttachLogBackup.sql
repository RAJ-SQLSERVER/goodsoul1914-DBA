-- *** IMPORTANT ***
-- Start SQLDEV01

-- Connect to SQLDEV01

USE [master];
GO

IF DATABASEPROPERTYEX (N'DBMaint2008', N'Version') > 0
BEGIN
	ALTER DATABASE [DBMaint2008] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [DBMaint2008];
END
GO

-- Imagine a complete server meltdown
-- We've just got a log file and some backups
-- Now what?

-- Restoring just the backups, we get:
RESTORE DATABASE [DBMaint2008]
	FROM DISK = N'D:\Pluralsight\DBMaint2008_Full_HAD.bck'
WITH REPLACE, NORECOVERY,
MOVE N'DBMaint2008' TO
	N'C:\Program Files\Microsoft SQL Server\MSSQL10.SQLDEV01\MSSQL\DATA\DBMaint2008.mdf',
MOVE N'DBMaint2008_log' TO
	N'C:\Program Files\Microsoft SQL Server\MSSQL10.SQLDEV01\MSSQL\DATA\DBMaint2008.ldf';
GO

-- And all other backups...
RESTORE LOG [DBMaint2008]
	FROM DISK = N'D:\Pluralsight\DBMaint2008_Log1_HAD.bck'
WITH NORECOVERY;
GO

-- Bring it online
RESTORE DATABASE [DBMaint2008] WITH RECOVERY;
GO

-- Check the data
SELECT * FROM [DBMaint2008].[dbo].[TestTable];
GO

-- What about getting the data from the log file?

-- Get rid of the newly restored database
DROP DATABASE [DBMaint2008];
GO

-- Create a dummy database
CREATE DATABASE [DBMaint2008];
GO

-- Shut the database down
ALTER DATABASE [DBMaint2008] SET OFFLINE;
GO

-- Delete the files and copy in the log file
-- from D:\Pluralsight

-- Restart the database
ALTER DATABASE [DBMaint2008] SET ONLINE;
GO

-- Take a log backup?
BACKUP LOG [DBMaint2008] TO
	DISK = N'D:\Pluralsight\DBMaint2008_tail.bck'
WITH INIT;
GO

-- Use the special syntax!
BACKUP LOG [DBMaint2008] TO
	DISK = N'D:\Pluralsight\DBMaint2008_tail.bck'
WITH INIT, NO_TRUNCATE;
GO

-- Now we can restore everything
-- First the full backup...
RESTORE DATABASE [DBMaint2008]
	FROM DISK = N'D:\Pluralsight\DBMaint2008_Full_HAD.bck'
WITH REPLACE, NORECOVERY,
MOVE N'DBMaint2008' TO
	N'C:\Program Files\Microsoft SQL Server\MSSQL10.SQLDEV01\MSSQL\DATA\DBMaint2008.mdf',
MOVE N'DBMaint2008_log' TO
	N'C:\Program Files\Microsoft SQL Server\MSSQL10.SQLDEV01\MSSQL\DATA\DBMaint2008.ldf';
GO

-- And all other backups...
RESTORE LOG [DBMaint2008]
	FROM DISK = N'D:\Pluralsight\DBMaint2008_Log1_HAD.bck'
WITH NORECOVERY;
GO

-- And restore the tail of the log backup
-- we just took
RESTORE LOG [DBMaint2008]
	FROM DISK = N'D:\Pluralsight\DBMaint2008_tail.bck'
WITH NORECOVERY;
GO

-- And finalize recovery
RESTORE DATABASE [DBMaint2008] WITH RECOVERY;
GO

-- Check the data
SELECT * FROM [DBMaint2008].[dbo].[TestTable];
GO