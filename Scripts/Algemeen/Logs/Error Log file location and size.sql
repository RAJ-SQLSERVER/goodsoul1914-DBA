/*  Query SQL Server's Error Log file location and size */

DECLARE @logfiles TABLE (FilArchive# TINYINT, Date DATETIME, LogFileSizeB BIGINT);

INSERT @logfiles
EXEC xp_enumerrorlogs;

SELECT FilArchive#,
       Date,
       CONVERT (VARCHAR(50), CAST(SUM (CAST(LogFileSizeB AS FLOAT)) / 1024 / 1024 AS DECIMAL(10, 4))) + ' MB' AS "SizeMB"
FROM @logfiles
GROUP BY FilArchive#,
         Date,
         LogFileSizeB;

-- to identify error log file location
SELECT SERVERPROPERTY ('ErrorLogFileName') AS "Error_Log_Location";
