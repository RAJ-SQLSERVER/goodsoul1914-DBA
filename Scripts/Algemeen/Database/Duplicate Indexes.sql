/********************************************************************************************
-- Tables with duplicate indexes. 
That is, an index is a duplicate if it references the same column and ordinal position 
as another index in the same database. Duplicate indexes provide no benefits, while also
increasing the I/O overhead of ongoing write operations, as well as defrag operations. 

The overall result is write performance, wasted disk space, and longer index maintenance 
operations. 

Drop duplicate indexes to get an immediate performance benefit for write operations and also 
for index rebuilds and reorgs. Existing queries should be unaffected.
********************************************************************************************/
WITH IndexColumns
AS (
	SELECT DISTINCT SCHEMA_NAME(o.schema_id) AS 'SchemaName',
		OBJECT_NAME(o.object_id) AS TableName,
		i.Name AS IndexName,
		o.object_id,
		i.index_id,
		i.type,
		(
			SELECT CASE key_ordinal
					WHEN 0
						THEN NULL
					ELSE '[' + COL_NAME(k.object_id, column_id) + '] ' + CASE 
							WHEN is_descending_key = 1
								THEN 'Desc'
							ELSE 'Asc'
							END
					END AS [data()]
			FROM sys.index_columns(NOLOCK) AS k
			WHERE k.object_id = i.object_id
				AND k.index_id = i.index_id
			ORDER BY key_ordinal,
				column_id
			FOR XML path('')
			) AS cols,
		CASE 
			WHEN i.index_id = 1
				THEN (
						SELECT '[' + name + ']' AS [data()]
						FROM sys.columns(NOLOCK) AS c
						WHERE c.object_id = i.object_id
							AND c.column_id NOT IN (
								SELECT column_id
								FROM sys.index_columns(NOLOCK) AS kk
								WHERE kk.object_id = i.object_id
									AND kk.index_id = i.index_id
								)
						ORDER BY column_id
						FOR XML path('')
						)
			ELSE (
					SELECT '[' + COL_NAME(k.object_id, column_id) + ']' AS [data()]
					FROM sys.index_columns(NOLOCK) AS k
					WHERE k.object_id = i.object_id
						AND k.index_id = i.index_id
						AND is_included_column = 1
						AND k.column_id NOT IN (
							SELECT column_id
							FROM sys.index_columns AS kk
							WHERE k.object_id = kk.object_id
								AND kk.index_id = 1
							)
					ORDER BY key_ordinal,
						column_id
					FOR XML path('')
					)
			END AS inc
	FROM sys.indexes(NOLOCK) AS i
	INNER JOIN sys.objects AS o(NOLOCK) ON i.object_id = o.object_id
	INNER JOIN sys.index_columns AS ic(NOLOCK) ON ic.object_id = i.object_id
		AND ic.index_id = i.index_id
	INNER JOIN sys.columns AS c(NOLOCK) ON c.object_id = ic.object_id
		AND c.column_id = ic.column_id
	WHERE o.type = 'U'
		AND i.index_id <> 0
		AND i.type <> 3
		AND i.type <> 5
		AND i.type <> 6
		AND i.type <> 7
	GROUP BY o.schema_id,
		o.object_id,
		i.object_id,
		i.Name,
		i.index_id,
		i.type
	),
DuplicatesTable
AS (
	SELECT ic1.SchemaName,
		ic1.TableName,
		ic1.IndexName,
		ic1.object_id,
		ic2.IndexName AS DuplicateIndexName,
		CASE 
			WHEN ic1.index_id = 1
				THEN ic1.cols + ' (Clustered)'
			WHEN ic1.inc = ''
				THEN ic1.cols
			WHEN ic1.inc IS NULL
				THEN ic1.cols
			ELSE ic1.cols + ' INCLUDE ' + ic1.inc
			END AS IndexCols,
		ic1.index_id
	FROM IndexColumns AS ic1
	JOIN IndexColumns AS ic2 ON ic1.object_id = ic2.object_id
		AND ic1.index_id < ic2.index_id
		AND ic1.cols = ic2.cols
		AND (
			ISNULL(ic1.inc, '') = ISNULL(ic2.inc, '')
			OR ic1.index_id = 1
			)
	)
SELECT SchemaName,
	TableName,
	IndexName,
	DuplicateIndexName,
	IndexCols,
	index_id,
	object_id,
	0 AS IsXML
FROM DuplicatesTable AS dt
ORDER BY 1,
	2,
	3;
