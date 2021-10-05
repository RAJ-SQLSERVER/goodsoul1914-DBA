USE [master];
GO

IF DATABASEPROPERTYEX (N'DBMaint2008', N'Version') > 0
BEGIN
	ALTER DATABASE [DBMaint2008] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [DBMaint2008];
END
GO

-- Create a database
CREATE DATABASE [DBMaint2008];
GO

USE [DBMaint2008];
GO

CREATE TABLE [TestTable] (
	[C1] INT IDENTITY,
	[C2] CHAR (100));
GO

-- Take a full backup
BACKUP DATABASE [DBMaint2008] TO
	DISK = N'D:\Pluralsight\DBMaint2008_Full_HAD.bck'
	WITH INIT;
GO

-- Insert some rows
INSERT INTO [TestTable] VALUES (
	'Transaction 1');
INSERT INTO [TestTable] VALUES (
	'Transaction 2');

-- Take a log backup
BACKUP LOG [DBMaint2008] TO
	DISK = N'D:\Pluralsight\DBMaint2008_Log1_HAD.bck'
	WITH INIT;
GO

-- Insert some more rows
INSERT INTO [TestTable] VALUES (
	'Transaction 3');
INSERT INTO [TestTable] VALUES (
	'Transaction 4');
GO
	
-- Simulate disaster
-- Take the database offline
ALTER DATABASE [DBMaint2008] SET OFFLINE;
GO

-- Delete the data file

