USE [master];
GO

IF DATABASEPROPERTYEX (N'KeyUpdateTest', N'Version') > 0
BEGIN
	ALTER DATABASE [KeyUpdateTest] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [KeyUpdateTest];
END
GO

CREATE DATABASE [KeyUpdateTest];
GO

USE [KeyUpdateTest];
GO
ALTER DATABASE [KeyUpdateTest] SET RECOVERY SIMPLE;
GO

-- Create a table with a clustered index and a single
-- record
CREATE TABLE [test] ([c1] INT, [c2] VARCHAR (4000));

CREATE CLUSTERED INDEX [test_cl] ON [test] ([c1]);
GO

INSERT INTO [test] VALUES (1, REPLICATE ('Paul', 1000));
INSERT INTO [test] VALUES (2, REPLICATE ('Andy', 1000));
GO
CHECKPOINT;
GO 

-- Start a transaction
BEGIN TRAN
INSERT INTO [test] VALUES (4, REPLICATE ('Susy', 1000));
INSERT INTO [test] VALUES (5, REPLICATE ('John', 1000));
GO

-- Look at usage

-- Start nested xact
BEGIN TRAN
INSERT INTO [test] VALUES (6, REPLICATE ('Dave', 1000));
INSERT INTO [test] VALUES (7, REPLICATE ('Bret', 1000));
GO

-- Look at usage

-- Commit next transaction
COMMIT TRAN;
GO

-- Look at usage
-- Any change?

-- Do final commit
COMMIT TRAN;
GO

-- Look at usage

