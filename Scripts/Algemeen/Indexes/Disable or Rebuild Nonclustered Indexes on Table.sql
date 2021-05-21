DECLARE @DisableOrRebuild AS NVARCHAR(20);

SET @DisableOrRebuild = 'DISABLE';-- or use 'REBUILD' here

DECLARE @TableName AS NVARCHAR(200) = 'myTable';-- Enter your table name here
DECLARE @SchemaName AS NVARCHAR(200) = 'dbo';-- Enter the schema here
DECLARE @Sql AS NVARCHAR(max) = '';

SELECT @Sql = @Sql + N'ALTER INDEX ' + QUOTENAME(i.name) + N' ON ' + QUOTENAME(s.name) + '.' + QUOTENAME(o.name) + ' ' + @DisableOrRebuild + N';' + CHAR(13) + CHAR(10)
FROM sys.indexes AS i
INNER JOIN sys.objects AS o ON i.object_id = o.object_id
INNER JOIN sys.schemas AS s ON s.schema_id = o.schema_id
WHERE i.type_desc = N'NONCLUSTERED'
	AND o.type_desc = N'USER_TABLE'
	AND o.name = @TableName
	AND s.name = @SchemaName;

EXEC (@Sql);
