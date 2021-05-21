USE master;
GO

SET NOCOUNT ON;
GO

-- SECTION 1: Create a linked server
-- One of the constants to be set before running the script [needs to be in its own batch!]
DECLARE @Server_OLD sysname = '<<must be provided>>'; -- Instance where source database is

IF EXISTS (SELECT * FROM sys.servers WHERE name = 'SourceSRV')
BEGIN;
    EXEC sys.sp_dropserver 'SourceSRV';
END;

-- Create temporary linked server name to point to source server. 
-- (This prevents a lot of dynamic SQL!)
EXEC sys.sp_addlinkedserver 'SourceSRV', '', 'SQLNCLI', @Server_OLD;
GO

-- SECTION 2: Restore a copy of the database, up to the requested point in time
-- Constants to be set before running the script
DECLARE @DB_name_OLD sysname = '<<must be provided>>',     -- Name of source database to copy
        @DB_name_NEW sysname = '<<must be provided>>',     -- Name of destination database to create
        @DataFileName1 sysname = '<<must be provided>>',   -- Logical filename of primary data file (must match original)
        @DataFilePath1 sysname = '<<must be provided>>',   -- Path and filename where to create primary data file
        @DataFileName2 sysname = NULL,                     -- Logical filename of secondary data file (must match original) - use NULL for n/a
        @DataFilePath2 sysname = NULL,                     -- Path and filename where to create secondary data file
        @LogFileName sysname = '<<must be provided>>',     -- Logical filename of log file (must match original)
        @LogFilePath sysname = '<<must be provided>>',     -- Path and filename where to create log file
        @recovery_point DATETIME = '<<must be provided>>'; -- Target date and time for the point-in-time recovery (please use yyyy-mm-ddThh:mm:ss notation)

-- Variables used in the script
DECLARE @sql NVARCHAR(MAX),
        @physical_device_name NVARCHAR(260),
        @full_backup_time DATETIME,
        @diff_backup_time DATETIME,
        @last_log_time DATETIME,
        @message NVARCHAR(MAX);


-- Step 1: Find last full backup before recovery point, then restore it
SET @sql
    = N'RESTORE DATABASE @DB_name_NEW
FROM DISK = @physical_device_name
WITH FILE = 1, NORECOVERY, NOUNLOAD, REPLACE, STATS = 5, STOPAT = @recovery_point,
     MOVE N''' + @DataFileName1 + N''' TO N''' + @DataFilePath1 + N''',' + COALESCE('
     MOVE N''' + @DataFileName2 + ''' TO N''' + @DataFilePath2 + ''',', '') + N'
     MOVE N''' + @LogFileName + N''' TO N''' + @LogFilePath + N''';';

SELECT TOP (1)
       @physical_device_name = bmf.physical_device_name,
       @full_backup_time = bs.backup_start_date
FROM SourceSRV.msdb.dbo.backupset AS bs
    INNER JOIN SourceSRV.msdb.dbo.backupmediafamily AS bmf
        ON bmf.media_set_id = bs.media_set_id
WHERE bs.database_name = @DB_name_OLD
      AND bs.type = 'D'
      AND bs.backup_start_date < @recovery_point
ORDER BY bs.backup_start_date DESC;

SET @message
    = N'Starting restore of full backup file ' + @physical_device_name + N', taken '
      + CONVERT(NVARCHAR(30), @full_backup_time, 120);
RAISERROR(@message, 0, 1) WITH NOWAIT;
EXEC sys.sp_executesql @sql,
                       N'@DB_name_NEW sysname, @physical_device_name nvarchar(260), @recovery_point datetime',
                       @DB_name_NEW,
                       @physical_device_name,
                       @recovery_point;


-- Step 2: Find last differential backup before recovery point, then restore it
SET @sql
    = N'RESTORE DATABASE @DB_name_NEW
FROM DISK = @physical_device_name
WITH FILE = 1, NORECOVERY, NOUNLOAD, REPLACE, STATS = 5, STOPAT = @recovery_point;';

SELECT TOP (1)
       @physical_device_name = bmf.physical_device_name,
       @diff_backup_time = bs.backup_start_date
FROM SourceSRV.msdb.dbo.backupset AS bs
    INNER JOIN SourceSRV.msdb.dbo.backupmediafamily AS bmf
        ON bmf.media_set_id = bs.media_set_id
WHERE bs.database_name = @DB_name_OLD
      AND bs.type = 'I'
      AND bs.backup_start_date >= @full_backup_time
      AND bs.backup_start_date < @recovery_point
ORDER BY bs.backup_start_date DESC;

IF @@ROWCOUNT > 0
BEGIN;
    SET @message
        = N'Starting restore of differential backup file ' + @physical_device_name + N', taken '
          + CONVERT(NVARCHAR(30), @diff_backup_time, 120);
    RAISERROR(@message, 0, 1) WITH NOWAIT;
    EXEC sys.sp_executesql @sql,
                           N'@DB_name_NEW sysname, @physical_device_name nvarchar(260), @recovery_point datetime',
                           @DB_name_NEW,
                           @physical_device_name,
                           @recovery_point;
END;


-- Step 3: Find all log backups taken after the just-restored differential or full backup; restore them until we are past the recovery point
SET @sql
    = N'RESTORE LOG @DB_name_NEW
FROM DISK = @physical_device_name
WITH FILE = 1, NORECOVERY, NOUNLOAD, REPLACE, STATS = 5, STOPAT = @recovery_point;';

DECLARE c CURSOR LOCAL FAST_FORWARD READ_ONLY TYPE_WARNING FOR
SELECT bmf.physical_device_name,
       bs.backup_start_date
FROM SourceSRV.msdb.dbo.backupset AS bs
    INNER JOIN SourceSRV.msdb.dbo.backupmediafamily AS bmf
        ON bmf.media_set_id = bs.media_set_id
WHERE bs.database_name = @DB_name_OLD
      AND bs.type = 'L'
      AND bs.backup_start_date >= COALESCE(@diff_backup_time, @full_backup_time)
ORDER BY bs.backup_start_date ASC;

OPEN c;

FETCH NEXT FROM c
INTO @physical_device_name,
     @last_log_time;

WHILE @@FETCH_STATUS = 0
BEGIN;
    SET @message
        = N'Starting restore of log backup file ' + @physical_device_name + N', taken '
          + CONVERT(NVARCHAR(30), @last_log_time, 120);
    RAISERROR(@message, 0, 1) WITH NOWAIT;
    EXEC sys.sp_executesql @sql,
                           N'@DB_name_NEW sysname, @physical_device_name nvarchar(260), @recovery_point datetime',
                           @DB_name_NEW,
                           @physical_device_name,
                           @recovery_point;

    IF @last_log_time > @recovery_point
        BREAK;

    FETCH NEXT FROM c
    INTO @physical_device_name,
         @last_log_time;
END;

CLOSE c;
DEALLOCATE c;


-- Step 4: Perform recovery
SET @sql = N'RESTORE DATABASE @DB_name_NEW
WITH RECOVERY;';

RAISERROR('Starting recovery', 0, 1) WITH NOWAIT;
EXEC sys.sp_executesql @sql,
                       N'@DB_name_NEW sysname, @physical_device_name nvarchar(260), @recovery_point datetime',
                       @DB_name_NEW,
                       @physical_device_name,
                       @recovery_point;
GO

-- SECTION 3: Remove the temporary linked server that we created earlier
EXEC sys.sp_dropserver 'SourceSRV';
GO