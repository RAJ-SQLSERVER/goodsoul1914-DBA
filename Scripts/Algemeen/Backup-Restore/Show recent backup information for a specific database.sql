/*
Show recent backup information for a specific database
*/
SELECT bs.name,
       bs.description,
       CASE
           WHEN bs.type = 'D' THEN 'Full'
           WHEN bs.type = 'I' THEN 'Diff'
           ELSE 'Log'
       END AS "backup_type",
       bs.expiration_date,
       bms.is_compressed,
       bmf.device_type,
       bs.user_name,
       bs.server_name,
       bs.database_name,
       bs.is_copy_only,
       bs.backup_start_date,
       bs.backup_finish_date,
       DATEDIFF (SECOND, bs.backup_start_date, bs.backup_finish_date) AS "duration",
       bs.backup_size,
       bs.compressed_backup_size,
       CONVERT (INT, bs.compressed_backup_size / bs.backup_size * 100) AS "compression_ratio",
       bmf.physical_device_name,
       bs.backup_set_id,
       bs.media_set_id
FROM msdb.dbo.backupset AS bs
INNER JOIN msdb.dbo.backupmediaset AS bms
    ON bs.media_set_id = bms.media_set_id
INNER JOIN msdb.dbo.backupmediafamily AS bmf
    ON bs.media_set_id = bmf.media_set_id
WHERE bs.database_name = 'StackOverflow2013'
      AND bs.backup_start_date > DATEADD (DAY, -20, GETDATE ());
GO
