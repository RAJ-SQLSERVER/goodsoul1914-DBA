-------------------------------------------------------------------------------
-- Script Date        : 19th February 2010
-- Script Author      : Perry Whittle
-- Script Description : Returns all server logins, any server roles they hold 
--                      and server level permissions assigned.
-------------------------------------------------------------------------------

SELECT sp.name AS ServerPrincipal,
       sp.type_desc AS LoginType,
       CASE sp.is_disabled
           WHEN 0 THEN
               'No'
           WHEN 1 THEN
               'Yes'
       END AS UserDisabled,
       sp.create_date AS DateCreated,
       sp.modify_date AS DateModified,
       sp.default_database_name AS DefaultDB,
       sp.default_language_name AS DefaultLang,
       ISNULL(STUFF(
                       (
                           SELECT ',' + ssp22.name
                           FROM sys.server_principals AS ssp2
                               INNER JOIN sys.server_role_members AS ssrm2
                                   ON ssp2.principal_id = ssrm2.member_principal_id
                               INNER JOIN sys.server_principals AS ssp22
                                   ON ssrm2.role_principal_id = ssp22.principal_id
                           WHERE ssp2.principal_id = sp.principal_id
                           ORDER BY ssp2.name
                           FOR XML PATH(N''), TYPE
                       ).value(N'.[1]', N'nvarchar(max)'),
                       1,
                       1,
                       N''
                   ),
              'NoRolesHeld'
             ) AS ListofServerRoles,
       ISNULL(
                 STUFF(
                          (
                              SELECT ';' + ' Permission [' + sspm3.permission_name + '] is ['
                                     + CASE
                                           WHEN sspm3.state_desc = 'GRANT' THEN
                                               'Granted]'
                                           WHEN sspm3.state_desc = 'DENY' THEN
                                               'Denied]'
                                       END AS PermGrants
                              FROM sys.server_principals AS ssp3
                                  INNER JOIN sys.server_permissions AS sspm3
                                      ON ssp3.principal_id = sspm3.grantee_principal_id
                              WHERE sspm3.class = 100
                                    AND sspm3.grantee_principal_id = sp.principal_id
                              FOR XML PATH(N''), TYPE
                          ).value(N'.[1]', N'nvarchar(max)'),
                          1,
                          1,
                          N''
                      ),
                 'NoServerPermissions'
             ) + ' on ' + @@servername + '' AS PermGrants
FROM sys.server_principals AS sp
WHERE sp.type IN ( 'S', 'G', 'U' )
      AND sp.name NOT LIKE '##%##'
ORDER BY ServerPrincipal;