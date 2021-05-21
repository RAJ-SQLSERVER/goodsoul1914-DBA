USE DBA;
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.usp_CaptureLoginAuths @user sysname = NULL
AS
DECLARE @name sysname;
DECLARE @role_string VARCHAR(50);
DECLARE @deflt_dbid SMALLINT;
DECLARE @auth_name sysname;
DECLARE @type VARCHAR(1);
DECLARE @hasaccess INT;
DECLARE @denylogin INT;
DECLARE @is_disabled INT;
DECLARE @PWD_varbinary VARBINARY(256);
DECLARE @PWD_string VARCHAR(514);
DECLARE @SID_varbinary VARBINARY(85);
DECLARE @SID_string VARCHAR(514);
DECLARE @tmpstr VARCHAR(1024);
DECLARE @is_policy_checked VARCHAR(3);
DECLARE @is_expiration_checked VARCHAR(3);
DECLARE @defaultdb NVARCHAR(128);

DECLARE @usrname VARCHAR(50),
        @dbname  NVARCHAR(128),
        @savedb  NVARCHAR(128),
        @dbrole  VARCHAR(50),
        @svrrole VARCHAR(50);

DECLARE @RoleName VARCHAR(50),
        @UserName VARCHAR(50),
        @CMD      NVARCHAR(4000),
        @SQL      NVARCHAR(4000);

SET NOCOUNT ON;


IF (@user IS NULL)
BEGIN
    PRINT 'No user specified.';
-- RETURN -1
END;


DECLARE login_curs CURSOR FOR
SELECT    p.sid,
          p.name,
          p.type,
          p.is_disabled,
          p.default_database_name,
          l.hasaccess,
          l.denylogin
FROM      sys.server_principals AS p
LEFT JOIN sys.syslogins AS l
    ON (l.name = p.name)
WHERE     p.type IN ( 'S', 'G', 'U' )
          AND p.name = @user;


OPEN login_curs;
FETCH NEXT FROM login_curs
INTO @SID_varbinary,
     @name,
     @type,
     @is_disabled,
     @defaultdb,
     @hasaccess,
     @denylogin;
IF (@@fetch_status = -1)
BEGIN
    PRINT 'No login(s) found.';
    CLOSE login_curs;
    DEALLOCATE login_curs;
    RETURN -1;
END;

SET @tmpstr = '/* sp_help_revlogin script ';
PRINT @tmpstr;
SET @tmpstr = '** Generated ' + CONVERT(VARCHAR, GETDATE()) + ' on ' + @@SERVERNAME + ' */';
PRINT @tmpstr;
PRINT '';

WHILE (@@fetch_status = 0)
BEGIN

    PRINT '';
    SET @tmpstr = '-- Login: ' + @name;
    PRINT @tmpstr;
    IF (@type IN ( 'G', 'U' ))
    BEGIN -- NT authenticated account/group
        SELECT @tmpstr = 'USE MASTER';
        PRINT @tmpstr;
        SELECT @tmpstr = 'GO';
        PRINT @tmpstr;
        SET @tmpstr
            = 'CREATE LOGIN ' + QUOTENAME(@name) + ' FROM WINDOWS WITH DEFAULT_DATABASE = [' + @defaultdb + ']';
    END;
    ELSE
    BEGIN -- SQL Server authentication
        -- obtain password and sid
        SET @PWD_varbinary = CAST(LOGINPROPERTY(@name, 'PasswordHash') AS VARBINARY(256));
        EXEC sp_hexadecimal @PWD_varbinary, @PWD_string OUT;
        EXEC sp_hexadecimal @SID_varbinary, @SID_string OUT;

        -- obtain password policy state
        SELECT @is_policy_checked = CASE is_policy_checked
                                        WHEN 1 THEN
                                            'ON'
                                        WHEN 0 THEN
                                            'OFF'
                                        ELSE
                                            NULL
                                    END
        FROM   sys.sql_logins
        WHERE  name = @name;
        SELECT @is_expiration_checked = CASE is_expiration_checked
                                            WHEN 1 THEN
                                                'ON'
                                            WHEN 0 THEN
                                                'OFF'
                                            ELSE
                                                NULL
                                        END
        FROM   sys.sql_logins
        WHERE  name = @name;
        SELECT @tmpstr = 'USE MASTER';
        PRINT @tmpstr;
        SELECT @tmpstr = 'GO';
        PRINT @tmpstr;
        SET @tmpstr
            = 'CREATE LOGIN ' + QUOTENAME(@name) + ' WITH PASSWORD = ' + @PWD_string + ' HASHED, SID = ' + @SID_string
              + ', DEFAULT_DATABASE = [' + @defaultdb + ']';
    END;

    IF (@is_policy_checked IS NOT NULL)
    BEGIN
        SET @tmpstr = @tmpstr + ', CHECK_POLICY = ' + @is_policy_checked;
    END;

    IF (@is_expiration_checked IS NOT NULL)
    BEGIN
        SET @tmpstr = @tmpstr + ', CHECK_EXPIRATION = ' + @is_expiration_checked;
    END;
    --END

    IF (@denylogin = 1)
    BEGIN -- login is denied access
        SET @tmpstr = @tmpstr + '; DENY CONNECT SQL TO ' + QUOTENAME(@name);
    END;
    ELSE IF (@hasaccess = 0)
    BEGIN -- login exists but does not have access
        SET @tmpstr = @tmpstr + '; REVOKE CONNECT SQL TO ' + QUOTENAME(@name);
    END;

    IF (@is_disabled = 1)
    BEGIN -- login is disabled
        SET @tmpstr = @tmpstr + '; ALTER LOGIN ' + QUOTENAME(@name) + ' DISABLE';
    END;
    PRINT @tmpstr;
    --END


    -- CAPTURE SERVER ROLES 


    DECLARE @svrrole_cnt INT;
    SET @svrrole_cnt = 0;

    CREATE TABLE #svrrolemember_kk
    (
        svrrole VARCHAR(100),
        membername VARCHAR(100),
        membersid VARBINARY(2048)
    );

    SET @CMD = N'truncate table #svrRoleMember_kk insert into #svrRoleMember_kk exec sp_helpsrvrolemember ';

    EXEC (@CMD);


    DECLARE svrrole_curs CURSOR FOR
    SELECT svrrole,
           membername
    FROM   #svrrolemember_kk
    WHERE  membername = @user;


    OPEN svrrole_curs;
    FETCH NEXT FROM svrrole_curs
    INTO @svrrole,
         @usrname;

    WHILE (@@FETCH_STATUS = 0)
    BEGIN
        IF @svrrole_cnt = 0
        BEGIN
            SET @tmpstr = ' ';
            PRINT @tmpstr;
            SET @tmpstr = '-- ********************';
            PRINT @tmpstr;
            SET @tmpstr = '-- SERVER ROLES';
            PRINT @tmpstr;
            SET @tmpstr = '-- ********************';
            PRINT @tmpstr;
            SET @tmpstr = '';
            SET @tmpstr
                = 'EXEC master..sp_addsrvrolemember @loginame = ''' + @usrname + ''' , @rolename = ''' + @svrrole
                  + '''';
            PRINT @tmpstr;
            SET @svrrole_cnt = @svrrole_cnt + 1;
        END;
        ELSE
        BEGIN
            SET @tmpstr
                = 'EXEC master..sp_addsrvrolemember @loginame = ''' + @usrname + ''' , @rolename = ''' + @svrrole
                  + '''';
            PRINT @tmpstr;
        END;

        FETCH NEXT FROM svrrole_curs
        INTO @svrrole,
             @usrname;
    END;

    DROP TABLE #svrrolemember_kk;
    CLOSE svrrole_curs;
    DEALLOCATE svrrole_curs;



    --DATABASE ACCESS INCUDING DEFAULT DB AND OTHER DATABASES

    DECLARE @Set_Create_User VARCHAR(1);
    SET @Set_Create_User = 'N';

    SET @tmpstr = ' ';
    PRINT @tmpstr;
    SET @tmpstr = ' ';
    PRINT @tmpstr;
    SET @tmpstr = '-- **************************';
    PRINT @tmpstr;
    SET @tmpstr = '-- DATABASE ACCESS and ROLES';
    PRINT @tmpstr;
    SET @tmpstr = '-- **************************';
    PRINT @tmpstr;
    SET @tmpstr = '';

    CREATE TABLE #permission
    (
        user_name VARCHAR(128),
        databasename NVARCHAR(128),
        role VARCHAR(128)
    );

    DECLARE longspcur CURSOR FOR
    SELECT name
    FROM   sys.server_principals
    WHERE  type IN ( 'S', 'U', 'G' )
           AND name = @name;

    OPEN longspcur;

    FETCH NEXT FROM longspcur
    INTO @UserName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        CREATE TABLE #userroles_kk
        (
            databasename NVARCHAR(128),
            role VARCHAR(50)
        );

        CREATE TABLE #rolemember_kk
        (
            dbrole VARCHAR(100),
            membername VARCHAR(100),
            membersid VARBINARY(2048)
        );

        SET @CMD
            = N'use ? truncate table #RoleMember_kk insert into #RoleMember_kk exec sp_helprolemember insert into #UserRoles_kk (DatabaseName, Role) select db_name(), dbRole from #RoleMember_kk where MemberName = '''
              + @UserName + N'''';

        EXEC sp_foreachdb @CMD;

        INSERT INTO #permission
        SELECT          @UserName AS "user",
                        b.name,
                        u.role
        FROM            sys.sysdatabases AS b
        LEFT OUTER JOIN #userroles_kk AS u
            ON u.databasename = b.name
        ORDER BY        1;

        DROP TABLE #userroles_kk;

        DROP TABLE #rolemember_kk;

        FETCH NEXT FROM longspcur
        INTO @UserName;
    END;

    CLOSE longspcur;

    DEALLOCATE longspcur;


    SET @savedb = N'';

    DECLARE role_curs CURSOR FOR
    SELECT   user_name,
             databasename,
             role
    FROM     #permission
    WHERE    role IS NOT NULL
             AND user_name = @name
    ORDER BY databasename;


    OPEN role_curs;
    FETCH NEXT FROM role_curs
    INTO @usrname,
         @dbname,
         @dbrole;

    WHILE (@@FETCH_STATUS = 0)
    BEGIN
        IF @dbname <> @savedb
        BEGIN
            SET @tmpstr = ' ';
            PRINT @tmpstr;
            SET @tmpstr = 'USE [' + @dbname + ']';
            PRINT @tmpstr;
            SET @tmpstr = 'GO';
            PRINT @tmpstr;
            SET @tmpstr = 'CREATE USER [' + @usrname + '] FOR LOGIN [' + @usrname + ']';
            PRINT @tmpstr;
            SET @tmpstr = 'EXEC sp_addrolemember ''' + @dbrole + ''', ''' + @usrname + '''';
            PRINT @tmpstr;
            SET @savedb = @dbname;
            SET @Set_Create_User = 'Y';
        END;
        ELSE
        BEGIN
            SET @tmpstr = 'EXEC sp_addrolemember ''' + @dbrole + ''', ''' + @usrname + '''';
            PRINT @tmpstr;
        END;

        FETCH NEXT FROM role_curs
        INTO @usrname,
             @dbname,
             @dbrole;
    END;

    CLOSE role_curs;
    DEALLOCATE role_curs;

    --DROP TABLE #Permission 
    --FETCH NEXT FROM login_curs INTO @SID_varbinary, @name, @type, @is_disabled, @defaultdb, @hasaccess, @denylogin

    --END
    --CLOSE login_curs
    --DEALLOCATE login_curs



    -- DATABASE PERMISSIONS AND OBJECT AUTHORITIES


    DECLARE @DBNAME_AUTH     NVARCHAR(128),
            @DBUSRNAME       NVARCHAR(128),
            @PERMISSION_NAME NVARCHAR(128),
            @OBJECT_OWNER    NVARCHAR(128),
            @OBJECT_TYPE     NVARCHAR(128),
            @OBJECT_NAME     NVARCHAR(128),
            @COLUMN_NAME     NVARCHAR(128),
            @SAVED_DBNAME    NVARCHAR(128),
            @DBObjAuth_CNT   INT;

    CREATE TABLE #DB_Auths
    (
        #DBNAME_AUTH NVARCHAR(128),
        #DBUSRNAME NVARCHAR(128),
        #PERMISSION_NAME NVARCHAR(128),
        #OBJECT_OWNER NVARCHAR(128),
        #OBJECT_TYPE NVARCHAR(128),
        #OBJECT_NAME NVARCHAR(128),
        #COLUMN_NAME NVARCHAR(128)
    );

    SET @SAVED_DBNAME = N'';
    SET @DBObjAuth_CNT = 0;

    SET @CMD
        = N'use ? INSERT INTO #DB_Auths 
		SELECT 
		[DatabaseName] = (Select db_name()), 
		[DatabaseUserName] = princ.[name], 
		[PermissionType] = perm.[permission_name], 
		[ObjectOwner] = sch.name, 
		[ObjectType] = CASE perm.[class] 
		WHEN 1 THEN obj.type_desc -- Schema-contained objects
		ELSE perm.[class_desc] -- Higher-level objects
		END, 
		[ObjectName] = CASE perm.[class] 
		WHEN 1 THEN OBJECT_NAME(perm.major_id) -- General objects
		WHEN 3 THEN schem.[name] -- Schemas
		WHEN 4 THEN imp.[name] -- Impersonations
		END,
		[ColumnName] = col.[name]
		FROM 
		--database user
		sys.database_principals princ 
		LEFT JOIN 
		--Login accounts
		sys.server_principals ulogin on princ.[sid] = ulogin.[sid]
		LEFT JOIN 
		--Permissions
		sys.database_permissions perm ON perm.[grantee_principal_id] = princ.[principal_id]
		LEFT JOIN 
		--Table columns
		sys.columns col ON col.[object_id] = perm.major_id 
		AND col.[column_id] = perm.[minor_id]
		LEFT JOIN 
		sys.objects obj ON perm.[major_id] = obj.[object_id]
		LEFT JOIN 
		sys.schemas schem ON schem.[schema_id] = perm.[major_id]
		LEFT JOIN 
		sys.database_principals imp ON imp.[principal_id] = perm.[major_id]
		LEFT JOIN 
		sys.schemas sch ON obj.schema_id = sch.schema_id 
		WHERE 
		princ.[type] IN (''S'',''U'',''G'') AND
		-- No need for these system accounts
		princ.[name] NOT IN (''sys'', ''INFORMATION_SCHEMA'')
		AND ulogin.name = ''' + @name + N'''';


    EXEC sp_foreachdb @CMD;


    DECLARE DB_AUTH_CURSOR CURSOR FOR
    SELECT   #DBNAME_AUTH,
             #DBUSRNAME,
             #PERMISSION_NAME,
             #OBJECT_OWNER,
             #OBJECT_TYPE,
             #OBJECT_NAME,
             #COLUMN_NAME
    FROM     #DB_Auths
    ORDER BY #DBNAME_AUTH,
             #OBJECT_TYPE;

    OPEN DB_AUTH_CURSOR;
    FETCH NEXT FROM DB_AUTH_CURSOR
    INTO @DBNAME_AUTH,
         @DBUSRNAME,
         @PERMISSION_NAME,
         @OBJECT_OWNER,
         @OBJECT_TYPE,
         @OBJECT_NAME,
         @COLUMN_NAME;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @DBNAME_AUTH <> @SAVED_DBNAME
           AND @OBJECT_TYPE = 'DATABASE'
        BEGIN
            SET @tmpstr = ' ';
            PRINT @tmpstr;
            SET @tmpstr = ' ';
            PRINT @tmpstr;
            SET @tmpstr = '-- **************************************';
            PRINT @tmpstr;
            SET @tmpstr = ('-- DATABASE PERMISSIONS [' + @DBNAME_AUTH + ']');
            PRINT @tmpstr;
            SET @tmpstr = '-- **************************************';
            PRINT @tmpstr;
            SET @tmpstr = '';
            PRINT @tmpstr;
            SET @tmpstr = '--Login: ' + @DBUSRNAME;
            PRINT @tmpstr;
            SET @tmpstr = '';
            PRINT @tmpstr;
            SET @tmpstr = ' ';
            PRINT @tmpstr;
            SET @tmpstr = 'USE [' + @DBNAME_AUTH + ']';
            PRINT @tmpstr;
            SET @tmpstr = 'GO';
            PRINT @tmpstr;
            IF @Set_Create_User = 'N'
            BEGIN
                SET @tmpstr = 'CREATE USER [' + @DBUSRNAME + '] FOR LOGIN [' + @DBUSRNAME + ']';
                PRINT @tmpstr;
            END;
            SET @tmpstr = 'GRANT ' + @PERMISSION_NAME + ' TO ' + @DBUSRNAME;
            PRINT @tmpstr;
            SET @SAVED_DBNAME = @DBNAME_AUTH;
            SET @DBObjAuth_CNT = 0;
        END;
        ELSE IF @DBNAME_AUTH = @SAVED_DBNAME
                AND @OBJECT_TYPE = 'DATABASE'
        BEGIN
            SET @tmpstr = 'GRANT ' + @PERMISSION_NAME + ' TO ' + @DBUSRNAME;
            PRINT @tmpstr;
        END;


        IF @DBNAME_AUTH <> @SAVED_DBNAME
           AND @OBJECT_TYPE <> 'DATABASE'
        BEGIN
            SET @DBObjAuth_CNT = @DBObjAuth_CNT + 1;
            SET @tmpstr = ' ';
            PRINT @tmpstr;
            SET @tmpstr = ' ';
            PRINT @tmpstr;
            SET @tmpstr = '--                     *********************************************';
            PRINT @tmpstr;
            SET @tmpstr = ('--                    DATABASE OBJECT AUTHORITIES [' + @DBNAME_AUTH + ']');
            PRINT @tmpstr;
            SET @tmpstr = '--                     *********************************************';
            PRINT @tmpstr;
            SET @tmpstr = ' ';
            PRINT @tmpstr;
            SET @tmpstr
                = ' GRANT ' + @PERMISSION_NAME + ' ON [' + @OBJECT_OWNER + '].[' + @OBJECT_NAME + ']' + ' TO '
                  + @DBUSRNAME;
            PRINT @tmpstr;
            SET @SAVED_DBNAME = @DBNAME_AUTH;
        END;
        ELSE IF @DBNAME_AUTH = @SAVED_DBNAME
                AND @OBJECT_TYPE <> 'DATABASE'
        BEGIN
            SET @DBObjAuth_CNT = @DBObjAuth_CNT + 1;
            IF @DBObjAuth_CNT = 1
            BEGIN
                SET @tmpstr = ' ';
                PRINT @tmpstr;
                SET @tmpstr = ' ';
                PRINT @tmpstr;
                SET @tmpstr = '--                     *********************************************';
                PRINT @tmpstr;
                SET @tmpstr = ('--                     DATABASE OBJECT AUTHORIES [' + @DBNAME_AUTH + ']');
                PRINT @tmpstr;
                SET @tmpstr = '--                     *********************************************';
                PRINT @tmpstr;
                SET @tmpstr = ' ';
                PRINT @tmpstr;
                SET @tmpstr = '                       USE [' + @DBNAME_AUTH + ']';
                PRINT @tmpstr;
                SET @tmpstr = '                       GO';
                PRINT @tmpstr;
                SET @tmpstr = ' ';
                SET @tmpstr
                    = '                       GRANT ' + @PERMISSION_NAME + ' ON [' + @OBJECT_OWNER + '].['
                      + @OBJECT_NAME + ']' + ' TO ' + @DBUSRNAME;
                PRINT @tmpstr;
            END;
            ELSE IF @DBObjAuth_CNT > 1
            BEGIN
                SET @tmpstr
                    = '                       GRANT ' + @PERMISSION_NAME + ' ON [' + @OBJECT_OWNER + '].['
                      + @OBJECT_NAME + ']' + ' TO ' + @DBUSRNAME;
                PRINT @tmpstr;
            END;
        END;

        FETCH NEXT FROM DB_AUTH_CURSOR
        INTO @DBNAME_AUTH,
             @DBUSRNAME,
             @PERMISSION_NAME,
             @OBJECT_OWNER,
             @OBJECT_TYPE,
             @OBJECT_NAME,
             @COLUMN_NAME;

    END;

    CLOSE DB_AUTH_CURSOR;
    DEALLOCATE DB_AUTH_CURSOR;

    DROP TABLE #DB_Auths;

    DROP TABLE #permission;

END;
CLOSE login_curs;
DEALLOCATE login_curs;

RETURN 0;
GO


