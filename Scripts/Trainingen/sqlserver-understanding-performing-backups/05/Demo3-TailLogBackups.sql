-- Tail-of-the-log Backups demo

RAISERROR(N'Oops! No, don''t just hit F5. Run these demos one at a time.', 20, 1) WITH LOG;
GO

USE master;
GO

IF DATABASEPROPERTYEX (N'Company', N'Version') > 0
BEGIN
    ALTER DATABASE Company SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Company;
END;
GO

IF DATABASEPROPERTYEX (N'Company_Copy', N'Version') > 0
BEGIN
    ALTER DATABASE Company_Copy SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Company_Copy;
END;
GO

-- Create the database
CREATE DATABASE Company
ON PRIMARY (NAME = N'Company', FILENAME = N'D:\SQLData\Company.mdf')
LOG ON (NAME = N'Company_log', FILENAME = N'D:\SQLLogs\Company_log.ldf');
GO

-- Create a table
USE Company;
GO

CREATE TABLE RandomData (c1 INT IDENTITY, c2 VARCHAR(100));
GO

INSERT INTO RandomData
VALUES ('Initial data: transaction 1');
GO

-- And take a full backup
BACKUP DATABASE Company
TO  DISK = N'D:\SQLBackups\Company_Full.bak'
WITH INIT;
GO

-- Now add some more data
INSERT INTO RandomData
VALUES ('Transaction 2');
GO
INSERT INTO RandomData
VALUES ('Transaction 3');
GO

-- And a log backup
BACKUP LOG Company TO DISK = N'D:\SQLBackups\Company_Log1.bak' WITH INIT;
GO

-- Now add some more data
INSERT INTO RandomData
VALUES ('Transaction 4');
GO
INSERT INTO RandomData
VALUES ('Transaction 5');
GO

-- Simulate a crash
ALTER DATABASE Company SET OFFLINE;
GO

-- Delete the data file
EXECUTE master.dbo.sp_configure N'show advanced options', 1;
RECONFIGURE;
EXECUTE master.dbo.sp_configure N'xp_cmdshell', 1;
RECONFIGURE;
EXEC master.dbo.xp_cmdshell N'del D:\SQLData\Company.mdf';
EXECUTE master.dbo.sp_configure N'xp_cmdshell', 0;
RECONFIGURE;
EXECUTE master.dbo.sp_configure N'show advanced options', 0;
RECONFIGURE;

-- Try to bring the database online
ALTER DATABASE Company SET ONLINE;
GO

/*
Msg 5120, Level 16, State 101, Line 75
Unable to open the physical file "D:\SQLData\Company.mdf". Operating system error 2: "2(The system cannot find the file specified.)".
Msg 5181, Level 16, State 5, Line 75
Could not restart database "Company". Reverting to the previous status.
Msg 5069, Level 16, State 1, Line 75
ALTER DATABASE statement failed.
*/

-- The backups we have don't have the most recent transactions
-- so if we restore the backups we'll lose those transactions.

-- Let's see...
RESTORE DATABASE Company_Copy
FROM DISK = N'D:\SQLBackups\Company_Full.bak'
WITH MOVE N'Company'
     TO N'D:\SQLData\Company_Copy.mdf',
     MOVE N'Company_log'
     TO N'D:\SQLLogs\Company_Copy_log.ldf',
     REPLACE,
     NORECOVERY;
GO

RESTORE LOG Company_Copy
FROM DISK = N'D:\SQLBackups\Company_Log1.bak'
WITH NORECOVERY;
GO

RESTORE DATABASE Company_Copy WITH RECOVERY;
GO

-- What data do we have?
SELECT *
FROM Company_Copy.dbo.RandomData;
GO
/*
c1	c2
1	Initial data: transaction 1
2	Transaction 2
3	Transaction 3
*/

-- Take a log backup?
BACKUP LOG Company
TO  DISK = N'D:\SQLBackups\Company_Log_Tail.bak'
WITH INIT;
GO

/*
Msg 945, Level 14, State 2, Line 115
Database 'Company' cannot be opened due to inaccessible files or insufficient memory or disk space.  
See the SQL Server errorlog for details.
Msg 3013, Level 16, State 1, Line 115
BACKUP LOG is terminating abnormally.
*/

-- Use the special syntax!
BACKUP LOG Company
TO  DISK = N'D:\SQLBackups\Company_Log_Tail.bak'
WITH INIT,
     NO_TRUNCATE;
GO

-- Now restore
RESTORE DATABASE Company_Copy
FROM DISK = N'D:\SQLBackups\Company_Full.bak'
WITH MOVE N'Company'
     TO N'D:\SQLData\Company_Copy.mdf',
     MOVE N'Company_log'
     TO N'D:\SQLLogs\Company_Copy_log.ldf',
     REPLACE,
     NORECOVERY;
GO

RESTORE LOG Company_Copy
FROM DISK = N'D:\SQLBackups\Company_Log1.bak'
WITH NORECOVERY;
GO

RESTORE LOG Company_Copy
FROM DISK = N'D:\SQLBackups\Company_Log_Tail.bak'
WITH NORECOVERY;
GO

RESTORE DATABASE Company_Copy WITH RECOVERY;
GO

-- Is everything there?
SELECT *
FROM Company_Copy.dbo.RandomData;
GO