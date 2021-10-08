USE master;
GO

IF DATABASEPROPERTYEX (N'DBMaint2012', N'Version') > 0
BEGIN
    ALTER DATABASE DBMaint2012 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DBMaint2012;
END;
GO

-- Create a database to use
CREATE DATABASE DBMaint2012;
GO

USE DBMaint2012;
GO

-- And a table
CREATE TABLE TestTable (c1 INT IDENTITY, c2 CHAR(1000) DEFAULT 'a');

CREATE CLUSTERED INDEX TT_CL ON TestTable (c1);
GO

-- Insert 7000 records
SET NOCOUNT ON;
GO

INSERT INTO TestTable
DEFAULT VALUES;
GO 7000

-- Clear the log
CHECKPOINT;
GO

-- Go into the BULK_LOGGED recovery model
ALTER DATABASE DBMaint2012 SET RECOVERY BULK_LOGGED;
GO

BACKUP DATABASE DBMaint2012
TO  DISK = 'D:\SQLBackups\DBMaint2012.bck'
WITH INIT;
GO

-- Rebuild the clustered index
ALTER INDEX TT_CL ON TestTable REBUILD;
GO

-- Examine the log
SELECT *
FROM fn_dblog (NULL, NULL);
GO

-- Now switch to FULL and clear the log
ALTER DATABASE DBMaint2012 SET RECOVERY FULL;
GO

BACKUP LOG DBMaint2012
TO  DISK = 'D:\Pluralsight\DBMaint2012_log.bck'
WITH INIT;
GO

-- Rebuild the clustered index again
ALTER INDEX TT_CL ON TestTable REBUILD;
GO

-- Examine the log
SELECT *
FROM fn_dblog (NULL, NULL);
GO