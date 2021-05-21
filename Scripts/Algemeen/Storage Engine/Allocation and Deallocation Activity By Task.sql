-- Returns page allocation and deallocation activity by task for the database
-------------------------------------------------------------------------------
SELECT t.task_address,
       t.parent_task_address,
       tsu.session_id,
       tsu.request_id,
       t.exec_context_id,
       tsu.user_objects_alloc_page_count / 128 AS Total_UserMB,
       (tsu.user_objects_alloc_page_count - tsu.user_objects_dealloc_page_count) / 128.0 AS Acive_UserMB,
       tsu.internal_objects_alloc_page_count / 128 AS Total_IntMB,
       (tsu.internal_objects_alloc_page_count - tsu.internal_objects_dealloc_page_count) / 128.0 AS Active_IntMB,
       t.task_state,
       t.scheduler_id,
       t.worker_address
FROM sys.dm_db_task_space_usage AS tsu
    INNER JOIN sys.dm_os_tasks AS t
        ON tsu.session_id = t.session_id
           AND tsu.exec_context_id = t.exec_context_id
WHERE tsu.session_id > 50
ORDER BY tsu.session_id;
GO