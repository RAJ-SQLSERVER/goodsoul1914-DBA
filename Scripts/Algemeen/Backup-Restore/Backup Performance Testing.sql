SET NOCOUNT ON;

IF OBJECT_ID (N'tempdb..#output', N'U') IS NOT NULL DROP TABLE #output;

CREATE TABLE #output (txt NVARCHAR(1000) NULL);

IF OBJECT_ID (N'backup_test_results', N'U') IS NOT NULL
    DROP TABLE backup_test_results;

CREATE TABLE backup_test_results (
    rownum          INT          NOT NULL PRIMARY KEY CLUSTERED IDENTITY(1, 1),
    DBName          sysname      NOT NULL,
    StartDate       DATETIME     NOT NULL,
    BackupPath      VARCHAR(260) NOT NULL,
    StripeCount     INT          NOT NULL,
    BufferCount     INT          NOT NULL,
    BlockSize       INT          NOT NULL,
    MaxTransferSize INT          NOT NULL,
    Checksum        INT          NOT NULL,
    CopyOnly        INT          NOT NULL,
    Compression     INT          NOT NULL,
    Format          INT          NOT NULL,
    Init            INT          NOT NULL,
    Duration        INT          NOT NULL,
    IsDefaultBackup BIT          NOT NULL --indicates default buffer counts
);

--Trace flag 3213 displays backup/restore parameters used.
--Trace flag 3604 sends output to the client instead of the errorlog.

DBCC TRACEON(3213, 3604);

DECLARE @DebugOnly BIT = 0;
DECLARE @DatabaseName sysname;
DECLARE @BackupPath NVARCHAR(260);
DECLARE @MaxStripes INT;
DECLARE @CurrentStripes INT;
DECLARE @BufferCount INT; --BUFFERCOUNT
DECLARE @BufferCountLoop INT;
DECLARE @BlockSize INT; --BLOCKSIZE  (512, 1024, 2048, 4096, 8192, 16384, 32768, and 65536)
DECLARE @MaxTransferSize INT; --MAXTRANSFERSIZE (64KB to 4MB)
DECLARE @Checksum BIT;
DECLARE @CopyOnly BIT;
DECLARE @Compression BIT; --COMPRESSION or NO_COMPRESSION
DECLARE @Format BIT; --FORMAT or NOFORMAT
DECLARE @Init BIT; --INIT or NOINIT
DECLARE @DatabaseDeviceCount INT;

DECLARE @ToClause NVARCHAR(MAX);
DECLARE @cmd NVARCHAR(MAX);
DECLARE @StartTime DATETIME;
DECLARE @EndTime DATETIME;
DECLARE @Connector NVARCHAR(MAX);
DECLARE @DelConnector NVARCHAR(MAX);
DECLARE @DelCmd NVARCHAR(MAX);
DECLARE @msg NVARCHAR(100);

SET @MaxStripes = 3;
SET @DatabaseName = DB_NAME ();
SET @BackupPath = N'D:\SQLBackups\DT-RSD-01\' + @DatabaseName;
SET @BufferCount = 1;
SET @BlockSize = 512;
SET @MaxTransferSize = 1048576;
SET @Checksum = 0;
SET @CopyOnly = 1;
SET @Compression = 1;
SET @Format = 1;
SET @Init = 1;

DECLARE @res TABLE (
    [File Exists]             BIT NOT NULL,
    [File is a Directory]     BIT NOT NULL,
    [Parent Directory Exists] BIT NOT NULL
);

INSERT INTO @res
EXEC sys.xp_fileexist @BackupPath;

IF (SELECT r.[File is a Directory] FROM @res AS r) = 0
BEGIN
    SET @msg = N'Backup Folder "' + @BackupPath + N'" does not exist.';
    RAISERROR (@msg, 18, 1);
END;
ELSE
BEGIN
    --distinct I/O paths, i.e. individual disks, not database files
    SELECT @DatabaseDeviceCount = COUNT (DISTINCT SUBSTRING (mf.physical_name, 1, CHARINDEX (':', mf.physical_name)))
    FROM sys.master_files AS mf
    WHERE mf.database_id = (SELECT database_id FROM sys.databases AS d WHERE d.name = @DatabaseName)
          AND mf.type_desc = 'ROWS';

    IF @DebugOnly = 0
    BEGIN
        /* warm up the I/O path to reduce issues with timimg for first backup */
        BACKUP DATABASE @DatabaseName TO DISK = 'NUL' WITH COPY_ONLY;
    END;

    --buffercount loop (5 iterations)
    SET @BufferCountLoop = 0; --0 is special case for default number of buffers
    WHILE @BufferCountLoop <= 128
    BEGIN
        --maxtransfersize loop (6 iterations)
        SET @MaxTransferSize = 65536;
        WHILE @MaxTransferSize <= (2 * 1048576)
        BEGIN
            --blocksize loop (8 iterations)
            SET @BlockSize = 512;
            WHILE @BlockSize <= 65536
            BEGIN
                SET @CurrentStripes = 1;
                WHILE @CurrentStripes <= @MaxStripes
                BEGIN
                    SET @Connector = N'';
                    SET @DelConnector = N'';
                    SET @ToClause = N'';
                    SET @DelCmd = N'';
                    DECLARE @i INT = 1;
                    WHILE @i <= @CurrentStripes
                    BEGIN
                        SET @ToClause = @ToClause + @Connector + N'DISK = N''' + @BackupPath + N'/' + @DatabaseName
                                        + N'_TestBackup_Stripe_'
                                        + RIGHT(N'00000000000' + CONVERT (NVARCHAR(10), @i), 10) + N'.bak''';
                        SET @DelCmd = @DelCmd + @DelConnector + N'EXEC sys.xp_delete_file 0, ''' + @BackupPath + N'/'
                                      + @DatabaseName + N'_TestBackup_Stripe_'
                                      + RIGHT(N'00000000000' + CONVERT (NVARCHAR(10), @i), 10) + N'.bak'';';
                        SET @Connector = CHAR (13) + CHAR (10) + CHAR (9) + N', ';
                        SET @DelConnector = CHAR (13) + CHAR (10);
                        SET @i += 1;
                    END;
                    IF @BufferCountLoop = 0
                    BEGIN
                        /* default buffer count algorthim (wrapped for readability)
            https://blogs.msdn.microsoft.com/sqlserverfaq/2010/05/06/
               incorrect-buffercount-data-transfer-option-can-lead-to-oom-condition/
        */
                        SET @BufferCount = (@CurrentStripes * 4) + @CurrentStripes + (2 * @DatabaseDeviceCount);
                    END;
                    ELSE BEGIN
SET @BufferCount = @BufferCountLoop;
                    END;
                    SET @cmd = N'BACKUP DATABASE ' + QUOTENAME (@DatabaseName) + N'
								TO ' + @ToClause + N'
								WITH BUFFERCOUNT = ' + CONVERT (NVARCHAR(10), @BufferCount)
                               + N'
									, BLOCKSIZE = ' + CONVERT (NVARCHAR(10), @BlockSize)
                               + N'
									, MAXTRANSFERSIZE = ' + CONVERT (NVARCHAR(10), @MaxTransferSize) + N'
    '                          + CASE
                                     WHEN @Checksum = 1 THEN N', CHECKSUM'
                                     ELSE N', NO_CHECKSUM'
                                 END + N'
    '                          + CASE
                                     WHEN @CopyOnly = 1 THEN N', COPY_ONLY'
                                     ELSE N''
                                 END + N'
    '                          + CASE
                                     WHEN @Compression = 1 THEN N', COMPRESSION'
                                     ELSE N', NO_COMPRESSION'
                                 END + N'
    '                          + CASE
                                     WHEN @Format = 1 THEN N', FORMAT'
                                     ELSE N', NO_FORMAT'
                                 END + N'
    '                          + CASE
                                     WHEN @Init = 1 THEN N', INIT'
                                     ELSE N', NO_INIT'
                                 END + N'
    , STATS = 10'   ;
                    PRINT @cmd;
                    PRINT N'';
                    PRINT @DelCmd;
                    IF @DebugOnly = 0
                    BEGIN
                        SET @StartTime = GETDATE ();
                        --INSERT INTO #output (txt)
                        EXEC sys.sp_executesql @cmd;
                        SET @EndTime = GETDATE ();
                        INSERT INTO backup_test_results (DBName,
                                                         StartDate,
                                                         BackupPath,
                                                         StripeCount,
                                                         BufferCount,
                                                         BlockSize,
                                                         MaxTransferSize,
                                                         Checksum,
                                                         CopyOnly,
                                                         Compression,
                                                         Format,
                                                         Init,
                                                         Duration,
                                                         IsDefaultBackup)
                        VALUES (@DatabaseName,
                                @StartTime,
                                @BackupPath,
                                @CurrentStripes,
                                @BufferCount,
                                @BlockSize,
                                @MaxTransferSize,
                                @Checksum,
                                @CopyOnly,
                                @Compression,
                                @Format,
                                @Init,
                                DATEDIFF (MILLISECOND, @StartTime, @EndTime),
                                CASE
                                    WHEN @BufferCountLoop = 0 THEN 1
                                    ELSE 0
                                END);
                        PRINT N'Duration in MILLISECONDS: '
                              + CONVERT (NVARCHAR(10), DATEDIFF (MILLISECOND, @StartTime, @EndTime));
                        IF @DelCmd <> ''
                        BEGIN
                            INSERT INTO #output (txt)
                            EXEC sys.sp_executesql @DelCmd;
                        END;
                    END;
                    SET @CurrentStripes += 1;
                    PRINT N'';
                END;

                SET @BlockSize = @BlockSize * 2;
            END;

            SET @MaxTransferSize = @MaxTransferSize * 2;
        END;

        PRINT '===============================================================================================';
        SET @BufferCountLoop = @BufferCountLoop * 2;
        IF @BufferCountLoop = 0 SET @BufferCountLoop = 4; --reset the special case so we can try non-default-buffer-count backups
    END;

END;

DBCC TRACEOFF(3213, 3604);
GO

-- Analyze
SELECT rownum,
       StartDate,
       BackupPath,
       StripeCount,
       BufferCount,
       BlockSize,
       MaxTransferSize,
       Checksum,
       CopyOnly,
       Compression,
       Format,
       Init,
       Duration / 1000.0 AS "DurationInSec",
       IsDefaultBackup
FROM dbo.backup_test_results
ORDER BY DurationInSec;
GO

-- Analyze using pivot "Default backups"
SELECT p.DBName,
       'Default' AS "BufferCount",
       p.MaxTransferSize,
       p.BlockSize,
       p.[1],
       p.[2],
       p.[3],
       p.[4],
       p.[5],
       p.[6],
       p.[7],
       p.[8],
       p.[9],
       p.[10],
       (p.[1] + p.[2] + p.[3] + p.[4] + p.[5] + p.[6] + p.[7] + p.[8] + p.[9] + p.[10]) / 10 AS "AvgDuration"
FROM (
    SELECT btr.DBName,
           btr.BlockSize,
           btr.MaxTransferSize,
           btr.StripeCount,
           btr.Duration
    FROM backup_test_results AS btr
    WHERE btr.IsDefaultBackup = 1
) AS src
PIVOT (
    MIN(src.Duration)
    FOR src.StripeCount IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10])
) AS p
ORDER BY p.DBName,
         p.MaxTransferSize,
         p.BlockSize;

-- Analyze using pivot "Non-default backups"
SELECT p.DBName,
       p.BufferCount,
       p.MaxTransferSize,
       p.BlockSize,
       p.[1],
       p.[2],
       p.[3],
       p.[4],
       p.[5],
       p.[6],
       p.[7],
       p.[8],
       p.[9],
       p.[10]
FROM (
    SELECT btr.DBName,
           btr.BufferCount,
           btr.BlockSize,
           btr.MaxTransferSize,
           btr.StripeCount,
           btr.Duration
    FROM backup_test_results AS btr
    WHERE btr.IsDefaultBackup = 0
) AS src
PIVOT (
    MIN(src.Duration)
    FOR src.StripeCount IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10])
) AS p
ORDER BY p.DBName,
         p.BufferCount,
         p.MaxTransferSize
    , p.BlockSize;
GO

