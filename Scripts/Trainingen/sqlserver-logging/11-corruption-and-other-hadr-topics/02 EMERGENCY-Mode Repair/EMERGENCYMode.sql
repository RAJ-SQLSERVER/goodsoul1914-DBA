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

-- Create an employee table and some data
USE DBMaint2012;
GO
CREATE TABLE Employees (FirstName VARCHAR(20), LastName VARCHAR(20), YearlyBonus INT);
GO

INSERT INTO Employees
VALUES ('John', 'Doe', 5000);
INSERT INTO Employees
VALUES ('Jane', 'Doe', 5000);
GO

-- Simulate an in-flight transaction
BEGIN TRAN;
GO

UPDATE Employees
SET YearlyBonus = 10000
WHERE FirstName = 'Jane'
      AND LastName = 'Doe';
GO

-- Force the updated page to disk
CHECKPOINT;
GO

-- Simulate hardware failure with corruption
-- SHUTDOWN WITH NOWAIT in another window and
-- use a hex editor to corrupt the log file header.

-- Restart SQL Server

-- After shutdown/corruption/startup

USE DBMaint2012;
GO

-- Uh-oh - what's the status?
SELECT DATABASEPROPERTYEX (N'DBMaint2012', N'STATUS');
GO

-- No backups...
-- Let's try EMERGENCY mode repair
ALTER DATABASE DBMaint2012 SET EMERGENCY;
GO

DBCC CHECKDB(N'DBMaint2012', REPAIR_ALLOW_DATA_LOSS) WITH NO_INFOMSGS, ALL_ERRORMSGS;
GO

-- Set single user mode as well
ALTER DATABASE DBMaint2012 SET SINGLE_USER;
GO
DBCC CHECKDB(N'DBMaint2012', REPAIR_ALLOW_DATA_LOSS) WITH NO_INFOMSGS, ALL_ERRORMSGS;
GO

-- Now try again...
USE DBMaint2012;
GO

-- Check the state
SELECT DATABASEPROPERTYEX (N'DBMaint2012', N'STATUS');
GO

-- What about the data?
SELECT *
FROM Employees;
GO
