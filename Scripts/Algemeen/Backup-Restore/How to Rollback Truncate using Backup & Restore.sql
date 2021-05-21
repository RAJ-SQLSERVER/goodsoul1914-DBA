-- Step 1: execute these statements to create a database
USE master
GO
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'TruncatevsDelete')
	ALTER DATABASE TruncatevsDelete SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

DROP DATABASE TruncatevsDelete;
GO

CREATE DATABASE TruncatevsDelete;
GO

-- Step 2: execute the following statement(s) to create tables
USE TruncatevsDelete;
GO

-- Query 1:
CREATE TABLE DeleteTest
(
	id INT IDENTITY(1,1),
	Test CHAR(20) DEFAULT 'Operation DELETE'
);
GO

-- Query 2:
CREATE TABLE TruncateTest
(
	id INT IDENTITY(1, 1),
	Test CHAR(20) DEFAULT 'Operation TRUNCATE'
);
GO

-- Step 3: execute the following statements to take a full backup
USE master
GO
BACKUP DATABASE TruncatevsDelete
TO  DISK = 'D:\SQLBackup\TruncatevsDelete.bak';
GO

-- Step 4: insert records into the tables
SET NOCOUNT ON
USE TruncatevsDelete
GO
INSERT INTO dbo.DeleteTest DEFAULT VALUES;
GO 5
INSERT INTO dbo.TruncateTest DEFAULT VALUES;
GO 5

-- Step 5: view the records in the table
SELECT id,
       Test
FROM dbo.DeleteTest;
SELECT id,
       Test
FROM dbo.TruncateTest;

-- Step 6: perform delete and truncate operations
USE TruncatevsDelete
GO
-- Query 1: Delete operation
DELETE FROM dbo.DeleteTest
WHERE id <= 3;
GO
-- Query 2: Truncate operation
TRUNCATE TABLE dbo.TruncateTest;
GO

-- Step 7: View the records in the tables
SELECT id,
       Test
FROM dbo.DeleteTest;
SELECT id,
       Test
FROM dbo.TruncateTest;

-- Step 8: Read data from the transaction log
SELECT [Current LSN],
       Operation,
       [Transaction ID],
       [Begin Time],
       [Transaction Name],
       [Transaction SID],
       AllocUnitName
FROM sys.fn_dblog(NULL, NULL)
WHERE [Transaction Name] IN ( 'DELETE', 'TRUNCATE TABLE' );
GO

/*
00000045:00000125:0001

69	0000000293	00001

00000045:00000127:0001
*/

-- Step 9: take a log backup of the database
USE master
GO
BACKUP LOG TruncatevsDelete TO DISK = 'D:\SQLBackup\TruncatevsDelete.trn';
GO

-- Step 10: restore the full backup with norecovery
RESTORE DATABASE TruncatevsDelete_DeleteCopy
FROM DISK = 'D:\SQLBackup\TruncatevsDelete.bak'
WITH MOVE 'TruncatevsDelete'
     TO 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\TruncatevsDelete_DeleteCopy.mdf',
     MOVE 'TruncatevsDelete_Log'
     TO 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\TruncatevsDelete_DeleteCopy_Log.ldf',
     REPLACE,
     NORECOVERY;
GO

-- Step 11: restore log backup with STOPBEFOREMARK option to recover exact LSN
RESTORE LOG TruncatevsDelete_DeleteCopy
FROM DISK = 'D:\SQLBackup\TruncatevsDelete.trn'
WITH STOPBEFOREMARK = 'lsn:69000000029300001'
GO

-- Step 12: verify whether records are back into table
USE TruncatevsDelete_DeleteCopy
GO
SELECT id,
       Test
FROM dbo.DeleteTest;
GO
SELECT id,
       Test
FROM dbo.TruncateTest;
GO

-- Step 13: drop the database
USE master
GO
DROP DATABASE TruncatevsDelete_DeleteCopy
GO

-- Step 14: restore full backup with norecovery
RESTORE DATABASE TruncatevsDelete_TruncateCopy
FROM DISK = 'D:\SQLBackup\TruncatevsDelete.bak'
WITH MOVE 'TruncatevsDelete'
     TO 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\TruncatevsDelete_TruncateCopy.mdf',
     MOVE 'TruncatevsDelete_Log'
     TO 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\TruncatevsDelete_TruncateCopy_Log.ldf',
     REPLACE,
     NORECOVERY;
GO

-- Step 15: restore log backup with STOPBEFOREMARK option to recover exact LSN
RESTORE LOG TruncatevsDelete_TruncateCopy
FROM DISK = 'D:\SQLBackup\TruncatevsDelete.trn'
WITH STOPBEFOREMARK = 'lsn:69000000029500001'
GO

-- Step 16: verify whether records are in table or not
USE TruncatevsDelete_TruncateCopy
GO
SELECT id,
       Test
FROM dbo.TruncateTest;
GO

-----------------------
-- Begin cleanup
-----------------------
USE master
GO
DROP DATABASE TruncatevsDelete_TruncateCopy
GO
DROP DATABASE TruncatevsDelete
GO
-----------------------
-- End cleanup
-----------------------
