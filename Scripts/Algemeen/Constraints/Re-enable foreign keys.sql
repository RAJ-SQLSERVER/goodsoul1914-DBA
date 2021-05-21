-- re-enable fks
USE targetdb;
GO

DECLARE @sql NVARCHAR(MAX) = N'';

;WITH x
AS (SELECT DISTINCT
           obj = QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' + QUOTENAME(OBJECT_NAME(parent_object_id))
    FROM sys.foreign_keys)
SELECT @sql += N'ALTER TABLE ' + obj + N' WITH CHECK CHECK CONSTRAINT ALL;
'
FROM x;

EXEC sp_executesql @sql;