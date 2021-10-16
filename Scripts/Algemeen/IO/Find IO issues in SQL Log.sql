SET NOCOUNT ON;

IF OBJECT_ID ('tempdb..#errorLogs') IS NOT NULL DROP TABLE #errorLogs;

IF OBJECT_ID ('tempdb..#logData') IS NOT NULL DROP TABLE #logData;

DECLARE @maxLog    INT,
        @searchStr VARCHAR(256),
        @startDate DATETIME;

CREATE TABLE #errorLogs (LogID INT, LogDate DATETIME, LogSize BIGINT);

CREATE TABLE #logData (LogDate DATETIME, ProcInfo VARCHAR(64), LogText VARCHAR(MAX));

INSERT INTO #errorLogs
EXEC sys.sp_enumerrorlogs;

SELECT @maxLog = MAX (LogID)
FROM #errorLogs;

--WHERE [LogDate] <= @startDate 
---ORDER BY [LogDate] DESC; 
WHILE @maxLog >= 0
BEGIN
    INSERT INTO #logData
    EXEC sys.sp_readerrorlog @maxLog, 1, @searchStr;

    SET @maxLog = @maxLog - 1;
END;

-- 
SELECT *
FROM (
    SELECT LogDate,
           SUBSTRING (
               REPLACE (LogText, 'SQL Server has encountered ', ''),
               0,
               CHARINDEX ('o', REPLACE (LogText, 'SQL Server has encountered ', ''))
           ) AS "Ocurrences",
           REPLACE (
               SUBSTRING (
                   SUBSTRING (LogText, CHARINDEX ('[', LogText), 100),
                   0,
                   CHARINDEX ('\', SUBSTRING (LogText, CHARINDEX ('[', LogText), 100))
               ),
               '[',
               ''
           ) AS "DriveLetter",
           SUBSTRING (
               SUBSTRING (
                   SUBSTRING (LogText, CHARINDEX ('[', LogText), 500),
                   CHARINDEX ('\', SUBSTRING (LogText, CHARINDEX ('[', LogText), 500)),
                   500
               ),
               0,
               CHARINDEX (
                   '(',
                   SUBSTRING (
                       SUBSTRING (LogText, CHARINDEX ('[', LogText), 500),
                       CHARINDEX ('\', SUBSTRING (LogText, CHARINDEX ('[', LogText), 500)),
                       500
                   )
               )
           ) AS "datafile"
    FROM #logData
    WHERE LogText LIKE '%I/O%'
) AS x
WHERE x.DriveLetter <> ''
ORDER BY 1 DESC;
