SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE usp_DatabaseBackups @database   VARCHAR(256) = 'all',
                                     @backupType CHAR(1)      = 'A'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @sqlCommand VARCHAR(MAX);

    SET @sqlCommand = '
    WITH MostRecentBackups
	AS(
		SELECT 
			database_name AS [Database],
			MAX(bus.backup_finish_date) AS LastBackupTime,
			CASE bus.type
				WHEN ''D'' THEN ''Full''
				WHEN ''I'' THEN ''Differential''
				WHEN ''L'' THEN ''Transaction Log''
			END AS Type
		FROM msdb.dbo.backupset bus
		WHERE bus.type <> ''F''
		GROUP BY bus.database_name,bus.type
	),
	BackupsWithSize
	AS(
		SELECT 
			mrb.*, 
			(SELECT TOP 1 CONVERT(DECIMAL(10,4), b.compressed_backup_size/1024/1024/1024) AS backup_size FROM msdb.dbo.backupset b WHERE [Database] = b.database_name AND LastBackupTime = b.backup_finish_date) AS [Backup Size],
			(SELECT TOP 1 DATEDIFF(s, b.backup_start_date, b.backup_finish_date) FROM msdb.dbo.backupset b WHERE [Database] = b.database_name AND LastBackupTime = b.backup_finish_date) AS [Seconds],
			(SELECT TOP 1 b.media_set_id FROM msdb.dbo.backupset b WHERE [Database] = b.database_name AND LastBackupTime = b.backup_finish_date) AS media_set_id
		FROM MostRecentBackups mrb
	)

	SELECT 
		d.name AS [Database],
      	d.state_desc AS State,
      	d.recovery_model_desc AS [Recovery Model],';

    IF @backupType = 'F'
       OR @backupType = 'A'
        SET @sqlCommand += '
      bf.LastBackupTime AS [Last Full],
      DATEDIFF(DAY,bf.LastBackupTime,GETDATE()) AS [Time Since Last Full (in Days)],
      bf.[Backup Size] AS [Full Backup Size],
      bf.Seconds AS [Full Backup Seconds to Complete],
      (SELECT TOP 1 bmf.physical_device_name FROM msdb.dbo.backupmediafamily bmf WHERE bmf.media_set_id = bf.media_set_id AND bmf.device_type = 2) AS [Full Backup Path]
      ' ;

    IF @backupType = 'A' SET @sqlCommand += ',';

    IF @backupType = 'D'
       OR @backupType = 'A'
        SET @sqlCommand += '
	  bd.LastBackupTime AS [Last Differential],
      DATEDIFF(DAY,bd.LastBackupTime,GETDATE()) AS [Time Since Last Differential (in Days)],
      bd.[Backup Size] AS [Differential Backup Size],
      bd.Seconds AS [Diff Backup Seconds to Complete],
      (SELECT TOP 1 bmf.physical_device_name FROM msdb.dbo.backupmediafamily bmf WHERE bmf.media_set_id = bd.media_set_id AND bmf.device_type = 2) AS [Diff Backup Path]
      ' ;

    IF @backupType = 'A' SET @sqlCommand += ',';

    IF @backupType = 'L'
       OR @backupType = 'A'
        SET @sqlCommand += '
	  bt.LastBackupTime AS [Last Transaction Log],
      DATEDIFF(MINUTE,bt.LastBackupTime,GETDATE()) AS [Time Since Last Transaction Log (in Minutes)],
      bt.[Backup Size] AS [Transaction Log Backup Size],
      bt.Seconds AS [TLog Backup Seconds to Complete],
      (SELECT TOP 1 bmf.physical_device_name FROM msdb.dbo.backupmediafamily bmf WHERE bmf.media_set_id = bt.media_set_id AND bmf.device_type = 2) AS [Transaction Log Backup Path]
	  ' ;

    SET @sqlCommand += '
	FROM sys.databases d
	LEFT JOIN BackupsWithSize bf ON (d.name = bf.[Database] AND (bf.Type = ''Full'' OR bf.Type IS NULL))
	LEFT JOIN BackupsWithSize bd ON (d.name = bd.[Database] AND (bd.Type = ''Differential'' OR bd.Type IS NULL))
	LEFT JOIN BackupsWithSize bt ON (d.name = bt.[Database] AND (bt.Type = ''Transaction Log'' OR bt.Type IS NULL))
	WHERE d.name <> ''tempdb'' AND d.source_database_id IS NULL';

    IF LOWER (@database) <> 'all'
        SET @sqlCommand += ' AND d.name =' + CHAR (39) + @database + CHAR (39);

    EXEC (@sqlCommand);
END;
GO