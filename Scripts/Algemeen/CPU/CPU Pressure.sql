-- Verifying CPU pressure via signal wait time.
SELECT SUM(signal_wait_time_ms) AS TotalSignalWaitTime,
       SUM(CAST(signal_wait_time_ms AS NUMERIC(20, 2))) / SUM(CAST(wait_time_ms AS NUMERIC(20, 2))) * 100 AS PercentageSignalWaitsOfTotalTime
FROM sys.dm_os_wait_stats;
GO

-- Investigating CPU pressure
-- Total waits are wait_time_ms (high signal waits indicates CPU pressure)
---------------------------------------------------------------------------------------------------
SELECT CAST(100.0 * SUM(signal_wait_time_ms) / SUM(wait_time_ms) AS NUMERIC(20, 2)) AS [%signal (cpu) waits],
       CAST(100.0 * SUM(wait_time_ms - signal_wait_time_ms) / SUM(wait_time_ms) AS NUMERIC(20, 2)) AS [%resource waits]
FROM sys.dm_os_wait_stats;
GO