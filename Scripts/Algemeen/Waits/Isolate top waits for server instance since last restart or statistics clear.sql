-- Isolate top waits for server instance since last restart or statistics clear
WITH Waits
AS (
    SELECT wait_type,
           wait_time_ms / 1000. AS wait_time_s,
           100. * wait_time_ms / SUM (wait_time_ms) OVER () AS pct,
           ROW_NUMBER () OVER (ORDER BY wait_time_ms DESC) AS rn
    FROM sys.dm_os_wait_stats
    WHERE wait_type NOT IN ( 'CLR_SEMAPHORE', 'LAZYWRITER_SLEEP', 'RESOURCE_QUEUE', 'SLEEP_TASK', 'SLEEP_SYSTEMTASK',
                             'SQLTRACE_BUFFER_FLUSH', 'WAITFOR', 'LOGMGR_QUEUE', 'CHECKPOINT_QUEUE',
                             'REQUEST_FOR_DEADLOCK_SEARCH', 'XE_TIMER_EVENT', 'BROKER_TO_FLUSH', 'BROKER_TASK_STOP',
                             'CLR_MANUAL_EVENT', 'CLR_AUTO_EVENT', 'DISPATCHER_QUEUE_SEMAPHORE',
                             'FT_IFTS_SCHEDULER_IDLE_WAIT', 'XE_DISPATCHER_WAIT', 'XE_DISPATCHER_JOIN',
                             'SQLTRACE_INCREMENTAL_FLUSH_SLEEP'
)
)
SELECT W1.wait_type,
       CAST(W1.wait_time_s AS DECIMAL(12, 2)) AS wait_time_s,
       CAST(W1.pct AS DECIMAL(12, 2)) AS pct,
       CAST(SUM (W2.pct) AS DECIMAL(12, 2)) AS running_pct
FROM Waits AS W1
INNER JOIN Waits AS W2
    ON W2.rn <= W1.rn
GROUP BY W1.rn,
         W1.wait_type,
         W1.wait_time_s,
         W1.pct
HAVING SUM (W2.pct) - W1.pct < 99
OPTION (RECOMPILE); -- percentage threshold
GO


