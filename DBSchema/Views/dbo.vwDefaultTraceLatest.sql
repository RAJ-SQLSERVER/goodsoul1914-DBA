SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW vwDefaultTraceLatest
AS
SELECT StartTime,
       SqlInstance,
       LoginName,
       HostName,
       DatabaseName,
       ApplicationName,
       TextData
FROM dbo.DefaultTraceEntries
WHERE (ApplicationName NOT LIKE 'dbatools%')
      AND (ApplicationName NOT LIKE 'oversight')
      AND (ApplicationName NOT LIKE 'Red Gate Software%')
      AND (TextData NOT LIKE '%DBCC %')
      AND (TextData NOT LIKE 'No STATS:%')
      AND (TextData NOT LIKE 'Login failed%')
      AND (TextData NOT LIKE 'dbcc show_stat%')
      AND (TextData NOT LIKE 'RESTORE DATABASE%')
      AND StartTime >= DATEADD (D, -1, GETDATE ());
GO
