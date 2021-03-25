USE DBA;
GO

IF OBJECT_ID ('tempdb.dbo.#SQLErrorLog') IS NOT NULL DROP TABLE #SQLErrorLog;
CREATE TABLE #SQLErrorLog (
    SQLInstance VARCHAR(100)   NOT NULL,
    LogDate     VARCHAR(20)    NOT NULL,
    ProcessInfo NVARCHAR(200)  NOT NULL,
    LogType     VARCHAR(20)    NULL,
    LogText     NVARCHAR(3999) NULL,
    [Count]       INT            NULL
);

INSERT INTO #SQLErrorLog (SQLInstance, LogDate, ProcessInfo, LogType, LogText, Count)
EXEC dbo.usp_GetSQLLogEntries @Group = 1, @UseExclusions = 1, @ExecSql = 1;
GO

SELECT *
FROM #SQLErrorLog
WHERE ProcessInfo NOT IN ( 'Sort Warnings', 'Missing Join Predicate', 'Hash Warning' )
ORDER BY LogDate DESC, [Count] DESC;
GO
