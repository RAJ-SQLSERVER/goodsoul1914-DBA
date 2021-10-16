DECLARE @iCount AS SMALLINT;

CREATE TABLE #CounterValues (Counter_name VARCHAR(50), Currentvalue INT, DateTimeOfCapture DATETIME);

SET @iCount = 1;

WHILE @iCount < 3
BEGIN
    INSERT INTO #CounterValues
    SELECT counter_name,
           cntr_value,
           GETDATE ()
    FROM sys.dm_os_performance_counters
    WHERE Counter_name IN ( 'Free list stalls/sec', 'Lazy writes/sec', 'Batch Requests/sec', 'SQL Compilations/sec',
                            'SQL Re-Compilations/sec', 'Cursor Requests/sec', 'Checkpoint pages/sec'
    )
          AND instance_name IN ( '', '_total' );

    WAITFOR DELAY '00:00:10';

    SET @iCount = @iCount + 1;
END;


DECLARE @cols AS NVARCHAR(MAX);
DECLARE @query AS NVARCHAR(MAX);


SET @cols = STUFF (
                (
                    SELECT DISTINCT ','
                                    + QUOTENAME (
                                          CONVERT (VARCHAR(40), LEFT(CONVERT (CHAR(40), DateTimeOfCapture, 109), 20))
                                      ) AS "DateTimeOfCapture"
                    FROM #CounterValues
                    ORDER BY DateTimeOfCapture ASC
                    FOR XML PATH (''), TYPE
                ).value ('.', 'NVARCHAR(MAX)'),
                1,
                1,
                ''
            );

PRINT @cols;
SET @query = N'SELECT  Counter_Name,' + @cols
             + N' from 
            (
				SELECT   Counter_Name, currentvalue, LEFT(CONVERT(CHAR(40),DateTimeOfCapture, 109) , 20) AS TimeOfCapture
				FROM #CounterValues
			) x
            PIVOT 
            (
                SUM(Currentvalue)
				FOR TimeOfCapture IN  (' + @cols + N')
            ) p ';


EXECUTE (@query);

--Returns detail rows for confirmation

SELECT Counter_name,
       Currentvalue,
       DateTimeOfCapture,
       LEFT(CONVERT (CHAR(40), DateTimeOfCapture, 109), 20) AS "FormattedDate"
FROM #CounterValues
ORDER BY Counter_name,
         DateTimeOfCapture;

DROP TABLE #CounterValues;