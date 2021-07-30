/*========================================================================================================================

Description:	Display the last date & time of each backup type for each database
Scope:			Instance
Author:			Guy Glantser
Created:		03/10/2013
Last Updated:	03/10/2013
Notes:			Make sure there is an adequate backup strategy for each database

=========================================================================================================================*/

SELECT DatabaseName AS "DatabaseName",
       D AS "LastFullBackupDateTime",
       I AS "LastDifferentialBackupDateTime",
       L AS "LastLogBackupDateTime",
       F AS "LastFileOrFilegroupBackupDateTime",
       G AS "LastDifferentialFileBackupDateTime",
       P AS "LastPartialBackupDateTime",
       Q AS "LastDifferentialPartialBackupDateTime"
FROM (
    SELECT Databases.database_id AS "DatabaseId",
           Databases.name AS "DatabaseName",
           Backups.type AS "BackupType",
           MAX (Backups.backup_start_date) AS "LastBackupDateTime"
    FROM sys.databases AS Databases
    LEFT OUTER JOIN msdb.dbo.backupset AS Backups
        ON Databases.name = Backups.database_name
    GROUP BY Databases.database_id,
             Databases.name,
             Backups.type
) AS LastBackups
PIVOT (MIN(LastBackupDateTime)
FOR BackupType IN (D, I, L, F, G, P, Q)
) AS DatabaseLastBackups
ORDER BY DatabaseId ASC;
GO
