USE master;
GO

IF OBJECT_ID ('dbo.usp_SecurityAuditServerLogins') IS NULL
    EXECUTE sp_executesql N'CREATE PROCEDURE dbo.usp_SecurityAuditServerLogins AS RETURN';
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- =============================================
-- Author:      Raul Gonzalez @SQLDoubleG
-- Create date: 28/06/2013
-- Description: Returns Server Login information
--              This SP returns
--                  - Server logins with server roles and permissions, logins included if it is a Windows Group, groups the login belong to and database users mapped to the login
--
-- Change log:  2014-03-04 RAG  - Removed the last 2 resultsets and included that info into que main one, columns [IncludedLogins] and [IncludedInWindowsGroups]
--                              - Functionality to search a AD user when is included in a Windows Group
--              2014-05-15 RAG  - Included list of database users the login is mapped to 
--              2014-09-09 RAG  - Added column CREATE_LOGIN, which contain the script required to recreate the login and its server roles if any
--              2016-05-13 RAG  - Fixed bug when scripting server roles
--              2017-03-14 RAG  - Removed deprecated view syslogins
--                              - Added state_desc to the permisssion list (DENY, REVOKE, GRANT, GRANT_WITH_GRANT_OPTION)
--                              - Added server permisssions to the CREATE LOGIN statement
--
-- Copyright:   (C) 2017 Raul Gonzalez (@SQLDoubleG https://www.sqldoubleg.com)
--
--              THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
--              ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
--              TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
--              PARTICULAR PURPOSE.
--
--              THE AUTHOR SHALL NOT BE LIABLE TO YOU OR ANY THIRD PARTY FOR ANY INDIRECT, 
--              SPECIAL, INCIDENTAL, PUNITIVE, COVER, OR CONSEQUENTIAL DAMAGES OF ANY KIND
--
--              YOU MAY ALTER THIS CODE FOR YOUR OWN *NON-COMMERCIAL* PURPOSES. YOU MAY
--              REPUBLISH ALTERED CODE AS LONG AS YOU INCLUDE THIS COPYRIGHT AND GIVE DUE CREDIT. 
--
-- =============================================
ALTER PROCEDURE dbo.usp_SecurityAuditServerLogins @loginName sysname = NULL
AS
    BEGIN

        SET NOCOUNT ON;

        DECLARE @sqlString NVARCHAR(4000);

        DECLARE @groupName   sysname,
                @numGroups   INT,
                @countGroups INT = 1;

        DECLARE @version NVARCHAR(128) = CONVERT (NVARCHAR(128), SERVERPROPERTY ('ProductVersion'));
        DECLARE @numericVersion DECIMAL(3, 1) = CONVERT (
                                                    DECIMAL(3, 1), (LEFT(@version, CHARINDEX ('.', @version, 0) + 1))
                                                );

        CREATE TABLE #usersInGroups (
            accountName    sysname,
            Type           sysname,
            privilege      sysname,
            mappedLogin    sysname,
            permissionPath sysname
        );

        CREATE TABLE #allDbUsers (database_name sysname, database_username sysname, sid VARBINARY(85));

        DECLARE @GO CHAR(4) = CHAR (10) + 'GO' + CHAR (10);

        SELECT IDENTITY(INT, 1, 1) AS "ID",
               name AS "GroupName"
        INTO #windowsGroups
        FROM sys.server_principals AS sp
        WHERE sp.type = 'G'
              AND name NOT LIKE 'NT SERVICE\%';

        SET @numGroups = @@ROWCOUNT;

        WHILE @countGroups <= @numGroups
            BEGIN
                SELECT @groupName = GroupName
                FROM #windowsGroups
                WHERE ID = @countGroups;

                SET @sqlString = N'EXEC XP_LOGININFO ' + QUOTENAME (@groupName) + N', [members]';

                INSERT INTO #usersInGroups
                EXECUTE sp_executesql @sqlString;

                SET @countGroups += 1;

            END;

        -- Get all DB users
        EXECUTE sp_MSforeachdb N'
        USE [?]
        INSERT INTO #allDbUsers
            SELECT DB_NAME() AS database_name
                    , name AS database_username
                    , sid AS principal_sid
                FROM sys.database_principals
                WHERE is_fixed_role = 0
                    AND type <> ''R''
                    AND sid IS NOT NULL
                    AND name NOT IN (''guest'')
    '   ;

        -- All server logins with their server roles
        SELECT @@SERVERNAME AS "ServerName",
               sp.principal_id,
               sp.name AS "LoginName",
               sp.type_desc AS "LoginType",
               CASE
                   WHEN sp.is_disabled = 1 THEN 'Yes'
                   ELSE 'No'
               END AS "IsDisabled",
               sp.default_database_name,
               STUFF ((
                          SELECT ', ' + sp2.name
                          FROM sys.server_role_members AS srm
                          LEFT JOIN sys.server_principals AS sp2
                              ON sp2.principal_id = srm.role_principal_id
                          WHERE srm.member_principal_id = sp.principal_id
                          FOR XML PATH ('')
                      ),
                      1,
                      2,
                      ''
               ) AS "ServerRoles",
               STUFF ((
                          SELECT ', ' + p.state_desc + ' ' + p.permission_name
                          FROM sys.server_permissions AS p
                          WHERE p.grantee_principal_id = sp.principal_id
                          FOR XML PATH ('')
                      ),
                      1,
                      2,
                      ''
               ) AS "ServerPermissions",
               STUFF ((
                          SELECT ', ' + QUOTENAME (mappedLogin)
                          FROM #usersInGroups AS u
                          WHERE u.permissionPath = sp.name
                          ORDER BY mappedLogin
                          FOR XML PATH ('')
                      ),
                      1,
                      2,
                      ''
               ) AS "IncludedLogins",
               STUFF ((
                          SELECT ', ' + QUOTENAME (permissionPath)
                          FROM #usersInGroups AS u
                          WHERE u.mappedLogin = sp.name
                          ORDER BY permissionPath
                          FOR XML PATH ('')
                      ),
                      1,
                      2,
                      ''
               ) AS "IncludedInWindowsGroups",
               STUFF ((
                          SELECT ', ' + QUOTENAME (database_name) + '.' + QUOTENAME (database_username)
                          FROM #allDbUsers AS u
                          WHERE u.sid = sp.sid
                          ORDER BY database_name
                          FOR XML PATH ('')
                      ),
                      1,
                      2,
                      ''
               ) AS "MappedToDBuser",
               STUFF (
               (
                   SELECT @GO
                          + CASE
                                WHEN @numericVersion >= 11 THEN
                                    'ALTER SERVER ROLE ' + QUOTENAME (sp2.name) + ' DROP MEMBER ' + QUOTENAME (sp.name)
                                ELSE
                                    'EXECUTE sys.sp_dropsrvrolemember ' + QUOTENAME (sp.name) + ', '
                                    + QUOTENAME (sp2.name)
                            END
                   FROM sys.server_role_members AS srm
                   LEFT JOIN sys.server_principals AS sp2
                       ON sp2.principal_id = srm.role_principal_id
                   WHERE srm.member_principal_id = sp.principal_id
                   FOR XML PATH ('')
               ),
               1,
               4,
               ''
               ) AS "DROP_SERVER_ROLE",
               'USE [master]' + @GO
               + CASE
                     WHEN sp.type IN ( 'U', 'G' ) THEN
                         'CREATE LOGIN ' + QUOTENAME (sp.name) + ' FROM WINDOWS WITH DEFAULT_DATABASE = '
                         + QUOTENAME (sp.default_database_name)
                     ELSE
                         'CREATE LOGIN ' + QUOTENAME (sp.name) + ' WITH PASSWORD = '
                         + CONVERT (NVARCHAR(256), LOGINPROPERTY (sp.name, 'PasswordHash'), 1) + ' HASHED, SID = '
                         + CONVERT (NVARCHAR(256), (sp.sid), 1) + ', DEFAULT_DATABASE = '
                         + QUOTENAME (sp.default_database_name) + ', CHECK_POLICY = '
                         + CASE
                               WHEN sqll.is_policy_checked = 1 THEN 'ON'
                               ELSE 'OFF'
                           END + ', CHECK_EXPIRATION = ' + CASE
                                                               WHEN sqll.is_expiration_checked = 1 THEN 'ON'
                                                               ELSE 'OFF'
                                                           END + @GO
                         + (
                             SELECT p.state_desc + ' ' + p.permission_name + ' TO ' + QUOTENAME (sp.name) + @GO AS "text()"
                             FROM sys.server_permissions AS p
                             WHERE p.grantee_principal_id = sp.principal_id
                             FOR XML PATH ('')
                         )
                 END + CASE
                           WHEN sp.is_disabled = 1 THEN 'ALTER LOGIN ' + QUOTENAME (sp.name) + ' DISABLE' + @GO
                           ELSE ''
                       END
               + ISNULL (
                     STUFF (
                     (
                         SELECT CHAR (10)
                                + CASE
                                      WHEN @numericVersion >= 11 THEN
                                          'ALTER SERVER ROLE ' + QUOTENAME (name) + ' ADD MEMBER '
                                          + QUOTENAME (sp.name)
                                      ELSE
                                          'EXECUTE sp_addsrvrolemember ' + QUOTENAME (sp.name) + ', '
                                          + QUOTENAME (name)
                                  END + CHAR (10) + 'GO'
                         FROM sys.server_role_members AS rm
                         INNER JOIN sys.server_principals AS r
                             ON r.principal_id = rm.role_principal_id
                                AND r.type = 'R'
                         WHERE rm.member_principal_id = sp.principal_id
                         FOR XML PATH ('')
                     ),
                     1,
                     1,
                     ''
                     ),
                     ''
                 ) AS "CREATE_LOGIN"
        FROM sys.server_principals AS sp
        LEFT JOIN sys.sql_logins AS sqll
            ON sqll.sid = sp.sid
        WHERE sp.type <> 'R' -- R = Server role
              AND sp.name NOT LIKE '#%#'
              AND sp.name NOT LIKE 'NT %\%'
              AND (
                  sp.name LIKE ISNULL (@loginName, sp.name)
                  -- Lookup for the given login within all windows groups in the server
                  OR EXISTS (
            SELECT 1
            FROM #usersInGroups AS uig
            WHERE uig.permissionPath = sp.name
                  AND uig.mappedLogin LIKE ISNULL (@loginName, uig.mappedLogin)
        )
              )
        ORDER BY ServerRoles DESC,
                 LoginType ASC,
                 LoginName ASC;

        DROP TABLE #windowsGroups;
        DROP TABLE #usersInGroups;
    END;
GO