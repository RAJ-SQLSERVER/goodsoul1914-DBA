RAISERROR(N'Oops! No, don''t just hit F5. Run these demos one at a time.', 20, 1) WITH LOG;
GO

USE master;
GO

IF DATABASEPROPERTYEX (N'DBMaint2012', N'Version') > 0
BEGIN
    ALTER DATABASE DBMaint2012 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DBMaint2012;
END;
GO

-- Enable trace flags to watch zero-initialization
DBCC TRACEON(3605, 3004, -1);
GO

-- Flush the error log
EXEC sp_cycle_errorlog;
GO

-- Create a database
CREATE DATABASE DBMaint2012
ON PRIMARY (
       NAME = N'DBMaint2012_data',
       FILENAME = N'D:\SQLData\DBMaint2012_data.mdf'
   )
LOG ON (
    NAME = N'DBMaint2012_log',
    FILENAME = N'D:\SQLLogs\DBMaint2012_log.ldf',
    SIZE = 10MB,
    FILEGROWTH = 10MB
);
GO

-- Examine the errorlog
EXEC xp_readerrorlog;
GO

-- Drop the database again
DROP DATABASE DBMaint2012;
GO

-- Turn off the traceflags
DBCC TRACEOFF(3605, 3004, -1);
GO

-- In the other window, flush wait stats

-- Recreate the database
CREATE DATABASE DBMaint2012
ON PRIMARY (
       NAME = N'DBMaint2012_data',
       FILENAME = N'D:\SQLData\DBMaint2012_data.mdf'
   )
LOG ON (
    NAME = N'DBMaint2012_log',
    FILENAME = N'D:\SQLLogs\DBMaint2012_log.ldf',
    SIZE = 10MB,
    FILEGROWTH = 10MB
);
GO

-- Examine waits in the other window