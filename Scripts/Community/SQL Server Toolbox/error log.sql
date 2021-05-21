--#TODO: review string filters at bottom.
--Can execute in a multiserver query
--Execute in Grid mode
USE tempdb;
GO
SELECT SYSDATETIMEOFFSET ();
DECLARE @oldestdate AS DATE,
        @now        AS DATETIME2(0);
SELECT @oldestdate = DATEADD (WEEK, -5, SYSDATETIME ()),
       @now = SYSDATETIME (); --Filter the time frame of the logs.

SELECT 'Getting errors since ' + CAST(@oldestdate AS VARCHAR(30));

--Get list of logs associated with the SQL Server (by default is 7, probably need more!) 
CREATE TABLE #SQLErrorLogList (
    LogNumber  INT          NOT NULL,
    LogEndDate DATETIME2(0) NOT NULL,
    LogSize_b  BIGINT       NOT NULL
);
CREATE NONCLUSTERED INDEX IDX_CL_ell
ON #SQLErrorLogList (LogNumber)
INCLUDE (LogEndDate);

INSERT INTO #SQLErrorLogList
EXEC sys.sp_enumerrorlogs;

--error messages in current log
CREATE TABLE #readerrorlog (
    LogDate        DATETIME      NOT NULL,
    LogProcessInfo VARCHAR(255)  NOT NULL,
    LogMessageText VARCHAR(1500) NOT NULL
);

CREATE CLUSTERED INDEX IDX_CL_rel ON #readerrorlog (LogDate);

DECLARE @lognumber     INT = 0,
        @endoflogfiles BIT = 0,
        @maxlognumber  INT = 0;

SELECT @maxlognumber = MAX (LogNumber)
FROM #SQLErrorLogList;
WHILE (
    ((SELECT LogEndDate FROM #SQLErrorLogList WHERE @lognumber = LogNumber) > @oldestdate)
    AND @lognumber <= @maxlognumber
)
BEGIN

    INSERT INTO #readerrorlog
    EXEC master.dbo.xp_readerrorlog @lognumber, --current log file
                                    1,          --SQL Error Log
                                    N'',        --search string 1, must be unicode. Leave empty on purpose, as we do filtering later on.
                                    N'',        --search string 2, must be unicode. Leave empty on purpose, as we do filtering later on.
                                    @oldestdate,
                                    @now,       --time filter. Should be @oldestdate < @now
                                    N'desc';    --sort

    --print 'including lognumber ' + str(@lognumber)

    SET @lognumber = @lognumber + 1;
END;
GO

CREATE NONCLUSTERED INDEX IDX_NC_rel
ON #readerrorlog (LogDate DESC, LogMessageText)
INCLUDE (LogProcessInfo);

GO
--order of servers in a multiserver query is not determinant

--Raw error list
SELECT *
FROM #readerrorlog
WHERE 1 = 1
      AND (
          LogMessageText LIKE '%error%'
          OR LogMessageText LIKE '%failure%'
          OR LogMessageText LIKE '%failed%'
          OR LogMessageText LIKE '%corrupt%'
      )
      AND LogMessageText NOT LIKE '%without errors%'
      AND LogMessageText NOT LIKE '%returned no errors%'
      AND LogMessageText NOT LIKE 'Registry startup parameters:%'
      AND LogMessageText NOT LIKE '%informational%'
      AND LogMessageText NOT LIKE '%found 0 errors%'
ORDER BY LogDate DESC;

--Aggregate error counts
SELECT LogMessageText,
       LogProcessInfo,
       COUNT (LogDate) AS "ErrorCount",
       MAX (LogDate) AS "MostRecentOccurrence"
FROM #readerrorlog
WHERE 1 = 1
      AND (
          LogMessageText LIKE '%error%'
          OR LogMessageText LIKE '%failure%'
          OR LogMessageText LIKE '%failed%'
          OR LogMessageText LIKE '%corrupt%'
      )
      AND LogMessageText NOT LIKE '%without errors%'
      AND LogMessageText NOT LIKE '%returned no errors%'
      AND LogMessageText NOT LIKE 'Registry startup parameters:%'
      AND LogMessageText NOT LIKE '%informational%'
      AND LogMessageText NOT LIKE '%found 0 errors%'
GROUP BY LogMessageText,
         LogProcessInfo
ORDER BY COUNT (LogDate) DESC,
         MAX (LogDate) DESC;

SELECT LogDate AS "Reboots"
FROM #readerrorlog
WHERE LogMessageText LIKE 'Registry startup parameters:%'
ORDER BY LogDate DESC;
GO

DROP TABLE #readerrorlog;
DROP TABLE #SQLErrorLogList;