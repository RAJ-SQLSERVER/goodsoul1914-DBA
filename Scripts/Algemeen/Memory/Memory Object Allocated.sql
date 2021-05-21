-- Returns memory objects that are currently allocated by SQL Server. 
--	You can use sys.dm_os_memory_objects to analyze memory use and to identify possible memory leaks.
--------------------------------------------------------------------------------------------------
SELECT type,
	SUM(pages_in_bytes) / 1024 AS pages_kb
FROM sys.dm_os_memory_objects
GROUP BY type
ORDER BY 2 DESC;
GO
