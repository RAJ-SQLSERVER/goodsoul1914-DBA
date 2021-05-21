SET NOCOUNT ON;

DECLARE @File NVARCHAR(1000) = N'MyDatabase.bak';
DECLARE @Path NVARCHAR(1000) = N'D:SQLBackups';
DECLARE @MDFPath NVARCHAR(1000) = N'E:MSSQLData';
DECLARE @LDFPath NVARCHAR(1000) = N'L:MSSQLLogs';

DECLARE @FullLoc NVARCHAR(2000) = @Path + @File;

DECLARE @DatabaseName NVARCHAR(128);
DECLARE @RestoreMDF NVARCHAR(2000);
DECLARE @RestoreLDF NVARCHAR(2000);
DECLARE @RestoreCommandFull NVARCHAR(4000);
DECLARE @sqlexec NVARCHAR(4000);

DECLARE @MDFID INT;
DECLARE @LDFID INT;
DECLARE @MDFName NVARCHAR(128);
DECLARE @LDFName NVARCHAR(128);


DECLARE @RestoreFiles TABLE
(
    ID INT IDENTITY(1, 1),
    LogicalName NVARCHAR(128),
    PhysicalName NVARCHAR(260),
    [Type] CHAR(1),
    FileGroupName NVARCHAR(128),
    [size] NUMERIC(20, 0),
    MAXSIZE NUMERIC(20, 0),
    FileID BIGINT,
    CreateLSN NUMERIC(25, 0),
    DropLSN NUMERIC(25, 0),
    UniqueID UNIQUEIDENTIFIER,
    ReadOnlyLSN NUMERIC(25, 0),
    ReadWriteLSN NUMERIC(25, 0),
    BackupSizeInBytes BIGINT,
    SourceBlockSize INT,
    FileGroupID INT,
    LogGroupGUID UNIQUEIDENTIFIER,
    DifferentialBaseLSN NUMERIC(25, 0),
    DifferentialBaseGUID UNIQUEIDENTIFIER,
    IsReadOnly BIT,
    IsPresent BIT,
    TDEThumbprint VARBINARY(32)
);

DECLARE @RestoreHeader TABLE
(
    BackupName NVARCHAR(128),
    BackupDescription NVARCHAR(255),
    BackupType SMALLINT,
    ExpirationDate DATETIME,
    Compressed CHAR(1),
    POSITION SMALLINT,
    DeviceType TINYINT,
    UserName NVARCHAR(128),
    ServerName NVARCHAR(128),
    DatabaseName NVARCHAR(128),
    DatabaseVersion INT,
    DatabaseCreationDate DATETIME,
    BackupSize NUMERIC(20, 0),
    FirstLSN NUMERIC(25, 0),
    LastLSN NUMERIC(25, 0),
    CheckpointLSN NUMERIC(25, 0),
    DatabaseBackupLSN NUMERIC(25, 0),
    BackupStartDate DATETIME,
    BackupFinishDate DATETIME,
    SortORder SMALLINT,
    [CodePage] SMALLINT,
    UnicodeLocaleId INT,
    UnicodeComparisonStyle INT,
    CompatabilityLevel TINYINT,
    SoftwareVendorId INT,
    SoftwareVersionMajor INT,
    SoftwareVersionMinor INT,
    SoftwareVersionBuild INT,
    MachineName NVARCHAR(128),
    Flags INT,
    BindingID UNIQUEIDENTIFIER,
    RecoveryForkID UNIQUEIDENTIFIER,
    [Collation] NVARCHAR(128),
    FamilyGUID UNIQUEIDENTIFIER,
    HasBulkLoggedData BIT,
    IsSnapshot BIT,
    IsReadOnly BIT,
    IsSingleUser BIT,
    HasBackupChecksums BIT,
    IsDamaged BIT,
    BeginsLogChain BIT,
    HasIncompleteMetaData BIT,
    IsForceOffline BIT,
    IsCopyOnly BIT,
    FirstRecoveryForkID UNIQUEIDENTIFIER,
    ForkPointLSN NUMERIC(25, 0),
    RecoveryModel NVARCHAR(60),
    DifferentialBaseLSN NUMERIC(25, 0),
    DifferentialBaseGUID UNIQUEIDENTIFIER,
    BackupTypeDescription NVARCHAR(60),
    BackupSetGUID UNIQUEIDENTIFIER,
    CompressedBackupSize BIGINT
);

SELECT @sqlexec = N'RESTORE FILELISTONLY FROM DISK = ''' + @FullLoc + N'''';
INSERT INTO @RestoreFiles
EXEC (@sqlexec);


SELECT @sqlexec = N'RESTORE HEADERONLY FROM DISK = ''' + @FullLoc + N'''';
INSERT INTO @RestoreHeader
EXEC (@sqlexec);

SELECT @DatabaseName = DatabaseName
FROM @RestoreHeader;


SELECT @MDFID = MIN(ID)
FROM @RestoreFiles
WHERE [Type] != 'L';
WHILE @MDFID IS NOT NULL
BEGIN
    IF @MDFID = 1
    BEGIN
        SELECT @RestoreMDF
            = N'WITH MOVE ' + CHAR(39) + LogicalName + CHAR(39) + N' TO ' + CHAR(39) + @MDFPath
              + REVERSE(LEFT(REVERSE(PhysicalName), CHARINDEX('', REVERSE(PhysicalName)) - 1)) + CHAR(39) + CHAR(13)
        FROM @RestoreFiles
        WHERE ID = @MDFID;
    END;
    ELSE
    BEGIN
        SELECT @RestoreMDF
            = @RestoreMDF + N', MOVE ' + CHAR(39) + LogicalName + CHAR(39) + N' TO ' + CHAR(39) + @MDFPath
              + REVERSE(LEFT(REVERSE(PhysicalName), CHARINDEX('', REVERSE(PhysicalName)) - 1)) + CHAR(39)
        FROM @RestoreFiles
        WHERE ID = @MDFID;
    END;

    SELECT @MDFID = MIN(ID)
    FROM @RestoreFiles
    WHERE ID > @MDFID
          AND [Type] != 'L';
END;


SELECT @LDFID = MIN(ID)
FROM @RestoreFiles
WHERE [Type] = 'L';
WHILE @LDFID IS NOT NULL
BEGIN
    SELECT @RestoreLDF
        = ISNULL(@RestoreLDF, '') + N', MOVE ' + CHAR(39) + LogicalName + CHAR(39) + N' TO ' + CHAR(39) + @LDFPath
          + REVERSE(LEFT(REVERSE(PhysicalName), CHARINDEX('', REVERSE(PhysicalName)) - 1)) + CHAR(39)
    FROM @RestoreFiles
    WHERE ID = @LDFID;

    SELECT @LDFID = MIN(ID)
    FROM @RestoreFiles
    WHERE ID > @LDFID
          AND [Type] = 'L';
END;


SELECT @RestoreCommandFull
    = N'RESTORE DATABASE ' + QUOTENAME(@DatabaseName) + N' ' + CHAR(13) + N'FROM DISK = ''' + @FullLoc + N''''
      + CHAR(13);
SELECT @RestoreCommandFull = @RestoreCommandFull + @RestoreMDF + @RestoreLDF + CHAR(13) + N', NORECOVERY, STATS=20;';
--PRINT @RestoreCommandFull

EXEC (@RestoreCommandFull);
