-- page allocation and deallocation activity
SELECT     s.session_id,
           dbu.database_id,
           dbu.internal_objects_alloc_page_count,
           dbu.internal_objects_dealloc_page_count,
           (dbu.internal_objects_alloc_page_count - dbu.internal_objects_dealloc_page_count) * 8192 / 1024 AS kbytes_used_internal,
           r.total_elapsed_time
FROM       sys.dm_exec_requests AS r
INNER JOIN sys.dm_exec_sessions AS s ON r.session_id = s.session_id
LEFT JOIN  sys.dm_db_task_space_usage AS dbu ON dbu.session_id = r.session_id
                                                AND dbu.request_id = r.request_id
WHERE      dbu.internal_objects_alloc_page_count > 0
ORDER BY   kbytes_used_internal DESC;



SELECT mf.physical_name,
       mf.size AS entire_file_page_count,
       dfsu.unallocated_extent_page_count,
       dfsu.user_object_reserved_page_count,
       dfsu.internal_object_reserved_page_count,
       dfsu.mixed_extent_page_count
FROM   sys.dm_db_file_space_usage AS dfsu
JOIN   sys.master_files AS mf ON mf.database_id = dfsu.database_id
                                 AND mf.file_id = dfsu.file_id;