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
CREATE TABLE [test] ([c1] INT, [c2] INT, [c3] INT);

INSERT INTO [test] VALUES (1, 1, 1);
GO

-- Clear out the log (more on this in module 5)
CHECKPOINT;
GO

-- Implicit transaction to insert a new record
INSERT INTO [test] VALUES (2, 2, 2);
GO

-- Look at various fields, including locks being logged
SELECT * FROM fn_dblog (NULL, NULL);
GO

-- Explicit transaction to insert a new record
BEGIN TRAN;
GO
INSERT INTO [test] VALUES (3, 3, 3);
GO

SELECT * FROM fn_dblog (NULL, NULL);
GO

-- Now commit
COMMIT TRAN;
GO

SELECT * FROM fn_dblog (NULL, NULL);
GO

-- Now delete a row
DELETE FROM [test] WHERE [c1] = 1;
GO

SELECT * FROM fn_dblog (NULL, NULL);
GO



	