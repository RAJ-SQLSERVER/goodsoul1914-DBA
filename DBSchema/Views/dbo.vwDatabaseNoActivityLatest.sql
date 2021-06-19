SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW vwDatabaseNoActivityLatest
AS
WITH DatabaseInfo
AS (
    SELECT CheckDate,
           SqlInstance,
           Name,
           ActiveConnections,
           ROUND (SizeMB, 2) AS SizeMB,
           ROUND (DataSpaceUsage / 1024, 2) AS DataSpaceUsageMB,
           ROUND (IndexSpaceUsage / 1024, 2) AS IndexSpaceUsageMB,
           SpaceAvailable - (LAG (SpaceAvailable) OVER (PARTITION BY SqlInstance, Name ORDER BY CheckDate)) AS SpaceAvailableDiffKB,
           CreateDate
    FROM DBA.dbo.Databases
)
SELECT DatabaseInfo.SqlInstance,
       Name,
       DatabaseInfo.SizeMB,
       DatabaseInfo.DataSpaceUsageMB,
       DatabaseInfo.IndexSpaceUsageMB,
       DatabaseInfo.CreateDate
FROM DatabaseInfo
WHERE Name NOT IN ( 'master', 'model', 'msdb', 'tempdb', 'SSISDB', 'ReportServer', 'ReportServerTempDB' )
      AND SqlInstance NOT IN ( 'GPMVISION01', 'GPPCSQL01', 'GPAX4HHIS01' )
      AND DatabaseInfo.SpaceAvailableDiffKB = 0
      AND DatabaseInfo.ActiveConnections = 0
      AND DatabaseInfo.CreateDate <= DATEADD (MONTH, -1, GETDATE ())
      AND DatabaseInfo.CheckDate >= DATEADD (DAY, -1, GETDATE ())
GO
