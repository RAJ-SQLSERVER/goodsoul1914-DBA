RAISERROR (N'Oops! No, don''t just hit F5. Run these demos one at a time.', 20, 1) WITH LOG;
GO

USE master;
GO

IF DATABASEPROPERTYEX (N'DBMaint2012', N'Version') > 0
BEGIN
    ALTER DATABASE DBMaint2012 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DBMaint2012;
END;
GO

CREATE DATABASE DBMaint2012;
GO

USE DBMaint2012;
GO

CREATE TABLE TestTable (c1 INT IDENTITY, c2 CHAR(1000) DEFAULT 'a');

CREATE CLUSTERED INDEX TT_CL ON dbo.TestTable (c1);
GO

-- Insert 70 records in a transaction
SET NOCOUNT ON;
GO

BEGIN TRANSACTION;
GO

INSERT INTO dbo.TestTable (c2)
VALUES (DEFAULT);
GO 70

-- Force the data pages and log records to disk
CHECKPOINT;
GO

-- In another window, shutdown SQL Server
-- SHUTDOWN 

-- Then restart SQL Server in a terminal window:
-- C:> net start mssql$sql2012

-- Make sure crash recovery has completed
EXEC sys.xp_readerrorlog;
GO

-- Look at the log generated
USE DBMaint2012;
GO

SELECT *
FROM fn_dblog (NULL, NULL);
GO

-- If recovery finished, it will have checkpointed, 
-- so allow the log reader to go further back in the log
DBCC TRACEON (2537);
GO

SELECT *
FROM fn_dblog (NULL, NULL);
GO