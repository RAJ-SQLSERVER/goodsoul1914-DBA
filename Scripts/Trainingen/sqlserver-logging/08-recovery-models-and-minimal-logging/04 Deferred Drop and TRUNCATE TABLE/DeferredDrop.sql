USE [master];
GO

IF DATABASEPROPERTYEX (N'DBMaint2012', N'Version') > 0
BEGIN
	ALTER DATABASE [DBMaint2012] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [DBMaint2012];
END
GO

-- Create a database to use
CREATE DATABASE [DBMaint2012];
GO

USE [DBMaint2012];
GO

-- Create a small table
CREATE TABLE [TestTable] (
	[c1]	INT IDENTITY,
	[c2]	CHAR (1000) DEFAULT 'a');

CREATE CLUSTERED INDEX [TT_CL]
ON [TestTable] ([c1]);
GO

-- Insert 700 records
SET NOCOUNT ON;
GO
INSERT INTO [TestTable] DEFAULT VALUES;
GO 700

-- Clear the log
CHECKPOINT;
GO

-- Truncate the table and examine the log
TRUNCATE TABLE [TestTable];

SELECT * FROM fn_dblog (NULL, NULL);
GO

-- Now a larger table
INSERT INTO [TestTable] DEFAULT VALUES;
GO 70000

-- This may take a few minutes...

-- Clear the log
CHECKPOINT;
GO

-- Truncate the table and examine the log
TRUNCATE TABLE [TestTable];

SELECT * FROM fn_dblog (NULL, NULL);
GO

-- Wait a few seconds and then look at the log again
SELECT * FROM fn_dblog (NULL, NULL);
GO