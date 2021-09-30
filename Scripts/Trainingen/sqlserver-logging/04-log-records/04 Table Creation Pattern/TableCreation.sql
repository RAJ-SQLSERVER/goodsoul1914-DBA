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

-- Clear out the log (more on this in Module 5)
CHECKPOINT;
GO

-- Create a simple table
CREATE TABLE [test] ([c1] INT, [c2] INT, [c3] INT);
GO

SELECT * FROM fn_dblog (NULL, NULL);
GO

-- Insert a record to cause allocations
INSERT INTO [test] VALUES (1, 1, 1);
GO

SELECT * FROM fn_dblog (NULL, NULL);
GO



	