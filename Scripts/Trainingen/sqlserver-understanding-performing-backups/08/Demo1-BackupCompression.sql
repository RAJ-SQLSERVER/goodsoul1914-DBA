-- Delete everything from the backup history table
-- Do not do this on a production system!
USE msdb;
GO

DECLARE @today DATETIME = GETDATE ();
EXEC sp_delete_backuphistory @oldest_date = @today;
GO

-- Script to increase AdventureWorks size is at
-- http://bit.ly/1IHkiSg

-- Uncompressed backup
BACKUP DATABASE AdventureWorks
TO  DISK = N'D:\SQLBackups\ADV_Uncompressed.bak'
WITH INIT,
     NAME = N'AdventureWorks Uncompressed SSD';
GO

-- Compressed backup
BACKUP DATABASE AdventureWorks
TO  DISK = N'D:\SQLBackups\ADV_Compressed.bak'
WITH INIT,
     NAME = N'AdventureWorks Compressed SSD',
     COMPRESSION;
GO

SELECT DATEDIFF (s, backup_start_date, backup_finish_date) AS "Time",
       (CASE type
            WHEN N'D' THEN N'Full'
            WHEN N'I' THEN N'Diff'
            WHEN N'L' THEN N'Log'
            ELSE N'Unknown'
        END
       ) AS "Type",
       name,
       backup_size,
       compressed_backup_size
FROM msdb.dbo.backupset
ORDER BY backup_start_date;
GO

-- What about restore?
DROP DATABASE AdventureWorks;
GO

RESTORE DATABASE AdventureWorks
FROM DISK = N'D:\SQLBackups\ADV_Uncompressed.bak'
WITH REPLACE;
GO

DROP DATABASE AdventureWorks;
GO

RESTORE DATABASE AdventureWorks
FROM DISK = N'D:\SQLBackups\ADV_Compressed.bak'
WITH REPLACE;
GO

-- And now with the backup stored on a spinning drive

-- Uncompressed backup
BACKUP DATABASE AdventureWorks
TO  DISK = N'D:\SQLBackups\ADV_Uncompressed.bak'
WITH INIT,
     NAME = N'AdventureWorks2014 Uncompressed Spinning';
GO

-- Compressed backup
BACKUP DATABASE AdventureWorks
TO  DISK = N'D:\SQLBackups\ADV_Compressed.bak'
WITH INIT,
     NAME = N'AdventureWorks2014 Compressed Spinning',
     COMPRESSION;
GO

SELECT DATEDIFF (s, backup_start_date, backup_finish_date) AS "Time",
       (CASE type
            WHEN N'D' THEN N'Full'
            WHEN N'I' THEN N'Diff'
            WHEN N'L' THEN N'Log'
            ELSE N'Unknown'
        END
       ) AS "Type",
       name,
       backup_size,
       compressed_backup_size
FROM msdb.dbo.backupset
ORDER BY backup_start_date;
GO

-- What about restore?
DROP DATABASE AdventureWorks;
GO

RESTORE DATABASE AdventureWorks
FROM DISK = N'D:\SQLBackups\ADV_Uncompressed.bak'
WITH REPLACE;
GO

DROP DATABASE AdventureWorks;
GO

RESTORE DATABASE AdventureWorks2014
FROM DISK = N'D:\SQLBackups\ADV_Compressed.bak'
WITH REPLACE;
GO

-- More pronounced effect with spinning drives involved