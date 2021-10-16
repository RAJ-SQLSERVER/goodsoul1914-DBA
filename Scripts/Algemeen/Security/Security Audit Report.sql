-------------------------------------------------------------------------------
-- SQL Server Login Audit 
--  
-- Developed by: Mayur H. Sanap 
-- Date:        25 oct 2012 
--  
-- This query will generate a report in one table having separate details for 
-- each task like sql server & datbase roles, orphan users details get 
-- separately & orphan logins details separately. 
-------------------------------------------------------------------------------

IF EXISTS (SELECT * FROM tempdb.sys.all_objects WHERE name LIKE '%#Login_Audit%')
    DROP TABLE #Login_Audit;

CREATE TABLE #Login_Audit (
    A NVARCHAR(500),
    B NVARCHAR(500)
        DEFAULT '',
    C NVARCHAR(200)
        DEFAULT '',
    D NVARCHAR(200)
        DEFAULT ''
);
GO

INSERT INTO #Login_Audit (A, B, C, D)
SELECT '--- SQL SERVER SECURITY AUDIT ---' AS "Security Report",
       '-----',
       '-----',
       '-----';
GO

INSERT INTO #Login_Audit (A, B, C, D)
SELECT 'Total Count of Login' AS "Login count",
       'Windows User',
       'SQL server User',
       'Windows Group';
GO

INSERT INTO #Login_Audit
SELECT a,
       b,
       c,
       d
FROM (SELECT COUNT (name) AS "a" FROM sys.syslogins WHERE name NOT LIKE '%#%') AS a , -- total count 
(
    SELECT COUNT (name) AS "b"
    FROM sys.syslogins
    WHERE name NOT LIKE '%#%'
          AND isntuser = 1
) AS b ,                                                                              --for login is windows user  
(
    SELECT COUNT (name) AS "c"
    FROM sys.syslogins
    WHERE name NOT LIKE '%#%'
          AND isntname = 0
) AS c ,                                                                              -- for login is sql server login  
(
    SELECT COUNT (name) AS "d"
    FROM sys.syslogins
    WHERE name NOT LIKE '%#%'
          AND isntgroup = 1
) AS d;
GO

INSERT INTO #Login_Audit (A, B, C, D)
SELECT '--- SYSADMIN SERVER ROLE ASSIGN TO ---' AS "sysadmin_server role",
       ' ----- ',
       ' ----- ',
       ' ----- ';
GO

INSERT INTO #Login_Audit (A, B, C, D)
SELECT 'Login name' AS "Sys Admin role",
       ' Type ',
       ' Login Status ',
       '';
GO

INSERT INTO #Login_Audit (A, B, C)
SELECT a.name AS "Logins",
       a.type_desc,
       CASE a.is_disabled
           WHEN 1 THEN 'Disable'
           WHEN 0 THEN 'Enable'
       END
FROM sys.server_principals AS a
INNER JOIN sys.server_role_members AS b
    ON a.principal_id = b.member_principal_id
WHERE b.role_principal_id = 3
ORDER BY a.name;
GO

INSERT INTO #Login_Audit (A, B, C, D)
SELECT '--- FIXED SERVER ROLE DETAILS ---' AS "Fixed_server role",
       ' ----- ',
       ' ----- ',
       ' ----- ';
GO

INSERT INTO #Login_Audit (A, B, C, D)
SELECT 'ROLE name' AS "Fixed_server role",
       ' Members ',
       ' Type ',
       '';
GO

INSERT INTO #Login_Audit (A, B, C)
SELECT c.name AS "Fixed_roleName",
       a.name AS "logins",
       a.type_desc
FROM sys.server_principals AS a
INNER JOIN sys.server_role_members AS b
    ON a.principal_id = b.member_principal_id
INNER JOIN sys.server_principals AS c
    ON c.principal_id = b.role_principal_id
--WHERE a.principal_id > 250 
ORDER BY c.name;
GO

INSERT INTO #Login_Audit (A, B, C, D)
SELECT '--- FIXED DATABASE ROLES DETAILS ---' AS "Fixed_database_Roles",
       ' ----- ',
       ' ----- ',
       ' ----- ';
GO

INSERT INTO #Login_Audit (A, B, C, D)
SELECT 'Database Name' AS "Fixed_database_Role",
       'Role Name',
       'Member',
       'Type';
GO

INSERT INTO #Login_Audit
EXEC master.dbo.sp_MSforeachdb 'use [?] 
SELECT db_name()as DBNAME, c.name as DB_ROLE ,a.name as Role_Member, a.type_desc 
FROM sys.database_principals a  
  INNER JOIN sys.database_role_members b ON a.principal_id = b.member_principal_id 
  INNER JOIN sys.database_principals c ON c.principal_id = b.role_principal_id 
WHERE a.name <> ''dbo''and c.is_fixed_role=1 ';
GO

------------ used is_fixed = 0 for non fixed database roles(need to run on each database) 

INSERT INTO #Login_Audit (A, B, C, D)
SELECT '--- NON FIXED DATABASE ROLES DETAILS ---' AS "NON_Fixed_database_Roles",
       ' ----- ',
       ' ----- ',
       ' ----- ';
GO

INSERT INTO #Login_Audit (A, B, C, D)
SELECT 'Database Name' AS "Non Fixed_database role",
       'Role Name',
       'Member ',
       'Type';
GO

INSERT INTO #Login_Audit
EXEC master.dbo.sp_MSforeachdb 'use [?] 
SELECT db_name()as DBNAME, c.name as DB_ROLE ,a.name as Role_Member, a.type_desc 
FROM sys.database_principals a  
  INNER JOIN sys.database_role_members b ON a.principal_id = b.member_principal_id 
  INNER JOIN sys.database_principals c ON c.principal_id = b.role_principal_id 
WHERE a.name <> ''dbo''and c.is_fixed_role=0 ';
GO

INSERT INTO #Login_Audit (A, B, C, D)
SELECT '--- SERVER LEVEL PERMISSION DETAILS ---' AS "Server_Level_Permission",
       ' ----- ',
       ' ----- ',
       ' ----- ';
GO

INSERT INTO #Login_Audit (A, B, C, D)
SELECT 'Logins' AS "Server permission",
       'Permission Type',
       ' Permission_desc ',
       'Status';
GO

INSERT INTO #Login_Audit
SELECT b.name,
       a.type,
       a.permission_name,
       a.state_desc
FROM sys.server_permissions AS a
INNER JOIN sys.server_principals AS b
    ON a.grantee_principal_id = b.principal_id
--INNER JOIN sys.server_principals b ON b.principal_id = b.role_principal_id 
WHERE b.name NOT LIKE '%#%'
ORDER BY b.name;
GO

INSERT INTO #Login_Audit (A, B, C, D)
SELECT '--- DATABASE LEVEL PERMISSION DETAILS ---' AS "DATABASE_Level_Permission",
       ' ----- ',
       ' ----- ',
       ' ----- ';
GO

INSERT INTO #Login_Audit (A, B, C, D)
SELECT 'Database Name' AS "DB permission",
       'Login Name',
       ' Permission ',
       'Status';
GO

INSERT INTO #Login_Audit
EXEC master.dbo.sp_MSforeachdb 'use [?] 
SELECT db_name () as DBNAME,b.name as users,a.permission_name,a.state_desc 
FROM sys.database_permissions a  
  INNER JOIN sys.database_principals b ON a.grantee_principal_id = b.principal_id 
  where a.class =0 and b.name <> ''dbo'' and b.name <> ''guest''and   b.name not like ''%#%''';
GO

INSERT INTO #Login_Audit (A, B, C, D)
SELECT '--- PASSWORD POLICY DETAILS ---' AS "Password_ Policy_Details",
       ' ----- ',
       ' ----- ',
       ' ----- ';
GO

INSERT INTO #Login_Audit (A, B, C, D)
SELECT 'Users' AS "Policy",
       'type',
       ' Policy status',
       'Password policy status';
GO

INSERT INTO #Login_Audit
SELECT a.name AS "SQL_Server_Login",
       a.type_desc,
       CASE b.is_policy_checked
           WHEN 1 THEN 'Password Policy Applied'
           ELSE 'Password Policy Not Applied'
       END AS "Password_Policy_Status",
       CASE b.is_expiration_checked
           WHEN 1 THEN 'Password Expiration Check Applied'
           ELSE 'Password Expiration Check Not Applied'
       END AS "Password_Expiration_Check_Status"
FROM sys.server_principals AS a
INNER JOIN sys.sql_logins AS b
    ON a.principal_id = b.principal_id
WHERE a.name NOT LIKE '%#%'
ORDER BY a.name;
GO

INSERT INTO #Login_Audit (A, B, C, D)
SELECT '--- ORPHAN LOGINS ---' AS "Orphan_Login_Details",
       ' ----- ',
       ' ----- ',
       ' ----- ';
GO

INSERT INTO #Login_Audit (A, B, C, D)
SELECT 'Logins Name' AS "orphan logine",
       'ID',
       '',
       '';
GO

INSERT INTO #Login_Audit (A, B)
EXEC sp_validatelogins;
GO

INSERT INTO #Login_Audit (A, B, C, D)
SELECT '--- ORPHAN USERS ---' AS "Orphan_USERS_Details",
       ' ----- ',
       ' ----- ',
       ' ----- ';
GO

INSERT INTO #Login_Audit (A, B, C, D)
SELECT 'User Name' AS "orphan users",
       '',
       '  ',
       '';
GO

INSERT INTO #Login_Audit (A)
SELECT u.name
FROM master..syslogins AS l
RIGHT JOIN sysusers AS u
    ON l.sid = u.sid
WHERE l.sid IS NULL
      AND issqlrole <> 1
      AND isapprole <> 1
      AND u.name <> 'INFORMATION_SCHEMA'
      AND u.name <> 'guest'
      AND u.name <> 'system_function_schema'
      AND u.name <> 'sys';

INSERT INTO #Login_Audit (A, B, C, D)
SELECT '--- DATABASE OWNER DETAILS ---' AS "Database_Owner_details",
       ' ----- ',
       ' ----- ',
       ' ----- ';
GO

INSERT INTO #Login_Audit (A, B, C, D)
SELECT 'Database Name' AS "DB owner",
       'Owener name',
       '  ',
       '';
GO

INSERT INTO #Login_Audit (A, B)
SELECT name,
       SUSER_SNAME (owner_sid)
FROM sys.databases
ORDER BY name ASC;
GO

SELECT *
FROM #Login_Audit;