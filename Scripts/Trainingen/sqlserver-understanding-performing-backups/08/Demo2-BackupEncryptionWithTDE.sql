-- Demo script for Backup Encryption demo

USE [master];
GO

IF DATABASEPROPERTYEX (N'Company', N'Version') > 0
BEGIN
	ALTER DATABASE [Company] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [Company];
END
GO

-- Create the database
CREATE DATABASE [Company] ON PRIMARY (
    NAME = N'Company',
    FILENAME = N'D:\Pluralsight\Company.mdf')
LOG ON (
    NAME = N'Company_log',
    FILENAME = N'D:\Pluralsight\Company_log.ldf');
GO

-- Create a table that will grow large quickly
USE [Company]
GO

CREATE TABLE [RandomData] (
	[c1] INT IDENTITY,
	[c2] CHAR (8000) DEFAULT 'a');
GO
SET NOCOUNT ON;
GO

INSERT INTO [RandomData] DEFAULT VALUES;
GO 1000

-- Encrypt the database
USE [master];
GO

CREATE MASTER KEY ENCRYPTION BY
PASSWORD = 'Sligachan*01*';
GO

CREATE CERTIFICATE [MyCompanyCert]
WITH SUBJECT = 'My Certificate';
GO

USE [Company];
GO

CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_128
ENCRYPTION BY SERVER CERTIFICATE [MyCompanyCert];
GO

USE [master];
GO

BACKUP CERTIFICATE [MyCompanyCert]
TO FILE = N'C:\Pluralsight\MyCompanyCert'
WITH PRIVATE KEY (FILE = N'C:\Pluralsight\MyCompanyCertKey',
	ENCRYPTION BY PASSWORD = N'RandomPassword');
GO

ALTER DATABASE [Company] SET ENCRYPTION ON;
GO

-- See if encryption has completed yet
SELECT * FROM sys.dm_database_encryption_keys
WHERE [database_id] = DB_ID ('Company');
GO
-- Encryption state of 3 means it's encrypted, 2 means
-- encryption is still in progress. Wait till it's 3.

-- Create a backup of the encrypted database
BACKUP DATABASE [Company]
TO DISK = N'D:\Pluralsight\CompanyEncrypted.bak'
WITH
	INIT,
	NAME = N'Company Encrypted Full';
GO

-- Now pretend the instance has been destroyed
USE [master];
GO

DROP DATABASE [Company];
GO

DROP CERTIFICATE [MyCompanyCert];
GO

DROP MASTER KEY;
GO

-- And try to restore
USE [master];
GO

-- Try to restore...
RESTORE DATABASE [Company]
FROM DISK = 'D:\Pluralsight\CompanyEncrypted.bak'
WITH REPLACE;
GO

-- Ok - restore the certificate
CREATE CERTIFICATE [MyCompanyCert]
FROM FILE = N'C:\Pluralsight\MyCompanyCert'
WITH PRIVATE KEY (FILE = N'C:\Pluralsight\MyCompanyCertKey',
	DECRYPTION BY PASSWORD = N'RandomPassword');
GO

-- Oops - create a master key and try again
CREATE MASTER KEY ENCRYPTION BY
PASSWORD = 'Sligachan*02*';
GO

CREATE CERTIFICATE [MyCompanyCert]
FROM FILE = N'C:\Pluralsight\MyCompanyCert'
WITH PRIVATE KEY (FILE = N'C:\Pluralsight\MyCompanyCertKey',
	DECRYPTION BY PASSWORD = N'RandomPassword');
GO

-- And try the restore again
RESTORE DATABASE [Company]
FROM DISK = 'D:\Pluralsight\CompanyEncrypted.bak'
WITH REPLACE;
GO

-- With a TDE-enabled database, a restore is impossible
-- without the correct certificate!

-- Cleanup code
USE [master];
GO

DROP DATABASE [Company];
GO

DROP CERTIFICATE [MyCompanyCert];
GO

DROP MASTER KEY;
GO