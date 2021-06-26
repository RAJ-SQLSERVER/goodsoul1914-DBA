-- All tables in one database
SELECT '[' + s.name + '].[' + t.name + ']' AS Table_name
FROM sys.change_tracking_tables tr
INNER JOIN sys.tables t ON t.object_id = tr.object_id
INNER JOIN sys.schemas s ON s.schema_id = t.schema_id

-- For all tables in all databases
CREATE TABLE ##ctTables (TableName VARCHAR(100));

EXEC sp_MSforeachdb 'USE [?];
INSERT INTO ##ctTables
 SELECT ''[?].['' + s.name + ''].['' + t.name + '']'' AS Table_name
  FROM sys.change_tracking_tables tr
INNER JOIN sys.tables t on t.object_id = tr.object_id
INNER JOIN sys.schemas s on s.schema_id = t.schema_id
';

SELECT *
FROM ##ctTables;

DROP TABLE ##ctTables;

