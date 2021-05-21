USE AdventureWorks;

DECLARE @Table VARCHAR(128);
DECLARE @Schema VARCHAR(128);
DECLARE @SQL VARCHAR(1000);
DECLARE @Count VARCHAR(1000);

CREATE TABLE #tableList (
	SchemaName VARCHAR(128),
	TableName VARCHAR(128),
	ID BIT
	);

CREATE TABLE #tableCount (
	SchemaName VARCHAR(128),
	TableName VARCHAR(128),
	[RowCount] INT
	);

INSERT INTO #tableList
SELECT SCHEMA_NAME(schema_id) AS SchemaName,
	name AS TableName,
	0
FROM sys.tables
ORDER BY SCHEMA_NAME(schema_id),
	name;

WHILE (
		SELECT COUNT(*)
		FROM #tableList
		WHERE ID = 0
		) > 0
BEGIN
	SELECT TOP 1 @Table = TableName,
		@Schema = SchemaName
	FROM #tableList
	WHERE ID = 0;

	SET @Count = 'SELECT COUNT(*) FROM [' + @Schema + '].[' + @Table + ']';
	SET @SQL = 'INSERT INTO #tableCount ([SchemaName], [TableName], [RowCount]) VALUES (''' + @Schema + ''',''' + @Table + ''',(' + @Count + '))';

	EXEC (@SQL);

	IF @@ERROR <> 0
		PRINT @SQL;

	UPDATE #tableList
	SET ID = 1
	WHERE TableName = @Table
		AND SchemaName = @Schema;
END;

SELECT *
FROM #tableCount
ORDER BY SchemaName,
	TableName;

DROP TABLE #tableCount;

DROP TABLE #tableList;
