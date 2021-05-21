EXEC sp_MSforeachtable @command1 = 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';

DECLARE @linkedServer SYSNAME = 'SERVER';
DECLARE @SourceDbName SYSNAME = 'DB';
DECLARE @sql VARCHAR(8000);
DECLARE @tableName SYSNAME;

DECLARE Cur_tab CURSOR
FOR
SELECT name
FROM sys.tables AS t
WHERE t.type = 'U';

OPEN Cur_tab;

FETCH NEXT
FROM Cur_tab
INTO @tableName;

DECLARE @listStr VARCHAR(MAX);

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @listStr = NULL;

	SELECT @listStr = COALESCE(@listStr + ',', '') + name
	FROM sys.columns
	WHERE object_id = OBJECT_ID(@tableName);

	SET @sql = 'SET IDENTITY_INSERT ' + @tableName + ' ON;INSERT INTO ' + @tableName + '(' + @listStr + ')SELECT ' + @listStr + ' FROM [' + CONVERT(VARCHAR, @linkedServer) + '].[' + CONVERT(VARCHAR, @SourceDbName) + '].[DBO].[' + @tableName + '] 
        ;SET IDENTITY_INSERT ' + @tableName + ' OFF;';

	PRINT @sql;

	EXEC (@sql);

	FETCH NEXT
	FROM Cur_tab
	INTO @tableName;
END;

CLOSE Cur_tab;

DEALLOCATE Cur_tab;

EXEC sp_MSforeachtable @command1 = 'ALTER TABLE ? CHECK CONSTRAINT ALL';
