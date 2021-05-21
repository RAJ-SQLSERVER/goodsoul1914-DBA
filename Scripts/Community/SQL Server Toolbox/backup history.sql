--Looks for a complete backup history, displaying the latest backup of each type.

--See also toolbox/multiserver backup history.sql for health checks.

USE master;
GO
--sql2012 and above
SELECT database_name,
       backuptype,
       d.recovery_model_desc,
       MAX (BackupDate) AS "BackupDate",
       d.state_desc,
       d.is_read_only,
       dm.Replica_Role --SQL 2012+
FROM sys.databases AS d
INNER JOIN (
    SELECT DISTINCT database_name,
                    DB_ID (database_name) AS "database_id",
                    CASE type
                        WHEN 'D' THEN 'Database'
                        WHEN 'I' THEN 'Differential database'
                        WHEN 'L' THEN 'Transaction Log'
                        WHEN 'F' THEN 'File or filegroup'
                        WHEN 'G' THEN 'Differential file'
                        WHEN 'P' THEN 'Partial'
                        WHEN 'Q' THEN 'Differential partial'
                    END AS "backuptype",
                    MAX (backup_finish_date) AS "BackupDate"
    FROM msdb.dbo.backupset AS bs
    GROUP BY database_name,
             type
    UNION
    SELECT DISTINCT DB_NAME (d.database_id),
                    d.database_id,
                    'Database' AS "backuptype",
                    NULL
    FROM master.sys.databases AS d
    UNION
    SELECT DISTINCT DB_NAME (d.database_id),
                    d.database_id,
                    'Transaction Log' AS "backuptype",
                    NULL
    FROM master.sys.databases AS d
    WHERE d.recovery_model_desc IN ( 'FULL', 'BULK_LOGGED' )
) AS a
    ON d.database_id = a.database_id

--SQL 2012+
LEFT OUTER JOIN (
    SELECT database_id,
           CASE
               WHEN database_state_desc IS NOT NULL
                    AND last_received_time IS NULL THEN 'PRIMARY '
               WHEN database_state_desc IS NOT NULL
                    AND last_received_time IS NOT NULL THEN 'SECONDARY'
               ELSE NULL
           END AS "Replica_Role"
    FROM sys.dm_hadr_database_replica_states
) AS dm
    ON dm.database_id = a.database_id
WHERE database_name NOT IN ( 'model', 'tempdb' )
      AND NOT (backuptype = 'transaction log' AND recovery_model_desc = 'SIMPLE')
GROUP BY database_name,
         backuptype,
         d.recovery_model_desc,
         d.state_desc,
         d.is_read_only,
         dm.Replica_Role
ORDER BY backuptype,
         recovery_model_desc,
         database_name ASC;
GO

/*
--for SQL 2000 and above
select distinct 
	  database_name	= d.name 
	, a.backuptype	
	, RecoveryModel	=	databasepropertyex(d.name, 'Recovery')  
	, BackupDate	=	Max(a.backup_finish_date)  
	from master.dbo.sysdatabases d
	left outer join 
	(		select distinct 
			database_name
			, backuptype = case type	WHEN 'D' then 'Database'
									WHEN 'I' then 'Differential database backup'
									WHEN 'L' then 'Transaction Log'
									WHEN 'F' then 'File or filegroup'
									WHEN 'G' then 'Differential file'
									WHEN 'P' then 'Partial'
									WHEN 'Q' then 'Differential partial' END
			, backup_finish_date	=	MAX(backup_finish_date)  	
			from msdb.dbo.backupset bs							
		 group by Database_name, type
		 UNION 
		 select distinct
			  d.name
			, backuptype = 'Database'
			, null
			FROM master.dbo.sysdatabases d
		 UNION
		 select distinct
			  d.name
			, backuptype = 'Transaction Log'
			, null
		  FROM master.dbo.sysdatabases d
		  where databasepropertyex(d.name, 'Recovery') in ('FULL', 'BULK_LOGGED')
  ) a
	on d.name = a.database_name
 group by d.name , backuptype ,	databasepropertyex(d.name, 'Recovery')
order by backuptype, RecoveryModel, BackupDate asc
 */

--granular backup history
SELECT TOP 1000 bs.database_name,
                CASE
                    WHEN bs.type = 'D'
                         AND bs.is_copy_only = 0 THEN 'Full Database'
                    WHEN bs.type = 'D'
                         AND bs.is_copy_only = 1 THEN 'Full Copy-Only Database'
                    WHEN bs.type = 'I' THEN 'Differential database backup'
                    WHEN bs.type = 'L' THEN 'Transaction Log'
                    WHEN bs.type = 'F' THEN 'File or filegroup'
                    WHEN bs.type = 'G' THEN 'Differential file'
                    WHEN bs.type = 'P' THEN 'Partial'
                    WHEN bs.type = 'Q' THEN 'Differential partial'
                END + ' Backup' AS "backuptype",
                bs.recovery_model,
                bs.backup_start_date AS "BackupStartDate",
                bs.backup_finish_date AS "BackupFinishDate",
                bf.physical_device_name AS "LatestBackupLocation",
                bs.backup_size / 1024. / 1024. AS "backup_size_mb",
                bs.compressed_backup_size / 1024. / 1024. AS "compressed_backup_size_mb",
                database_backup_lsn, -- For tlog and differential backups, this is the checkpoint_lsn of the FULL backup it is based on. 
                checkpoint_lsn,
                begins_log_chain
FROM msdb.dbo.backupset AS bs
LEFT OUTER JOIN msdb.dbo.backupmediafamily AS bf
    ON bs.media_set_id = bf.media_set_id
WHERE bs.backup_start_date > DATEADD (MONTH, -1, GETDATE ()) --only look at last month
--and database_name = 'w' --optionally filter by database
ORDER BY bs.database_name ASC,
         bs.backup_start_date DESC;



/*
  --Latest Restore
 select d.name, Latest_Restore = max(restore_date)
	from sys.databases d
	LEFT OUTER JOIN msdb.dbo.restorehistory rh on d.name = rh.destination_database_name
	group by d.name
	order by Latest_Restore desc

*/


--Look for backups to NUL, a sign that someone doesn't know what they're doing to the tlog. (Probably VEEAM. Bad VEEAM.)
--This is bad. Backup to NUL is just truncating the log without backing up the log, breaking the tlog chain. Any subsequent tlog backups are broken until a FULL backup restarts a valid chain.
--Do not allow VEEAM or other VSS-based backup solutions to do backups to NUL. 
--In VEEAM, this is somewhere near the "application aware backups" or similar settings menu in various settings. Disable this. 
SELECT bs.database_name,
       CASE
           WHEN bs.type = 'D'
                AND bs.is_copy_only = 0 THEN 'Full Database'
           WHEN bs.type = 'D'
                AND bs.is_copy_only = 1 THEN 'Full Copy-Only Database'
           WHEN bs.type = 'I' THEN 'Differential database backup'
           WHEN bs.type = 'L' THEN 'Transaction Log'
           WHEN bs.type = 'F' THEN 'File or filegroup'
           WHEN bs.type = 'G' THEN 'Differential file'
           WHEN bs.type = 'P' THEN 'Partial'
           WHEN bs.type = 'Q' THEN 'Differential partial'
       END + ' Backup' AS "backuptype",
       bs.recovery_model,
       bs.backup_start_date AS "BackupStartDate",
       bs.backup_finish_date AS "BackupFinishDate",
       bf.physical_device_name AS "LatestBackupLocation",
       bs.backup_size / 1024. / 1024. AS "backup_size_mb",
       bs.compressed_backup_size / 1024. / 1024. AS "compressed_backup_size_mb",
       database_backup_lsn, -- For tlog and differential backups, this is the checkpoint_lsn of the FULL backup it is based on. 
       checkpoint_lsn,
       begins_log_chain
FROM msdb.dbo.backupset AS bs
LEFT OUTER JOIN msdb.dbo.backupmediafamily AS bf
    ON bs.media_set_id = bf.media_set_id
WHERE bf.physical_device_name = 'NUL'
ORDER BY bs.database_name ASC,
         bs.backup_start_date DESC;
