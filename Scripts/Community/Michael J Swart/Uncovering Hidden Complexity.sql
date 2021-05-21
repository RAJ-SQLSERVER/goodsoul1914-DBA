DECLARE @object_name sysname = 'Sales.SalesOrderDetail';

WITH dependencies AS
(
    SELECT @object_name AS "object_name",
           CAST(QUOTENAME (OBJECT_SCHEMA_NAME (OBJECT_ID (@object_name))) + '.'
                + QUOTENAME (OBJECT_NAME (OBJECT_ID (@object_name))) AS sysname) AS "escaped_name",
           type_desc,
           OBJECT_ID (@object_name) AS "object_id",
           1 AS "is_updated",
           CAST('/' + CAST(OBJECT_ID (@object_name) % 10000 AS VARCHAR(30)) + '/' AS HIERARCHYID) AS "tree",
           0 AS "trigger_parent_id"
    FROM sys.objects
    WHERE object_id = OBJECT_ID (@object_name)
    UNION ALL
    SELECT CAST(OBJECT_SCHEMA_NAME (o.object_id) + '.' + OBJECT_NAME (o.object_id) AS sysname),
           CAST(QUOTENAME (OBJECT_SCHEMA_NAME (o.object_id)) + '.' + QUOTENAME (OBJECT_NAME (o.object_id)) AS sysname),
           o.type_desc,
           o.object_id,
           CASE o.type
               WHEN 'U' THEN re.is_updated
               ELSE 1
           END,
           CAST(d.tree.ToString () + CAST(o.object_id % 10000 AS VARCHAR(30)) + '/' AS HIERARCHYID),
           0 AS "trigger_parent_id"
    FROM dependencies AS d
    CROSS APPLY sys.dm_sql_referenced_entities (d.escaped_name, DEFAULT) AS re
    JOIN sys.objects AS o
        ON o.object_id = ISNULL (
                             re.referenced_id,
                             OBJECT_ID (ISNULL (re.referenced_schema_name, 'dbo') + '.' + re.referenced_entity_name)
                         )
    WHERE tree.GetLevel () < 10
          AND re.referenced_minor_id = 0
          AND o.object_id <> d.trigger_parent_id
          AND CAST(d.tree.ToString () AS VARCHAR(1000))NOT LIKE '%' + CAST(o.object_id % 10000 AS VARCHAR(1000)) + '%'
    UNION ALL
    SELECT CAST(OBJECT_SCHEMA_NAME (t.object_id) + '.' + OBJECT_NAME (t.object_id) AS sysname),
           CAST(QUOTENAME (OBJECT_SCHEMA_NAME (t.object_id)) + '.' + QUOTENAME (OBJECT_NAME (t.object_id)) AS sysname),
           'SQL_TRIGGER',
           t.object_id,
           0 AS "is_updated",
           CAST(d.tree.ToString () + CAST(t.object_id % 10000 AS VARCHAR(30)) + '/' AS HIERARCHYID),
           t.parent_id AS "trigger_parent_id"
    FROM dependencies AS d
    JOIN sys.triggers AS t
        ON d.object_id = t.parent_id
    WHERE d.is_updated = 1
          AND tree.GetLevel () < 10
          AND CAST(d.tree.ToString () AS VARCHAR(1000))NOT LIKE '%' + CAST(t.object_id % 10000 AS VARCHAR(1000)) + '%'
)
SELECT REPLICATE ('—', tree.GetLevel () - 1) + ' ' + object_name,
       type_desc AS "type",
       tree.ToString () AS "dependencies"
FROM dependencies
ORDER BY tree;