/*
	VIEW DATA IN THE ERRORLOG
*/

-- DROP TABLE #LogInfo

DECLARE @searchstring1 NVARCHAR(500) = N'';
DECLARE @searchstring2 NVARCHAR(500) = N'';
DECLARE @Limit INT = 10000;
DECLARE @FileList AS TABLE (
    subdirectory NVARCHAR(4000) NOT NULL,
    DEPTH        BIGINT         NOT NULL,
    [FILE]       BIGINT         NOT NULL
);

DECLARE @ErrorLog     NVARCHAR(4000),
        @ErrorLogPath NVARCHAR(4000);
SELECT @ErrorLog = CAST(SERVERPROPERTY (N'errorlogfilename') AS NVARCHAR(4000));
SELECT @ErrorLogPath = SUBSTRING (@ErrorLog, 1, LEN (@ErrorLog) - CHARINDEX (N'\', REVERSE (@ErrorLog))) + N'\';

INSERT INTO @FileList
EXEC xp_dirtree @ErrorLogPath, 0, 1;

DECLARE @NumberOfLogfiles INT;
SET @NumberOfLogfiles = (
    SELECT COUNT (*)
    FROM @FileList
    WHERE [@FileList].subdirectory LIKE N'ERRORLOG%'
);
-- SELECT @NumberOfLogfiles;
IF @Limit IS NOT NULL
   AND @NumberOfLogfiles > @Limit
    SET @NumberOfLogfiles = @Limit;
----------------------------------------------------------------------

CREATE TABLE #LogInfo (LogDate DATETIME, ProcessInfo NVARCHAR(500), ErrorText NVARCHAR(MAX));

DECLARE @p1 INT = 0;

WHILE @p1 < @NumberOfLogfiles
BEGIN
    -- P1 is the file number starting at 0
    DECLARE @p2 INT           = 1,				-- P2 1 for SQL logs, 2 for SQL Agent logs
            @p3 NVARCHAR(255) = @searchstring1, -- P3 is a value to search on
            @p4 NVARCHAR(255) = @searchstring2; -- P4 is another search value

    BEGIN TRY
        INSERT INTO #LogInfo
        EXEC sys.xp_readerrorlog @p1, @p2, @p3, @p4;
    END TRY
    BEGIN CATCH
        PRINT 'Error occurred processing file ' + CAST(@p1 AS VARCHAR(10));
    END CATCH;

    SET @p1 = @p1 + 1;
END;
GO


-- Example #1
SELECT *
FROM #LogInfo
WHERE ProcessInfo NOT IN ( 'Backup', 'Logon' )
ORDER BY LogDate DESC;
GO


-- Example #2 - has a login been used recently
SELECT UserList.UserName,
       MAX (CASE WHEN #LogInfo.ErrorText LIKE '%succeeded%' THEN LogDate ELSE NULL END) AS "LatestSuccess",
       MAX (CASE WHEN #LogInfo.ErrorText LIKE '%failed%' THEN LogDate ELSE NULL END) AS "LatestFailure"
FROM #LogInfo
CROSS APPLY (
    SELECT REPLACE (REPLACE (ErrorText, 'Login succeeded for user ''', ''), 'Login failed for user ''', '')
) AS RemoveFront(ErrorText)
CROSS APPLY (
    SELECT SUBSTRING (RemoveFront.ErrorText, 1, CHARINDEX ('''', RemoveFront.ErrorText) - 1)
) AS UserList(UserName)
WHERE #LogInfo.ProcessInfo = 'Logon'
      AND #LogInfo.ErrorText LIKE 'Login%'
GROUP BY UserList.UserName;
GO