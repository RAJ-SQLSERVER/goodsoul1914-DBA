SET NOCOUNT OFF;

IF OBJECT_ID (N'tempdb..##temp1') IS NOT NULL DROP TABLE ##temp1;

CREATE TABLE ##temp1 (query VARCHAR(1000));

INSERT INTO ##temp1
SELECT 'use ' + DB_NAME () + ';';

INSERT INTO ##temp1
SELECT 'go';

/*creating database roles*/
INSERT INTO ##temp1
SELECT 'if DATABASE_PRINCIPAL_ID(''' + name + ''')  is null 
                    exec sp_addrole ''' + name + ''''
FROM sysusers
WHERE issqlrole = 1
      AND (sid IS NOT NULL AND sid <> 0x0);

/*creating application roles*/
INSERT INTO ##temp1
SELECT 'if DATABASE_PRINCIPAL_ID(' + CHAR (39) + name + CHAR (39)
       + ')
                    is null CREATE APPLICATION ROLE [' + name + '] WITH DEFAULT_SCHEMA = [' + default_schema_name
       + '], Password=' + CHAR (39) + 'Pass$w0rd123' + CHAR (39) + ' ;'
FROM sys.database_principals
WHERE type_desc = 'APPLICATION_ROLE';

INSERT INTO ##temp1
SELECT CASE
           WHEN state_desc = 'GRANT_WITH_GRANT_OPTION' THEN
               SUBSTRING (state_desc, 0, 6) + ' ' + permission_name + ' to ' + '[' + USER_NAME (grantee_principal_id)
               + ']' + ' WITH GRANT OPTION ;'
           ELSE state_desc + ' ' + permission_name + ' to ' + '[' + USER_NAME (grantee_principal_id) + ']' + ' ;'
       END
FROM sys.database_permissions
WHERE class = 0
      AND USER_NAME (grantee_principal_id) NOT IN ( 'dbo', 'guest', 'sys', 'information_schema' );

INSERT INTO ##temp1
SELECT CASE
           WHEN state_desc = 'GRANT_WITH_GRANT_OPTION' THEN
               SUBSTRING (state_desc, 0, 6) + ' ' + permission_name + ' on ' + OBJECT_SCHEMA_NAME (major_id) + '.['
               + OBJECT_NAME (major_id) + '] to ' + '[' + USER_NAME (grantee_principal_id) + ']'
               + ' with grant option ;'
           ELSE
               state_desc + ' ' + permission_name + ' on ' + OBJECT_SCHEMA_NAME (major_id) + '.['
               + OBJECT_NAME (major_id) + '] to ' + '[' + USER_NAME (grantee_principal_id) + ']' + ' ;'
       END
FROM sys.database_permissions
WHERE class = 1
      AND USER_NAME (grantee_principal_id) NOT IN ( 'public' );


INSERT INTO ##temp1
SELECT CASE
           WHEN state_desc = 'GRANT_WITH_GRANT_OPTION' THEN
               SUBSTRING (state_desc, 0, 6) + ' ' + permission_name + ' ON schema::[' + sa.name + '] to ['
               + USER_NAME (dp.grantee_principal_id) + '] with grant option ;'
           ELSE
               state_desc + ' ' + permission_name + ' ON schema::[' + sa.name + '] to ['
               + USER_NAME (dp.grantee_principal_id) + '] ;' COLLATE Latin1_General_CI_AS
       END
FROM sys.database_permissions AS dp
INNER JOIN sys.schemas AS sa
    ON sa.schema_id = dp.major_id
WHERE dp.class = 3;

INSERT INTO ##temp1
SELECT CASE
           WHEN state_desc = 'GRANT_WITH_GRANT_OPTION' THEN
               SUBSTRING (state_desc, 0, 6) + ' ' + permission_name + ' ON APPLICATION  ROLE::[' + sa.name + '] to ['
               + USER_NAME (dp.grantee_principal_id) + '] with grant option ;'
           ELSE
               state_desc + ' ' + permission_name + ' ON  APPLICATION ROLE::[' + sa.name + '] to ['
               + USER_NAME (dp.grantee_principal_id) + '] ;' COLLATE Latin1_General_CI_AS
       END
FROM sys.database_permissions AS dp
INNER JOIN sys.database_principals AS sa
    ON sa.principal_id = dp.major_id
WHERE dp.class = 4
      AND sa.type = 'A';

INSERT INTO ##temp1
SELECT CASE
           WHEN state_desc = 'GRANT_WITH_GRANT_OPTION' THEN
               SUBSTRING (state_desc, 0, 6) + ' ' + permission_name + ' ON   ROLE::[' + sa.name + '] to ['
               + USER_NAME (dp.grantee_principal_id) + '] with grant option ;'
           ELSE
               state_desc + ' ' + permission_name + ' ON   ROLE::[' + sa.name + '] to ['
               + USER_NAME (dp.grantee_principal_id) + '] ;' COLLATE Latin1_General_CI_AS
       END
FROM sys.database_permissions AS dp
INNER JOIN sys.database_principals AS sa
    ON sa.principal_id = dp.major_id
WHERE dp.class = 4
      AND sa.type = 'R';

INSERT INTO ##temp1
SELECT CASE
           WHEN state_desc = 'GRANT_WITH_GRANT_OPTION' THEN
               SUBSTRING (state_desc, 0, 6) + ' ' + permission_name + ' ON ASSEMBLY::[' + sa.name + '] to ['
               + USER_NAME (dp.grantee_principal_id) + '] with grant option ;'
           ELSE
               state_desc + ' ' + permission_name + ' ON ASSEMBLY::[' + sa.name + '] to ['
               + USER_NAME (dp.grantee_principal_id) + '] ;' COLLATE Latin1_General_CI_AS
       END
FROM sys.database_permissions AS dp
INNER JOIN sys.assemblies AS sa
    ON sa.assembly_id = dp.major_id
WHERE dp.class = 5;

INSERT INTO ##temp1
SELECT CASE
           WHEN state_desc = 'GRANT_WITH_GRANT_OPTION' THEN
               SUBSTRING (state_desc, 0, 6) + '  ' + permission_name + ' ON type::[' + SCHEMA_NAME (schema_id) + '].['
               + sa.name + '] to [' + USER_NAME (dp.grantee_principal_id) + '] with grant option ;'
           ELSE
               state_desc + ' ' + permission_name + ' ON type::[' + SCHEMA_NAME (schema_id) + '].[' + sa.name
               + '] to [' + USER_NAME (dp.grantee_principal_id) + '] ;' COLLATE Latin1_General_CI_AS
       END
FROM sys.database_permissions AS dp
INNER JOIN sys.types AS sa
    ON sa.user_type_id = dp.major_id
WHERE dp.class = 6;


INSERT INTO ##temp1
SELECT CASE
           WHEN state_desc = 'GRANT_WITH_GRANT_OPTION' THEN
               SUBSTRING (state_desc, 0, 6) + '  ' + permission_name + ' ON  XML SCHEMA COLLECTION::['
               + SCHEMA_NAME (schema_id) + '].[' + sa.name + '] to [' + USER_NAME (dp.grantee_principal_id)
               + '] with grant option ;'
           ELSE
               state_desc + ' ' + permission_name + ' ON  XML SCHEMA COLLECTION::[' + SCHEMA_NAME (schema_id) + '].['
               + sa.name + '] to [' + USER_NAME (dp.grantee_principal_id) + '];' COLLATE Latin1_General_CI_AS
       END
FROM sys.database_permissions AS dp
INNER JOIN sys.xml_schema_collections AS sa
    ON sa.xml_collection_id = dp.major_id
WHERE dp.class = 10;



INSERT INTO ##temp1
SELECT CASE
           WHEN state_desc = 'GRANT_WITH_GRANT_OPTION' THEN
               SUBSTRING (state_desc, 0, 6) + '  ' + permission_name + ' ON message type::[' + sa.name + '] to ['
               + USER_NAME (dp.grantee_principal_id) + '] with grant option ;'
           ELSE
               state_desc + ' ' + permission_name + ' ON message type::[' + sa.name + '] to ['
               + USER_NAME (dp.grantee_principal_id) + '] ;' COLLATE Latin1_General_CI_AS
       END
FROM sys.database_permissions AS dp
INNER JOIN sys.service_message_types AS sa
    ON sa.message_type_id = dp.major_id
WHERE dp.class = 15;


INSERT INTO ##temp1
SELECT CASE
           WHEN state_desc = 'GRANT_WITH_GRANT_OPTION' THEN
               SUBSTRING (state_desc, 0, 6) + '  ' + permission_name + ' ON contract::[' + sa.name + '] to ['
               + USER_NAME (dp.grantee_principal_id) + '] with grant option ;'
           ELSE
               state_desc + ' ' + permission_name + ' ON contract::[' + sa.name + '] to ['
               + USER_NAME (dp.grantee_principal_id) + '] ;' COLLATE Latin1_General_CI_AS
       END
FROM sys.database_permissions AS dp
INNER JOIN sys.service_contracts AS sa
    ON sa.service_contract_id = dp.major_id
WHERE dp.class = 16;



INSERT INTO ##temp1
SELECT CASE
           WHEN state_desc = 'GRANT_WITH_GRANT_OPTION' THEN
               SUBSTRING (state_desc, 0, 6) + '  ' + permission_name + ' ON SERVICE::[' + sa.name + '] to ['
               + USER_NAME (dp.grantee_principal_id) + '] with grant option ;'
           ELSE
               state_desc + '  ' + permission_name + ' ON SERVICE::[' + sa.name + '] to ['
               + USER_NAME (dp.grantee_principal_id) + '] ;' COLLATE Latin1_General_CI_AS
       END
FROM sys.database_permissions AS dp
INNER JOIN sys.services AS sa
    ON sa.service_id = dp.major_id
WHERE dp.class = 17;


INSERT INTO ##temp1
SELECT CASE
           WHEN state_desc = 'GRANT_WITH_GRANT_OPTION' THEN
               SUBSTRING (state_desc, 0, 6) + '  ' + permission_name + ' ON REMOTE SERVICE BINDING::[' + sa.name
               + '] to [' + USER_NAME (dp.grantee_principal_id) + '] with grant option ;'
           ELSE
               state_desc + ' ' + permission_name + ' ON REMOTE SERVICE BINDING::[' + sa.name + '] to ['
               + USER_NAME (dp.grantee_principal_id) + '] ;' COLLATE Latin1_General_CI_AS
       END
FROM sys.database_permissions AS dp
INNER JOIN sys.remote_service_bindings AS sa
    ON sa.remote_service_binding_id = dp.major_id
WHERE dp.class = 18;

INSERT INTO ##temp1
SELECT CASE
           WHEN state_desc = 'GRANT_WITH_GRANT_OPTION' THEN
               SUBSTRING (state_desc, 0, 6) + '  ' + permission_name + ' ON route::[' + sa.name + '] to ['
               + USER_NAME (dp.grantee_principal_id) + '] with grant option ;'
           ELSE
               state_desc + ' ' + permission_name + ' ON route::[' + sa.name + '] to ['
               + USER_NAME (dp.grantee_principal_id) + '] ;' COLLATE Latin1_General_CI_AS
       END
FROM sys.database_permissions AS dp
INNER JOIN sys.routes AS sa
    ON sa.route_id = dp.major_id
WHERE dp.class = 19;

INSERT INTO ##temp1
SELECT CASE
           WHEN state_desc = 'GRANT_WITH_GRANT_OPTION' THEN
               SUBSTRING (state_desc, 0, 6) + '  ' + permission_name + ' ON FULLTEXT CATALOG::[' + sa.name + '] to ['
               + USER_NAME (dp.grantee_principal_id) + '] with grant option ;'
           ELSE
               state_desc + ' ' + permission_name + ' ON FULLTEXT CATALOG::[' + sa.name + '] to ['
               + USER_NAME (dp.grantee_principal_id) + '] ;' COLLATE Latin1_General_CI_AS
       END
FROM sys.database_permissions AS dp
INNER JOIN sys.fulltext_catalogs AS sa
    ON sa.fulltext_catalog_id = dp.major_id
WHERE dp.class = 23;

INSERT INTO ##temp1
SELECT CASE
           WHEN state_desc = 'GRANT_WITH_GRANT_OPTION' THEN
               SUBSTRING (state_desc, 0, 6) + '  ' + permission_name + ' ON SYMMETRIC KEY::[' + sa.name + '] to ['
               + USER_NAME (dp.grantee_principal_id) + '] with grant option ;'
           ELSE
               state_desc + ' ' + permission_name + ' ON SYMMETRIC KEY::[' + sa.name + '] to ['
               + USER_NAME (dp.grantee_principal_id) + '] ;' COLLATE Latin1_General_CI_AS
       END
FROM sys.database_permissions AS dp
INNER JOIN sys.symmetric_keys AS sa
    ON sa.symmetric_key_id = dp.major_id
WHERE dp.class = 24;

INSERT INTO ##temp1
SELECT CASE
           WHEN state_desc = 'GRANT_WITH_GRANT_OPTION' THEN
               SUBSTRING (state_desc, 0, 6) + '  ' + permission_name + ' ON certificate::[' + sa.name + '] to ['
               + USER_NAME (dp.grantee_principal_id) + '] with grant option ;'
           ELSE
               state_desc + ' ' + permission_name + ' ON certificate::[' + sa.name + '] to ['
               + USER_NAME (dp.grantee_principal_id) + '] ;' COLLATE Latin1_General_CI_AS
       END
FROM sys.database_permissions AS dp
INNER JOIN sys.certificates AS sa
    ON sa.certificate_id = dp.major_id
WHERE dp.class = 25;


INSERT INTO ##temp1
SELECT CASE
           WHEN state_desc = 'GRANT_WITH_GRANT_OPTION' THEN
               SUBSTRING (state_desc, 0, 6) + '  ' + permission_name + ' ON ASYMMETRIC KEY::[' + sa.name + '] to ['
               + USER_NAME (dp.grantee_principal_id) + '] with grant option ;'
           ELSE
               state_desc + ' ' + permission_name + ' ON ASYMMETRIC KEY::[' + sa.name + '] to ['
               + USER_NAME (dp.grantee_principal_id) + '] ;' COLLATE Latin1_General_CI_AS
       END
FROM sys.database_permissions AS dp
INNER JOIN sys.asymmetric_keys AS sa
    ON sa.asymmetric_key_id = dp.major_id
WHERE dp.class = 26;

INSERT INTO ##temp1
SELECT 'exec sp_addrolemember ''' + p.name + ''',' + '[' + m.name + ']' + ' ;'
FROM sys.database_role_members AS rm
JOIN sys.database_principals AS p
    ON rm.role_principal_id = p.principal_id
JOIN sys.database_principals AS m
    ON rm.member_principal_id = m.principal_id
WHERE m.name NOT LIKE 'dbo';


SELECT *
FROM ##temp1;