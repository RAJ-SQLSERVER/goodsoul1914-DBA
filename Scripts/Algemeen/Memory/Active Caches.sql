-- Returns a row for each active cache in the instance of SQL Server
-------------------------------------------------------------------------------
SELECT name,
	buckets_count,
	buckets_in_use_count,
	buckets_avg_length,
	hits_count,
	misses_count
FROM sys.dm_os_memory_cache_hash_tables
WHERE type = 'CACHESTORE_SQLCP'
	OR type = 'CACHESTORE_OBJCP'
ORDER BY buckets_count DESC;
GO
