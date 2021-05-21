SELECT T1.name AS DatabaseName,
       COALESCE(CONVERT(VARCHAR(12), MAX(T2.backup_finish_date), 101), 'Not Yet Taken') AS LastBackUpTaken,
       COALESCE(CONVERT(VARCHAR(12), MAX(T2.user_name), 101), 'NA') AS UserName
FROM sys.sysdatabases AS T1
    LEFT OUTER JOIN msdb.dbo.backupset AS T2
        ON T2.database_name = T1.name
GROUP BY T1.name
ORDER BY T1.name;