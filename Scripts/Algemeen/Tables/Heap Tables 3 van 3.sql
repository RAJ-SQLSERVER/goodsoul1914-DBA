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
	AND ps.forwarded_record_count > 0
