-- Get Average Task Counts
--
-- Sustained values above 10 suggest further investigation in that area
-- High Avg Task Counts are often caused by blocking/deadlocking 
-- or other resource contention
--
-- Sustained values above 1 suggest further investigation in that area
-- High Avg Runnable Task Counts are a good sign of CPU pressure
-- High Avg Pending DiskIO Counts are a sign of disk pressure
--
-- How to Do Some Very Basic SQL Server Monitoring
-- https://bit.ly/2q3Btgt
--
-- Clear Wait Stats with this command
-- DBCC SQLPERF('sys.dm_os_wait_stats', CLEAR);
-- (run multiple times) 
---------------------------------------------------------------------------------------------------

SELECT AVG(current_tasks_count) AS [Avg Task Count],
       AVG(work_queue_count) AS [Avg Work Queue Count],
       AVG(runnable_tasks_count) AS [Avg Runnable Task Count],
       AVG(pending_disk_io_count) AS [Avg Pending DiskIO Count]
FROM sys.dm_os_schedulers WITH (NOLOCK)
WHERE scheduler_id < 255
OPTION (RECOMPILE);
GO