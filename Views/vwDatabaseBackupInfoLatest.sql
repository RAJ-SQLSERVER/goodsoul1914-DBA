WITH BackupInfo
AS (
    SELECT CheckDate,
           SqlInstance,
           Name,
           RecoveryModel,
           LogReuseWaitStatus,
           LastFullBackup AS LastBackup,
           'Full' AS BackupType
    FROM DBA.dbo.Databases
    WHERE LastFullBackup <= DATEADD (DAY, -1, CheckDate)
    UNION
    SELECT CheckDate,
           SqlInstance,
           Name,
           RecoveryModel,
           LogReuseWaitStatus,
           LastLogBackup AS LastBackup,
           'Log' AS BackupType
    FROM DBA.dbo.Databases
    WHERE RecoveryModel = 'Full'
          AND LastLogBackup <= DATEADD (HOUR, -2, CheckDate)
)
SELECT BackupInfo.SqlInstance,
       Name,
       BackupInfo.RecoveryModel,
       BackupInfo.LogReuseWaitStatus,
       BackupInfo.LastBackup,
       BackupInfo.BackupType
FROM BackupInfo
WHERE CheckDate >= DATEADD (DAY, -1, GETDATE ())
      AND Name NOT IN ( 'tempdb', 'model', 'ReportServerTempDB' )
      AND SqlInstance LIKE ('GP%')
      AND SqlInstance NOT IN ( 'GPMVISION01', 'GPWOSQL02', 'GPAX4HHIS01', 'GPHIXLS03', 'GPHIXDWHLS01', 'GPAX4HSQL01' )
