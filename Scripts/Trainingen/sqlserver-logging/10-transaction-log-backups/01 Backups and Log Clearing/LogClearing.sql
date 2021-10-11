USE master;
GO

IF DATABASEPROPERTYEX (N'DBMaint2012', N'Version') > 0
BEGIN
    ALTER DATABASE DBMaint2012 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DBMaint2012;
END;
GO

-- Create the database
CREATE DATABASE DBMaint2012;
GO

USE DBMaint2012;
GO

-- Create a table and insert 8MB
CREATE TABLE BigTable (c1 INT IDENTITY, c2 CHAR(8000) DEFAULT 'a');
GO
CREATE CLUSTERED INDEX BigTable_CL ON BigTable (c1);
GO

SET NOCOUNT ON;
GO

INSERT INTO BigTable
DEFAULT VALUES;
GO 1000

-- Put the database into the FULL recovery model and clear out the log.
ALTER DATABASE DBMaint2012 SET RECOVERY FULL;
GO

BACKUP DATABASE DBMaint2012
TO  DISK = 'D:\SQLBackups\DBMaint2012_Full_0.bak'
WITH INIT,
     STATS;
GO

BACKUP LOG DBMaint2012
TO  DISK = 'D:\SQLBackups\DBMaint2012_Log_0_Initial.bak'
WITH INIT,
     STATS;
GO

-- Now rebuild the clustered index to generate a bunch of log
ALTER INDEX BigTable_CL ON BigTable REBUILD;
GO

-- Backup the log to get a baseline size
BACKUP LOG DBMaint2012
TO  DISK = 'D:\SQLBackups\DBMaint2012_Log_1_Baseline.bak'
WITH INIT,
     STATS;
GO

-- Test 1
-- Now rebuilds the clustered index again to generate more log
ALTER INDEX BigTable_CL ON BigTable REBUILD;
GO

-- Now try a full backup and see if it clears the log
BACKUP DATABASE DBMaint2012
TO  DISK = 'D:\SQLBackups\DBMaint2012_Full_1.bak'
WITH INIT,
     STATS;
GO

-- If it did, this next log backup should be very small
BACKUP LOG DBMaint2012
TO  DISK = 'D:\SQLBackups\DBMaint2012_Log_2_FullTest.bak'
WITH INIT,
     STATS;
GO

-- Test 2
-- Now rebuild the clustered index again to generate more log
ALTER INDEX BigTable_CL ON BigTable REBUILD;
GO

-- Now try a checkpoint and see if it clears the log
CHECKPOINT;
GO

-- If it did, this next log backup should be very small
BACKUP LOG DBMaint2012
TO  DISK = 'D:\SQLBackups\DBMaint2012_Log_3_CheckTest.bak'
WITH INIT,
     STATS;
GO

-- Test 3
-- Now the case where there's a long-running transaction and 
-- the log can't be cleared by the backup. When does it get cleared?

-- In the other window, do a long-running transaction...

-- In the other window, try a log backup

-- How much log is being used?
DBCC SQLPERF(LOGSPACE);
GO

-- Now let's take a log backup
BACKUP LOG DBMaint2012
TO  DISK = 'D:\SQLBackups\DBMaint2012_Log_4_LongTest.bak'
WITH INIT,
     STATS;
GO

-- How big is it?

-- Did the percentage used go down?
DBCC SQLPERF(LOGSPACE);
GO

-- Now commit the transaction...

-- Did the percentage used go down?
DBCC SQLPERF(LOGSPACE);
GO

-- Yes, why? Log space reservation.

-- How about a checkpoint?
CHECKPOINT;
GO
DBCC SQLPERF(LOGSPACE);
GO

-- How about a full backup?
BACKUP DATABASE DBMaint2012
TO  DISK = 'D:\SQLBackups\DBMaint2012_Full_2.bak'
WITH INIT,
     STATS;
GO
DBCC SQLPERF(LOGSPACE);
GO

-- How about a log backup?
BACKUP LOG DBMaint2012
TO  DISK = 'D:\SQLBackups\DBMaint2012_Log_5_LongTest2.bak'
WITH INIT,
     STATS;
GO
DBCC SQLPERF(LOGSPACE);
GO
