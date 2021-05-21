-- Blog post available on http://bit.ly/15t52r8
-- Demo: switching from FULL to BULK_LOGGED and back
USE master;
GO

-- 0) Drop database if it exists
IF DATABASEPROPERTYEX('testDB', 'Version') > 0
	DROP DATABASE testDB;
GO

-- 1) Create the database to use
CREATE DATABASE testDB ON PRIMARY (
	name = 'testDB_data',
	filename = N'D:\Documents\MSSQL\DATA\testDB_data.mdf'
	) log ON (
	name = 'testDB_log',
	filename = N'D:\Documents\MSSQL\LOG\testDB_log.ldf',
	size = 50 mb,
	filegrowth = 10 mb
	);
GO

USE testDB;
GO

-- 2) Switch to FULL recovery model
ALTER DATABASE testDB

SET recovery FULL;
GO

-- 3) Create a table and corresponding CI
CREATE TABLE testTable (
	c1 INT identity,
	c2 VARCHAR(100)
	);
GO

CREATE CLUSTERED INDEX testTable_CL ON testTable (c1);
GO

-- 4) Insert a row in the table
INSERT INTO testTable
VALUES ('Row inserted: transaction # 1');
GO

-- 5) Take a full backup
-- Will contain everuthing from the start to the end of the
-- reading process of the backup plus enough tlog to get 
-- back to a consistent state when restored
BACKUP DATABASE testDB TO DISK = 'D:\Documents\MSSQL\BACKUP\testDB.bak'
WITH init,
	stats,
	stats;
GO

-- 6) Insert more rows
SET NOCOUNT ON;
GO

INSERT INTO testTable
VALUES ('Insert more rows...');GO 1000

-- 7) Take a log backup
-- Will contain all changes that happened since the last
-- tlog backup
BACKUP log testDB TO DISK = 'D:\Documents\MSSQL\BACKUP\testDB_log1.trn'
WITH init,
	stats,
	stats;
GO

-- 8) Switch to BULK_LOGGED recovery model prior to performing
-- an index rebuild
ALTER DATABASE testDB

SET recovery bulk_logged;
GO

-- 9) Perform an index rebuild. Note that this is in the 
-- BULK_LOGGED recovery model
ALTER INDEX testTable_CL ON testTable rebuild;
GO

-- 10) Switch back to FULL recovery model after the index rebuild
ALTER DATABASE testDB

SET recovery FULL;
GO

-- 11) Add more rows in the table
INSERT INTO testTable
VALUES ('Row inserted: transaction # 2');
GO

INSERT INTO testTable
VALUES ('Row inserted: transaction # 3');
GO

-- 12) Simulate a system crash
SHUTDOWN
WITH NOWAIT;
GO

-- 13) Corrupt the data file (by deleting it)
USE testDB;
GO

-- 14) Backup the tail-of-the-log so we can keep the 
-- transactions that are still in the log but not persisted 
-- to the data files
BACKUP LOG testDB TO DISK = 'D:\Documents\MSSQL\BACKUP\testDB_tail.trn'
WITH init,
	stats,
	no_truncate;
GO

--100 percent processed.
--Processed 5 pages for database 'testDB', file 'testDB_log' on file 1.
--BACKUP WITH CONTINUE_AFTER_ERROR successfully generated a backup of the damaged database. Refer to the SQL Server error log for information about the errors that were encountered.
--BACKUP LOG successfully processed 5 pages in 0.071 seconds (0.474 MB/sec).
-- 15) Try restoring from backups
RESTORE DATABASE testDB
FROM DISK = 'D:\Documents\MSSQL\BACKUP\testDB.bak'
WITH REPLACE,
	norecovery;
GO

RESTORE LOG testDB
FROM DISK = 'D:\Documents\MSSQL\BACKUP\testDB_Log1.trn'
WITH REPLACE,
	norecovery;
GO

-- Restore the tail-of-the-log backup
RESTORE LOG testDB
FROM DISK = 'D:\Documents\MSSQL\BACKUP\testDB_tail.trn'
WITH REPLACE;
GO

--Msg 3182, Level 16, State 2, Line 131
--The backup set cannot be restored because the database was damaged when the backup occurred. Salvage attempts may exploit WITH CONTINUE_AFTER_ERROR.
--Msg 3013, Level 16, State 1, Line 131
--RESTORE LOG is terminating abnormally.
-- 16) Try using the CONTINUE_AFTER_ERROR parameter
RESTORE LOG testDB
FROM DISK = 'D:\Documents\MSSQL\BACKUP\testDB_tail.trn'
WITH REPLACE,
	continue_after_error;
GO

--Processed 0 pages for database 'testDB', file 'testDB_data' on file 1.
--Processed 5 pages for database 'testDB', file 'testDB_log' on file 1.
--The backup set was written with damaged data by a BACKUP WITH CONTINUE_AFTER_ERROR.
--RESTORE WITH CONTINUE_AFTER_ERROR was successful but some damage was encountered. Inconsistencies in the database are possible.
--RESTORE LOG successfully processed 5 pages in 0.081 seconds (0.415 MB/sec).
--Msg 824, Level 17, State 2, Line 138
--SQL Server detected a logical consistency-based I/O error: 
-- incorrect pageid (expected 1:347; actual 49344:-1061109568). 
-- It occurred during a read of page (1:347) in database ID 11 at 
-- offset 0x000000002b6000 in file 
-- 'D:\Documents\MSSQL\DATA\testDB_data.mdf'. Additional messages 
-- in the SQL Server error log or operating system error log may 
-- provide more detail. This is a severe error condition that 
-- threatens database integrity and must be corrected immediately. 
-- Complete a full database consistency check (DBCC CHECKDB). 
-- This error can be caused by many factors; for more information, 
-- see SQL Server Books Online.
-- 17) Check if all the records are there
SELECT *
FROM TestDB..TestTable;
GO

--Msg 824, Level 24, State 2, Line 161
--SQL Server detected a logical consistency-based I/O error: 
-- incorrect pageid (expected 1:376; actual 49344:-1061109568). 
-- It occurred during a read of page (1:376) in database ID 11 at 
-- offset 0x000000002f0000 in file 
-- 'D:\Documents\MSSQL\DATA\testDB_data.mdf'. Additional messages 
-- in the SQL Server error log or operating system error log may 
-- provide more detail. This is a severe error condition that 
-- threatens database integrity and must be corrected immediately. 
-- Complete a full database consistency check (DBCC CHECKDB). 
-- This error can be caused by many factors; for more information, 
-- see SQL Server Books Online.
-- 18) Try running DBCC CHECKDB
DBCC CHECKDB (testDB)
WITH no_infomsgs;
GO

--Msg 8909, Level 16, State 1, Line 178
--Table error: Object ID 0, index ID -1, partition ID 0, alloc unit ID -4557430888798879744 (type Unknown), page ID (1:336) contains an incorrect page ID in its page header. The PageId in the page header = (49344:-1061109568).
--Msg 8909, Level 16, State 1, Line 178
--Table error: Object ID 0, index ID -1, partition ID 0, alloc unit ID -4557430888798879744 (type Unknown), page ID (1:344) contains an incorrect page ID in its page header. The PageId in the page header = (49344:-1061109568).
--Msg 8909, Level 16, State 1, Line 178
--Table error: Object ID 0, index ID -1, partition ID 0, alloc unit ID -4557430888798879744 (type Unknown), page ID (1:345) contains an incorrect page ID in its page header. The PageId in the page header = (49344:-1061109568).
--Msg 8909, Level 16, State 1, Line 178
--Table error: Object ID 0, index ID -1, partition ID 0, alloc unit ID -4557430888798879744 (type Unknown), page ID (1:346) contains an incorrect page ID in its page header. The PageId in the page header = (49344:-1061109568).
--Msg 8939, Level 16, State 98, Line 178
--Table error: Object ID 0, index ID -1, partition ID 0, alloc unit ID -4557430888798879744 (type Unknown), page (1:347). Test (IS_OFF (BUF_IOERR, pBUF->bstat)) failed. Values are 133129 and -6.
--Msg 8909, Level 16, State 1, Line 178
--Table error: Object ID 0, index ID -1, partition ID 0, alloc unit ID -4557430888798879744 (type Unknown), page ID (1:376) contains an incorrect page ID in its page header. The PageId in the page header = (49344:-1061109568).
--CHECKDB found 0 allocation errors and 6 consistency errors not associated with any single object.
--Msg 8928, Level 16, State 1, Line 178
--Object ID 901578250, index ID 1, partition ID 72057594043236352, alloc unit ID 72057594049658880 (type In-row data): Page (1:336) could not be processed.  See other errors for details.
--Msg 8928, Level 16, State 1, Line 178
--Object ID 901578250, index ID 1, partition ID 72057594043236352, alloc unit ID 72057594049658880 (type In-row data): Page (1:344) could not be processed.  See other errors for details.
--Msg 8928, Level 16, State 1, Line 178
--Object ID 901578250, index ID 1, partition ID 72057594043236352, alloc unit ID 72057594049658880 (type In-row data): Page (1:345) could not be processed.  See other errors for details.
--Msg 8928, Level 16, State 1, Line 178
--Object ID 901578250, index ID 1, partition ID 72057594043236352, alloc unit ID 72057594049658880 (type In-row data): Page (1:346) could not be processed.  See other errors for details.
--Msg 8928, Level 16, State 1, Line 178
--Object ID 901578250, index ID 1, partition ID 72057594043236352, alloc unit ID 72057594049658880 (type In-row data): Page (1:347) could not be processed.  See other errors for details.
--Msg 8928, Level 16, State 1, Line 178
--Object ID 901578250, index ID 1, partition ID 72057594043236352, alloc unit ID 72057594049658880 (type In-row data): Page (1:376) could not be processed.  See other errors for details.
--Msg 8980, Level 16, State 1, Line 178
--Table error: Object ID 901578250, index ID 1, partition ID 72057594043236352, alloc unit ID 72057594049658880 (type In-row data). Index node page (0:0), slot 0 refers to child page (1:376) and previous child (0:0), but they were not encountered.
--CHECKDB found 0 allocation errors and 7 consistency errors in table 'testTable' (object ID 901578250).
--CHECKDB found 0 allocation errors and 13 consistency errors in database 'testDB'.
--repair_allow_data_loss is the minimum repair level for the errors found by DBCC CHECKDB (testDB).
-- Tail-of-the-log backup is corrupt because it needs to backup all of the
-- extents that changed as part of the minimally logged backup.
-- If the database is in FULL recovery model, all of those changes are 
-- in the transaction log
-- 19) Re-restore without the tail-of-the-log
RESTORE DATABASE testDB
FROM DISK = 'D:\Documents\MSSQL\BACKUP\testDB.bak'
WITH REPLACE,
	norecovery;
GO

RESTORE LOG testDB
FROM DISK = 'D:\Documents\MSSQL\BACKUP\testDB_Log1.trn'
WITH REPLACE;
GO

SELECT *
FROM TestDB..TestTable;
GO

--------------------------------------------------------------------
-- The right approach is to backup the tlog immediately after
-- switching back to the FULL recovery model
--------------------------------------------------------------------
USE master;
GO

-- 0) Drop database if it exists
IF DATABASEPROPERTYEX('testDB', 'Version') > 0
	DROP DATABASE testDB;
GO

-- 1) Create the database to use
CREATE DATABASE testDB ON PRIMARY (
	name = 'testDB_data',
	filename = N'D:\Documents\MSSQL\DATA\testDB_data.mdf'
	) log ON (
	name = 'testDB_log',
	filename = N'D:\Documents\MSSQL\LOG\testDB_log.ldf',
	size = 50 mb,
	filegrowth = 10 mb
	);
GO

USE testDB;
GO

-- 2) Switch to FULL recovery model
ALTER DATABASE testDB

SET recovery FULL;
GO

-- 3) Create a table and corresponding CI
CREATE TABLE testTable (
	c1 INT identity,
	c2 VARCHAR(100)
	);
GO

CREATE CLUSTERED INDEX testTable_CL ON testTable (c1);
GO

-- 4) Insert a row in the table
INSERT INTO testTable
VALUES ('Row inserted: transaction # 1');
GO

-- 5) Take a full backup
BACKUP DATABASE testDB TO DISK = 'D:\Documents\MSSQL\BACKUP\testDB.bak'
WITH init,
	stats,
	stats;
GO

-- 6) Insert more rows
SET NOCOUNT ON;
GO

INSERT INTO testTable
VALUES ('Insert more rows...');GO 1000

-- 7) Take a log backup
BACKUP log testDB TO DISK = 'D:\Documents\MSSQL\BACKUP\testDB_log1.trn'
WITH init,
	stats,
	stats;
GO

-- 8) Switch to BULK_LOGGED recovery model
ALTER DATABASE testDB

SET recovery bulk_logged;
GO

-- 9) Perform an index rebuild
ALTER INDEX testTable_CL ON testTable rebuild;
GO

-- 10) Switch back to FULL recovery model after the index rebuild
ALTER DATABASE testDB

SET recovery FULL;
GO

-- Immediately perform a log backup!!!
BACKUP LOG testDB TO DISK = 'D:\Documents\MSSQL\BACKUP\testDB_log1a.trn'
WITH init,
	stats,
	stats;
GO

-- 11) Add more rows in the table
INSERT INTO testTable
VALUES ('Row inserted: transaction # 2');
GO

INSERT INTO testTable
VALUES ('Row inserted: transaction # 3');
GO

-- 12) Simulate a system crash
SHUTDOWN
WITH NOWAIT;
GO

-- 13) Corrupt the data file and start the SQL Server service
USE testDB;
GO

-- 14) Try taking a tail-of-the-log backup
BACKUP LOG testDB TO DISK = 'D:\Documents\MSSQL\BACKUP\testDB_tail.trn'
WITH init,
	stats,
	no_truncate;
GO

-- 15) Try restoring from backups
RESTORE DATABASE testDB
FROM DISK = 'D:\Documents\MSSQL\BACKUP\testDB.bak'
WITH REPLACE,
	norecovery;
GO

RESTORE LOG testDB
FROM DISK = 'D:\Documents\MSSQL\BACKUP\testDB_Log1.trn'
WITH REPLACE,
	norecovery;
GO

RESTORE LOG testDB
FROM DISK = 'D:\Documents\MSSQL\BACKUP\testDB_Log1a.trn'
WITH REPLACE,
	norecovery;
GO

RESTORE LOG testDB
FROM DISK = 'D:\Documents\MSSQL\BACKUP\testDB_tail.trn'
WITH REPLACE;
GO

SELECT *
FROM TestDB..TestTable;
GO


