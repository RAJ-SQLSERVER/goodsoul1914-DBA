-- Bufferpool utilization for each object in a database
-------------------------------------------------------------------------------
SELECT CASE 
		WHEN obd.database_id = 32767
			THEN N'Resource Database'
		ELSE DB_NAME(obd.database_id)
		END AS DatabaseName,
	o.name AS ObjectName,
	COUNT(*) * 8 / 1024 AS MBUsed,
	SUM(CAST(obd.free_space_in_bytes AS BIGINT)) / (1024 * 1024) AS MBEmpty
FROM sys.dm_os_buffer_descriptors AS obd
INNER JOIN sys.allocation_units AS au ON obd.allocation_unit_id = au.allocation_unit_id
INNER JOIN sys.partitions AS p ON au.container_id = p.hobt_id
INNER JOIN sys.objects AS o ON p.object_id = o.object_id
WHERE obd.database_id = DB_ID()
	AND o.type != 'S'
GROUP BY obd.database_id,
	o.name
ORDER BY COUNT(*) * 8 / 1024 DESC;
GO

-- Breaks down buffers by object (table, index) in the buffer pool
-------------------------------------------------------------------------------
SELECT OBJECT_NAME(p.object_id) AS ObjectName,
	p.index_id,
	COUNT(*) / 128 AS [Buffer size(MB)],
	COUNT(*) AS Buffer_count
FROM sys.allocation_units AS a
INNER JOIN sys.dm_os_buffer_descriptors AS b ON a.allocation_unit_id = b.allocation_unit_id
INNER JOIN sys.partitions AS p ON a.container_id = p.hobt_id
WHERE b.database_id = DB_ID()
	AND p.object_id > 100 -- exclude system objects
GROUP BY p.object_id,
	p.index_id
ORDER BY Buffer_count DESC;
GO
