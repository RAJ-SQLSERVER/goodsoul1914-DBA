USE [msdb];
GO 

IF EXISTS (SELECT * FROM [sys].[objects]
	WHERE [name] = N'IsReallyInFullRecovery')
   DROP FUNCTION [IsReallyInFullRecovery];
GO
 
CREATE FUNCTION [IsReallyInFullRecovery] (
   @DBName sysname)
RETURNS BIT
AS
BEGIN
   DECLARE @IsReallyFull		BIT;
   DECLARE @LastLogBackupLSN	NUMERIC (25,0);
   DECLARE @RecoveryModel		TINYINT;
   
   SELECT @LastLogBackupLSN = [last_log_backup_lsn]
   FROM [sys].[database_recovery_status]
   WHERE [database_id] = DB_ID (@DBName); 

   SELECT @RecoveryModel = [recovery_model]
   FROM [sys].[databases]
   WHERE [database_id] = DB_ID (@DBName); 

   IF (@RecoveryModel = 1 AND @LastLogBackupLSN IS NOT NULL)
      SELECT @IsReallyFull = 1
   ELSE
      SELECT @IsReallyFull = 0; 

   RETURN (@IsReallyFull);
END;
GO 

-- Create some databases
IF DATABASEPROPERTYEX (N'SimpleModeDB', N'Version') > 0
BEGIN
	ALTER DATABASE [SimpleModeDB] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [SimpleModeDB];
END
GO
IF DATABASEPROPERTYEX (N'BulkLoggedModeDB', N'Version') > 0
BEGIN
	ALTER DATABASE [BulkLoggedModeDB] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [BulkLoggedModeDB];
END
GO
IF DATABASEPROPERTYEX (N'FullModeDB', N'Version') > 0
BEGIN
	ALTER DATABASE [FullModeDB] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [FullModeDB];
END
GO

CREATE DATABASE [SimpleModeDB];
CREATE DATABASE [BulkLoggedModeDB];
CREATE DATABASE [FullModeDB];
GO 

-- Set the recovery models
ALTER DATABASE [SimpleModeDB] SET RECOVERY SIMPLE;
ALTER DATABASE [BulkLoggedModeDB] SET RECOVERY BULK_LOGGED;
ALTER DATABASE [FullModeDB] SET RECOVERY FULL;
GO 

-- Are any really in FULL?
SELECT
	[Name],
	[msdb].[dbo].[IsReallyInFullRecovery] ([Name])
	AS N'ReallyInFULL'
FROM [sys].[databases]
WHERE [Name] LIKE N'%ModeDB';
GO 

-- Make FullModeDB really in FULL
BACKUP DATABASE [FullModeDB]
	TO DISK = N'D:\Pluralsight\FullModeDB.bck'
	WITH INIT;
GO

SELECT
	[msdb].[dbo].[IsReallyInFullRecovery] (N'FullModeDB')
	AS N'ReallyInFULL';
GO

-- Switch to SIMPLE and back
ALTER DATABASE [FullModeDB] SET RECOVERY SIMPLE;
ALTER DATABASE [FullModeDB] SET RECOVERY FULL;
GO

SELECT
	[msdb].[dbo].[IsReallyInFullRecovery] (N'FullModeDB')
	AS N'ReallyInFULL';
GO

-- Switch back to FULL with a bridging data backup
BACKUP DATABASE [FullModeDB]
	TO DISK = N'D:\Pluralsight\FullModeDB_Diff.bck'
	WITH INIT, DIFFERENTIAL;
GO

SELECT
	[msdb].[dbo].[IsReallyInFullRecovery] (N'FullModeDB')
	AS N'ReallyInFULL';
GO