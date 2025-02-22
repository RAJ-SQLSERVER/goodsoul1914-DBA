--Collect CPU% for two minutes and alert if Average CPU usage > 50%

IF OBJECT_ID('tempdb..#TABLEHIGHCPU') IS NOT NULL
    DROP TABLE #TABLEHIGHCPU;

CREATE TABLE #TABLEHIGHCPU
(
    C1 INT,
    C2 INT
);

DECLARE @i INT = 1;
WHILE @i <= 12 -- Set Run time here; Value 6= 1 min (6x10sec)
BEGIN
    INSERT INTO #TABLEHIGHCPU
    SELECT cntr_value AS C1,
           (
               SELECT cntr_value
               FROM sys.dm_os_performance_counters WITH (NOLOCK)
               WHERE object_name = 'SQLServer:Resource Pool Stats'
                     AND counter_name = 'CPU usage % base'
                     AND instance_name = 'default'
           ) AS C2
    FROM sys.dm_os_performance_counters WITH (NOLOCK)
    WHERE object_name = 'SQLServer:Resource Pool Stats'
          AND counter_name = 'CPU usage %'
          AND instance_name = 'default';
    WAITFOR DELAY '00:00:10'; -- Set value for Delay in execution
    SET @i = @i + 1;
END;

DECLARE @CPU INT;
SET @CPU = 50; -- Set CPU Threshold here

IF @CPU <
(
    SELECT AVG(C1) * 100 / AVG(C2) FROM #TABLEHIGHCPU
)
    SELECT 'ALERT HIGH CPU!!!'; --Replace it with your sp_send_dbmail statement here 

ELSE
    SELECT 'CPU USAGE IS NORMAL';

SELECT AVG(C1) * 100 / AVG(C2) AS [AVG CPU %]
FROM #TABLEHIGHCPU;