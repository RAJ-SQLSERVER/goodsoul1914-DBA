-- Determine when the last log backup was taken.
------------------------------------------------------------------------------------------------
USE msdb;

SELECT backup_set_id,
       backup_start_date,
       backup_finish_date,
       backup_size,
       recovery_model,
       type
FROM dbo.backupset
WHERE database_name = 'DatabaseName';