-------------------------------------------------------------------------------
-- Script out database role and its securables
-------------------------------------------------------------------------------

DECLARE @RoleName VARCHAR(50) = 'hotflo_data_read';
DECLARE @Script VARCHAR(MAX) = 'CREATE ROLE ' + @RoleName + ';' + CHAR (13);

SELECT @Script
    = @Script + 'GRANT ' + prm.permission_name + ' ON ' + OBJECT_NAME (major_id) + ' TO ' + rol.name + ';'
      + CHAR (13) COLLATE SQL_Latin1_General_CP1_CI_AS
FROM sys.database_permissions AS prm
JOIN sys.database_principals AS rol
    ON prm.grantee_principal_id = rol.principal_id
WHERE rol.name = @RoleName;

PRINT @Script;