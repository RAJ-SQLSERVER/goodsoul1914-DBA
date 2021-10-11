USE master;
GO

IF DATABASEPROPERTYEX (N'DBMaint2012', N'Version') > 0
BEGIN
    ALTER DATABASE DBMaint2012 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DBMaint2012;
END;
GO

-- Create the database to use
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

-- Add a second log file
ALTER DATABASE DBMaint2012
ADD LOG FILE (
    NAME = N'DBMaint2012_log2',
    FILENAME = N'D:\SQLLogs\DBMaint2012_log2.ldf',
    SIZE = 5MB,
    FILEGROWTH = 1MB
);
GO

USE DBMaint2012;
GO

-- Shrink both log files as far as they will go
DBCC SHRINKFILE(2, 1);
GO

DBCC SHRINKFILE(3, 1);
GO

-- Now try to drop the second log file
ALTER DATABASE DBMaint2012 REMOVE FILE DBMaint2012_log2;
GO

-- What?
DBCC LOGINFO(N'DBMaint2012');
GO

-- Solution: grow the first file
ALTER DATABASE DBMaint2012
MODIFY FILE (NAME = N'DBMaint2012_log', SIZE = 5MB);
GO

-- Now it can be removed
ALTER DATABASE DBMaint2012 REMOVE FILE DBMaint2012_log2;
GO