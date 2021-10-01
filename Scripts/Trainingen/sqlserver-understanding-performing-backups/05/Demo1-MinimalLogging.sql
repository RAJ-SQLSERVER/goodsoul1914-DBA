-- Demo script for Log Backups and Minimal Logging demo

USE master;
GO

IF DATABASEPROPERTYEX (N'Company', N'Version') > 0
BEGIN
    ALTER DATABASE Company SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Company;
END;
GO

-- Create the database
CREATE DATABASE Company
ON PRIMARY (NAME = N'Company', FILENAME = N'D:\SQLData\Company.mdf')
LOG ON (
    NAME = N'Company_log',
    FILENAME = N'D:\SQLLogs\Company_log.ldf',
    SIZE = 100MB
);
GO

-- Delete everything from the backup history table
-- Do not do this on a production system!
USE msdb;
GO

DECLARE @today DATETIME = GETDATE ();
EXEC sp_delete_backuphistory @oldest_date = @today;
GO

-- Use the full recovery model
ALTER DATABASE Company SET RECOVERY FULL;
GO

USE Company;
GO

-- Create a table
CREATE TABLE RandomData (c1 INT IDENTITY, c2 CHAR(8000) DEFAULT 'filler');
CREATE CLUSTERED INDEX RD_CL ON RandomData (c1);
GO

-- Perform a full backup
BACKUP DATABASE Company
TO  DISK = N'D:\SQLBackups\Company_Full1.bak'
WITH INIT,
     NAME = N'Company Full 1';
GO

-- Now add some data
SET NOCOUNT ON;
INSERT INTO RandomData
DEFAULT VALUES;
GO 5000

-- Perform a log backup
BACKUP LOG Company
TO  DISK = N'D:\SQLBackups\Company_Log1.bak'
WITH INIT,
     NAME = N'Company Log 1';
GO

-- Perform a non-minimally logged rebuild
ALTER INDEX RD_CL ON RandomData REBUILD;
GO

-- Perform another log backup
BACKUP LOG Company
TO  DISK = N'D:\SQLBackups\Company_Log2.bak'
WITH INIT,
     NAME = N'Company Log 2: fully logged';
GO

-- Look at the messages to see what was backed up

-- Perform a minimally logged rebuild
ALTER DATABASE Company SET RECOVERY BULK_LOGGED;
GO

ALTER INDEX RD_CL ON RandomData REBUILD;
GO

ALTER DATABASE Company SET RECOVERY FULL;
GO

-- Perform another log backup
BACKUP LOG Company
TO  DISK = N'D:\SQLBackups\Company_Log3.bak'
WITH INIT,
     NAME = N'Company Log 3: minimally logged';
GO

-- Look at the messages to see what was backed up
/*
Processed 5096 pages for database 'Company', file 'Company' on file 1.
Processed 60 pages for database 'Company', file 'Company_log' on file 1.
BACKUP LOG successfully processed 5156 pages in 0.085 seconds (473.885 MB/sec).
*/

-- Examine the backup history table in msdb to
-- see log included in the data backups
SELECT name,
       backup_size,
       has_bulk_logged_data
FROM msdb.dbo.backupset
WHERE database_name = 'Company';
GO

