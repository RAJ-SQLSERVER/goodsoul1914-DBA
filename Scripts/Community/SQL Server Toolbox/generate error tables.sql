SET NOCOUNT ON;

DECLARE BuildErrorTables CURSOR FAST_FORWARD FOR
SELECT o.object_id
FROM sys.objects AS o
INNER JOIN sys.schemas AS s
    ON o.schema_id = s.schema_id
WHERE s.name = 'WH'
      AND type_desc = 'USER_TABLE'
      AND o.name <> 'DimDate';

OPEN BuildErrorTables;

DECLARE @object_id INT;

FETCH NEXT FROM BuildErrorTables
INTO @object_id;

DECLARE @BuildErrorTable TABLE (tsql VARCHAR(500) NULL);

WHILE @@FETCH_STATUS = 0
BEGIN

    INSERT INTO @BuildErrorTable (tsql)
    SELECT 'IF EXISTS (SELECT * FROM sys.objects o inner join sys.schemas s on o.schema_id = s.schema_id where o.name  = '''
           + OBJECT_NAME (@object_id) + ''' and s.name = ''ERROR'')';

    INSERT INTO @BuildErrorTable (tsql)
    SELECT 'DROP table ERROR.[' + CONVERT (sysname, OBJECT_NAME (@object_id)) + ']';

    INSERT INTO @BuildErrorTable (tsql)
    SELECT 'GO';

    INSERT INTO @BuildErrorTable (tsql)
    SELECT 'create table ERROR.[' + CONVERT (sysname, OBJECT_NAME (@object_id)) + '] (';

    INSERT INTO @BuildErrorTable (tsql)
    SELECT '	ID bigint not null IDENTITY(1,1) PRIMARY KEY ';

    INSERT INTO @BuildErrorTable (tsql)
    SELECT ', ' + c.name + ' '
           + CASE
                 WHEN t.name IN ( 'binary', 'sysname', 'smallint', 'int', 'bigint', 'decimal', 'float', 'real', 'date',
                                  'time', 'datetime', 'datetime2', 'datetimeoffset', 'timestamp', 'numeric', 'money',
                                  'smallmoney'
                 ) THEN 'varchar (100)'
                 WHEN t.name IN ( 'bit', 'tinyint' ) THEN 'varchar (10)'
                 WHEN t.name IN ( 'char', 'varchar' )
                      AND c.max_length <= 4000 THEN 'varchar (' + CAST(c.max_length * 2 AS VARCHAR(5)) + ')'
                 WHEN t.name IN ( 'char', 'varchar' )
                      AND c.max_length > 4000 THEN 'varchar (8000)'
                 WHEN t.name IN ( 'nchar', 'nvarchar' )
                      AND c.max_length <= 2000 THEN 'nvarchar (' + CAST(c.max_length * 2 AS VARCHAR(5)) + ')'
                 WHEN t.name IN ( 'nchar', 'nvarchar' )
                      AND c.max_length > 2000 THEN 'nvarchar (4000)'
                 WHEN t.name IN ( 'text' ) THEN 'varchar (8000)'
                 WHEN t.name IN ( 'ntext' ) THEN 'nvarchar (4000)'
                 ELSE 'varchar(8000)'
             END + ' NULL' AS "column_name"
    FROM sys.objects AS o
    INNER JOIN sys.schemas AS s
        ON o.schema_id = s.schema_id
    INNER JOIN sys.columns AS c
        ON c.object_id = o.object_id
    INNER JOIN sys.types AS t
        ON c.user_type_id = t.user_type_id
    WHERE o.object_id = @object_id;

    INSERT INTO @BuildErrorTable (tsql)
    SELECT ', ErrorDate datetime2(0) not null constraint DF_'
           + REPLACE (CONVERT (sysname, OBJECT_NAME (@object_id)), ' ', '_') + '_ErrorDate DEFAULT (getdate())';
    INSERT INTO @BuildErrorTable (tsql)
    SELECT ', ErrorText varchar(100) null';
    INSERT INTO @BuildErrorTable (tsql)
    SELECT ', ErrorCode varchar(100) null';
    INSERT INTO @BuildErrorTable (tsql)
    SELECT ', AuditID int null';

    INSERT INTO @BuildErrorTable (tsql)
    SELECT ');';

    INSERT INTO @BuildErrorTable (tsql)
    SELECT 'go';

    FETCH NEXT FROM BuildErrorTables
    INTO @object_id;

END;


SELECT *
FROM @BuildErrorTable;