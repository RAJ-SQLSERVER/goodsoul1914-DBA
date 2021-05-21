SET NOCOUNT ON;
USE tempdb;
GO

-- create table T1
-- drop table t1

CREATE TABLE dbo.T1
(
    c1_c1 UNIQUEIDENTIFIER NOT NULL
        DEFAULT (NEWID()),
    c1_testdata CHAR(1950) NOT NULL
        DEFAULT ('sqlservergeeks.com')
);
GO

CREATE UNIQUE CLUSTERED INDEX idx_c1_c1 ON dbo.T1 (c1_c1);
GO

-- Insert rows (run for a few seconds then stop)
SET NOCOUNT OFF;
USE tempdb;

TRUNCATE TABLE dbo.T1;

DECLARE @count AS INT;
SET @count = 0;

WHILE @count <= 1000000
BEGIN
    INSERT INTO dbo.T1
    DEFAULT VALUES;
    SET @count = @count + 1;
END;

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

DBCC DROPCLEANBUFFERS;

-- Check the data
SELECT c1_c1,
       c1_testdata
FROM dbo.T1;

-- Observe level of fragmentation
SELECT avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID('tempdb'), OBJECT_ID('dbo.T1'), 1, NULL, NULL);

DBCC DROPCLEANBUFFERS;

SELECT c1_c1,
       c1_testdata
FROM dbo.T1
ORDER BY c1_c1;

SELECT TOP (10)
       c1_c1,
       c1_testdata
FROM dbo.T1;

DBCC DROPCLEANBUFFERS;

UPDATE dbo.T1
SET c1_testdata = 'sqlmaestros.com'
WHERE c1_c1 > '7D85629D-45FE-4DF5-BBF3-0000634A6769';

ALTER INDEX idx_c1_c1 ON dbo.T1 REBUILD;

DBCC DROPCLEANBUFFERS;

UPDATE dbo.T1
SET c1_testdata = 'sqlmaestros.com'
WHERE c1_c1 > '7D85629D-45FE-4DF5-BBF3-0000634A6769';

