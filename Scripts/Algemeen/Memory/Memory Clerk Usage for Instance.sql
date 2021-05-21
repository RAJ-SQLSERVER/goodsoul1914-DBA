-- Memory Clerk Usage for instance
--
-- Look for high value for CACHESTORE_SQLCP (Ad-hoc query plans)
--
-- MEMORYCLERK_SQLBUFFERPOOL was new for SQL Server 2012. 
-- It should be your highest consumer of memory
--
-- CACHESTORE_SQLCP  SQL Plans         
-- These are cached SQL statements or batches that aren't in stored procedures, 
-- functions and triggers
-- Watch out for high values for CACHESTORE_SQLCP
-- Enabling 'optimize for ad hoc workloads' at the instance level can help 
-- reduce this
-- Running DBCC FREESYSTEMCACHE ('SQL Plans') periodically may be required to 
-- better control this
--
-- CACHESTORE_OBJCP  Object Plans      
-- These are compiled plans for stored procedures, functions and triggers
--
-- https://bit.ly/2H31xDR
-------------------------------------------------------------------------------
SELECT type,
	name,
	pages_kb,
	virtual_memory_reserved_kb,
	virtual_memory_committed_kb,
	awe_allocated_kb,
	shared_memory_reserved_kb,
	shared_memory_committed_kb,
	page_size_in_bytes
FROM sys.dm_os_memory_clerks
ORDER BY pages_kb DESC;
GO
