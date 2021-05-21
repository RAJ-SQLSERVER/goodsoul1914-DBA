
SELECT s.database_name,
       m.physical_device_name AS DestinationLocation,
       CAST(DATEDIFF(SECOND, s.backup_start_date, s.backup_finish_date) AS VARCHAR(4)) + ' ' + 'Seconds' AS Duration,
       s.backup_start_date,
       CASE
           WHEN ROW_NUMBER() OVER (PARTITION BY s.database_name ORDER BY s.backup_start_date ASC) = 1 THEN
               0
           ELSE
               DATEDIFF(
                           DAY,
                           LAG(s.backup_start_date, 1, 0) OVER (ORDER BY DAY(s.backup_start_date)),
                           s.backup_start_date
                       )
       END AS DaysSinceLastBackup,
       CASE s.[type]
           WHEN 'D' THEN
               'Full'
           WHEN 'I' THEN
               'Differential'
           WHEN 'L' THEN
               'Transaction Log'
		   ELSE
			   'Unknown'
       END AS BackupType
FROM msdb.dbo.backupset s
    INNER JOIN msdb.dbo.backupmediafamily m
        ON s.media_set_id = m.media_set_id
WHERE s.backup_start_date >= '01-05-2020'
      AND s.backup_start_date <= '08-30-2020'
      AND s.type IN ( 'D', 'I' )
ORDER BY s.database_name,
         s.backup_start_date;
GO

