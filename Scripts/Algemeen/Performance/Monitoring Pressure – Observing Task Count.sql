-- Monitoring pressure
-------------------------------------------------------------------------------
SELECT AVG(current_tasks_count) AS avg_task_count,
	AVG(runnable_tasks_count) AS avg_runnable_tasks_count,
	AVG(work_queue_count) AS avg_work_queue_count,
	AVG(pending_disk_io_count) AS avg_pending_disk_io_count
FROM sys.dm_os_schedulers
WHERE scheduler_id < 255;
