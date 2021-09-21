IF OBJECT_ID ('tempdb..#BatchResponses') IS NOT NULL
    DROP TABLE #BatchResponses;
GO

SELECT *
INTO #BatchResponses
FROM sys.dm_os_performance_counters
WHERE object_name LIKE '%Batch Resp Statistics%'
      AND instance_name IN ( 'Elapsed Time:Requests', 'Elapsed Time:Total(ms)' );
GO

SELECT CASE
           WHEN bcount.cntr_value = 0 THEN 0
           ELSE btime.cntr_value / bcount.cntr_value
       END AS "AvgRunTimeMS",
       CAST(bcount.cntr_value AS BIGINT) AS "StatementCount",
       bcount.counter_name,
       btime.cntr_value AS "TotalElapsedTimeMS",
       CAST((100.0 * btime.cntr_value / SUM (btime.cntr_value) OVER ()) AS DECIMAL(5, 2)) AS "ExecutionTimePercent",
       CAST((100.0 * bcount.cntr_value / SUM (bcount.cntr_value) OVER ()) AS DECIMAL(5, 2)) AS "ExecutionCountPercent"
FROM (
    SELECT *
    FROM #BatchResponses
    WHERE instance_name = 'Elapsed Time:Requests'
) AS bcount
JOIN (
    SELECT *
    FROM #BatchResponses
    WHERE instance_name = 'Elapsed Time:Total(ms)'
) AS btime
    ON bcount.counter_name = btime.counter_name
ORDER BY bcount.counter_name ASC;