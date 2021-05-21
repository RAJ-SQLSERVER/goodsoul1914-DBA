SELECT DB_NAME() AS "Database",
       p.name,
       p.type_desc,
       dbp.state_desc,
       dbp.permission_name,
       so.name,
       so.type_desc
FROM sys.database_permissions AS dbp
    LEFT JOIN sys.objects AS so
        ON dbp.major_id = so.object_id
    LEFT JOIN sys.database_principals AS p
        ON dbp.grantee_principal_id = p.principal_id
WHERE p.name = 'Mary'
ORDER BY so.name,
         dbp.permission_name;