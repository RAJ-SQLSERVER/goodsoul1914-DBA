SET NOCOUNT ON;

-- step_1: Declare threshold percentage limit
DECLARE @threshold INT = 5;

-- step_2: Create temp table and insert sqlperf data into it
CREATE TABLE #tlogtables
(
    databaseName sysname NOT NULL,
    logSize DECIMAL(18, 5) NOT NULL,
    logUsed DECIMAL(18, 5) NOT NULL,
    status INT NOT NULL
);

INSERT INTO #tlogtables
EXECUTE ('DBCC SQLPERF(LOGSPACE)');

-- step_3: get T-logs exceeding threshold size for a specific database
SELECT databaseName,
       logSize,
       logUsed,
       status
FROM #tlogtables
WHERE logUsed >= (@threshold)
      --AND databaseName = 'DbName';

-- step_4: send email if a T-log exceeds threshold
IF OBJECT_ID('tempdb..#tlogtables') IS NOT NULL
BEGIN
    EXEC msdb.dbo.sp_send_dbmail @profile_name = 'WINSRV1',
                                 @body = 'Log threshold reached',
                                 @recipients = 'mboomaars@gmail.com',
                                 @subject = 'ALERT: ... ';
END;

DROP TABLE #tlogtables;
SET NOCOUNT OFF;