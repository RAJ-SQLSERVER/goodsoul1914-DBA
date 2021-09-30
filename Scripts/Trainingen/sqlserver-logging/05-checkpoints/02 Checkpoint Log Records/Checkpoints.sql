USE [master];
GO

IF DATABASEPROPERTYEX (N'DBMaint2012', N'Version') > 0
BEGIN
	ALTER DATABASE [DBMaint2012] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [DBMaint2012];
END
GO

CREATE DATABASE [DBMaint2012];
GO

USE [DBMaint2012];
GO
SET NOCOUNT ON;
GO

-- Make sure the database is in SIMPLE
-- recovery model with no auto-stats (to avoid
-- unwanted log records)
ALTER DATABASE [DBMaint2012] SET RECOVERY SIMPLE;
ALTER DATABASE [DBMaint2012] SET AUTO_CREATE_STATISTICS OFF;
GO

-- Create a simple table with a record
CREATE TABLE [test] ([c1] INT);
INSERT INTO [test] VALUES (1);
GO

-- Clear out the log
CHECKPOINT;
GO

-- Look in the log
SELECT * FROM fn_dblog (NULL, NULL);
GO

-- Now start a transaction
BEGIN TRAN;
GO

INSERT INTO [test] VALUES (2);
GO

-- And another checkpoint
CHECKPOINT;
GO

-- Look in the log
SELECT * FROM fn_dblog (NULL, NULL);
GO

-- Clear up
COMMIT TRAN;
GO
