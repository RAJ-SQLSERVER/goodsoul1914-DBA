-------------------------------------------------------------------------------
-- List all Database Permissions 
-------------------------------------------------------------------------------

SELECT entity_name,
       subentity_name,
       permission_name
FROM dbo.fn_my_permissions (NULL, 'DATABASE')
ORDER BY permission_name;

-------------------------------------------------------------------------------
-- List all Database Permissions and their members
-------------------------------------------------------------------------------

SELECT PER.class_desc AS "PermClass",
       PER.type AS "PermType",
       ISNULL (SCH.name + N'.' + OBJ.name, DB_NAME ()) AS "ObjectName",
       ISNULL (COL.name, N'') AS "ColumnName",
       PRC.name AS "PrincName",
       PRC.type_desc AS "PrincType",
       GRT.name AS "GrantorName",
       PER.permission_name AS "PermName",
       PER.state_desc AS "PermState"
FROM sys.database_permissions AS PER
INNER JOIN sys.database_principals AS PRC
    ON PER.grantee_principal_id = PRC.principal_id
INNER JOIN sys.database_principals AS GRT
    ON PER.grantor_principal_id = GRT.principal_id
LEFT JOIN sys.objects AS OBJ
    ON PER.major_id = OBJ.object_id
LEFT JOIN sys.schemas AS SCH
    ON OBJ.schema_id = SCH.schema_id
LEFT JOIN sys.columns AS COL
    ON PER.major_id = COL.object_id
       AND PER.minor_id = COL.column_id
WHERE PER.major_id >= 0
ORDER BY PermClass,
         ObjectName,
         PrincName,
         PermType,
         PermName;

-------------------------------------------------------------------------------
-- List all Permissions
--
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-functions/sys-fn-my-permissions-transact-sql
-------------------------------------------------------------------------------

SELECT sys.schemas.name AS "Schema",
       sys.objects.name AS "Object",
       sys.database_principals.name AS "username",
       sys.database_permissions.type AS "permissions_type",
       sys.database_permissions.permission_name,
       sys.database_permissions.state AS "permission_state",
       sys.database_permissions.state_desc,
       state_desc + ' ' + permission_name + ' on [' + sys.schemas.name + '].[' + sys.objects.name + '] to ['
       + sys.database_principals.name + ']' COLLATE Latin1_General_CI_AS
FROM sys.database_permissions
JOIN sys.objects
    ON sys.database_permissions.major_id = sys.objects.object_id
JOIN sys.schemas
    ON sys.objects.schema_id = sys.schemas.schema_id
JOIN sys.database_principals
    ON sys.database_permissions.grantee_principal_id = sys.database_principals.principal_id
ORDER BY 1,
         2,
         3,
         5;