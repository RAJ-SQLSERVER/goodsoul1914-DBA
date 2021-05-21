-- Physical characteristics of each partition
---------------------------------------------------------------------------------------------------
SELECT OBJECT_NAME(indexes.object_id) AS Object_Name,
	ddps.index_id AS Index_ID,
	ddps.partition_number,
	ddps.row_count,
	ddps.used_page_count,
	ddps.in_row_reserved_page_count,
	ddps.lob_reserved_page_count,
	CASE pf.boundary_value_on_right
		WHEN 1
			THEN 'less than'
		ELSE 'less than or equal to'
		END AS comparison,
	value
FROM sys.dm_db_partition_stats AS ddps
JOIN sys.indexes ON ddps.object_id = indexes.object_id
	AND ddps.index_id = indexes.index_id
JOIN sys.partition_schemes AS ps ON ps.data_space_id = indexes.data_space_id
JOIN sys.partition_functions AS pf ON pf.function_id = ps.function_id
LEFT OUTER JOIN sys.partition_range_values AS prv ON pf.function_id = prv.function_id
	AND ddps.partition_number = prv.boundary_id
WHERE OBJECT_NAME(ddps.object_id) = 'salesOrder'
	AND ddps.index_id IN (0, 1);-- CLUSTERED table or HEAP
GO
