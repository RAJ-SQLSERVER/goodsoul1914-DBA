-- Returns a snapshot of the health of a cache in SQL Server
--------------------------------------------------------------------------------------------------
SELECT name,
	type,
	SUM(pages_kb) AS Size,
	SUM(pages_in_use_kb) AS Used_Size,
	SUM(entries_count) AS Entries,
	SUM(entries_in_use_count) AS Used_Entries
FROM sys.dm_os_memory_cache_counters
GROUP BY name,
	type
ORDER BY 4 DESC;
GO

-- Returns information about all entries in caches in SQL Server. Use this view to trace cache 
-- entries to their associated objects. You can also use this view to obtain statistics on cache entries.
-- 
-- name (CacheName)			Name of the cache in which we have this entry
-- in_use_count				Current parallel usage of this cache entry
-- is_dirty					Will be flushed the next time when memory is needed form the cache
-- disk_ios_count			Number of IOs when this entry is created
-- context_switches_count	Number of context switches when this entry is created
-- original_cost			Total cost including IO, CPU, memory, etc. during entry
--							Higher the cost lower the chances of flushing it
-- current_cost				Current cost of cache entry. This is updated during entry purging. 
--							If the plan is reused before flushing it gets reset to original cost.
-- pages_kb					Amount of space consumed by entry 
--							Till 2008 R2 this was pages_allocated_count which is the page count 
--							of allocations
--------------------------------------------------------------------------------------------------
SELECT TOP 10 OBJECT_NAME(est.objectid, EST.dbid) AS ObjectName,
	omce.name AS cacheName,
	omce.in_use_count,
	omce.is_dirty,
	omce.disk_ios_count,
	omce.context_switches_count,
	omce.original_cost,
	omce.current_cost,
	omce.pages_kb
FROM sys.dm_exec_cached_plans AS ecp
CROSS APPLY sys.dm_exec_sql_text(ecp.plan_handle) AS est
INNER JOIN sys.dm_os_memory_cache_entries AS omce ON ecp.memory_object_address = omce.memory_object_address;
GO
