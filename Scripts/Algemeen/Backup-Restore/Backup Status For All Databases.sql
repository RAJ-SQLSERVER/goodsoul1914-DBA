-- Backup Status for All Databases 
---------------------------------------------------------------------------------------------------
SELECT DB.name AS DatabaseName,
       MAX(DB.recovery_model_desc) AS RecModel,
       MAX(BS.backup_start_date) AS LastBackup,
       MAX(   CASE
                  WHEN BS.type = 'D' THEN
                      BS.backup_start_date
              END
          ) AS LastFull,
       SUM(   CASE
                  WHEN BS.type = 'D' THEN
                      1
              END
          ) AS CountFull,
       MAX(   CASE
                  WHEN BS.type = 'L' THEN
                      BS.backup_start_date
              END
          ) AS LastLog,
       SUM(   CASE
                  WHEN BS.type = 'L' THEN
                      1
              END
          ) AS CountLog,
       MAX(   CASE
                  WHEN BS.type = 'I' THEN
                      BS.backup_start_date
              END
          ) AS LastDiff,
       SUM(   CASE
                  WHEN BS.type = 'I' THEN
                      1
              END
          ) AS CountDiff,
       MAX(   CASE
                  WHEN BS.type = 'F' THEN
                      BS.backup_start_date
              END
          ) AS LastFile,
       SUM(   CASE
                  WHEN BS.type = 'F' THEN
                      1
              END
          ) AS CountFile,
       MAX(   CASE
                  WHEN BS.type = 'G' THEN
                      BS.backup_start_date
              END
          ) AS LastFileDiff,
       SUM(   CASE
                  WHEN BS.type = 'G' THEN
                      1
              END
          ) AS CountFileDiff,
       MAX(   CASE
                  WHEN BS.type = 'P' THEN
                      BS.backup_start_date
              END
          ) AS LastPart,
       SUM(   CASE
                  WHEN BS.type = 'P' THEN
                      1
              END
          ) AS CountPart,
       MAX(   CASE
                  WHEN BS.type = 'Q' THEN
                      BS.backup_start_date
              END
          ) AS LastPartDiff,
       SUM(   CASE
                  WHEN BS.type = 'Q' THEN
                      1
              END
          ) AS CountPartDiff
FROM sys.databases AS DB
    LEFT JOIN msdb.dbo.backupset AS BS
        ON BS.database_name = DB.name
WHERE ISNULL(BS.is_damaged, 0) = 0 -- exclude damaged backups          
GROUP BY DB.name
ORDER BY DB.name;


--------------------------------------------------------------------------------- 
--Database Backups for all databases For Previous Week 
--------------------------------------------------------------------------------- 
WITH T_bkpHistory
AS (SELECT --ROW_NUMBER()over(partition by bs.database_name order by bs.backup_finish_date desc) as RowID,
        CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS SERVER,
        bs.database_name,
        bs.backup_start_date,
        bs.backup_finish_date,
        bs.expiration_date,
        CASE bs.type
            WHEN 'D' THEN
                'Database'
            WHEN 'L' THEN
                'Log'
        END AS backup_type,
        CONVERT(DECIMAL(18, 3), bs.backup_size / 1024 / 1024) AS backup_size_MB,
        CONVERT(DECIMAL(18, 3), bs.backup_size / 1024 / 1024 / 1024) AS backup_size_GB,
        bmf.logical_device_name,
        bmf.physical_device_name,
        bs.name AS backupset_name,
        bs.description,
        first_lsn,
        last_lsn,
        checkpoint_lsn,
        database_backup_lsn,
        is_copy_only,
        is_snapshot
    --bs.* --bmf.*
    FROM msdb.dbo.backupmediafamily AS bmf
        INNER JOIN msdb.dbo.backupset AS bs
            ON bmf.media_set_id = bs.media_set_id
    WHERE bs.backup_start_date >= DATEADD(   DAY,
                                             -2,
                                  (
                                      SELECT MAX(bsi.backup_start_date)
                                      FROM msdb.dbo.backupmediafamily AS bmfi
                                          INNER JOIN msdb.dbo.backupset AS bsi
                                              ON bmfi.media_set_id = bsi.media_set_id
                                      WHERE bsi.database_name = bs.database_name
                                            AND bsi.type = 'D'
                                  )
                                         ))
SELECT *
FROM T_bkpHistory
ORDER BY database_name,
         backup_start_date DESC;

--------------------------------------------------------------------------------- 
--Database Backups for all databases For Previous Week 
--------------------------------------------------------------------------------- 
WITH t_BkpHistOry
AS (SELECT CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS SERVER,
           bs.database_name,
           bs.backup_start_date,
           bs.backup_finish_date,
           bs.expiration_date,
           CASE bs.type
               WHEN 'D' THEN
                   'Database'
               WHEN 'I' THEN
                   'Differential'
               WHEN 'L' THEN
                   'Log'
           END AS backup_type,
           bs.backup_size,
           bmf.logical_device_name,
           bmf.physical_device_name,
           bs.name AS backupset_name,
           bs.description,
           is_copy_only,
           ROW_NUMBER() OVER (PARTITION BY bs.database_name,
                                           bs.type
                              ORDER BY bs.backup_start_date DESC
                             ) AS BackupID
    FROM msdb.dbo.backupmediafamily AS bmf
        INNER JOIN msdb.dbo.backupset AS bs
            ON bmf.media_set_id = bs.media_set_id
    WHERE bs.backup_start_date >= DATEADD(DAY, -15, GETDATE())),
     t_HistoryLastest
AS (SELECT h.SERVER,
           d.name AS dbName,
           h.backup_type,
           h.backup_start_date,
           h.physical_device_name,
           LEFT(h.physical_device_name, LEN(h.physical_device_name) - CHARINDEX('\', REVERSE(h.physical_device_name))) AS bkpPath,
           RIGHT(h.physical_device_name, 3) AS Extension
    FROM sys.databases AS d
        LEFT OUTER JOIN t_BkpHistOry AS h
            ON h.database_name = d.name
    WHERE BackupID = 1),
     t_BkpPaths
AS (SELECT *,
           ROW_NUMBER() OVER (PARTITION BY backup_type, bkpPath, Extension ORDER BY dbName) AS BkpPathID
    FROM t_HistoryLastest AS h)
SELECT --distinct backup_type, bkpPath, Extension
    *
FROM t_BkpPaths -- order by  bkpPath, dbName
WHERE BkpPathID = 1;
--where bkpPath = 'F:\Dump'
--where backup_type = 'Log'
--and bkpPath = 'G:\mssqldata\Backup'