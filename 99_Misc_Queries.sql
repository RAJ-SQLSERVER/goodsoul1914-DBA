-------------------------------------------------------------------------------
-- Select all trace file entries and group them by day
-------------------------------------------------------------------------------  

SELECT SUBSTRING (CONVERT (NVARCHAR(10), LogDate, 120), 1, 10) AS LogDate,
       ProcessInfo,
       LogText,
       COUNT (*) AS Occurrence
FROM dbo.SQLLogging
WHERE LogType = 'Trace'
GROUP BY SUBSTRING (CONVERT (NVARCHAR(10), LogDate, 120), 1, 10),
         ProcessInfo,
         LogText
ORDER BY LogDate DESC,
         Occurrence DESC,
         ProcessInfo,
         LogText;
GO
