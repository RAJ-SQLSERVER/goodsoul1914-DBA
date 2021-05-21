-- How many Objects exists in a Schema
-- ------------------------------------------------------------------------------------------------
WITH usage
AS (
	SELECT OBJ.schema_id,
		COUNT(*) AS ObjectCount
	FROM sys.objects AS OBJ
	GROUP BY OBJ.schema_id
	)
SELECT SCH.name AS SchemaName,
	ISNULL(PRC.name, N'n/a') AS SchemaOwner,
	ISNULL(USG.ObjectCount, 0) AS ObjectCount
FROM sys.schemas AS SCH
LEFT JOIN sys.server_principals AS PRC ON SCH.principal_id = PRC.principal_id
LEFT JOIN usage AS USG ON SCH.schema_id = USG.schema_id
ORDER BY SCH.name;
GO


