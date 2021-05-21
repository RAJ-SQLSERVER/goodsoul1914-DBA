-- process memory consumption
SELECT physical_memory_in_use_kb / 1024 AS physical_memory_in_use_mb,
       large_page_allocations_kb / 1024 AS large_page_allocations_mb,
       locked_page_allocations_kb / 1024 AS locked_page_allocations_mb,
       total_virtual_address_space_kb / 1024 AS total_virtual_address_space_mb,
       virtual_address_space_reserved_kb / 1024 AS virtual_address_space_reserved_mb,
       virtual_address_space_committed_kb / 1024 AS virtual_address_space_committed_mb,
       virtual_address_space_available_kb / 1024 AS virtual_address_space_available_mb,
       available_commit_limit_kb / 1024 AS available_commit_limit_mb
FROM sys.dm_os_process_memory;
GO

-- buffer pool
-- <=2012
SELECT SUM(pages_kb + virtual_memory_committed_kb + shared_memory_committed_kb + awe_allocated_kb) / 1024 AS [used_by_buffer_pool_mb]
FROM sys.dm_os_memory_clerks
WHERE type = 'MEMORYCLERK_SQLBUFFERPOOL';
GO

-- procedure cache
SELECT COUNT(*) AS "Plan Count",
       SUM(CAST(size_in_bytes AS BIGINT)) / 1024 / 1024 AS "Plan Cache Size (MB)"
FROM sys.dm_exec_cached_plans;
GO

-- get buffer pool utilization by each database
SELECT [database_name] = CASE
                           WHEN database_id = 32767 THEN
                               'RESOURCEDB'
                           ELSE
                               DB_NAME(database_id)
                       END,
       size_mb = COUNT(1) / 128.0
FROM sys.dm_os_buffer_descriptors
GROUP BY database_id
ORDER BY 2 DESC;
GO

-- get buffer pool utilization by object in a database
USE AdventureWorks;
GO
SELECT [database_name] = CASE
                             WHEN database_id = 32767 THEN
                                 'RESOURCEDB'
                             ELSE
                                 DB_NAME(database_id)
                         END,
       object_name = o.name,
       size_mb = COUNT(1) / 128.0
FROM sys.dm_os_buffer_descriptors obd
    INNER JOIN sys.allocation_units au
        ON obd.allocation_unit_id = au.allocation_unit_id
    INNER JOIN sys.partitions p
        ON au.container_id = p.hobt_id
    INNER JOIN sys.objects o
        ON p.object_id = o.object_id
WHERE obd.database_id = DB_ID()
      AND o.type <> 'S'
GROUP BY obd.database_id,
         o.name;
GO

DBCC DROPCLEANBUFFERS
GO

