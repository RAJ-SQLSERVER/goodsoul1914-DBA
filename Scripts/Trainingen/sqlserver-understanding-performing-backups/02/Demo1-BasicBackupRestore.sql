-- Demo script for Basic Backup and Restore Commands demo

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
LOG ON (NAME = N'Company_log', FILENAME = N'D:\SQLLogs\Company_log.ldf');
GO

USE Company;
GO

-- Create a table
CREATE TABLE RandomData (c1 INT IDENTITY, c2 VARCHAR(100));
GO

INSERT INTO RandomData
VALUES ('Initial data: transaction 1');
GO

-- And perform a full backup
BACKUP DATABASE Company
TO  DISK = N'D:\SQLBackups\Company_Full.bak'
WITH INIT;
GO

-- Now add some more data and perform a log backup
INSERT INTO RandomData
VALUES ('Transaction 2');
INSERT INTO RandomData
VALUES ('Transaction 3');
GO

BACKUP LOG Company TO DISK = N'D:\Pluralsight\Company_Log1.bak' WITH INIT;
GO

-- And more data
INSERT INTO RandomData
VALUES ('Transaction 4');
INSERT INTO RandomData
VALUES ('Transaction 5');
GO

-- And perform another log backup
BACKUP LOG Company TO DISK = N'D:\Pluralsight\Company_Log2.bak' WITH INIT;
GO

-- Simulate corruption that destroys the database
USE master;
GO

DROP DATABASE Company;
GO

-- We have three backups - so restore them
-- Restore the full backup
RESTORE DATABASE Company
FROM DISK = N'D:\Pluralsight\Company_Full.bak'
WITH REPLACE;
GO

-- And the log backups
RESTORE LOG Company FROM DISK = N'D:\Pluralsight\Company_Log1.bak';

RESTORE LOG Company FROM DISK = N'D:\Pluralsight\Company_Log2.bak';
GO

-- WITH RECOVERY is the DEFAULT!
-- We need to start again...
RESTORE DATABASE Company
FROM DISK = N'D:\Pluralsight\Company_Full.bak'
WITH REPLACE,
     NORECOVERY;
GO

-- And the log backups
RESTORE LOG Company
FROM DISK = N'D:\Pluralsight\Company_Log1.bak'
WITH NORECOVERY;

RESTORE LOG Company
FROM DISK = N'D:\Pluralsight\Company_Log2.bak'
WITH NORECOVERY;
GO

-- And then finalize recovery
RESTORE DATABASE Company WITH RECOVERY;
GO

SELECT *
FROM Company.dbo.RandomData;
GO

-- What if we want to examine things
-- between restores?
RESTORE DATABASE Company
FROM DISK = N'D:\Pluralsight\Company_Full.bak'
WITH REPLACE,
     STANDBY = N'D:\Pluralsight\standbyfile.dat';
GO

-- We can see what's in there...
SELECT *
FROM Company.dbo.RandomData;
GO

-- Let's do the next log file.
RESTORE LOG Company
FROM DISK = N'D:\Pluralsight\Company_Log1.bak'
WITH STANDBY = N'D:\Pluralsight\standbyfile.dat';
GO

-- Now what's there?
SELECT *
FROM Company.dbo.RandomData;
GO

-- Now restore the rest and bring the database online
RESTORE LOG Company
FROM DISK = N'D:\Pluralsight\Company_Log2.bak'
WITH NORECOVERY;
GO

RESTORE DATABASE Company WITH RECOVERY;
GO

SELECT *
FROM Company.dbo.RandomData;
GO


