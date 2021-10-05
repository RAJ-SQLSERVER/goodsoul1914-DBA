USE [master];
GO

IF DATABASEPROPERTYEX (N'DBMaint2012', N'Version') > 0
BEGIN
	ALTER DATABASE [DBMaint2012] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [DBMaint2012];
END
GO

-- Create the database
CREATE DATABASE [DBMaint2012];
GO

USE [DBMaint2012];
GO

ALTER DATABASE [DBMaint2012]
	SET RECOVERY FULL;
GO

-- Create a table
CREATE TABLE [TestTable] (
	[c1] INT IDENTITY,
	[c2] VARCHAR (100));
GO
CREATE CLUSTERED INDEX [TestTable_CL]
	ON [TestTable] ([c1]);
GO

INSERT INTO [TestTable]
	VALUES ('Initial data: transaction 1');
GO

-- And take a full backup
BACKUP DATABASE [DBMaint2012] TO
	DISK = 'D:\Pluralsight\DBMaint2012.bck'
WITH INIT;
GO

-- Now add some more data
SET NOCOUNT ON;
GO
INSERT INTO [TestTable]
	VALUES ('More data...');
GO 1000

BACKUP LOG [DBMaint2012] TO
	DISK = 'D:\Pluralsight\DBMaint2012_Log1.bck'
WITH INIT;
GO

-- Minimally-logged operation
ALTER DATABASE [DBMaint2012]
	SET RECOVERY BULK_LOGGED;
GO

ALTER INDEX [TestTable_CL] ON [TestTable] REBUILD;
GO

ALTER DATABASE [DBMaint2012]
	SET RECOVERY FULL;
GO

-- And some more user transactions
INSERT INTO [TestTable]
	VALUES ('Transaction 2');
GO
INSERT INTO [TestTable]
	VALUES ('Transaction 3');
GO

-- Simulate a crash
SHUTDOWN WITH NOWAIT;
GO

-- Delete the data file and restart SQL

USE [DBMaint2012];
GO

-- The backup doesn't have the most recent
-- transactions - if we restore it we'll
-- lose them.

-- Take a log backup!
BACKUP LOG [DBMaint2012] TO
	DISK = 'D:\Pluralsight\DBMaint2012_tail.bck'
WITH INIT, NO_TRUNCATE;
GO

-- Hmm - marked as corrupt!

-- Now restore
RESTORE DATABASE [DBMaint2012] FROM
	DISK = 'D:\Pluralsight\DBMaint2012.bck'
WITH REPLACE, NORECOVERY;
GO

RESTORE LOG [DBMaint2012] FROM
	DISK = 'D:\Pluralsight\DBMaint2012_Log1.bck'
WITH REPLACE, NORECOVERY;
GO

RESTORE LOG [DBMaint2012] FROM
	DISK = 'D:\Pluralsight\DBMaint2012_tail.bck'
WITH REPLACE;
GO

-- Force it with CONTINUE_AFTER_ERROR
RESTORE LOG [DBMaint2012] FROM
	DISK = 'D:\Pluralsight\DBMaint2012_tail.bck'
WITH REPLACE, CONTINUE_AFTER_ERROR;
GO

-- Hmm - doesn't look good.

-- Is everything there?
SELECT * FROM [DBMaint2012].[dbo].[TestTable];
GO

-- Woah!
DBCC CHECKDB (N'DBMaint2012') WITH NO_INFOMSGS;
GO

-- The tail-of-the-log backup is essentially corrupt because
-- it couldn't back up the data file pages

-- Re-restore without the tail-of-the-log
RESTORE DATABASE [DBMaint2012] FROM
	DISK = 'D:\Pluralsight\DBMaint2012.bck'
WITH REPLACE, NORECOVERY;
GO

RESTORE LOG [DBMaint2012] FROM
	DISK = 'D:\Pluralsight\DBMaint2012_Log1.bck'
WITH REPLACE;
GO

-- Is everything there?
SELECT * FROM [DBMaint2012].[dbo].[TestTable];
GO

-- Nope - lost transaction 2 and 3
