-- Inspecting the physical table structure
-- ------------------------------------------------------------------------------------------------
SELECT p.index_id,
	p.partition_number,
	pc.leaf_null_bit,
	COALESCE(cx.name, c.name) AS column_name,
	pc.partition_column_id,
	pc.max_inrow_length,
	pc.max_length,
	pc.key_ordinal,
	pc.leaf_offset,
	pc.is_nullable,
	pc.is_dropped,
	pc.is_uniqueifier,
	pc.is_sparse,
	pc.is_anti_matter
FROM sys.system_internals_partitions AS p
JOIN sys.system_internals_partition_columns AS pc ON p.partition_id = pc.partition_id
LEFT JOIN sys.index_columns AS ic ON p.object_id = ic.object_id
	AND ic.index_id = p.index_id
	AND ic.index_column_id = pc.partition_column_id
LEFT JOIN sys.columns AS c ON p.object_id = c.object_id
	AND ic.column_id = c.column_id
LEFT JOIN sys.columns AS cx ON p.object_id = cx.object_id
	AND p.index_id IN (0, 1)
	AND pc.partition_column_id = cx.column_id
WHERE p.object_id = OBJECT_ID('Badges')
ORDER BY index_id,
	partition_number;
GO


