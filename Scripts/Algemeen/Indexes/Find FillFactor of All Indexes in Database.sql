/*
 Find FillFactor of All Indexes in a Database
*/
USE DBATools;
GO

SELECT DB_NAME() AS DatabaseName,
	ss.name + '.' + so.name AS TableName,
	si.name AS IndexName,
	si.type_desc AS IndexType,
	si.fill_factor AS [FillFactor]
FROM sys.indexes AS si
INNER JOIN sys.objects AS so ON si.object_id = so.object_id
INNER JOIN sys.schemas AS ss ON so.schema_id = ss.schema_id
WHERE si.name IS NOT NULL
	AND so.type = 'U'
ORDER BY si.fill_factor DESC;
