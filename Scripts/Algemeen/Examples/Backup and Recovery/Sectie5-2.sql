-- DATABASE RECOVERY TECHNIQUES
---------------------------------------------------------------------------------------------------
---------------------------------------------------
-- 1) Taking tail-of-the-log backups.
---------------------------------------------------
USE master;
GO

CREATE DATABASE testDB ON PRIMARY (
	name = N'testDB_data',
	filename = N'D:\Documents\MSSQL\DATA\testDB_data.mdf'
	) log ON (
	name = N'testDB_log',
	filename = N'D:\Documents\MSSQL\LOG\testDB_log.ldf',
	size = 50 mb,
	filegrowth = 10 mb
	);
GO

USE testDB;
GO

ALTER DATABASE testDB

SET recovery FULL;
GO

CREATE TABLE testTable (
	c1 INT identity,
	c2 VARCHAR(100)
	);
GO

CREATE CLUSTERED INDEX testTable_CL ON testTable (c1);
GO

INSERT INTO testTable
VALUES ('Row inserted: transaction #1');
GO

BACKUP DATABASE testDB TO DISK = 'D:\Documents\MSSQL\BACKUP\testDB.bak'
WITH init,
	stats,
	stats;
GO

SET NOCOUNT ON;
GO

INSERT INTO testTable
VALUES ('Inserted more rows...');GO 1000

USE testDB;
GO

SELECT *
FROM testTable;
GO

SHUTDOWN
WITH NOWAIT;
GO

-- Delete the data file now and start the SQL Server service.
USE testDB;
GO

-- inaccessible files !!!
xp_readerrorlog;

--LogDate					ProcessInfo		Text
--2020-02-26 19:58:38.770	Logon			Login failed for user 'MicrosoftAccount\mboomaars@gmail.com'. Reason: Failed to open the explicitly specified database 'testDB'. [CLIENT: <local machine>]
-- Perform tail-of-the-log backup.
BACKUP log testDB TO DISK = 'D:\Documents\MSSQL\BACKUP\testDB_tail.trn'
WITH init,
	stats,
	no_truncate;
GO

-- Try restoring from backup.
RESTORE DATABASE testDB
FROM DISK = 'D:\Documents\MSSQL\BACKUP\testDB.bak'
WITH replace,
	norecovery;
GO

RESTORE log testDB
FROM DISK = 'D:\Documents\MSSQL\BACKUP\testDB_tail.trn'
WITH replace;
GO

USE testDB;
GO

SELECT *
FROM testTable;
GO

---------------------------------------------------------
-- 2) Recovering databases to a specific point in time
---------------------------------------------------------
USE master;
GO

BACKUP DATABASE SalesDB TO DISK = 'D:\Documents\MSSQL\BACKUP\SalesDBBackup.bak'
WITH name = N'Full database backup',
	description = N'Starting point for recovery',
	init,
	stats = 10;
GO

-- Check number of records in the table
USE SalesDB;
GO

SELECT COUNT(*)
FROM dbo.Sales;
GO

-- 6715220
-- Perform some transactions
UPDATE dbo.Sales
SET Quantity = Quantity + 2
WHERE CustomerID > 6000;
GO

DELETE
FROM dbo.Sales
WHERE CustomerID > 1000
	AND CustomerID < 2000;
GO

-- Simulate a disaster - accidentally dropping a table
-------- DROP TABLE BATCH ---------
SELECT GETDATE();
GO

-- 2020-02-26 20:16:20.840
WAITFOR DELAY '00:00:02';
GO

DROP TABLE dbo.Sales;
GO

-- Check database properties. Not too many options because of single data file
sp_helpfile;
GO

--name			fileid	filename								filegroup	size		maxsize			growth		usage
--SalesDBData	1		D:\Documents\MSSQL\Data\SalesDBData.mdf	PRIMARY		204800 KB	Unlimited		1024 KB		data only
--SalesDBLog	2		D:\Documents\MSSQL\Log\SalesDBLog.ldf	NULL		1694592 KB	2147483648 KB	10%			log only
-- Contain the disaster by restricting access to the database
USE master;
GO

ALTER DATABASE SalesDB

SET restricted_user
WITH

ROLLBACK immediate;
GO

--Nonqualified transactions are being rolled back. Estimated rollback completion: 0%.
--Nonqualified transactions are being rolled back. Estimated rollback completion: 100%.
-- Perform tail-of-the-log backup.
BACKUP log SalesDB TO DISK = 'D:\Documents\MSSQL\BACKUP\SalesDB_tail.trn'
WITH init,
	stats,
	no_truncate,
	name = N'Tail-of-the-log Backup',
	description = N'Tail-of-the-log Backup';
GO

-- Check backup contents
RESTORE headeronly
FROM DISK = N'D:\Documents\MSSQL\BACKUP\SalesDBBackup.bak';
GO

RESTORE headeronly
FROM DISK = N'D:\Documents\MSSQL\BACKUP\SalesDB_tail.trn';
GO

-- Restore database from backups - FULL
USE master;
GO

RESTORE DATABASE SalesDB
FROM DISK = N'D:\Documents\MSSQL\BACKUP\SalesDBBackup.bak'
WITH norecovery,
	restricted_user;
GO

-- Restore database from backups - Tail-of-the-log
RESTORE log SalesDB
FROM DISK = N'D:\Documents\MSSQL\BACKUP\SalesDB_tail.trn'
WITH restricted_user,
	stopat = '2020-02-26 20:15:20.840',
	recovery;
GO

-- Check the dropped table
USE SalesDB;
GO

SELECT MAX(SalesId)
FROM dbo.Sales;
GO

-- 6737977
-- Create a snapshot of the restored point.
-- This will be used as a point of reference
sp_helpfile;
GO

CREATE DATABASE SalesDB_RestorePointSnapshot ON (
	name = N'SalesDBData',
	filename = N'D:\Documents\MSSQL\Data\SalesDB_RestorePointSnapshot.ss'
	) AS snapshot OF SalesDB;
GO

DBCC CHECKIDENT ('Sales');-- the number of rows we have...
	--Checking identity information: current identity value '6737977', current column value '6737977'.
	--DBCC execution completed. If DBCC printed error messages, contact your system administrator.
	-- Create a gap in the IDENTITY values of the Sales table
	-- This will be used for inserting records that we have recovered in the process

DBCC CHECKIDENT (
		'Sales',
		reseed,
		6800000
		);
GO

-- Allow users back in the database so they can continue their work
-- RTO is when the db is back online
USE master;
GO

ALTER DATABASE SalesDB

SET multi_user;
GO

-- Create another copy of the db similar to what we have restored
--	This will be used for comparison with the snapshot which is read-only
--	and we can no longer touch the production db because it is already live!
USE master;
GO

sp_helpfile;
GO

RESTORE DATABASE SalesDB_Investigate
FROM DISK = N'D:\Documents\MSSQL\BACKUP\SalesDBBackup.bak'
WITH MOVE N'SalesDBData' TO N'D:\Documents\MSSQL\Data\SalesDBData_Investigate.mdf',
	MOVE N'SalesDBLog' TO N'D:\Documents\MSSQL\Log\SalesDBLog_Investigate.ldf',
	standby = N'D:\Documents\MSSQL\BACKUP\SalesDBBackup_UNDO.bak',
	stopat = '2020-02-26 20:15:20.840',
	stats;
GO

RESTORE log SalesDB_Investigate
FROM DISK = N'D:\Documents\MSSQL\BACKUP\SalesDB_tail.trn'
WITH standby = N'D:\Documents\MSSQL\BACKUP\SalesDBBackup_UNDO.bak',
	stopat = '2020-02-26 20:15:20.840',
	stats;
GO

-- NOTE: we have to repeat this process over and over until we find the EXACT point in
--		 time that the table was dropped. We will also query the table until the restored
--		 data no longer shows the dropped object. This is the FINAL point of the STOPAT param
-- Compare the snapshot with the restored investigation database
SELECT MAX(salesid) AS RestoredDB
FROM SalesDB_Investigate.dbo.Sales;
GO

-- 6737977
SELECT MAX(salesid) AS ProductionDB
FROM SalesDB_RestorePointSnapshot.dbo.Sales;
GO

--6737977
--=============================================
-- Display the number of rows that are in the snapshot but not in the restored copy
SELECT *
FROM SalesDB_Investigate.dbo.Sales AS R
WHERE R.SalesID > 6737977;-- highest value before the gap in SalesDB
GO

-- Recover the missing rows
-- OPTION 1: use INSERT ... SELECT
SET IDENTITY_INSERT SalesDB.dbo.Sales ON;
GO

INSERT INTO SalesDB.dbo.Sales (
	SalesID,
	SalesPersonID,
	CustomerID,
	ProductID,
	Quantity
	)
SELECT *
FROM SalesDB_Investigate.dbo.Sales AS R
WHERE R.SalesID > 6737977;
GO

-- OPTION 2: use tablediff.exe
-- http://msdn.microsoft.com/en-us/library/ms162843.aspx
-- OPTION 3: use fn_dblog() 
USE SalesDB;
GO

SELECT SUSER_SNAME([Transaction SID]) AS Culprit,
	Description,
	*
FROM fn_dblog(NULL, NULL)
WHERE Description LIKE 'DROP%';
GO

---------------------------------------------------------------------------------------------------
-- 3) ISOLATING CRITICAL OBJECTS FOR HA & DR
---------------------------------------------------------------------------------------------------
-- If the primary filegroup is offline, 
-- technically the database is offline !!!
-- 0) Create a 2GB VHD drive and assign drive letter G 
sp_helpdb;
GO

-- 1) Create user-defined filegroup
USE SalesDB;
GO

ALTER DATABASE SalesDB ADD filegroup SalesDBSalesDataFG;
GO

ALTER DATABASE SalesDB ADD FILE (
	name = N'SalesDBSalesData',
	filename = N'G:\MSSQL\DATA\SalesDBSalesData.ndf',
	size = 480,
	maxsize = 480,
	filegrowth = 10
	) TO filegroup SalesDBSalesDataFG;
GO

-- 2) Validate filegroup creation
sp_helpfile;
GO

-- 3) Move the Sales table to the newly created filegroup
USE SalesDB;
GO

CREATE UNIQUE CLUSTERED INDEX SalesPK ON dbo.Sales (SalesID)
	WITH (
			drop_existing = ON,
			online = ON
			) ON [SalesDBSalesDataFG];
GO

-- Have a look at the standard report named Disk Usage
-- 4) Backup the database after any major database change
USE master;
GO

BACKUP DATABASE SalesDB TO DISK = N'D:\Documents\MSSQL\BACKUP\SalesDBBackup.bak'
WITH init,
	stats = 10;
GO

-- Simulate activity
USE SalesDB;
GO

UPDATE dbo.Sales
SET Quantity = Quantity + 1
WHERE CustomerID > 10000;
GO

-- 5) Simulate disk corruption on drive G:\
-- 6) Run the checkpoint process manually to see the disk corruption issue
CHECKPOINT;

--Msg 5901, Level 16, State 1, Line 371
--One or more recovery units belonging to database 'SalesDB' failed to generate a checkpoint. This is typically caused by lack of system resources such as disk or memory, or in some cases due to database corruption. Examine previous entries in the error log for more detailed information on this failure.
--Msg 823, Level 24, State 3, Line 371
--The operating system returned error 21(Het apparaat is niet klaar.) to SQL Server during a write at offset 0x0000000c31a000 in file 'G:\MSSQL\DATA\SalesDBSalesData.ndf'. Additional messages in the SQL Server error log and operating system error log may provide more detail. This is a severe system-level error condition that threatens database integrity and must be corrected immediately. Complete a full database consistency check (DBCC CHECKDB). This error can be caused by many factors; for more information, see SQL Server Books Online.
-- 7) Set the corrupt file to offline
ALTER DATABASE SalesDB modify FILE (
	name = N'SalesDBSalesData',
	offline
	);
GO

--Msg 823, Level 24, State 1, Line 366
--The operating system returned error 21(Het apparaat is niet klaar.) to SQL Server during a read at offset 0000000000000000 in file 'G:\MSSQL\DATA\SalesDBSalesData.ndf'. Additional messages in the SQL Server error log and operating system error log may provide more detail. This is a severe system-level error condition that threatens database integrity and must be corrected immediately. Complete a full database consistency check (DBCC CHECKDB). This error can be caused by many factors; for more information, see SQL Server Books Online.
-- 8) Verify that the file is offline
USE SalesDB;
GO

SELECT FILE_ID,
	name,
	physical_name,
	state_desc
FROM sys.database_files;
GO

--FILE_ID	name				physical_name							state_desc
--1			SalesDBData			D:\Documents\MSSQL\Data\SalesDBData.mdf	ONLINE
--2			SalesDBLog			D:\Documents\MSSQL\Log\SalesDBLog.ldf	ONLINE
--3			SalesDBSalesData	G:\MSSQL\DATA\SalesDBSalesData.ndf		OFFLINE
-- 9) Backup tail-of-the-log
USE master;
GO

BACKUP log SalesDB TO DISK = N'D:\Documents\MSSQL\BACKUP\SalesDBBackup_tail.trn'
WITH noinit,
	no_truncate,
	stats = 10;
GO

-- 10) Restore damaged file from backup and move it to different location
USE master;
GO

RESTORE DATABASE SalesDB FILE = N'SalesDBSalesData'
FROM DISK = N'D:\Documents\MSSQL\BACKUP\SalesDBBackup.bak'
WITH FILE = 1,
	MOVE N'SalesDBSalesData' TO N'D:\Documents\MSSQL\DATA\SalesDBSalesData.ndf',
	norecovery;
GO

--Processed 23288 pages for database 'SalesDB', file 'SalesDBSalesData' on file 1.
--RESTORE DATABASE ... FILE=<name> successfully processed 23288 pages in 7.104 seconds (25.610 MB/sec).
-- The other tables are still accessible even though the damaged filegroup is being restored
SELECT *
FROM SalesDB.dbo.Products;
GO

-- 11) Restore tail-of-the-log backup
USE master;
GO

RESTORE log SalesDB
FROM DISK = N'D:\Documents\MSSQL\BACKUP\SalesDBBackup_tail.trn'
WITH recovery,
	stats = 10;
GO

-- 12) Verify that the file is online
USE SalesDB;
GO

SELECT FILE_ID,
	name,
	physical_name,
	state_desc
FROM sys.database_files;
GO

--FILE_ID	name				physical_name									state_desc
--1			SalesDBData			D:\Documents\MSSQL\Data\SalesDBData.mdf			ONLINE
--2			SalesDBLog			D:\Documents\MSSQL\Log\SalesDBLog.ldf			ONLINE
--3			SalesDBSalesData	D:\Documents\MSSQL\DATA\SalesDBSalesData.ndf	ONLINE
-- Restore previous version
USE master;
GO

RESTORE DATABASE SalesDB
FROM DISK = N'D:\Documents\MSSQL\BACKUP\WINSRV1\SalesDB\FULL\WINSRV1_SalesDB_FULL_20200228_220111.bak'
WITH recovery,
	stats = 10;
GO

---------------------------------------------------------------------------------------------------
-- 4) USE TABLE PARTITIONING FOR HA/DR
---------------------------------------------------------------------------------------------------
-- 1) Create multiple filegroups
USE SalesDB;
GO

sp_helpfile;
GO

-- Partition 1
ALTER DATABASE SalesDB ADD filegroup SalesDBSalesDataPartition1;
GO

ALTER DATABASE SalesDB ADD FILE (
	name = N'SalesDBSalesDataPartition1',
	filename = N'D:\Documents\MSSQL\DATA\SalesDBSalesDataPartition1.ndf',
	size = 480,
	maxsize = 480,
	filegrowth = 10
	) TO filegroup SalesDBSalesDataPartition1;
GO

-- Partition 2
ALTER DATABASE SalesDB ADD filegroup SalesDBSalesDataPartition2;
GO

ALTER DATABASE SalesDB ADD FILE (
	name = N'SalesDBSalesDataPartition2',
	filename = N'D:\Documents\MSSQL\DATA\SalesDBSalesDataPartition2.ndf',
	size = 480,
	maxsize = 480,
	filegrowth = 10
	) TO filegroup SalesDBSalesDataPartition2;
GO

-- Partition 3
ALTER DATABASE SalesDB ADD filegroup SalesDBSalesDataPartition3;
GO

ALTER DATABASE SalesDB ADD FILE (
	name = N'SalesDBSalesDataPartition3',
	filename = N'G:\MSSQL\DATA\SalesDBSalesDataPartition3.ndf',
	size = 480,
	maxsize = 480,
	filegrowth = 10
	) TO filegroup SalesDBSalesDataPartition3;
GO

-- 2) Validate filegroup creation
sp_helpfile;

--name	fileid	filename	filegroup	size	maxsize	growth	usage
--SalesDBData	1	D:\Documents\MSSQL\Data\SalesDBData.mdf	PRIMARY	204800 KB	Unlimited	1024 KB	data only
--SalesDBLog	2	D:\Documents\MSSQL\Log\SalesDBLog.ldf	NULL	1694592 KB	2147483648 KB	10%	log only
--SalesDBSalesDataPartition1	3	D:\Documents\MSSQL\DATA\SalesDBSalesDataPartition1.ndf	SalesDBSalesDataPartition1	491520 KB	491520 KB	10240 KB	data only
--SalesDBSalesDataPartition2	4	D:\Documents\MSSQL\DATA\SalesDBSalesDataPartition2.ndf	SalesDBSalesDataPartition2	491520 KB	491520 KB	10240 KB	data only
--SalesDBSalesDataPartition3	5	G:\MSSQL\DATA\SalesDBSalesDataPartition3.ndf	SalesDBSalesDataPartition3	491520 KB	491520 KB	10240 KB	data only
-- 3) Create partition function and scheme
CREATE PARTITION FUNCTION SalesPartitions_ufn (INT) AS range right
FOR
VALUES (
	2500000,
	5000000
	);
GO

-- 0 - 2500000 / 2500000 - 5000000 / > 5000000 
CREATE PARTITION scheme SalesPartition_ups AS PARTITION SalesPartitions_ufn TO (
	SalesDBSalesDataPartition1,
	SalesDBSalesDataPartition2,
	SalesDBSalesDataPartition3
	);
GO

-- 4) Do an online operation while moving the data across partitions
USE SalesDB;
GO

CREATE UNIQUE CLUSTERED INDEX SalesPK ON Sales (SalesID)
	WITH (
			drop_existing = ON,
			online = ON
			) ON SalesPartition_ups(SalesID);
GO

-- Have a look at the standard report named Disk Usage
-- 5) Backup database after major changes to database
USE master;
GO

BACKUP DATABASE SalesDB TO DISK = N'D:\Documents\MSSQL\BACKUP\SalesDBBackup.bak'
WITH name = N'Full Database Backup',
	description = N'Starting point for recovery',
	init,
	stats = 10;
GO

-- 6) View partition metadata
USE SalesDB;
GO

SELECT *
FROM sys.partitions
WHERE object_id = OBJECT_ID('dbo.Sales');
GO

-- 7) View data with partition number
SELECT TOP 5 *,
	$PARTITION.SalesPartitions_ufn(SalesID) AS PartitionNo
FROM dbo.Sales
WHERE SalesID < 2500000;

SELECT TOP 5 *,
	$PARTITION.SalesPartitions_ufn(SalesID) AS PartitionNo
FROM dbo.Sales
WHERE SalesID >= 2500000
	AND SalesID < 5000000;

SELECT TOP 5 *,
	$PARTITION.SalesPartitions_ufn(SalesID) AS PartitionNo
FROM dbo.Sales
WHERE SalesID >= 5000000;

-- 8) Verify that data from all partitions is available
USE SalesDB;
GO

-- Partition1
SELECT TOP 5 *
FROM dbo.Sales
WHERE SalesID < 2500000;
GO

-- Partition2
SELECT TOP 5 *
FROM dbo.Sales
WHERE SalesID >= 2500000
	AND SalesID < 5000000;
GO

-- Partition3
SELECT TOP 5 *
FROM dbo.Sales
WHERE SalesID >= 5000000;
GO

-- Simulate activity
USE SalesDB;
GO

UPDATE dbo.Sales
SET Quantity = Quantity + 1
WHERE CustomerID > 10000;
GO

-- 9) Simulate corrupted disk partition on drive G:\ - the drive containing partitions 3
-- Partition1
SELECT TOP 5 *
FROM dbo.Sales
WHERE SalesID < 2500000;
GO

-- Partition3
SELECT TOP 5 *
FROM dbo.Sales
WHERE SalesID >= 5000000
ORDER BY SalesID DESC;
GO

-- Data is still in the cache, so even though the data is no longer on disk, the query 
-- will run successfully
-- 11) Run an update statement on a record that is on the corrupted disk
USE SalesDB;
GO

UPDATE dbo.Sales
SET Quantity = 2
WHERE SalesID = 6000001;
GO

-- The records are boing modified in cache and stored in tlog
-- 12) Run the checkpoint process manually
CHECKPOINT;
GO

--Msg 5901, Level 16, State 1, Line 639
--One or more recovery units belonging to database 'SalesDB' failed to generate a checkpoint. This is typically caused by lack of system resources such as disk or memory, or in some cases due to database corruption. Examine previous entries in the error log for more detailed information on this failure.
--Msg 823, Level 24, State 3, Line 639
--The operating system returned error 21(Het apparaat is niet klaar.) to SQL Server during a write at offset 0x0000000cdf0000 in file 'G:\MSSQL\DATA\SalesDBSalesDataPartition4File1.ndf'. Additional messages in the SQL Server error log and operating system error log may provide more detail. This is a severe system-level error condition that threatens database integrity and must be corrected immediately. Complete a full database consistency check (DBCC CHECKDB). This error can be caused by many factors; for more information, see SQL Server Books Online.
-- 13) Verify that the update statement was committed
SELECT TOP 10 *
FROM dbo.Sales
WHERE SalesID > 6000000;
GO

-- 14) Run DBCC DROPCLEANBUFFERS to remove all clean buffers from the buffer pool
DBCC DROPCLEANBUFFERS;
GO

-- Re-run query 13
--Msg 823, Level 24, State 2, Line 647
--The operating system returned error 21(Het apparaat is niet klaar.) to SQL Server during a read at offset 0x0000000dc20000 in file 'G:\MSSQL\DATA\SalesDBSalesDataPartition4File1.ndf'. Additional messages in the SQL Server error log and operating system error log may provide more detail. This is a severe system-level error condition that threatens database integrity and must be corrected immediately. Complete a full database consistency check (DBCC CHECKDB). This error can be caused by many factors; for more information, see SQL Server Books Online.
-- 15) Set the corrupt partition to OFFLINE
USE master;
GO

ALTER DATABASE SalesDB modify FILE (
	name = N'SalesDBSalesDataPartition3',
	offline
	);
GO

--Msg 823, Level 24, State 3, Line 662
--The operating system returned error 21(Het apparaat is niet klaar.) to SQL Server during a write at offset 0x0000000cdf0000 in file 'G:\MSSQL\DATA\SalesDBSalesDataPartition4File1.ndf'. Additional messages in the SQL Server error log and operating system error log may provide more detail. This is a severe system-level error condition that threatens database integrity and must be corrected immediately. Complete a full database consistency check (DBCC CHECKDB). This error can be caused by many factors; for more information, see SQL Server Books Online.
-- 16) Verify that the files are offline
USE SalesDB;
GO

SELECT FILE_ID,
	name,
	physical_name,
	state_desc
FROM sys.database_files;
GO

--FILE_ID	name							physical_name												state_desc
--1			SalesDBData						D:\Documents\MSSQL\Data\SalesDBData.mdf						ONLINE
--2			SalesDBLog						D:\Documents\MSSQL\Log\SalesDBLog.ldf						ONLINE
--3			SalesDBSalesDataPartition1File1	D:\Documents\MSSQL\DATA\SalesDBSalesDataPartition1File1.ndf	ONLINE
--4			SalesDBSalesDataPartition2File1	D:\Documents\MSSQL\DATA\SalesDBSalesDataPartition2File1.ndf	ONLINE
--5			SalesDBSalesDataPartition3File1	G:\MSSQL\DATA\SalesDBSalesDataPartition3File1.ndf			OFFLINE			OFFLINE
-- 17) Backup tail-of-the-log
USE master;
GO

BACKUP log SalesDB TO DISK = N'D:\Documents\MSSQL\BACKUP\SalesDBBackup_tail.trn'
WITH noinit,
	no_truncate,
	stats = 10;
GO

-- 18) Restore damaged file from backup and move it to different location
USE master;
GO

RESTORE DATABASE SalesDB FILE = N'SalesDBSalesDataPartition3'
FROM DISK = N'D:\Documents\MSSQL\BACKUP\SalesDBBackup.bak'
WITH FILE = 1,
	MOVE N'SalesDBSalesDataPartition3' TO N'D:\Documents\MSSQL\DATA\SalesDBSalesDataPartition3.ndf',
	norecovery;
GO

-- 19) Restore tail-of-the-log backup 
USE master;
GO

RESTORE log SalesDB
FROM DISK = N'D:\Documents\MSSQL\BACKUP\SalesDBBackup_tail.trn'
WITH recovery,
	stats = 10;
GO

-- 20) Verify that the files are online
USE SalesDB;
GO

SELECT FILE_ID,
	name,
	physical_name,
	state_desc
FROM sys.database_files;
GO

--FILE_ID	name							physical_name												state_desc
--1			SalesDBData						D:\Documents\MSSQL\Data\SalesDBData.mdf						ONLINE
--2			SalesDBLog						D:\Documents\MSSQL\Log\SalesDBLog.ldf						ONLINE
--3			SalesDBSalesDataPartition1File1	D:\Documents\MSSQL\DATA\SalesDBSalesDataPartition1File1.ndf	ONLINE
--4			SalesDBSalesDataPartition2File1	D:\Documents\MSSQL\DATA\SalesDBSalesDataPartition2File1.ndf	ONLINE
--5			SalesDBSalesDataPartition3File1	D:\Documents\MSSQL\DATA\SalesDBSalesDataPartition3File1.ndf	online
USE SalesDB;
GO

SELECT TOP 10 *
FROM dbo.Sales
WHERE SalesID > 6000000;
GO

-- Restore previous version
USE master;
GO

RESTORE DATABASE SalesDB
FROM DISK = N'D:\Documents\MSSQL\BACKUP\WINSRV1\SalesDB\FULL\WINSRV1_SalesDB_FULL_20200228_220111.bak'
WITH recovery,
	stats = 10;
GO

---------------------------------------------------------------------------------------------------
-- 5) PERFORMING PAGE-LEVEL RESTORES
---------------------------------------------------------------------------------------------------
-- 0) Corrupt a page
DBCC TRACEON (3604);
GO

DBCC page('SalesDB', 1, 2784, 3);

SELECT 2784 * 8192 AS [My Offset];-- 22806528

USE master;

ALTER DATABASE SalesDB

SET offline;

-- Use hex editor 
-- CTRL + G to offset 22806522
-- Corrupt the file
ALTER DATABASE SalesDB

SET online;

-- 1) Query our corrupt database
USE SalesDB;
GO

SELECT *
FROM dbo.Sales
WHERE SalesID > 2762100;
GO

-- 2) Run DBCC CHECKDB to check the allocation
-- and structural integrity of all the objects in the database
DBCC CHECKDB (SalesDB)
WITH no_infomsgs;

-- 3) Let's have a look at the page in detail
DBCC TRACEON (3604);
GO

DBCC page('SalesDB', 1, 2784, 3);
GO

-- 4) Backup tail-of-the-log
BACKUP log SalesDB TO DISK = N'D:\Documents\MSSQL\BACKUP\SalesDBBackup_tail.bak'
WITH init,
	no_truncate;
GO

-- 5) Restore corrupt database page
USE master;
GO

RESTORE DATABASE SalesDB page = '1:2783'
FROM DISK = N'D:\Documents\MSSQL\BACKUP\WINSRV1\SalesDB\FULL\WINSRV1_SalesDB_FULL_20200228_220111.bak';
GO

SELECT *
FROM SalesDB.dbo.Sales
WHERE SalesID < 10000;
GO

-- 6) Restore tail-of-the-log
USE master;
GO

RESTORE log SalesDB
FROM DISK = N'D:\Documents\MSSQL\BACKUP\SalesDBBackup_tail.bak';
GO

-- Check consistency
DBCC CHECKDB (SalesDB)
WITH no_infomsgs;

-- Test
USE SalesDB;
GO

SELECT *
FROM dbo.Sales
WHERE SalesID > 2762100;
GO


