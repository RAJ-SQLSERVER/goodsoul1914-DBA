SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW vwNoRecentLogBackup
AS
SELECT SqlInstance,
       Name,
       LastLogBackup
FROM dbo.Databases
WHERE CheckDate >= DATEADD (DAY, -1, GETDATE ())
      AND (LastLogBackup <= DATEADD (DAY, -2, GETDATE ()))
	  AND RecoveryModel <> 'Simple'
      AND (SqlInstance LIKE 'GP%')
      AND (SqlInstance NOT IN ( 'GPWOSQL02', 'GPPIICIXSQL01', 'GPMVISION01', 'GPAX4HSQL01', 'GPAX4HHIS01' ))
      AND (Name NOT IN ( 'tempdb', 'model' ));
GO
