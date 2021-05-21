SELECT i.name AS index_name,
	SUBSTRING(column_names, 1, LEN(column_names) - 1) AS columns,
	CASE 
		WHEN i.type = 1
			THEN 'Clustered index'
		WHEN i.type = 2
			THEN 'Nonclustered unique index'
		WHEN i.type = 3
			THEN 'XML index'
		WHEN i.type = 4
			THEN 'Spatial index'
		WHEN i.type = 5
			THEN 'Clustered columnstore index'
		WHEN i.type = 6
			THEN 'Nonclustered columnstore index'
		WHEN i.type = 7
			THEN 'Nonclustered hash index'
		END AS index_type,
	CASE 
		WHEN i.is_unique = 1
			THEN 'Unique'
		ELSE 'Not unique'
		END AS [unique],
	SCHEMA_NAME(t.schema_id) + '.' + t.name AS table_view,
	CASE 
		WHEN t.type = 'U'
			THEN 'Table'
		WHEN t.type = 'V'
			THEN 'View'
		END AS object_type
FROM sys.objects AS t
INNER JOIN sys.indexes AS i ON t.object_id = i.object_id
CROSS APPLY (
	SELECT col.name + ', '
	FROM sys.index_columns AS ic
	INNER JOIN sys.columns AS col ON ic.object_id = col.object_id
		AND ic.column_id = col.column_id
	WHERE ic.object_id = t.object_id
		AND ic.index_id = i.index_id
	ORDER BY index_column_id
	FOR XML path('')
	) AS D(column_names)
WHERE t.is_ms_shipped <> 1
	AND index_id > 0
ORDER BY i.name;

/************************
Find all disabled indexes
************************/
EXEC sp_msForEachDB ' 
USE [?];
SELECT DB_NAME() as dbName, i.name AS Index_Name, i.index_id, i.type_desc, s.name AS [Schema_Name], o.name AS Table_Name
FROM sys.indexes i
JOIN sys.objects o on o.object_id = i.object_id
JOIN sys.schemas s on s.schema_id = o.schema_id
WHERE i.is_disabled = 1
ORDER BY
i.name;
';
