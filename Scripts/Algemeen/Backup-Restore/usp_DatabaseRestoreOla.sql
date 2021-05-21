USE [master];
GO

CREATE PROCEDURE [dbo].[usp_DatabaseRestoreOla]
    @dbName sysname,
    @SourceServer NVARCHAR(500),
    @backupPath NVARCHAR(500)
AS

/* To restore backups created from ola.hallengren's backup solution (RS) */

SET NOCOUNT ON;
DECLARE @cmd NVARCHAR(500),
        @lastFullBackup NVARCHAR(500),
        @lastDiffBackup NVARCHAR(500),
        @backupFile NVARCHAR(500);

DECLARE @fileList TABLE
(
    backupFile NVARCHAR(255)
);
DECLARE @directoryList TABLE
(
    backupFile NVARCHAR(255)
);

/* Kill any connections */

DECLARE @kill VARCHAR(8000) = '';
SELECT @kill = @kill + 'kill ' + CONVERT(VARCHAR(5), spid) + ';'
FROM [master].[dbo].[sysprocesses]
WHERE dbid = DB_ID(@dbName)
      AND spid > 50;
EXEC (@kill);

/* Match that of Olas output */

SET @backupPath = @backupPath + '\' + @SourceServer + '\' + @dbName + '\';

/* Get List of Files */

SET @cmd = N'DIR /s /b /O D ' + @backupPath;
IF
(
    SELECT value_in_use FROM sys.configurations WHERE name = 'xp_cmdshell'
) = 0
BEGIN /* cmd shell is disabled */
    EXEC sp_configure 'show advanced options', 1;
    RECONFIGURE;
    EXEC sp_configure xp_cmdshell, 1;
    RECONFIGURE;
    INSERT INTO @fileList
    (
        backupFile
    )
    EXEC master.sys.xp_cmdshell @cmd;
    EXEC sp_configure 'xp_cmdshell', 0;
    RECONFIGURE;
    EXEC sp_configure 'show advanced options', 0;
    RECONFIGURE;
END;
ELSE /* cmd shell is enabled */
    INSERT INTO @fileList
    (
        backupFile
    )
    EXEC master.sys.xp_cmdshell @cmd;

/* Find latest full backup */

SELECT @lastFullBackup = MAX(backupFile)
FROM @fileList
WHERE backupFile LIKE '%' + @SourceServer + '_' + @dbName + '_FULL_%.bak';

SET @cmd = N'RESTORE DATABASE [' + @dbName + N'] FROM DISK = ''' + @lastFullBackup + N''' WITH NORECOVERY, REPLACE';
SELECT (@cmd);
EXEC (@cmd);

/* Find latest diff backup */

SELECT @lastDiffBackup = MAX(backupFile)
FROM @fileList
WHERE backupFile LIKE '%' + @SourceServer + '_' + @dbName + '_DIFF_%.bak'
      AND RIGHT(backupFile, 19) > RIGHT(@lastFullBackup, 19);

/* check to make sure there is a diff backup */

IF @lastDiffBackup IS NOT NULL
BEGIN
    SET @cmd = N'RESTORE DATABASE [' + @dbName + N'] FROM DISK = ''' + @lastDiffBackup + N''' WITH NORECOVERY';
    SELECT (@cmd);
    EXEC (@cmd);
    SET @lastFullBackup = @lastDiffBackup;
END;

--/* check for log backups */

--	DECLARE backupFiles CURSOR FOR 
--	SELECT backupFile 
--	FROM @fileList
--	WHERE backupFile LIKE  '%' + @SourceServer + '_' + @dbName + '_LOG_%.trn'
--	AND RIGHT(backupfile, 19) > RIGHT(@lastFullBackup, 19)

--	OPEN backupFiles 

--/* Loop through all the files for the database */

--	FETCH NEXT FROM backupFiles INTO @backupFile 

--	WHILE @@FETCH_STATUS = 0 
--		BEGIN 
--		   SET @cmd = 'RESTORE LOG [' + @dbName + '] FROM DISK = ''' 
--			   + @backupFile + ''' WITH NORECOVERY'
--		   SELECT (@cmd); EXEC (@cmd)
--		   FETCH NEXT FROM backupFiles INTO @backupFile 
--		END

--	CLOSE backupFiles 
--	DEALLOCATE backupFiles 

/* put database in a useable state */

SET @cmd = N'RESTORE DATABASE [' + @dbName + N'] WITH RECOVERY';
SELECT (@cmd);
EXEC (@cmd);

GO


/*
dbo.usp_DatabaseRestore @dbName = 'Credit',
                        @SourceServer = 'LT-RSD-01',
                        @backupPath = 'D:\SQLBackup';
*/