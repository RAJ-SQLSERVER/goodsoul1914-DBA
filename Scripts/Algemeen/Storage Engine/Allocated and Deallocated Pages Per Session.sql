-- Returns the number of pages allocated and deallocated by each session 
-- for the database
-------------------------------------------------------------------------------
SELECT session_id,
       user_objects_alloc_page_count / 128 AS user_objs_total_sizeMB,
       (user_objects_alloc_page_count - user_objects_dealloc_page_count) / 128.0 AS user_objs_active_sizeMB,
       internal_objects_alloc_page_count / 128 AS internal_objs_total_sizeMB,
       (internal_objects_alloc_page_count - internal_objects_dealloc_page_count) / 128.0 AS internal_objs_active_sizeMB
FROM sys.dm_db_session_space_usage
ORDER BY user_objects_alloc_page_count DESC;
GO