-- Returns one row per scheduler in SQL Server where each scheduler is mapped to an individual 
-- processor. Use this view to monitor the condition of a scheduler or to identify runaway tasks.
---------------------------------------------------------------------------------------------------
SELECT work_queue_count,
       scheduler_id,
       current_tasks_count,
       runnable_tasks_count,
       current_workers_count,
       active_workers_count
FROM sys.dm_os_schedulers
ORDER BY 1 DESC;
GO