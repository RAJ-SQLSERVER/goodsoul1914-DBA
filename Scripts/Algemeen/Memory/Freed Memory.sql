-- Max_free_entries_count		The max limit of free entries allowed in a pool
-- Free_entries_count			Current free entries in the pool
-- Removed_in_all_rounds_count	Number of entries removed since SQL Server 
--								started from the pool
-------------------------------------------------------------------------------
SELECT type,
	name,
	max_free_entries_count,
	free_entries_count,
	removed_in_all_rounds_count
FROM sys.dm_os_memory_pools
ORDER BY removed_in_all_rounds_count DESC;
GO
