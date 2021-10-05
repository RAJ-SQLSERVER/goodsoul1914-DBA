USE master;
GO

IF DATABASEPROPERTYEX (N'DBMaint2012', N'Version') > 0
BEGIN
    ALTER DATABASE DBMaint2012 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DBMaint2012;
END;
GO

CREATE DATABASE DBMaint2012
ON PRIMARY (
       NAME = N'DBMaint2012_data',
       FILENAME = N'D:\SQLData\DBMaint2012_data.mdf'
   )
LOG ON (
    NAME = N'DBMaint2012_log',
    FILENAME = N'D:\SQLLogs\DBMaint2012_log.ldf',
    SIZE = 5MB,
    FILEGROWTH = 1MB
);
GO

USE DBMaint2012;
GO
SET NOCOUNT ON;
GO

-- Make sure the database is in SIMPLE
-- recovery model
ALTER DATABASE DBMaint2012 SET RECOVERY SIMPLE;
GO

-- What does the log look like?
DBCC LOGINFO;
GO

-- Create a table that will grow very
-- quickly and generate lots of transaction
-- log
CREATE TABLE BigRows (c1 INT IDENTITY, c2 CHAR(8000) DEFAULT 'a');
GO

-- Insert some rows to fill the first
-- two VLFs and start on the third
INSERT INTO BigRows
DEFAULT VALUES;
GO 300

-- What does the log look like now?
DBCC LOGINFO;
GO

-- Now start an explicit transaction which
-- will hold VLF 3 and onwards active
BEGIN TRAN;
INSERT INTO BigRows
DEFAULT VALUES;
GO

-- Now checkpoint to clear the first two
-- VLFs and look at the log again
CHECKPOINT;
GO

DBCC LOGINFO;
GO

-- Now add some more rows that will fill
-- up VLFs 3 and 4 and then wrap around
INSERT INTO BigRows
DEFAULT VALUES;
GO 300 

DBCC LOGINFO;
GO

-- Now add some more rows - the log is
-- forced to grow. What do the VLF
-- sequence numbers look like?
INSERT INTO BigRows
DEFAULT VALUES;
GO 300 

DBCC LOGINFO;
GO

-- Will checkpoint clear it now?
CHECKPOINT;
GO

DBCC LOGINFO;
GO

-- Look at the amount of log used
DBCC SQLPERF(LOGSPACE);
GO

-- How about now?
COMMIT TRAN;
GO

DBCC LOGINFO;
GO

-- Look at the amount of log used
-- What happened?
DBCC SQLPERF(LOGSPACE);
GO

-- How about now?
CHECKPOINT;
GO

DBCC LOGINFO;
GO