-------------------------------------------------------------------------------
-- How to detect and prevent unexpected growth of SQL Server database TempDB
-------------------------------------------------------------------------------

SELECT create_date AS "SQL Service Startup Time"
FROM sys.databases
WHERE name = 'tempdb';
GO


/*
    Now, execute the following query to create a temporary table and perform 
    data insertion. The temporary table storage location is the TempDB database. 
    This query uses a CROSS JOIN operator with multiple columns and further 
    sorts the results using the ORDER BY clause.
*/
SELECT *
FROM sys.configurations
CROSS JOIN sys.configurations AS SCA
CROSS JOIN sys.configurations AS SCB
CROSS JOIN sys.configurations AS SCC
CROSS JOIN sys.configurations AS SCD
CROSS JOIN sys.configurations AS SCE
CROSS JOIN sys.configurations AS SCF
CROSS JOIN sys.configurations AS SCG
CROSS JOIN sys.configurations AS SCH
ORDER BY SCA.name,
         SCA.value,
         SCC.value_in_use DESC;
GO


/*
    This query will take a long time and might result in high CPU usage as well 
    in your system. While the query is running, open another query window and 
    use the DMV sys.dm_db_task_space_usage to get information of page allocation 
    and deallocation activity by the task. We join this DMV with other DMV's to 
    get the required information for the SQL Server database TempDB:
*/
SELECT s.session_id,
       dbu.database_id,
       dbu.internal_objects_alloc_page_count,
       dbu.internal_objects_dealloc_page_count,
       (dbu.internal_objects_alloc_page_count - dbu.internal_objects_dealloc_page_count) * 8192 / 1024 AS "kbytes_used_internal",
       r.total_elapsed_time
FROM sys.dm_exec_requests AS r
INNER JOIN sys.dm_exec_sessions AS s
    ON r.session_id = s.session_id
LEFT JOIN sys.dm_db_task_space_usage AS dbu
    ON dbu.session_id = r.session_id
       AND dbu.request_id = r.request_id
WHERE dbu.internal_objects_alloc_page_count > 0
ORDER BY kbytes_used_internal DESC;
GO


/*  
    The following query uses DMV sys.dm_db_file_space_usage and joins it with 
    sys.master_files to check the allocated and unallocated extent page counts 
    in the SQL Server database TempDB while the query is executing:
*/
SELECT mf.physical_name,
       mf.size AS "entire_file_page_count",
       dfsu.unallocated_extent_page_count,
       dfsu.user_object_reserved_page_count,
       dfsu.internal_object_reserved_page_count,
       dfsu.mixed_extent_page_count
FROM sys.dm_db_file_space_usage AS dfsu
JOIN sys.master_files AS mf
    ON mf.database_id = dfsu.database_id
       AND mf.file_id = dfsu.file_id;
GO
