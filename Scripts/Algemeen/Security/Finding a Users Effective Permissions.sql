EXECUTE AS LOGIN = 'DT-RSD-01\mboom';

SELECT o.name,
       a.entity_name,
       a.subentity_name,
       a.permission_name
FROM sys.objects AS o
CROSS APPLY sys.fn_my_permissions (CONCAT (QUOTENAME (SCHEMA_NAME (schema_id)), '.', QUOTENAME (o.name)), 'OBJECT') AS a
UNION ALL
SELECT d.name,
       a.entity_name,
       a.subentity_name,
       a.permission_name
FROM sys.databases AS d
CROSS APPLY fn_my_permissions (QUOTENAME (d.name), 'DATABASE') AS a
UNION ALL
SELECT @@SERVERNAME COLLATE Latin1_General_CI_AS,
       a.entity_name,
       a.subentity_name,
       a.permission_name
FROM fn_my_permissions (NULL, 'SERVER') AS a
ORDER BY 1;

REVERT;