-- Memory used by the bufferpool
-- ------------------------------------------------------------------------------------------------
SELECT SUM(pages_kb + virtual_memory_committed_kb + shared_memory_committed_kb + awe_allocated_kb) / 1024 AS used_by_bufferpool_MB
FROM sys.dm_os_memory_clerks
WHERE type = 'MEMORYCLERK_SQLBUFFERPOOL';
GO
