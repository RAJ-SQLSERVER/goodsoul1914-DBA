-- List all database tables and there indexes with detailed information 
-- about row count and used + reserved data space
--------------------------------------------------------------------------------------------------
SELECT SCH.name AS SchemaName,
	OBJ.name AS ObjName,
	OBJ.type_desc AS ObjType,
	INDX.name AS IndexName,
	INDX.type_desc AS IndexType,
	PART.partition_number AS PartitionNumber,
	PART.rows AS PartitionRows,
	STAT.row_count AS StatRowCount,
	STAT.used_page_count * 8 AS UsedSizeKB,
	STAT.reserved_page_count * 8 AS RevervedSizeKB
FROM sys.partitions AS PART
INNER JOIN sys.dm_db_partition_stats AS STAT ON PART.partition_id = STAT.partition_id
	AND PART.partition_number = STAT.partition_number
INNER JOIN sys.objects AS OBJ ON STAT.object_id = OBJ.object_id
INNER JOIN sys.schemas AS SCH ON OBJ.schema_id = SCH.schema_id
INNER JOIN sys.indexes AS INDX ON STAT.object_id = INDX.object_id
	AND STAT.index_id = INDX.index_id
ORDER BY SCH.name,
	OBJ.name,
	INDX.name,
	PART.partition_number;
GO

--	Get all indexes list with key columns and include columns as well as usage statistics 
--	Script By: Aasim Abdullah for http://connectsql.blogspot.com 
--------------------------------------------------------------------------------------------------
SELECT '[' + Sch.name + '].[' + Tab.name + ']' AS TableName,
	Ind.type_desc,
	Ind.name AS IndexName,
	SUBSTRING((
			SELECT ', ' + AC.name
			FROM sys.tables AS T
			INNER JOIN sys.indexes AS I ON T.object_id = I.object_id
			INNER JOIN sys.index_columns AS IC ON I.object_id = IC.object_id
				AND I.index_id = IC.index_id
			INNER JOIN sys.all_columns AS AC ON T.object_id = AC.object_id
				AND IC.column_id = AC.column_id
			WHERE Ind.object_id = I.object_id
				AND Ind.index_id = I.index_id
				AND IC.is_included_column = 0
			ORDER BY IC.key_ordinal
			FOR XML path('')
			), 2, 8000) AS KeyCols,
	SUBSTRING((
			SELECT ', ' + AC.name
			FROM sys.tables AS T
			INNER JOIN sys.indexes AS I ON T.object_id = I.object_id
			INNER JOIN sys.index_columns AS IC ON I.object_id = IC.object_id
				AND I.index_id = IC.index_id
			INNER JOIN sys.all_columns AS AC ON T.object_id = AC.object_id
				AND IC.column_id = AC.column_id
			WHERE Ind.object_id = I.object_id
				AND Ind.index_id = I.index_id
				AND IC.is_included_column = 1
			ORDER BY IC.key_ordinal
			FOR XML path('')
			), 2, 8000) AS IncludeCols,
	usg_stats.user_seeks AS UserSeek,
	usg_stats.user_scans AS UserScans,
	usg_stats.user_lookups AS UserLookups,
	usg_stats.user_updates AS UserUpdates
FROM sys.indexes AS Ind
INNER JOIN sys.tables AS Tab ON Tab.object_id = Ind.object_id
INNER JOIN sys.schemas AS Sch ON Sch.schema_id = Tab.schema_id
LEFT OUTER JOIN sys.dm_db_index_usage_stats AS usg_stats ON Ind.index_id = usg_stats.index_id
	AND Ind.OBJECT_ID = usg_stats.OBJECT_ID
	AND usg_stats.database_id = DB_ID()
WHERE Ind.type_desc <> 'HEAP'
--AND Tab.name = 'YourTableNameHere' -- uncomment to get single table indexes detail 
ORDER BY TableName;
GO


