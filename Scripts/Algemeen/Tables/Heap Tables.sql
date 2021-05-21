/**********************************
Find Tables Without Clustered Index
**********************************/
SELECT DB_NAME() AS DatabaseName,
	SCHEMA_NAME(ST.schema_id) + '.' + ST.name AS TableName
FROM sys.tables AS st
WHERE ST.Type = 'U'
	AND OBJECTPROPERTY(ST.object_id, 'TableHasClustIndex') = 0;

WITH TableNotHasClustIndex
AS (
	SELECT DB_NAME() AS DatabaseName,
		SCHEMA_NAME(ST.schema_id) + '.' + ST.name AS TableName,
		(
			SELECT SUM(SP.rows)
			FROM sys.partitions AS SP
			WHERE ST.object_id = SP.object_id
			) AS NoOfRows
	FROM sys.tables AS st
	WHERE OBJECTPROPERTY(ST.object_id, 'TableHasClustIndex') = 0
	)
SELECT *
FROM TableNotHasClustIndex
WHERE NoOfRows > 1000;

-- List heap tables 
-- ------------------------------------------------------------------------------------------------
SELECT SCH.name + '.' + TBL.name AS TableName
FROM sys.tables AS TBL
INNER JOIN sys.schemas AS SCH ON TBL.schema_id = SCH.schema_id
INNER JOIN sys.indexes AS IDX ON TBL.object_id = IDX.object_id
	AND IDX.type = 0 -- = Heap 
ORDER BY TableName;
GO


