-- Returns a row for every worker in the system
-------------------------------------------------------------------------------
SELECT ot.session_id,
       ow.pending_io_count,
       CASE ow.wait_started_ms_ticks
           WHEN 0 THEN
               0
           ELSE
       (osi.ms_ticks - ow.wait_started_ms_ticks) / 1000
       END AS Suspended_wait,
       CASE ow.wait_resumed_ms_ticks
           WHEN 0 THEN
               0
           ELSE
       (osi.ms_ticks - ow.wait_resumed_ms_ticks) / 1000
       END AS Runnable_wait,
       (osi.ms_ticks - ow.task_bound_ms_ticks) / 1000 AS task_time,
       (osi.ms_ticks - ow.worker_created_ms_ticks) / 1000 AS worker_time,
       ow.end_quantum - ow.start_quantum AS last_worker_quantum,
       ow.state,
       ow.last_wait_type,
       ow.affinity,
       ow.quantum_used,
       ow.tasks_processed_count
FROM sys.dm_os_workers AS ow
    INNER JOIN sys.dm_os_tasks AS ot
        ON ow.task_address = ot.task_address
    CROSS JOIN sys.dm_os_sys_info AS osi
WHERE ot.session_id > 50
      AND is_preemptive = 0;
GO