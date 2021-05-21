/*

Principals are entities that can request SQL Server resources. Like other 
components of the SQL Server authorization model, principals can be arranged in 
a hierarchy. The scope of influence of a principal depends on the scope of the 
definition of the principal: Windows, server, database; and whether the principal is 
indivisible or a collection. A Windows Login is an example of an indivisible 
principal, and a Windows Group is an example of a principal that is a collection. 
Every principal has a security identifier (SID). This topic applies to all version of 
SQL Server, but there are some restictions on server-level principals in SQL 
Database or SQL Data Warehouse.

SQL Server-level principals
- SQL Server authentication Login
- Windows authentication login for a Windows user
- Windows authentication login for a Windows group
- Azure Active Directory authentication login for a AD user
- Azure Active Directory authentication login for a AD group
- Server Role

Database-level principals
- Database User
	- Users based on logins in master
		- User based on a login based on a Windows Active Directory account. 
		  CREATE USER [Contoso\Fritz];
		- User based on a login based on a Windows group. 
		  CREATE USER [Contoso\Sales];
		- User based on a login using SQL Server authentication. 
		  CREATE USER Mary;
	- Users that authenticate at the database
		- User based on a Windows user that has no login. 
		  CREATE USER [Contoso\Fritz];
		- User based on a Windows group that has no login. 
		  CREATE USER [Contoso\Sales];
		- User in SQL Database or SQL Data Warehouse based on an Azure Active Directory user. 
		  CREATE USER [Fritz@contoso.com] FROM EXTERNAL PROVIDER;
		- Contained database user with password. (Not available in SQL Data Warehouse.) 
		  CREATE USER Mary WITH PASSWORD = '********';
	- Users based on Windows principals that connect through Windows group logins
		- User based on a Windows user that has no login, but can connect to the Database Engine through membership in a Windows group. 
		  CREATE USER [Contoso\Fritz];
		- User based on a Windows group that has no login, but can connect to the Database Engine through membership in a different Windows group. 
		  CREATE USER [Contoso\Fritz];
	- Users that cannot authenticate
		- User without a login. Cannot login but can be granted permissions. 
		  CREATE USER CustomApp WITHOUT LOGIN;
		- User based on a certificate. Cannot login but can be granted permissions and can sign modules. 
		  CREATE USER TestProcess FOR CERTIFICATE CarnationProduction50;
		- User based on an asymmetric key. Cannot login but can be granted permissions and can sign modules. 
		  CREATE User TestProcess FROM ASYMMETRIC KEY PacificSales09;
- Database Role
- Application Role

sa Login
The SQL Server sa log in is a server-level principal. By default, it is created when 
an instance is installed. Beginning in SQL Server 2005 (9.x), the default database of 
sa is master. This is a change of behavior from earlier versions of SQL Server. The 
sa login is a member of the sysadmin fixed server-level role. The sa login has all 
permissions on the server and cannot be limited. The sa login cannot be 
dropped, but it can be disabled so that no one can use it.

dbo User and dbo Schema
The dbo user is a special user principal in each database. All SQL Server 
administrators, members of the sysadmin fixed server role, sa login, and owners 
of the database, enter databases as the dbo user. The dbo user has all permissions 
in the database and cannot be limited or dropped. dbo stands for database 
owner, but the dbouser account is not the same as the db_owner fixed database 
role, and the db_owner fixed database role is not the same as the user account 
that is recorded as the owner of the database.
The dbo user owns the dbo schema. The dbo schema is the default schema for all 
users, unless some other schema is specified. The dbo schema cannot be 
dropped.

public Server Role and Database Role
Every login belongs to the public fixed server role, and every database user 
belongs to the public database role. When a login or user has not been granted 
or denied specific permissions on a securable, the login or user inherits the 
permissions granted to public on that securable. The public fixed server role and 
the public fixed database role cannot be dropped. However you can revoke 
permissions from the public roles. There are many permissions that are assigned 
to the public roles by default. Most of these permissions are needed for routine 
operations in the database; the type of things that everyone should be able to do. 
Be careful when revoking permissions from the public login or user, as it will 
affect all logins/users. Generally you should not deny permissions to public, 
because the deny statement overrides any grant statements you might make to 
individuals.

INFORMATION_SCHEMA and sys Users and Schemas
Every database includes two entities that appear as users in catalog views: 
INFORMATION_SCHEMA and sys. These entities are required for internal use by the 
Database Engine. They cannot be modified or dropped.

Certificate-based SQL Server Logins
Server principals with names enclosed by double hash marks (##) are for internal 
system use only. The following principals are created from certificates when SQL 
Server is installed, and should not be deleted.

- ##MS_SQLResourceSigningCertificate##
- ##MS_SQLReplicationSigningCertificate##
- ##MS_SQLAuthenticatorCertificate##
- ##MS_AgentSigningCertificate##
- ##MS_PolicyEventProcessingLogin##
- ##MS_PolicySigningCertificate##
- ##MS_PolicyTsqlExecutionLogin##

These principal accounts do not have passwords that can be changed by 
administrators as they are based on certificates issued to Microsoft.

The guest User
Each database includes a guest. Permissions granted to the guest user are 
inherited by users who have access to the database, but who do not have a user 
account in the database. The guest user cannot be dropped, but it can be 
disabled by revoking it's CONNECT permission. The CONNECT permission can be 
revoked by executing REVOKE CONNECT FROM GUEST; within any database other than 
master or tempdb.

*/

-- Reports the login security configuration of Microsoft® SQL Server™
-- Is a deprecated feature
EXEC xp_loginconfig;

-- Returns version information about Microsoft SQL Server
EXEC xp_msver;

-- Returns one row for each table privilege that is granted to or granted by 
-- the current user in the current database.
EXEC sp_table_privileges @table_name = '%';

-- Returns information about the roles in the current database.
EXEC sp_helprole;
EXEC sp_MSforeachdb @command1 = N'Use [?]; exec sp_helprole;';

-- Reports information about database-level principals in the current database
EXEC sp_helpuser;
EXEC sp_MSforeachdb @command1 = N'Use [?]; exec sp_helpuser;';

-- Returns the physical names and attributes of files associated with the 
-- current database.
-- Use this stored procedure to determine the names of files to attach to 
-- or detach from the server.
EXEC sp_helpfile;

-- Returns a report that has information about user permissions for an object, 
-- or statement permissions, in the current database.
EXEC sp_helprotect;
EXEC sp_MSforeachdb @command1 = N'Use [?]; exec sp_helprotect;';

-------------------------------------------------------------------------------
-- SERVER-LEVEL
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- List every server-level principal
-------------------------------------------------------------------------------
SELECT name,
       principal_id,
       sid,
       type,
       type_desc,
       is_disabled,
       create_date,
       modify_date,
       default_database_name,
       default_language_name,
       credential_id,
       owning_principal_id,
       is_fixed_role
FROM sys.server_principals;
GO

-------------------------------------------------------------------------------
-- list permissions explicitly granted or denied to server principals.
--
-- The permissions of fixed server roles (other than public) do not appear in 
-- sys.server_permissions. Therefore, server principals may have additional 
-- permissions not listed here.
-------------------------------------------------------------------------------
SELECT pr.principal_id,
       pr.name,
       pr.type_desc,
       pe.state_desc,
       pe.permission_name
FROM sys.server_principals AS pr
    JOIN sys.server_permissions AS pe
        ON pe.grantee_principal_id = pr.principal_id;
GO

-------------------------------------------------------------------------------
-- List names and id's of the server roles and their members.
-------------------------------------------------------------------------------
SELECT sys.server_role_members.role_principal_id,
       role.name AS RoleName,
       sys.server_role_members.member_principal_id,
       member.name AS MemberName
FROM sys.server_role_members
    JOIN sys.server_principals AS role
        ON sys.server_role_members.role_principal_id = role.principal_id
    JOIN sys.server_principals AS member
        ON sys.server_role_members.member_principal_id = member.principal_id;
GO

-------------------------------------------------------------------------------
-- List all securable classes
-------------------------------------------------------------------------------
SELECT class_desc,
       class
FROM sys.securable_classes
ORDER BY class;
GO

-------------------------------------------------------------------------------
-- DATABASE-LEVEL
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Listing all the permissions of database principals

-- The permissions of fixed database roles do not appear in 
-- sys.database_permissions. Therefore, database principals may have additional 
-- permissions not listed here.
-------------------------------------------------------------------------------
SELECT pr.principal_id,
       pr.name,
       pr.type_desc,
       pr.authentication_type_desc,
       pe.state_desc,
       pe.permission_name
FROM sys.database_principals AS pr
    JOIN sys.database_permissions AS pe
        ON pe.grantee_principal_id = pr.principal_id;
GO

-------------------------------------------------------------------------------
-- Listing permissions on schema objects within a database
-------------------------------------------------------------------------------
SELECT pr.principal_id,
       pr.name,
       pr.type_desc,
       pr.authentication_type_desc,
       pe.state_desc,
       pe.permission_name,
       s.name + '.' + o.name AS ObjectName
FROM sys.database_principals AS pr
    JOIN sys.database_permissions AS pe
        ON pe.grantee_principal_id = pr.principal_id
    JOIN sys.objects AS o
        ON pe.major_id = o.object_id
    JOIN sys.schemas AS s
        ON o.schema_id = s.schema_id;
GO

-------------------------------------------------------------------------------
-- List members of database roles
-------------------------------------------------------------------------------
SELECT DP1.name AS DatabaseRoleName,
       ISNULL(DP2.name, 'No members') AS DatabaseUserName
FROM sys.database_role_members AS DRM
    RIGHT OUTER JOIN sys.database_principals AS DP1
        ON DRM.role_principal_id = DP1.principal_id
    LEFT OUTER JOIN sys.database_principals AS DP2
        ON DRM.member_principal_id = DP2.principal_id
WHERE DP1.type = 'R'
ORDER BY DP1.name;
GO

-------------------------------------------------------------------------------
-- Extraction of the current SQL Authenticated accounts with their 
-- authentication settings
-------------------------------------------------------------------------------
SELECT sp.name AS "Account",
       sp.[principal_id] AS "Account Principal ID",
       sp.[sid] AS "Account SID",
       sp.[type_desc] AS "Account Type",
       sp.[is_disabled] AS "Account Disabled",
       sl.denylogin AS "Account Deny Login",
       sl.hasaccess AS "Has Access",
       sp.[create_date] AS "Account Create Date",
       sp.[modify_date] AS "Account Modify Date",
       LOGINPROPERTY(sp.name, 'PasswordLastSetTime') AS "Account Last Password Change Date",
       sp.is_policy_checked AS "Enforce Windows Password Policies?",
       sp.is_expiration_checked AS "Enforce Windows Expiration Policies?",
       sp.password_hash AS "Password Hash",
       CASE
           WHEN (PWDCOMPARE('', sp.password_hash) = 1) THEN
               'Yes'
           ELSE
               'No'
       END AS "Blank Password?"
FROM master.sys.sql_logins AS sp
    LEFT JOIN master.sys.syslogins AS sl
        ON sp.sid = sl.sid;
