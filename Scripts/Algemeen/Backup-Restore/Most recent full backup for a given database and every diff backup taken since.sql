/* 
Most recent full backup for a given database and every diff backup taken since 
and will do so in the proper order that they need to be restored
*/
SELECT bs.type,
       bmf.physical_device_name
FROM msdb.dbo.backupset AS bs
INNER JOIN msdb.dbo.backupmediafamily AS bmf
    ON bs.media_set_id = bmf.media_set_id
WHERE bs.database_name = 'StackOverflow2013'
      AND bs.backup_finish_date >= (
          SELECT TOP (1) backup_finish_date
          FROM msdb.dbo.backupset AS b1
          WHERE b1.database_name = 'StackOverflow2013'
                AND b1.type = 'D'
          ORDER BY b1.backup_finish_date DESC
      )
ORDER BY bs.type,
         bs.backup_finish_date;
GO