-- Backups and Log Clearing demo
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
GO

-- Perform a full backup
BACKUP DATABASE Company
TO  DISK = N'D:\SQLBackups\Company_Full1.bak'
WITH INIT,
     NAME = N'Company Full 1';
GO

-- Examine the log
-- SQL Server 2017+ has a DMV you can use: sys.dm_db_log_info
DBCC LOGINFO(N'Company');
GO

-- Now add some data
SET NOCOUNT ON;
INSERT INTO RandomData
DEFAULT VALUES;
GO 5000

-- Examine the log again
DBCC LOGINFO(N'Company');
GO

-- Perform a log backup
BACKUP LOG Company
TO  DISK = N'D:\SQLBackups\Company_Log1.bak'
WITH INIT,
     NAME = N'Company Log 1';
GO

-- Examine the backup history table in msdb to
-- see log included in the backups
SELECT name,
       first_lsn,
       last_lsn
FROM msdb.dbo.backupset
WHERE database_name = 'Company';
GO

-- Examine the log again
DBCC LOGINFO(N'Company');
GO

-- Add some more data
INSERT INTO RandomData
DEFAULT VALUES;
GO 4000

-- Examine the log again
DBCC LOGINFO(N'Company');
GO

-- Perform a log backup
BACKUP LOG Company
TO  DISK = N'D:\SQLBackups\Company_Log2.bak'
WITH INIT,
     NAME = N'Company Log 2';
GO

-- Examine the log again
DBCC LOGINFO(N'Company');
GO

-- Add some more data
INSERT INTO RandomData
DEFAULT VALUES;
GO 4000

-- Examine the log again
DBCC LOGINFO(N'Company');
GO

-- Perform a log backup
BACKUP LOG Company
TO  DISK = N'D:\SQLBackups\Company_Log3.bak'
WITH INIT,
     NAME = N'Company Log 3';
GO

-- Examine the log again
DBCC LOGINFO(N'Company');
GO

-- Examine the backup history table in msdb to
-- see log included in the backups
SELECT name,
       first_lsn,
       last_lsn
FROM msdb.dbo.backupset
WHERE database_name = 'Company';
GO

-- Add some more data
INSERT INTO RandomData
DEFAULT VALUES;
GO 4000

-- Examine the log again
DBCC LOGINFO(N'Company');
GO

-- What about a data backup?
BACKUP DATABASE Company
TO  DISK = N'D:\SQLBackups\Company_Full2.bak'
WITH INIT,
     NAME = N'Company Full 2';
GO

-- Examine the log again
DBCC LOGINFO(N'Company');
GO

-- Perform a log backup
BACKUP LOG Company
TO  DISK = N'D:\SQLBackups\Company_Log4.bak'
WITH INIT,
     NAME = N'Company Log 4';
GO

-- Examine the log again
DBCC LOGINFO(N'Company');
GO

-- Use the other demo script to start a transaction

-- Examine the log again
DBCC LOGINFO(N'Company');
GO

-- Perform a log backup
BACKUP LOG Company
TO  DISK = N'D:\SQLBackups\Company_Log5.bak'
WITH INIT,
     NAME = N'Company Log 5';
GO

-- Examine the log again
DBCC LOGINFO(N'Company');
GO

-- Why can't the log clear?
-- SQL Server 2017+ has a DMV you can use: sys.dm_db_log_stats
SELECT log_reuse_wait_desc
FROM sys.databases
WHERE name = N'Company';
GO

-- Find the open transaction
DBCC OPENTRAN(N'Company');
GO

-- Commit the transaction in the other window

-- Did that allow the log to clear?
DBCC LOGINFO(N'Company');
GO

-- Why can't the log clear?
SELECT log_reuse_wait_desc
FROM sys.databases
WHERE name = N'Company';
GO

-- What about a checkpoint?
CHECKPOINT;
GO

DBCC LOGINFO(N'Company');
GO

-- Why can't the log clear?
SELECT log_reuse_wait_desc
FROM sys.databases
WHERE name = N'Company';
GO

-- Perform a log backup
BACKUP LOG Company
TO  DISK = N'D:\SQLBackups\Company_Log6.bak'
WITH INIT,
     NAME = N'Company Log 6';
GO

-- Examine the log again
DBCC LOGINFO(N'Company');
GO