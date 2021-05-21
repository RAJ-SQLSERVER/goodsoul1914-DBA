SELECT '--EXEC sp_rename ''' + OBJECT_SCHEMA_NAME(IndexesTable.ObjectId) + '.' + OBJECT_NAME(IndexesTable.ObjectId) + '.' + IndexesTable.IndexName + ''', ''' + CASE 
		WHEN IndexesTable.IsUnique = 1
			THEN 'AK_'
		ELSE 'IX_'
		END + OBJECT_NAME(IndexesTable.ObjectId) + '_' + IndexesTable.IndexName + ''', ''index'';' AS Code
FROM (
	SELECT s.name AS SchemaName,
		t.name AS TableName,
		i.name AS IndexName,
		t.object_id AS ObjectId,
		i.index_id AS IndexId,
		i.is_unique IsUnique
	FROM sys.tables t
	INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
	INNER JOIN sys.indexes i ON t.object_id = i.object_id
	WHERE i.index_id > 0
		AND i.type IN (1, 2)
	) AS IndexesTable
WHERE IndexName <> CASE 
		WHEN IsUnique = 1
			THEN 'AK_'
		ELSE 'IX_'
		END + IndexName
ORDER BY 1;
GO


