SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW vwErrorLogLatest
AS
SELECT SqlInstance,
       Text,
       COUNT (*) AS Count
FROM dbo.ErrorLogs
WHERE (Text NOT LIKE 'Login succeeded for %')
      AND (Text NOT LIKE 'Log was backed up%')
      AND (Text NOT LIKE 'Log was restored.%')
      AND (Text NOT LIKE 'BACKUP DATABASE successfully%')
      AND (Text NOT LIKE 'RESTORE DATABASE successfully%')
      AND (Text NOT LIKE 'Database backed up.%')
      AND (Text NOT LIKE 'Database was restored%')
      AND (Text NOT LIKE 'Restore is complete %')
      AND (Text NOT LIKE '%without errors%')
      AND (Text NOT LIKE '%0 errors%')
      AND (Text NOT LIKE 'Starting up database%')
      AND (Text NOT LIKE 'Parallel redo is %')
      AND (Text NOT LIKE 'This instance of SQL Server%')
      AND (Text NOT LIKE 'Error: %, Severity:%')
      AND (Text NOT LIKE 'Setting database option %')
      AND (Text NOT LIKE 'Recovery is writing a checkpoint%')
      AND (Text NOT LIKE 'Process ID % was killed by hostname %')
      AND (Text NOT LIKE 'The database % is marked RESTORING and is in a state that does not allow recovery to be run.')
      AND (Text NOT LIKE '%informational message only%')
      AND (Text NOT LIKE 'I/O is frozen on database%')
      AND (Text NOT LIKE 'I/O was resumed on database%')
      AND (Text NOT LIKE 'The error log has been reinitialized%')
      AND LogDate >= DATEADD (D, -1, GETDATE ())
GROUP BY SqlInstance,
         Text
GO
