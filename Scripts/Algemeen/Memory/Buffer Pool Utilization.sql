-- Bufferpool utilization
--------------------------------------------------------------------------------------------------
SELECT COUNT(*) AS cached_pages_count,
	obj.name AS objectname,
	ind.name AS indexname,
	obj.index_id AS indexid
FROM sys.dm_os_buffer_descriptors AS bd
INNER JOIN (
	SELECT p.object_id AS objectid,
		OBJECT_NAME(p.object_id) AS name,
		p.index_id,
		au.allocation_unit_id
	FROM sys.allocation_units AS au
	INNER JOIN sys.partitions AS p ON au.container_id = p.hobt_id
		AND (
			au.type = 1
			OR au.type = 3
			)
	
	UNION ALL
	
	SELECT p.object_id AS objectid,
		OBJECT_NAME(p.object_id) AS name,
		p.index_id,
		au.allocation_unit_id
	FROM sys.allocation_units AS au
	INNER JOIN sys.partitions AS p ON au.container_id = p.partition_id
		AND au.type = 2
	) AS obj ON bd.allocation_unit_id = obj.allocation_unit_id
LEFT OUTER JOIN sys.indexes AS ind ON obj.objectid = ind.object_id
	AND obj.index_id = ind.index_id
WHERE bd.database_id = DB_ID()
	AND bd.page_type IN ('data_page', 'index_page')
GROUP BY obj.name,
	ind.name,
	obj.index_id
ORDER BY cached_pages_count DESC;
