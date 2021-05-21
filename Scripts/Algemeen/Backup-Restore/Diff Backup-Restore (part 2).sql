-- If its Friday or the LSN's do not match - do a FULL backup

DECLARE @DBName VARCHAR(100) = 'Credit';
IF
(
    SELECT DATEPART(dw, GETDATE())
) = 6 --<< = Friday
OR
(
    SELECT MAX(differential_base_lsn)
    FROM [MyProdServer].[master].[sys].[master_files]
    WHERE [name] LIKE '%' + @DBName + '%'
) !=
(
    SELECT MAX(differential_base_lsn)
    FROM [MyReportServer].[master].[sys].[master_files]
    WHERE [name] LIKE '%' + @DBName + '%'
)
BEGIN
    SELECT 'We can only do a FULL backup';
    EXECUTE DBATools.dbo.DatabaseBackup @Databases = @DBName,
                                        @Directory = N'\\MyReportServer\backups',
                                        @BackupType = 'FULL',
                                        @CleanupTime = 1, --<< ONE HOUR
                                        @CleanupMode = 'BEFORE_BACKUP',
                                        @Compress = 'Y',
                                        @CheckSum = 'Y',
                                        @LogToTable = 'Y';
END;

-- Else do a DIFF backup

ELSE
BEGIN
    SELECT 'we can do a diff backup';
    EXECUTE DBATools.dbo.DatabaseBackup @Databases = @DBName,
                                        @Directory = N'\\MyReportServer\backups',
                                        @BackupType = 'DIFF',
                                        @CleanupTime = 168, --<< ONE WEEK
                                        @CleanupMode = 'BEFORE_BACKUP',
                                        @Compress = 'Y',
                                        @CheckSum = 'Y',
                                        @LogToTable = 'Y';
END;