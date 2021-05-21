WITH T_History
AS (SELECT bs.database_name AS dbName,
           CAST(MAX(bs.backup_size) / 1024 / 1024 AS DECIMAL(20, 2)) AS backup_size_MB,
           CAST(MAX(bs.compressed_backup_size) / 1024 / 1024 AS DECIMAL(20, 2)) AS compressed_backup_size_MB
    FROM msdb.dbo.backupmediafamily AS bmf
        INNER JOIN msdb.dbo.backupset AS bs
            ON bmf.media_set_id = bs.media_set_id
    WHERE bs.type IN ( 'D' )
    GROUP BY database_name),
     t_filtered
AS (SELECT d.name AS dbName,
           backup_size_MB,
           compressed_backup_size_MB
    FROM sys.databases AS d
        LEFT JOIN T_History AS h
            ON h.dbName = d.name)
SELECT 'Full-Backup' AS BackupType,
       SUM(f.backup_size_MB) / 1024 AS backup_size_GB,
       SUM(f.compressed_backup_size_MB) / 1024 AS compressed_backup_size_GB
FROM t_filtered AS f;
GO


WITH T_History
AS (SELECT bs.database_name AS dbName,
           CAST(MAX(bs.backup_size) / 1024 / 1024 AS DECIMAL(20, 2)) AS backup_size_MB,
           CAST(MAX(bs.compressed_backup_size) / 1024 / 1024 AS DECIMAL(20, 2)) AS compressed_backup_size_MB
    FROM msdb.dbo.backupmediafamily AS bmf
        INNER JOIN msdb.dbo.backupset AS bs
            ON bmf.media_set_id = bs.media_set_id
    WHERE bs.type IN ( 'L' )
          AND bs.backup_finish_date >= DATEADD(DAY, -1, GETDATE())
    GROUP BY database_name),
     t_filtered
AS (SELECT d.name AS dbName,
           backup_size_MB,
           compressed_backup_size_MB
    FROM sys.databases AS d
        LEFT JOIN T_History AS h
            ON h.dbName = d.name)
SELECT 'Log-Backup' AS BackupType,
       SUM(f.backup_size_MB) / 1024 AS backup_size_GB,
       SUM(f.compressed_backup_size_MB) / 1024 AS compressed_backup_size_GB
FROM t_filtered AS f;
GO