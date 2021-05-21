-- Backup Characteristics
---------------------------------------------------------------------------------------------------
SELECT d.name,
       MAX(d.recovery_model) AS [Recovery Model],
       is_password_protected, --Backups Encrypted: 
       MAX(   CASE
                  WHEN type = 'D' THEN
                      backup_start_date
                  ELSE
                      NULL
              END
          ) AS [Last Full Database Backup],
       MAX(   CASE
                  WHEN type = 'L' THEN
                      backup_start_date
                  ELSE
                      NULL
              END
          ) AS [Last Transaction Log Backup],
       MAX(   CASE
                  WHEN type = 'I' THEN
                      backup_start_date
                  ELSE
                      NULL
              END
          ) AS [Last Differential Backup],
       DATEDIFF(   DAY,
                   MIN(CASE
                           WHEN type = 'L' THEN
                               backup_start_date
                           ELSE
                               0
                       END
                      ), --How Often are Transaction Logs Backed Up:
                   MAX(   CASE
                              WHEN type = 'L' THEN
                                  backup_start_date
                              ELSE
                                  0
                          END
                      )
               ) / NULLIF(SUM(   CASE
                                     WHEN type = 'I' THEN
                                         1
                                     ELSE
                                         0
                                 END
                             ), 0) AS [Logs BackUp count],
       SUM(   CASE
                  WHEN type = 'D' THEN
                      DATEDIFF(SECOND, backup_start_date, backup_finish_date)
                  ELSE
                      0
              END
          ) / NULLIF(SUM(   CASE
                                WHEN type = 'D' THEN
                                    1
                                ELSE
                                    0
                            END
                        ), 0) AS [Average Database Full Backup Time],
       SUM(   CASE
                  WHEN type = 'I' THEN
                      DATEDIFF(SECOND, backup_start_date, backup_finish_date)
                  ELSE
                      0
              END
          ) / NULLIF(SUM(   CASE
                                WHEN type = 'I' THEN
                                    1
                                ELSE
                                    0
                            END
                        ), 0) AS [Average Differential Backup Time],
       SUM(   CASE
                  WHEN type = 'L' THEN
                      DATEDIFF(SECOND, backup_start_date, backup_finish_date)
                  ELSE
                      0
              END
          ) / NULLIF(SUM(   CASE
                                WHEN type = 'L' THEN
                                    1
                                ELSE
                                    0
                            END
                        ), 0) AS [Average Log Backup Time],
       SUM(   CASE
                  WHEN type = 'F' THEN
                      DATEDIFF(SECOND, backup_start_date, backup_finish_date)
                  ELSE
                      0
              END
          ) / NULLIF(SUM(   CASE
                                WHEN type = 'F' THEN
                                    1
                                ELSE
                                    0
                            END
                        ), 0) AS [Average file/Filegroup Backup Time],
       SUM(   CASE
                  WHEN type = 'G' THEN
                      DATEDIFF(SECOND, backup_start_date, backup_finish_date)
                  ELSE
                      0
              END
          ) / NULLIF(SUM(   CASE
                                WHEN type = 'G' THEN
                                    1
                                ELSE
                                    0
                            END
                        ), 0) AS [Average Differential file Backup Time],
       SUM(   CASE
                  WHEN type = 'P' THEN
                      DATEDIFF(SECOND, backup_start_date, backup_finish_date)
                  ELSE
                      0
              END
          ) / NULLIF(SUM(   CASE
                                WHEN type = 'P' THEN
                                    1
                                ELSE
                                    0
                            END
                        ), 0) AS [Average partial Backup Time],
       SUM(   CASE
                  WHEN type = 'Q' THEN
                      DATEDIFF(SECOND, backup_start_date, backup_finish_date)
                  ELSE
                      0
              END
          ) / NULLIF(SUM(   CASE
                                WHEN type = 'Q' THEN
                                    1
                                ELSE
                                    0
                            END
                        ), 0) AS [Average Differential partial Backup Time],
       MAX(   CASE
                  WHEN type = 'D' THEN
                      backup_size
                  ELSE
                      0
              END
          ) AS [Database Full Backup Size],
       SUM(   CASE
                  WHEN type = 'L' THEN
                      backup_size
                  ELSE
                      0
              END
          ) / NULLIF(SUM(   CASE
                                WHEN type = 'L' THEN
                                    1
                                ELSE
                                    0
                            END
                        ), 0) AS [Average Transaction Log Backup Size],
       CASE
           WHEN SUM(backup_size - compressed_backup_size) <> 0 THEN
               'yes'
           ELSE
               'no'
       END AS [Backups Compressed]
FROM master.sys.databases AS d
    LEFT OUTER JOIN msdb.dbo.backupset AS b
        ON d.name = b.database_name
WHERE d.database_id NOT IN ( 2, 3 )
GROUP BY d.name,
         is_password_protected;
--HAVING 
--	  MAX(b.backup_finish_date) <= DATEADD(dd, -7, GETDATE()) ;