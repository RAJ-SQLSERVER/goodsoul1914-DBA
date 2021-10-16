/*
Author: Eitan Blumin (t: @EitanBlumin | b: eitanblumin.com)
Date: 2020-06-04
Description:
	Use this script to restore from a database backup while easily moving all files to specified folders per file type.
	The script must be run in SQLCMD mode.
	Don't forget to modify the SQLCMD variables as needed.
*/
:setvar DatabaseName MyDatabase
:setvar BackupFilePath E:\SQLBackups\MyDatabase_backup_20200602_233000.bak
:setvar DataFilesFolder M:\SQLData
:setvar LogFilesFolder L:\SQLLogs
:setvar FullTextCatalogFolder M:\SQLData
:setvar FileStreamFolder M:\SQLData

USE [master];
GO
SET NOCOUNT, ARITHABORT, XACT_ABORT, QUOTED_IDENTIFIER ON;

-- Check if IFI is enabled
DECLARE @LogOnAccount NVARCHAR(300);
SELECT @LogOnAccount = service_account
FROM sys.dm_server_services
WHERE servicename LIKE 'SQL Server (%'
      AND instant_file_initialization_enabled = 'N';

IF @LogOnAccount IS NOT NULL
    RAISERROR(
                 N'WARNING: Instant File Initialization is not enabled. This can cause significantly longer restore durations for large databases.
Please follow these steps:
1. Run "secpol.msc" as an administrator.
2. Go to Security Settings > Local Policies > User Rights Assignments.
3. Double-click on the "Perform volume maintenance tasks" policy.
4. Click on "Add User or Group..." and add the service logon account "%s" to the list.',
                 11,
                 1,
                 @LogOnAccount
             );

-- Make sure folders exist
DECLARE @FoldersToCheck AS TABLE
(
    FolderPath NVARCHAR(260)
);
INSERT INTO @FoldersToCheck
VALUES
('$(DataFilesFolder)'),
('$(LogFilesFolder)'),
('$(FullTextCatalogFolder)'),
('$(FileStreamFolder)');

DECLARE @DirectoryExists INT,
        @FolderPath NVARCHAR(260);
DROP TABLE IF EXISTS #temp;
CREATE TABLE #temp
(
    FileExists INT,
    IsDirectory INT,
    ParentDirExists INT
);

DECLARE Folders CURSOR LOCAL FAST_FORWARD FOR
SELECT FolderPath
FROM @FoldersToCheck
WHERE FolderPath <> '';

OPEN Folders;
FETCH NEXT FROM Folders
INTO @FolderPath;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @DirectoryExists = 0;

    INSERT INTO #temp
    EXEC master.dbo.xp_fileexist @FolderPath;

    SELECT @DirectoryExists = IsDirectory
    FROM #temp;

    IF @DirectoryExists = 0
    BEGIN
        RAISERROR(N'-- Creating %s', 0, 1, @FolderPath) WITH NOWAIT;
        EXEC master.sys.xp_create_subdir @FolderPath;
    END;

    TRUNCATE TABLE #temp;

    FETCH NEXT FROM Folders
    INTO @FolderPath;
END;
CLOSE Folders;
DEALLOCATE Folders;
GO
DROP TABLE IF EXISTS #Files;
CREATE TABLE #Files
(
    LogicalName NVARCHAR(128),
    PhysicalName NVARCHAR(260),
    [Type] CHAR(1), -- L = Microsoft SQL Server log file, D = SQL Server data file, F = Full Text Catalog, S = FileStream, FileTable, or In-Memory OLTP container
    FileGroupName NVARCHAR(128) NULL,
    Size NUMERIC(20, 0),
    MaxSize NUMERIC(20, 0),
    FileID BIGINT,
    CreateLSN NUMERIC(25, 0),
    DropLSN NUMERIC(25, 0) NULL,
    UniqueID UNIQUEIDENTIFIER,
    ReadOnlyLSN NUMERIC(25, 0) NULL,
    ReadWriteLSN NUMERIC(25, 0) NULL,
    BackupSizeInBytes BIGINT,
    SourceBlockSize INT,
    FileGroupID INT,
    LogGroupGUID UNIQUEIDENTIFIER NULL,
    DifferentialBaseLSN NUMERIC(25, 0) NULL,
    DifferentialBaseGUID UNIQUEIDENTIFIER NULL,
    IsReadOnly BIT,
    IsPresent BIT,
    TDEThumbprint VARBINARY(32) NULL,
    SnapshotURL NVARCHAR(360) NULL
);

INSERT INTO #Files
EXEC (N'RESTORE FILELISTONLY FROM 
DISK = ''$(BackupFilePath)''
WITH FILE = 1;');

DECLARE @CMD NVARCHAR(MAX);

SELECT @CMD
    = ISNULL(@CMD + N'
', N'USE [master]
GO
RESTORE DATABASE [$(DatabaseName)] FROM 
DISK = ''$(BackupFilePath)''
WITH ')       + N'MOVE ' + QUOTENAME(LogicalName, N'''') + N' TO '
      + QUOTENAME(   CASE [Type]
                         WHEN 'D' THEN
                             N'$(DataFilesFolder)'
                         WHEN 'L' THEN
                             N'$(LogFilesFolder)'
                         WHEN 'F' THEN
                             N'$(FullTextCatalogFolder)'
                         WHEN 'S' THEN
                             N'$(FileStreamFolder)'
                     END + REVERSE(LEFT(REVERSE(PhysicalName), CHARINDEX('\', REVERSE(PhysicalName)))),
                     N''''
                 ) + N','
FROM #Files;

SET @CMD = @CMD + N'
FILE = 1, STATS = 5;
GO';

PRINT N'-------------------------------------------------------------';
PRINT N'-- Copy the following to a new query window and run it to start restoring the database backup:';
PRINT N'-------------------------------------------------------------';
PRINT @CMD;
PRINT N'-------------------------------------------------------------';
GO