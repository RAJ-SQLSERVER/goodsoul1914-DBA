-- Index operations for each level of the index
--------------------------------------------------------------------------------------------------
SELECT DB_NAME(database_id) AS DBName,
	OBJECT_NAME(i.object_id) AS TableName,
	i.name AS IndexName,
	leaf_insert_count,
	leaf_delete_count,
	leaf_update_count,
	nonleaf_insert_count,
	nonleaf_delete_count,
	nonleaf_update_count,
	row_lock_count,
	row_lock_wait_count,
	row_lock_wait_in_ms,
	page_lock_count,
	page_lock_wait_count,
	page_lock_wait_in_ms,
	page_latch_wait_count,
	page_latch_wait_in_ms,
	page_io_latch_wait_count,
	page_io_latch_wait_in_ms
FROM sys.dm_db_index_operational_stats(DB_ID('AdventureWorks2017'), OBJECT_ID('person.person'), NULL, NULL) AS iop
INNER JOIN sys.indexes AS i ON iop.index_id = i.index_id
	AND iop.object_id = i.object_id;
GO
