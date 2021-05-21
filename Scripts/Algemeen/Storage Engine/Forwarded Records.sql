SELECT os.forwarded_fetch_count,
	command = N'ALTER TABLE ' + QUOTENAME(DB_NAME(os.database_id)) + N'.' + QUOTENAME(OBJECT_SCHEMA_NAME(os.object_id, os.database_id)) + N'.' + QUOTENAME(OBJECT_NAME(os.object_id, os.database_id)) + N' REBUILD;',
	heap_size_mb = CAST(ps.reserved_page_count * 8. / 1024. AS BIGINT),
	nonclustered_indexes = (
		SELECT COUNT(DISTINCT i.index_id)
		FROM sys.indexes AS i
		WHERE os.object_id = i.object_id
			AND i.index_id <> 0
			AND i.is_disabled = 0
			AND i.is_hypothetical = 0
		),
	os.leaf_insert_count,
	os.leaf_update_count,
	os.leaf_delete_count
FROM sys.dm_db_index_operational_stats(DB_ID(), NULL, NULL, NULL) AS os
INNER JOIN sys.dm_db_partition_stats AS ps ON ps.object_id = os.object_id
	AND ps.index_id = os.index_id
	AND ps.partition_number = os.partition_number
WHERE os.index_id = 0
	AND os.forwarded_fetch_count > 0
ORDER BY os.forwarded_fetch_count DESC;
GO

-- List detailed stats about heap tables with forwarded records 
-- ------------------------------------------------------------------------------------------------
SELECT OBJECT_NAME(ps.object_id) AS TableName,
	i.name AS IndexName,
	ps.index_type_desc,
	ps.page_count,
	ps.record_count,
	ps.avg_fragmentation_in_percent,
	ps.forwarded_record_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'DETAILED') AS ps
INNER JOIN sys.indexes AS i ON ps.OBJECT_ID = i.OBJECT_ID
	AND ps.index_id = i.index_id
WHERE ps.index_type_desc = 'HEAP'
	AND ps.forwarded_record_count > 0;
GO

-- Forwarded fetches count on Heap tables
-- ------------------------------------------------------------------------------------------------
SELECT os.forwarded_fetch_count,
	command = N'ALTER TABLE ' + QUOTENAME(DB_NAME(os.database_id)) + N'.' + QUOTENAME(OBJECT_SCHEMA_NAME(os.object_id, os.database_id)) + N'.' + QUOTENAME(OBJECT_NAME(os.object_id, os.database_id)) + N' REBUILD;',
	heap_size_mb = CAST(ps.reserved_page_count * 8. / 1024. AS BIGINT),
	nonclustered_indexes = (
		SELECT COUNT(DISTINCT i.index_id)
		FROM sys.indexes AS i
		WHERE os.object_id = i.object_id
			AND i.index_id <> 0
			AND i.is_disabled = 0
			AND i.is_hypothetical = 0
		)
FROM sys.dm_db_index_operational_stats(DB_ID(), NULL, NULL, NULL) AS os
INNER JOIN sys.dm_db_partition_stats AS ps ON ps.object_id = os.object_id
	AND ps.index_id = os.index_id
	AND ps.partition_number = os.partition_number
WHERE os.index_id = 0
	AND os.forwarded_fetch_count > 0
ORDER BY os.forwarded_fetch_count DESC;
GO


