USE master;
GO

-- 1) Create a new database
CREATE DATABASE TestDB;
GO

USE TestDB;
GO

SET NOCOUNT ON;
GO

-- 2) Create a new table
CREATE TABLE TestTable (
	c1 INT identity,
	c2 CHAR(8000) DEFAULT 'I am a SQl Server DBA'
	);
GO

-- 3) Change the database to FULL recovery model
ALTER DATABASE TestDB

SET recovery FULL;
GO

sp_helpdb TestDB;
GO

-- 4) Run large transactions
-- 5) Run PerfMon and monitor the transaction log behavior
-- The database is now in pseudo-simple recovery model
-- MSSQLSERVER: Databases: Log File Size (KB)
-- MSSQLSERVER: Databases: Log File Used Size (KB)
-- MSSQLSERVER: Databases: Percent Log Used
-- 6) Take a FULL database backup
BACKUP DATABASE TestDB TO DISK = N'C:\demos\TestDB.bak'
WITH init,
	stats;
GO

-- 7) Monitor PerfMon counters after first full database backup
-- 8) Check what is preventing log truncation
SELECT log_reuse_wait_desc
FROM master.sys.databases
WHERE name = N'TestDB';
GO

-- 9) Perform a log backup
BACKUP log TestDB TO DISK = N'C:\demos\TestDB_log.trn'
WITH stats;
GO

-- 10) Monitor PerfMon counters after a log backup
