SELECT * FROM sys.dm_os_nodes;


SELECT * FROM sys.dm_os_memory_nodes


SELECT * FROM sys.dm_os_memory_clerks

-- get buffer pool from buffer descriptors
SELECT COUNT(*) / 128
FROM sys.dm_os_buffer_descriptors;

-- get buffer pool from clerk
SELECT pages_kb / 1024 AS [used_by_buffer_pool_mb]
FROM sys.dm_os_memory_clerks
WHERE type = 'MEMORYCLERK_SQLBUFFERPOOL';
GO

SELECT COUNT(*)
FROM sys.dm_os_memory_clerks
WHERE memory_node_id = 0;
GO


SELECT *
FROM sys.dm_os_memory_objects;

SELECT *
FROM sys.dm_os_memory_objects
WHERE page_allocator_address = '0x00000225AD0002C0';

SELECT *
FROM sys.dm_os_memory_objects
WHERE type = 'MEMOBJ_SOSWORKER'


-- Which memory objects belong to a particular memory clerk?
SELECT b.type AS clerk,
       b.pages_kb,
       a.type AS [object],
       *
FROM sys.dm_os_memory_objects a
    JOIN sys.dm_os_memory_clerks b
        ON a.page_allocator_address = b.page_allocator_address
GO

SELECT b.type AS clerk,
       b.pages_kb,
       a.type AS [object],
       *
FROM sys.dm_os_memory_objects a
    JOIN sys.dm_os_memory_clerks b
        ON a.page_allocator_address = b.page_allocator_address
WHERE b.type = 'CACHESTORE_PHDR'
ORDER BY b.pages_kb DESC;
GO

SELECT *
FROM sys.dm_os_memory_clerks
ORDER BY pages_kb DESC
GO

SELECT *
FROM sys.dm_os_memory_clerks
WHERE type = 'CACHESTORE_PHDR'; 
GO -- 60744

SELECT (SUM(pages_in_bytes) + 73728) / 1024 AS total
FROM sys.dm_os_memory_objects
WHERE type = 'MEMOBJ_PARSE';
GO -- 60744


