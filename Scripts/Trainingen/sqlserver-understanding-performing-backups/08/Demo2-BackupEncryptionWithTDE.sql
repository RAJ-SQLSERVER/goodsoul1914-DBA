RAISERROR(N'Oops! No, don''t just hit F5. Run these demos one at a time.', 20, 1) WITH LOG;
GO

USE master;
GO

IF DATABASEPROPERTYEX (N'Company', N'Version') > 0
BEGIN
    ALTER DATABASE Company SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Company;
END;
GO

-- Create the database
CREATE DATABASE Company
ON PRIMARY (NAME = N'Company', FILENAME = N'D:\SQLData\Company.mdf')
LOG ON (NAME = N'Company_log', FILENAME = N'D:\SQLLogs\Company_log.ldf');
GO

-- Create a table that will grow large quickly
USE Company;
GO

CREATE TABLE RandomData (c1 INT IDENTITY, c2 CHAR(8000) DEFAULT 'a');
GO
SET NOCOUNT ON;
GO

INSERT INTO RandomData
DEFAULT VALUES;
GO 1000

-- Encrypt the database
USE master;
GO

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Sligachan*01*';
GO

CREATE CERTIFICATE MyCompanyCert
WITH SUBJECT = 'My Certificate';
GO

USE Company;
GO

CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_128
ENCRYPTION BY SERVER CERTIFICATE MyCompanyCert;
GO

USE master;
GO

BACKUP CERTIFICATE MyCompanyCert TO FILE = N'D:\SQLBackups\MyCompanyCert'
WITH PRIVATE KEY (
    FILE = N'D:\SQLBackups\MyCompanyCertKey',
    ENCRYPTION BY PASSWORD = N'RandomPassword'
);
GO

ALTER DATABASE Company SET ENCRYPTION ON;
GO

-- See if encryption has completed yet
SELECT *
FROM sys.dm_database_encryption_keys
WHERE database_id = DB_ID ('Company');
GO
-- Encryption state of 3 means it's encrypted, 2 means
-- encryption is still in progress. Wait till it's 3.

-- Create a backup of the encrypted database
BACKUP DATABASE Company
TO  DISK = N'D:\SQLBackups\CompanyEncrypted.bak'
WITH INIT,
     NAME = N'Company Encrypted Full';
GO

-- Now pretend the instance has been destroyed
USE master;
GO

DROP DATABASE Company;
GO

DROP CERTIFICATE MyCompanyCert;
GO

DROP MASTER KEY;
GO

-- And try to restore
USE master;
GO

-- Try to restore...
RESTORE DATABASE Company
FROM DISK = 'D:\SQLBackups\CompanyEncrypted.bak'
WITH REPLACE;
GO
/*
Msg 33111, Level 16, State 3, Line 98
Cannot find server certificate with thumbprint '0xEB1E78EB63753DB5E5FFA38C42B208A44DDE6F0F'.
Msg 3013, Level 16, State 1, Line 98
RESTORE DATABASE is terminating abnormally.
*/

-- Ok - restore the certificate
CREATE CERTIFICATE MyCompanyCert
FROM FILE = N'D:\SQLBackups\MyCompanyCert'
WITH PRIVATE KEY (
    FILE = N'D:\SQLBackups\MyCompanyCertKey',
    DECRYPTION BY PASSWORD = N'RandomPassword'
);
GO
/*
Msg 15581, Level 16, State 1, Line 110
Please create a master key in the database or open the master key in the session before performing this operation.
*/

-- Oops - create a master key and try again
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Sligachan*02*';
GO

CREATE CERTIFICATE MyCompanyCert
FROM FILE = N'D:\SQLBackups\MyCompanyCert'
WITH PRIVATE KEY (
    FILE = N'D:\SQLBackups\MyCompanyCertKey',
    DECRYPTION BY PASSWORD = N'RandomPassword'
);
GO

-- And try the restore again
RESTORE DATABASE Company
FROM DISK = 'D:\SQLBackups\CompanyEncrypted.bak'
WITH REPLACE;
GO

-- With a TDE-enabled database, a restore is impossible without the correct certificate!

-- Cleanup code
USE master;
GO

DROP DATABASE Company;
GO

DROP CERTIFICATE MyCompanyCert;
GO

DROP MASTER KEY;
GO