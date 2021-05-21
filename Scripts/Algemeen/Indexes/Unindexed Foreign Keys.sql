/***********************
	Unindexed Foreign Keys	
***********************/
WITH v_NonIndexedFKColumns
AS (
	SELECT OBJECT_NAME(a.parent_object_id) AS Table_Name,
		b.NAME AS Column_Name
	FROM sys.foreign_key_columns AS a,
		sys.all_columns AS b,
		sys.objects AS c
	WHERE a.parent_column_id = b.column_id
		AND a.parent_object_id = b.object_id
		AND b.object_id = c.object_id
		AND c.is_ms_shipped = 0
	
	EXCEPT
	
	SELECT OBJECT_NAME(a.Object_id),
		b.NAME
	FROM sys.index_columns AS a,
		sys.all_columns AS b,
		sys.objects AS c
	WHERE a.object_id = b.object_id
		AND a.key_ordinal = 1
		AND a.column_id = b.column_id
		AND a.object_id = c.object_id
		AND c.is_ms_shipped = 0
	)
SELECT v.Table_Name AS NonIndexedCol_Table_Name,
	v.Column_Name AS NonIndexedCol_Column_Name,
	fk.NAME AS Constraint_Name,
	SCHEMA_NAME(fk.schema_id) AS Ref_Schema_Name,
	OBJECT_NAME(fkc.referenced_object_id) AS Ref_Table_Name,
	c2.NAME AS Ref_Column_Name
FROM v_NonIndexedFKColumns AS v,
	sys.all_columns AS c,
	sys.all_columns AS c2,
	sys.foreign_key_columns AS fkc,
	sys.foreign_keys AS fk
WHERE v.Table_Name = OBJECT_NAME(fkc.parent_object_id)
	AND v.Column_Name = c.NAME
	AND fkc.parent_column_id = c.column_id
	AND fkc.parent_object_id = c.object_id
	AND fkc.referenced_column_id = c2.column_id
	AND fkc.referenced_object_id = c2.object_id
	AND fk.object_id = fkc.constraint_object_id
ORDER BY 1,
	2;

/***********************
	Unindexed Foreign Keys	
***********************/
WITH fk_cte
AS (
	SELECT OBJECT_NAME(fk.referenced_object_id) AS pk_table,
		c2.name AS pk_column,
		kc.name AS pk_index_name,
		OBJECT_NAME(fk.parent_object_id) AS fk_table,
		c.name AS fk_column,
		fk.name AS fk_name,
		CASE 
			WHEN i.object_id IS NOT NULL
				THEN 1
			ELSE 0
			END AS does_fk_has_index,
		i.is_primary_key AS is_fk_a_pk_also,
		i.is_unique AS is_index_on_fk_unique,
		fk.*
	FROM sys.foreign_keys AS fk
	INNER JOIN sys.foreign_key_columns AS fkc ON fkc.constraint_object_id = fk.object_id
	INNER JOIN sys.columns AS c ON c.object_id = fk.parent_object_id
		AND c.column_id = fkc.parent_column_id
	LEFT JOIN sys.columns AS c2 ON c2.object_id = fk.referenced_object_id
		AND c2.column_id = fkc.referenced_column_id
	LEFT JOIN sys.key_constraints AS kc ON kc.parent_object_id = fk.referenced_object_id
		AND kc.type = 'PK'
	LEFT JOIN sys.index_columns AS ic ON ic.object_id = c.object_id
		AND ic.column_id = c.column_id
	LEFT JOIN sys.indexes AS i ON i.object_id = ic.object_id
		AND i.index_id = ic.index_id
	)
SELECT *
FROM fk_cte
LEFT JOIN sys.dm_db_partition_stats AS ps ON ps.object_id = fk_cte.parent_object_id
	AND ps.index_id <= 1
WHERE does_fk_has_index = 0 -- and fk_table = 'LineItems'
ORDER BY used_page_count DESC;
