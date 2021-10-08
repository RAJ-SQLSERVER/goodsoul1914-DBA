-- This demo is the same in Module 6 and 8
USE master;
GO

IF DATABASEPROPERTYEX (N'DBMaint2012', N'Version') > 0
BEGIN
    ALTER DATABASE DBMaint2012 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DBMaint2012;
END;
GO

-- Create the database to use
CREATE DATABASE DBMaint2012;
GO
USE DBMaint2012;
GO
SET NOCOUNT ON;
GO

-- Create a table that will grow very
-- quickly and generate lots of transaction
-- log
CREATE TABLE BigRows (c1 INT IDENTITY, c2 CHAR(8000) DEFAULT 'a');
GO

-- Make sure the database is in FULL
-- recovery model
ALTER DATABASE DBMaint2012 SET RECOVERY FULL;
GO

-- In another window, run LoopInserts.sql

-- Go to perfmon and monitor the log
-- Auto-scale the sizes

-- Watch the saw-tooth - even though we're in
-- FULL recovery mode, the log is being cleared

-- Really switch to FULL
BACKUP DATABASE DBMaint2012
TO  DISK = N'D:\SQLBackups\DBMaint2012.bck'
WITH INIT,
     STATS;
GO

-- Now the log is out of control...
-- Change comment out the WAITFOR in the other window

-- Log size is hundreds of MB!

-- What's causing the log to not be cleared?
SELECT log_reuse_wait_desc
FROM master.sys.databases
WHERE name = N'DBMaint2012';
GO

-- So let's do one
BACKUP LOG DBMaint2012
TO  DISK = N'D:\SQLBackups\DBMaint2012_log.bck'
WITH STATS;
GO

-- Note counters.....