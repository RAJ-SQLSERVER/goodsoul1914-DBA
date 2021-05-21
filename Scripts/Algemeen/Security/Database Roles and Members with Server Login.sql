-------------------------------------------------------------------------------
-- List Database Roles and Members with Server Login 
-------------------------------------------------------------------------------
SELECT ROL.name AS RoleName,
       MEM.name AS MemberName,
       MEM.type_desc AS MemberType,
       MEM.default_schema_name AS DefaultSchema,
       SP.name AS ServerLogin
FROM sys.database_role_members AS DRM
    INNER JOIN sys.database_principals AS ROL
        ON DRM.role_principal_id = ROL.principal_id
    INNER JOIN sys.database_principals AS MEM
        ON DRM.member_principal_id = MEM.principal_id
    INNER JOIN sys.server_principals AS SP
        ON MEM.sid = SP.sid
ORDER BY RoleName,
         MemberName;