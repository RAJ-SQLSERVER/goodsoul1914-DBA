-------------------------------------------------------------------------------
-- List all Server Permissions
-------------------------------------------------------------------------------
SELECT entity_name,
       subentity_name,
       permission_name
FROM dbo.fn_my_permissions(NULL, 'SERVER')
ORDER BY permission_name;

-------------------------------------------------------------------------------
-- List all Server Permissions and their members
-------------------------------------------------------------------------------
SELECT GRE.name AS Grantee,
       GRO.name AS Grantor,
       PER.class_desc AS PermClass,
       PER.permission_name AS PermName,
       PER.state_desc AS PermState,
       COALESCE(PRC.name, EP.name, N'') AS ObjectName,
       COALESCE(PRC.type_desc, EP.type_desc, N'') AS ObjectType
FROM sys.server_permissions AS PER
    INNER JOIN sys.server_principals AS GRO
        ON PER.grantor_principal_id = GRO.principal_id
    INNER JOIN sys.server_principals AS GRE
        ON PER.grantee_principal_id = GRE.principal_id
    LEFT JOIN sys.server_principals AS PRC
        ON PER.class = 101
           AND PER.major_id = PRC.principal_id
    LEFT JOIN sys.endpoints AS EP
        ON PER.class = 105
           AND PER.major_id = EP.endpoint_id
ORDER BY Grantee,
         PermName;
GO