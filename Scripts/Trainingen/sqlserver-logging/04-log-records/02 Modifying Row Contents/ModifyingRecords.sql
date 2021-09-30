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

-- Create a simple table with some records
CREATE TABLE [test] (
	[c1] INT, [c2] INT, [c3] INT,
	[c4] INT, [c5] INT, [c6] INT,
	[c7] INT, [c8] INT, [c9] INT,
	[c10] INT, [c11] INT, [c12] INT);

INSERT INTO [test] VALUES (1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
INSERT INTO [test] VALUES (2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2);
GO

-- Clear out the log (more on this in Module 5)
CHECKPOINT;
GO

-- Update a column
UPDATE [test] SET [c1] = 4 WHERE [c1] = 1;
GO

-- Look for before and after
SELECT * FROM fn_dblog (NULL, NULL);
GO

-- Now multiple columns
SELECT * FROM [test];
GO

UPDATE [test] SET [c1] = 8, [c3] = 9;
GO

-- LOP_MODIFY_ROW: before, after, index keys, logged locks
SELECT * FROM fn_dblog (NULL, NULL);
GO

-- LOP_MODIFY_ROW becomes LOP_MODIFY_COLUMNS if
-- multiple parts of record updated, or multiple
-- columns in fixed length > 16 bytes apart.
SELECT * FROM [test];

UPDATE [test] SET [c1] = 5, [c2] = 5,
	[c11] = 6, [c12] = 6
WHERE [c2] = 2;
GO

-- LOP_MOFIFY_COLUMNS: before/after offsets array, lengths array
-- index keys, logged locks, before/after pairs
SELECT * FROM fn_dblog (NULL, NULL);
GO
	
