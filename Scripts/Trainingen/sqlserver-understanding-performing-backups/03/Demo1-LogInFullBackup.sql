-- How Much Log in a Full Backup

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

-- Delete everything from the backup history table
-- Do not do this on a production system!
USE msdb;
GO

DECLARE @today DATETIME = GETDATE ();
EXEC sp_delete_backuphistory @oldest_date = @today;
GO

USE Company;
GO

-- Create a table
CREATE TABLE RandomData (c1 INT IDENTITY, c2 VARCHAR(100));
GO

-- And perform a full backup
BACKUP DATABASE Company
TO  DISK = N'D:\SQLBackups\Company_Full1.bak'
WITH INIT,
     NAME = N'Company Full';
GO

-- Now examine some data about the backup
RESTORE HEADERONLY FROM DISK = N'D:\SQLBackups\Company_Full1.bak';
GO

/*
BackupName	BackupDescription	BackupType	ExpirationDate	Compressed	Position	DeviceType	UserName	ServerName	DatabaseName	DatabaseVersion	DatabaseCreationDate	BackupSize	FirstLSN	LastLSN	CheckpointLSN	DatabaseBackupLSN	BackupStartDate	BackupFinishDate	SortOrder	CodePage	UnicodeLocaleId	UnicodeComparisonStyle	CompatibilityLevel	SoftwareVendorId	SoftwareVersionMajor	SoftwareVersionMinor	SoftwareVersionBuild	MachineName	Flags	BindingID	RecoveryForkID	Collation	FamilyGUID	HasBulkLoggedData	IsSnapshot	IsReadOnly	IsSingleUser	HasBackupChecksums	IsDamaged	BeginsLogChain	HasIncompleteMetaData	IsForceOffline	IsCopyOnly	FirstRecoveryForkID	ForkPointLSN	RecoveryModel	DifferentialBaseLSN	DifferentialBaseGUID	BackupTypeDescription	BackupSetGUID	CompressedBackupSize	Containment	KeyAlgorithm	EncryptorThumbprint	EncryptorType
Company Full	NULL	1	NULL	1	1	2	DT-RSD-01\mboom	DT-RSD-01	Company	904	2021-09-30 22:00:17.000	3030016	39000000021200001	39000000021500001	39000000021200001	0	2021-09-30 22:01:09.000	2021-09-30 22:01:10.000	52	0	1033	196609	150	4608	15	0	4102	DT-RSD-01	512	0390F1CE-418D-419C-ADE9-058A920E33F3	1C2F9B5E-3076-471C-8AF4-EDF502FF0495	SQL_Latin1_General_CP1_CI_AS	1C2F9B5E-3076-471C-8AF4-EDF502FF0495	0	0	0	0	0	0	0	0	0	0	1C2F9B5E-3076-471C-8AF4-EDF502FF0495	NULL	FULL	NULL	NULL	Database	E69A6CC2-DB21-4CE1-9E9A-9B85AD12FD91	485542	0	NULL	NULL	NULL
*/

-- And from the backup history table in msdb
SELECT name,
       checkpoint_lsn,
       first_lsn,
       last_lsn
FROM msdb.dbo.backupset
WHERE database_name = 'Company';
GO

-- Now go to the second window and start a transaction

-- Back in this window...

-- Now add some more data
SET NOCOUNT ON;
INSERT INTO RandomData
VALUES ('Random transaction');
GO 1000

-- And perform another full backup
BACKUP DATABASE Company
TO  DISK = N'D:\SQLBackups\Company_Full2.bak'
WITH INIT,
     NAME = N'Company Full with active transaction';
GO

-- Look in the backup history table in msdb again
SELECT name,
       checkpoint_lsn,
       first_lsn,
       last_lsn
FROM msdb.dbo.backupset
WHERE database_name = 'Company';
GO

-- Don't forget to clean up by committing the transaction in the other window