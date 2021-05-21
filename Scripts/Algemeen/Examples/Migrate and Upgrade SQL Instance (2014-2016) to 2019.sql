use [master];
go
sp_configure 'show advanced options', 1;
reconfigure;
go
sp_configure 'xp_cmdshell', 1;
reconfigure;
go
sp_configure 'Ole Automation Procedures', 1;
reconfigure;
go
sp_configure 'Ad Hoc Distributed Queries', 1;
reconfigure;
go
declare @Source_Instance sysname       = 'InstanceName', 
		@BackupDirectory nvarchar(200) = '\BackupDirectory';  -- must have enough space for all dbs backups in @Source_Instance 
declare @PrintOnly bit = 0; -- 0 = execute, 1 = print
declare @SQL            nvarchar(max), 
		@ProcExists     bit, 
		@PrintStatement nvarchar(200);

set nocount on;

/***********************************************************************************************************************************************************************
 STEP 1: CREATE EMPTY Databases (will replace with real ones in last step) *********************************************************************************************
***********************************************************************************************************************************************************************/

declare @DefaultData nvarchar(512);
exec master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SoftwareMicrosoftMSSQLServerMSSQLServer', N'DefaultData', @DefaultData output;

declare @DefaultLog nvarchar(512);
exec master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SoftwareMicrosoftMSSQLServerMSSQLServer', N'DefaultLog', @DefaultLog output;


-- Check if Linked Server available
if not exists (select top 1 srvname
			   from sys.sysservers
			   where srvname = @Source_Instance) 
begin
	set @SQL = 'EXEC master.dbo.sp_addlinkedserver @server = N''' + @Source_Instance + ''', @srvproduct=N''SQL Server''
	EXEC master.dbo.sp_serveroption @server=N''' + @Source_Instance + ''', @optname=N''data access'', @optvalue=N''true''
	EXEC master.dbo.sp_serveroption @server=N''' + @Source_Instance + ''', @optname=N''rpc'', @optvalue=N''true''
	EXEC master.dbo.sp_serveroption @server=N''' + @Source_Instance + ''', @optname=N''rpc out'', @optvalue=N''true''
	EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N''' + @Source_Instance + ''', @locallogin = NULL , @useself = N''True''';

	begin try
		exec (@SQL);
	end try
	begin catch
		print 'Couldn''t create a linked server to the Source instance [' + @Source_Instance + ']!';
		throw;
	end catch;
end;

set @SQL = 'SELECT [name] FROM [' + @Source_Instance + '].master.sys.sysdatabases WHERE dbid > 4'; -- get all users databases

declare @Databases table
(
	ID     int identity(1, 1) not null, 
	DBName sysname);

begin try
	insert into @Databases (DBName) 
	exec (@SQL);
end try
begin catch
	print 'Error retriving the list of databases from source Instance!';
	throw;
end catch;

declare @RowNum   int     = 1, 
		@Database sysname;
while @RowNum < (select MAX(ID) + 1
				 from @Databases) 
begin
	select @Database = DBName
	from @Databases
	where ID = @RowNum;
	set @SQL = 'CREATE DATABASE [' + @Database + '] ON  PRIMARY 
	( NAME = N''' + @Database + ''', FILENAME = N''' + @DefaultData + '' + @Database + '.mdf'' , SIZE = 8192KB , FILEGROWTH = 65536KB )
	 LOG ON 
	( NAME = N''' + @Database + '_log'', FILENAME = N''' + @DefaultLog + '' + @Database + '_log.ldf'' , SIZE = 8192KB , FILEGROWTH = 65536KB )
	ALTER DATABASE [' + @Database + '] SET COMPATIBILITY_LEVEL = 130';
	set @PrintStatement = '';
	begin try
		if @PrintOnly = 1
			print @SQL;
		else
		begin
			if exists (select top 1 name
					   from master.sys.sysdatabases
					   where name = @Database) 
				set @PrintStatement = 'The database [' + @Database + '] already exists!';
			else
				exec (@SQL);
		end;
	end try
	begin catch
		print 'Error creating database [' + @Database + '] from source Instance!';
		throw;
	end catch;
	if @PrintStatement = ''
	   and @PrintOnly = 0
		set @PrintStatement = 'Successfully created database [' + @Database + ']!';
	print @PrintStatement;
	set @RowNum = @RowNum + 1;
end;

set @SQL = '';
print 'Successfully created EMPTY Databases!';

/*****************************************************************************************************
 STEP 2 - CREATE LOGINs WITH SERVER ROLESPERMISSIONS  ************************************************
*****************************************************************************************************/

declare @SqlLogins table
(
	RowNum          int, 
	CreateStatement nvarchar(2000));
declare @CreateStatement nvarchar(2000);

set @SQL = 'SELECT @ProcExists = CAST(1 AS BIT) 
				FROM OPENROWSET(''SQLNCLI'', ''Server=' + @Source_Instance + ';Trusted_Connection=yes;'',  
				''SELECT [name] FROM sys.sysobjects WHERE [name] = ''''sp_hexadecimal'''' AND xtype = ''''P''''; '') AS a;';
exec sp_executesql @SQL, N'@ProcExists BIT  OUTPUT', @ProcExists output;
if ISNULL(@ProcExists, 0) <> 1

begin
	set @SQL = 'N''CREATE PROCEDURE [dbo].[sp_hexadecimal]
		@binvalue varbinary(256),
		@hexvalue varchar (514) OUTPUT
	AS
	DECLARE @charvalue varchar (514)
	DECLARE @i int
	DECLARE @length int
	DECLARE @hexstring char(16)
	SELECT @charvalue = ''''0x''''
	SELECT @i = 1
	SELECT @length = DATALENGTH (@binvalue)
	SELECT @hexstring = ''''0123456789ABCDEF''''
	WHILE (@i <= @length)
	BEGIN
	  DECLARE @tempint int
	  DECLARE @firstint int
	  DECLARE @secondint int
	  SELECT @tempint = CONVERT(int, SUBSTRING(@binvalue,@i,1))
	  SELECT @firstint = FLOOR(@tempint/16)
	  SELECT @secondint = @tempint - (@firstint*16)
	  SELECT @charvalue = @charvalue +
		SUBSTRING(@hexstring, @firstint+1, 1) +
		SUBSTRING(@hexstring, @secondint+1, 1)
	  SELECT @i = @i + 1
	END

	SELECT @hexvalue = @charvalue''';

	set @SQL = 'EXEC [' + @Source_Instance + '].master.sys.sp_executesql ' + @SQL;
	begin try
		exec sp_executesql @SQL;
	end try
	begin catch
		print 'Error creating stored proc [sp_hexadecimal]!';
		throw;
	end catch;
end;
set @ProcExists = null;
set @SQL = 'SELECT @ProcExists = CAST(1 AS BIT) 
				FROM OPENROWSET(''SQLNCLI'', ''Server=' + @Source_Instance + ';Trusted_Connection=yes;'',  
				''SELECT [name] FROM sys.sysobjects WHERE [name] = ''''sp_help_revlogin_copy'''' AND xtype = ''''P''''; '') AS a;';
exec sp_executesql @SQL, N'@ProcExists BIT  OUTPUT', @ProcExists output;
if ISNULL(@ProcExists, 0) = 1
begin
	set @SQL = 'N''DROP PROCEDURE [dbo].[sp_help_revlogin_copy]''';
	set @SQL = 'EXEC [' + @Source_Instance + '].master.sys.sp_executesql ' + @SQL;
	begin try
		exec sp_executesql @SQL;
	end try
	begin catch
		print 'Error dropping stored proc [sp_help_revlogin_copy]!';
		throw;
	end catch;
end;

set @SQL = 'N''CREATE PROCEDURE [dbo].[sp_help_revlogin_copy] 
AS
DECLARE @name sysname
DECLARE @type varchar (1)
DECLARE @hasaccess int
DECLARE @denylogin int
DECLARE @is_disabled int
DECLARE @PWD_varbinary  varbinary (256)
DECLARE @PWD_string  varchar (514)
DECLARE @SID_varbinary varbinary (85)
DECLARE @SID_string varchar (514)
DECLARE @tmpstr  varchar (1024)
DECLARE @is_policy_checked varchar (3)
DECLARE @is_expiration_checked varchar (3)

DECLARE @defaultdb sysname
DECLARE @ResultTable TABLE ([RowNum] INT Identity (1,1) NOT NULL, Statement NVARCHAR(2000))
 
SET NOCOUNT ON;

DECLARE login_curs CURSOR FOR

	SELECT p.sid, p.name, p.type, p.is_disabled, p.default_database_name, l.hasaccess, l.denylogin FROM 
	sys.server_principals p LEFT JOIN sys.syslogins l
	ON ( l.name = p.name ) WHERE p.type IN ( ''''S'''', ''''G'''', ''''U'''' ) AND p.name <> ''''sa''''
	AND CHARINDEX(''''#'''', p.name, 1) = 0 AND CHARINDEX(''''NT AUTHORITY'''', p.name, 1) = 0
	AND CHARINDEX(''''NT SERVICE'''', p.name, 1) = 0

OPEN login_curs

FETCH NEXT FROM login_curs INTO @SID_varbinary, @name, @type, @is_disabled, @defaultdb, @hasaccess, @denylogin
IF (@@fetch_status = -1)
BEGIN
	PRINT ''''No login(s) found.''''
	CLOSE login_curs
	DEALLOCATE login_curs
	RETURN -1
END
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		IF (@type IN ( ''''G'''', ''''U''''))
		BEGIN -- NT authenticated account/group
			SET @tmpstr = ''''IF NOT EXISTS(SELECT TOP 1 [name] FROM sys.syslogins WHERE [name] = '''''''''''' + @name + '''''''''''') 
			CREATE LOGIN '''' + QUOTENAME( @name ) + '''' FROM WINDOWS WITH DEFAULT_DATABASE = ['''' + @defaultdb + '''']''''
		END
	ELSE BEGIN -- SQL Server authentication
		-- obtain password and sid
			SET @PWD_varbinary = CAST( LOGINPROPERTY( @name, ''''PasswordHash'''' ) AS varbinary (256) )
		EXEC sp_hexadecimal @PWD_varbinary, @PWD_string OUT
		EXEC sp_hexadecimal @SID_varbinary,@SID_string OUT
 
		-- obtain password policy state
		SELECT @is_policy_checked = CASE is_policy_checked WHEN 1 THEN ''''ON'''' WHEN 0 THEN ''''OFF'''' ELSE NULL END FROM sys.sql_logins WHERE name = @name
		SELECT @is_expiration_checked = CASE is_expiration_checked WHEN 1 THEN ''''ON'''' WHEN 0 THEN ''''OFF'''' ELSE NULL END FROM sys.sql_logins WHERE name = @name
 
			SET @tmpstr = ''''IF NOT EXISTS(SELECT TOP 1 [name] FROM sys.syslogins WHERE [name] = '''''''''''' + @name + '''''''''''')
			CREATE LOGIN '''' + QUOTENAME( @name ) + '''' WITH PASSWORD = '''' + @PWD_string + '''' HASHED, SID = '''' + @SID_string + '''', DEFAULT_DATABASE = ['''' + @defaultdb + '''']''''

		IF ( @is_policy_checked IS NOT NULL )
		BEGIN
			SET @tmpstr = @tmpstr + '''', CHECK_POLICY = '''' + @is_policy_checked
		END
		IF ( @is_expiration_checked IS NOT NULL )
		BEGIN
			SET @tmpstr = @tmpstr + '''', CHECK_EXPIRATION = '''' + @is_expiration_checked
		END
	END
	IF (@denylogin = 1)
	BEGIN -- login is denied access
		SET @tmpstr = @tmpstr + ''''; DENY CONNECT SQL TO '''' + QUOTENAME( @name )
	END
	ELSE IF (@hasaccess = 0)
	BEGIN -- login exists but does not have access
		SET @tmpstr = @tmpstr + ''''; REVOKE CONNECT SQL TO '''' + QUOTENAME( @name )
	END
	IF (@is_disabled = 1)
	BEGIN -- login is disabled
		SET @tmpstr = @tmpstr + ''''; ALTER LOGIN '''' + QUOTENAME( @name ) + '''' DISABLE''''
	END
	INSERT INTO @ResultTable (Statement)
	SELECT @tmpstr
	END

	INSERT INTO @ResultTable (Statement)
	SELECT 
	''''EXEC master..sp_addsrvrolemember @loginame = N'''''''''''' + SL.[name] + '''''''''''', @rolename = N'''''''''''' + SR.[name] + ''''''''''''
	'''' AS [Role]
	FROM master.sys.server_role_members SRM
		JOIN master.sys.server_principals SR ON SR.principal_id = SRM.role_principal_id
		JOIN master.sys.server_principals SL ON SL.principal_id = SRM.member_principal_id
	WHERE SL.[type] IN (''''S'''',''''G'''',''''U'''', ''''R'''') AND SL.[name] = @name

	INSERT INTO @ResultTable (Statement)
	SELECT 
		CASE WHEN SrvPerm.state_desc <> ''''GRANT_WITH_GRANT_OPTION'''' 
			THEN SrvPerm.state_desc 
			ELSE ''''GRANT'''' 
		END
		+ '''' '''' + SrvPerm.permission_name + '''' TO ['''' + SP.[name] + '''']'''' + 
		CASE WHEN SrvPerm.state_desc <> ''''GRANT_WITH_GRANT_OPTION'''' 
			THEN '''''''' 
			ELSE '''' WITH GRANT OPTION'''' 
		END collate database_default AS [Permission] 
	FROM sys.server_permissions AS SrvPerm 
		JOIN sys.server_principals AS SP ON SrvPerm.grantee_principal_id = SP.principal_id 
	WHERE   SP.[type] IN ( ''''S'''', ''''U'''', ''''G'''' ) AND SP.[name] = @name

	FETCH NEXT FROM login_curs INTO @SID_varbinary, @name, @type, @is_disabled, @defaultdb, @hasaccess, @denylogin
	END
CLOSE login_curs
DEALLOCATE login_curs
SELECT * FROM @ResultTable''';

set @SQL = 'EXEC [' + @Source_Instance + '].master.sys.sp_executesql ' + @SQL;
begin try
	exec sp_executesql @SQL;
end try
begin catch
	print 'Error creating stored proc [sp_help_revlogin_copy]!';
	throw;
end catch;

set @SQL = 'EXEC [' + @Source_Instance + '].master.dbo.sp_help_revlogin_copy';

begin try
	insert into @SqlLogins (RowNum, 
							CreateStatement) 
	exec (@SQL);
end try
begin catch
	print 'Error executing stored proc [' + @Source_Instance + '].master.dbo.sp_help_revlogin_copy!';
	throw;
end catch;

set @RowNum = 1;
while @RowNum < (select MAX(RowNum) + 1
				 from @SqlLogins) 
begin
	select @CreateStatement = CreateStatement
	from @SqlLogins
	where RowNum = @RowNum;
	if @PrintOnly = 1
		print @CreateStatement;
	else
	begin try
		exec (@CreateStatement);
	end try
	begin catch
		print 'Error creating login [' + @CreateStatement + ']!';
		--THROW   keep going!
	end catch;

	set @RowNum = @RowNum + 1;
end;
set @SQL = '';
print 'Successfully transferred logins!';

/************************************************************************************************************************
 STEP 3 - LINKED SERVERS ************************************************************************************************
************************************************************************************************************************/

set @SQL = '
;WITH cte AS (
SELECT  a.server_id,
        a.[name],
        a.product,
        a.[provider],
        a.[data_source],
		a.[provider_string],
        CAST(a.[is_collation_compatible] as int) as [collation compatible],
        CAST(a.[is_data_access_enabled] as int) as [data access],
        CAST(a.[is_distributor] as int) as [dist],
        CAST(a.[is_publisher] as int) as [pub],
        CAST(a.[is_remote_login_enabled] as int) as [rpc],
        CAST(a.[is_rpc_out_enabled] as int) as [rpc out],
        CAST(a.[is_subscriber] as int) as [sub],
        CAST(a.[connect_timeout] as int) as [connect timeout],
        CAST(a.[collation_name] as int) as [collation name],
        CAST(a.[lazy_schema_validation] as int) as [lazy schema validation],
        CAST(a.[query_timeout] as int) as [query timeout],
        CAST(a.[uses_remote_collation] as int) as [use remote collation],
        CAST(a.[is_remote_proc_transaction_promotion_enabled] as int) as [remote proc transaction promotion],
        c.[name] as locallogin,
        b.remote_name,
        b.uses_self_credential, 
        b.local_principal_id
FROM [' + @Source_Instance + '].master.sys.servers a
LEFT OUTER JOIN [' + @Source_Instance + '].master.sys.linked_logins b ON b.server_id = a.server_id
LEFT OUTER JOIN [' + @Source_Instance + '].master.sys.server_principals c ON c.principal_id = b.local_principal_id
LEFT JOIN master.sys.servers a2 ON a.[name] = a2.[name] AND a2.is_linked = 1
WHERE a.is_linked = 1 AND a2.is_linked IS NULL)
, unp AS (

SELECT  server_id,
        [name],
        product,
        [provider],
        [data_source],
		[provider_string],
        CASE WHEN remote_name IS NULL THEN ''NULL'' ELSE ''N'''''' + remote_name +'''''''' END as rmtuser,
        CASE WHEN uses_self_credential = 0 THEN ''false'' ELSE ''true'' END as useself,
        CASE WHEN local_principal_id = 0 THEN ''NULL'' ELSE ''N'''''' + locallogin +'''''''' END as locallogin,
        Prop as PropertyName,
        CASE WHEN Props = 0 THEN ''false'' ELSE ''true'' END as PropertyValue
FROM (
    SELECT  server_id,
            [name],
            product,
            [provider],
            [data_source],
			[provider_string],
            locallogin,
            remote_name,
            uses_self_credential,
            local_principal_id,
            [collation compatible],
            [data access],
            [dist],
            [pub],
            [rpc],
            [rpc out],
            [sub],
            [connect timeout],
            [collation name],
            [lazy schema validation],
            [query timeout],
            [use remote collation],
            [remote proc transaction promotion]
    FROM cte
) as p
UNPIVOT (
    Props FOR Prop IN (
            [collation compatible],
            [data access],
            [dist],
            [pub],
            [rpc],
            [rpc out],
            [sub],
            [connect timeout],
            [collation name],
            [lazy schema validation],
            [query timeout],
            [use remote collation],
            [remote proc transaction promotion]
    )
) as unpvt
)

SELECT DISTINCT 
''EXEC master.dbo.sp_addlinkedserver @server = N'''''' + name + '''''', @srvproduct=N'''''' + CASE WHEN provider = N''SQLNCLI'' THEN N''SQL Server'' ELSE product END + '''''''' + 
CASE WHEN product <> ''SQL Server'' AND provider <> N''SQLNCLI'' THEN '', @provider=N'''''' + [provider] + '''''', @provstr=N'''''' + ISNULL([provider_string], '''') + '''''''' ELSE '';'' END
+ CHAR(10) +
''EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'''''' + name + '''''',@useself=N''''''+useself+'''''',@locallogin=''+locallogin+'',@rmtuser='' + rmtuser +'',@rmtpassword=''''########'''''' + CHAR(10)
Col1
FROM unp
UNION ALL
SELECT ''EXEC master.dbo.sp_serveroption @server=N''''''+name+'''''', @optname=N''''''+PropertyName + '''''', @optvalue=N'''''' + CASE WHEN PropertyName IN (''connect timeout'', ''query timeout'') THEN ''0'' ELSE PropertyValue END +'''''''' + CHAR(10)
Col1
FROM unp';

declare @TableOut table
(
	RowNum          int identity(1, 1), 
	CreateStatement nvarchar(1000));
insert into @TableOut (CreateStatement) 
execute sp_executesql @SQL;

set @RowNum = 1;
while @RowNum < (select MAX(RowNum) + 1
				 from @TableOut) 
begin
	select @CreateStatement = CreateStatement
	from @TableOut
	where RowNum = @RowNum;
	if @PrintOnly = 1
		print @CreateStatement;
	else
	begin try
		exec (@CreateStatement);
	end try
	begin catch
		print 'Error creating Linked Servers!';
		throw;
	end catch;
	set @RowNum = @RowNum + 1;
end;
print 'Linked servers created successully! Update passwords for the ones using remote login!';

/***********************************************************************************************************************************************
 STEP 4 - Copy Server options  *****************************************************************************************************************
***********************************************************************************************************************************************/

set @SQL = 'EXECUTE [' + @Source_Instance + '].master.sys.sp_configure ''show advanced options'', 1';
declare @OptionsSource table
(
	name         nvarchar(200), 
	minimum      int, 
	maximum      int, 
	config_value int, 
	run_value    int);

begin
	begin try
		exec (@SQL);
	end try
	begin catch
		print 'Error changing ''show advanced options'' to 1!';
		throw;
	end catch;
	set @SQL = 'EXEC [' + @Source_Instance + '].master.sys.sp_executesql N''RECONFIGURE'';';
	exec sp_executesql @SQL;
	set @SQL = 'EXEC [' + @Source_Instance + '].master.sys.sp_configure; ';
	begin try
		insert into @OptionsSource
		execute (@SQL);
	end try
	begin catch
		print 'Error reading server options from the Source Instance [' + @Source_Instance + ']!';
		throw;
	end catch;
	declare @OptionsDest table
	(
		name         nvarchar(200), 
		minimum      int, 
		maximum      int, 
		config_value int, 
		run_value    int);
	insert into @OptionsDest
	execute master.sys.sp_configure;

	declare @Options table
	(
		RowNum          int identity(1, 1), 
		CreateStatement nvarchar(1000));
	insert into @Options
	select 'EXECUTE master.sys.sp_configure ''' + a.name + ''',' + CAST(s.config_value as varchar)
	from @OptionsDest as a
		 inner join @OptionsSource as s on s.name = a.name
	where s.config_value <> a.config_value
		  and a.name not in ('xp_cmdshell', 'Ole Automation Procedures', 'Ad Hoc Distributed Queries');

	set @RowNum = 1;
	while @RowNum < (select MAX(RowNum) + 1
					 from @Options) 
	begin
		select @CreateStatement = CreateStatement
		from @Options
		where RowNum = @RowNum;
		if @PrintOnly = 1
			print @CreateStatement;
		else
		begin try
			exec (@CreateStatement);
		end try
		begin catch
			print 'Error setting server option [' + @CreateStatement + ']!';
			throw;
		end catch;
		set @RowNum = @RowNum + 1;
	end;
	reconfigure;
end;
print 'Successfully copied Server options';
set @SQL = '';

/********************************************************************************************************************************************
 STEP 5 - Copy Credentials  *****************************************************************************************************************
********************************************************************************************************************************************/

declare @CopyCredentials table
(
	RowNum        int identity(1, 1), 
	RestoreScript nvarchar(1000));
declare @Proxies table
(
	RowNum                     int identity(1, 1), 
	proxy_id                   int, 
	name                       sysname, 
	credential_identity        sysname, 
	enabled                    tinyint, 
	description                nvarchar(1024), 
	user_sid                   varbinary(85), 
	credential_id              int, 
	credential_identity_exists int);
declare @Proxies2 table
(
	RowNum         int identity(1, 1), 
	subsystem_id   int, 
	subsystem_name sysname, 
	proxy_id       int, 
	proxy_name     sysname);

-- Get the credentials from sys.credentials, the password is unknown
set @SQL = 'SELECT ''CREATE CREDENTIAL ['' + c.[name] + ''] WITH IDENTITY = '''''' + c.[credential_identity] + '''''', SECRET = ''''<Password>''''''
FROM [' + @Source_Instance + '].[master].[sys].[credentials] c
LEFT JOIN [master].[sys].[credentials] c2 ON c.[name] = c2.[name]
WHERE c2.[name] IS NULL
ORDER BY c.[name]';

begin try
	insert into @CopyCredentials (RestoreScript) 
	exec (@SQL);
end try
begin catch
	print 'Error reading Credentials on Instance [' + @Source_Instance + ']!';
	throw;
end catch;

set @SQL = '';
set @RowNum = 1;
while @RowNum < (select MAX(RowNum) + 1
				 from @CopyCredentials) 
begin
	select @CreateStatement = RestoreScript
	from @CopyCredentials
	where RowNum = @RowNum;

	if @PrintOnly = 1
		print @CreateStatement;
	else
	begin try
		execute sp_executesql @CreateStatement;
	end try
	begin catch
		print 'Error creating Credentials [' + @CreateStatement + ']!';
		throw;
	end catch;
	set @RowNum = @RowNum + 1;
end;

-- Get the proxies from sp_help_proxy and sys.credentials
set @SQL = 'EXEC [' + @Source_Instance + '].msdb..sp_help_proxy';
begin try
	insert into @Proxies (proxy_id, 
						  name, 
						  credential_identity, 
						  enabled, 
						  description, 
						  user_sid, 
						  credential_id, 
						  credential_identity_exists) 
	exec (@SQL);
end try
begin catch
	print 'Error reading Credentials on Instance [' + @Source_Instance + ']!';
	throw;
end catch;

set @CreateStatement = '';
set @RowNum = 1;
while @RowNum < (select MAX(RowNum) + 1
				 from @Proxies) 
begin
	select @CreateStatement = 'EXEC msdb.dbo.sp_add_proxy @proxy_name=''' + i.name + ''', @enabled=' + CAST(i.enabled as varchar) + ', @description=' + case
																																							when i.description is null then 'NULL'
																																						else '''' + i.description + ''''
																																						end + ', @credential_name=''' + [c].[name] + ''''
	from @Proxies as i
		 inner join master.sys.credentials as c on c.credential_id = i.credential_id
		 left join msdb.dbo.sysproxies as sp on sp.name = i.name
	where i.RowNum = @RowNum
		  and sp.name is null;

	if @PrintOnly = 1
		print @CreateStatement;
	else
	begin try
		execute sp_executesql @CreateStatement;
	end try
	begin catch
		print 'Error creating Proxy [' + @CreateStatement + ']!';
		throw;
	end catch;
	set @RowNum = @RowNum + 1;
end;

-- Get the proxy authorizations from sp_enum_proxy_for_subsystem

set @SQL = 'EXEC [' + @Source_Instance + '].msdb..sp_enum_proxy_for_subsystem';

begin try
	insert into @Proxies2 (subsystem_id, 
						   subsystem_name, 
						   proxy_id, 
						   proxy_name) 
	exec (@SQL);
end try
begin catch
	print 'Error reading Proxies Subsystem on Instance [' + @Source_Instance + ']!';
	throw;
end catch;

set @CreateStatement = '';
set @RowNum = 1;
while @RowNum < (select MAX(RowNum) + 1
				 from @Proxies2) 
begin
	select @CreateStatement = 'EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N''' + proxy_name + ''', @subsystem_id = ' + CAST(i.subsystem_id as varchar)
	from @Proxies2 as i
		 left join msdb.dbo.sysproxysubsystem as sp on sp.subsystem_id = i.subsystem_id
	where i.RowNum = @RowNum
		  and sp.subsystem_id is null;

	if @PrintOnly = 1
		print @CreateStatement;
	else
	begin try
		execute sp_executesql @CreateStatement;
	end try
	begin catch
		print 'Error creating Proxy Subsystem [' + @CreateStatement + ']!';
		throw;
	end catch;
	set @RowNum = @RowNum + 1;
end;

  /********************************************************************************************************************************************
 STEP 6 - Copy agent Jobs  ******************************************************************************************************************
********************************************************************************************************************************************/

set @SQL = 'IF EXISTS (SELECT TOP 1 1 FROM [' + @Source_Instance + '].msdb.dbo.sysoperators WHERE [enabled] = 1)
SELECT '''' + [name] + '''' Operator, 
''EXEC msdb.dbo.sp_add_operator @name=N'''''' + [name] + '''''', 
		@enabled=1, 
		@weekday_pager_start_time= '' + CAST(weekday_pager_start_time as VARCHAR) + '', 
		@weekday_pager_end_time='' + CAST(weekday_pager_end_time as VARCHAR) + '', 
		@saturday_pager_start_time='' + CAST(saturday_pager_start_time as VARCHAR) + '', 
		@saturday_pager_end_time='' + CAST(saturday_pager_end_time as VARCHAR) + '', 
		@sunday_pager_start_time='' + CAST(sunday_pager_start_time as VARCHAR) + '', 
		@sunday_pager_end_time='' + CAST(sunday_pager_end_time as VARCHAR) + '', 
		@pager_days='' + CAST(pager_days as VARCHAR) + '', 
		@email_address=N'''''' + email_address + '''''', 
		@category_name=N''''[Uncategorized]'''''' [Statement]
FROM [' + @Source_Instance + '].msdb.dbo.sysoperators WHERE [enabled] = 1';

declare @Operators table
(
	RowNum          int identity(1, 1), 
	Operator        sysname, 
	CreateStatement nvarchar(1000));
declare @Operator sysname;

insert into @Operators (Operator, 
						CreateStatement) 
exec (@SQL);

set @RowNum = 1;
while @RowNum < (select MAX(RowNum) + 1
				 from @Operators) 
begin
	select @CreateStatement = CreateStatement, 
		   @Operator = Operator
	from @Operators
	where RowNum = @RowNum;
	if @PrintOnly = 1
		print @CreateStatement;
	else
	begin
		if not exists (select top 1 1
					   from msdb.dbo.sysoperators
					   where name = @Operator) 
			execute sp_executesql @CreateStatement;
	end;
	set @RowNum = @RowNum + 1;
end;

declare @File varchar(300) = 'C:TempCreate_SQLAgentJobSript.ps1';  -- local folder on sql instance
declare @Text varchar(8000) = '
$ServerNameList = "' + @Source_Instance + '"

#Load the SQL Server SMO Assemly
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null

#Create a new SqlConnection object
$objSQLConnection = New-Object System.Data.SqlClient.SqlConnection

#For each server in the array do the following..
foreach($ServerName in $ServerNameList)
{
	Try
	{
		$objSQLConnection.ConnectionString = "Server=$ServerName;Integrated Security=SSPI;"
    		Write-Host "Trying to connect to SQL Server instance on $ServerName..." -NoNewline
    		$objSQLConnection.Open() | Out-Null
    		Write-Host "Success."
		$objSQLConnection.Close()
	}
	Catch
	{
		Write-Host -BackgroundColor Red -ForegroundColor White "Fail"
		$errText =  $Error[0].ToString()
    		if ($errText.Contains("network-related"))
		{Write-Host "Connection Error. Check server name, port, firewall."}

		Write-Host $errText
		continue
	}

	#IF the output folder does not exist then create it
	$OutputFolder = "c:TESTSQLI"
	$DoesFolderExist = Test-Path $OutputFolder
	$null = if (!$DoesFolderExist){MKDIR "$OutputFolder"}

	#Create a new SMO instance for this $ServerName
	$srv = New-Object "Microsoft.SqlServer.Management.Smo.Server" $ServerName

	#Script out each SQL Server Agent Job for the server
	$srv.JobServer.Jobs | foreach {$_.Script() + "GO`r`n"} | out-file "C:Tempjobs.sql"

}';
declare @OLE int;
declare @FileID int;

execute sp_OACreate 'Scripting.FileSystemObject', @OLE out; 
execute sp_OAMethod @OLE, 'OpenTextFile', @FileID out, @File, 8, 1; 
execute sp_OAMethod @FileID, 'WriteLine', null, @Text;
execute sp_OADestroy @FileID; 
execute sp_OADestroy @OLE;

declare @SqlPowerShell as varchar(200);
set @SqlPowerShell = 'powershell.exe -ExecutionPolicy Bypass -File "' + @File + '"';  

exec xp_cmdshell @SqlPowerShell;

set @SqlPowerShell = 'sqlcmd -S ' + @@SERVERNAME + ' -i C:Tempjobs.sql';

if @PrintOnly = 0
	exec xp_cmdshell @SqlPowerShell;

print 'Successfully copied agent Jobs!';

/****************************************************************************************************************************************
 STEP 7 - Copy DB Mail  *****************************************************************************************************************
****************************************************************************************************************************************/

set @SQL = 'DECLARE @Mail TABLE ([name] sysname, minimum INT, maximum INT, config_value INT, run_value INT)

INSERT INTO @Mail
EXEC sp_configure ''Database Mail XPs''

IF (SELECT TOP 1 config_value FROM @Mail) = 1
  BEGIN
    DECLARE @ProfileName sysname, @Account sysname
	WHILE EXISTS(SELECT TOP 1 * FROM msdb.dbo.sysmail_profile)
	  BEGIN
		SELECT TOP 1 @ProfileName = [name] FROM msdb.dbo.sysmail_profile
		EXEC msdb.dbo.sysmail_delete_profile_sp @profile_name=@ProfileName, @force_delete=True
	  END

	WHILE EXISTS(SELECT TOP 1 * FROM  msdb.dbo.sysmail_account)
	  BEGIN
	    SELECT TOP 1 @Account = [name] FROM msdb.dbo.sysmail_account
		EXEC msdb.dbo.sysmail_delete_account_sp @account_name=@Account
	  END

	DECLARE @profile_name sysname='''', @account_name sysname='''', @SMTP_servername sysname, @email_address NVARCHAR(128), @display_name NVARCHAR(128), @replyto NVARCHAR(128), @sequence_number INT = 0;
	WHILE EXISTS(SELECT TOP 1 1 FROM [' + @Source_Instance + '].msdb.dbo.[sysmail_account] WHERE @account_name <> [name] )
	  BEGIN
		SELECT TOP 1 @account_name = [name], @email_address = email_address, @display_name = display_name, @replyto = [replyto_address] FROM [' + @Source_Instance + '].[msdb].[dbo].[sysmail_account]
		SELECT TOP 1 @SMTP_servername = servername FROM [' + @Source_Instance + '].[msdb].[dbo].[sysmail_server]
		EXECUTE msdb.dbo.sysmail_add_account_sp
		@account_name = @account_name,
		@email_address = @email_address,
		@display_name = @display_name,
		@replyto_address = @replyto,
		@mailserver_name = @SMTP_servername;
	  END
	WHILE EXISTS(SELECT TOP 1 1 FROM [' + @Source_Instance + '].msdb.dbo.sysmail_profile WHERE @profile_name <> [name] )
	  BEGIN
		SELECT TOP 1 @profile_name = [name] FROM [' + @Source_Instance + '].msdb.dbo.sysmail_profile WHERE @profile_name <> [name] 
		SELECT TOP 1 @account_name = a.[name]
		FROM [' + @Source_Instance + '].[msdb].[dbo].[sysmail_profileaccount] pa
		INNER JOIN [' + @Source_Instance + '].[msdb].[dbo].[sysmail_account] a ON a.account_id = pa.account_id
		INNER JOIN [' + @Source_Instance + '].[msdb].[dbo].[sysmail_profile] p ON p.profile_id = pa.profile_id
		WHERE p.[name] = @profile_name

		EXECUTE msdb.dbo.sysmail_add_profile_sp @profile_name = @profile_name ;		
		-- Associate the account with the profile.
		SELECT @sequence_number = ISNULL(MAX(sequence_number), 0) + 1 FROM [msdb].[dbo].[sysmail_profileaccount]
		EXECUTE msdb.dbo.sysmail_add_profileaccount_sp
			@profile_name = @profile_name,
			@account_name = @account_name,
			@sequence_number = @sequence_number ;
	  END
  END';

begin try
	execute sp_executesql @SQL;
end try
begin catch
	print 'Error setting up DB Mail!';
	throw;
end catch;

print 'Successfully configured DB Mail!';

/*********************************************************************************************************************************************
 STEP 8 - Copy Certificates  *****************************************************************************************************************
*********************************************************************************************************************************************/

declare @CertName   sysname, 
		@CertDesc   nvarchar(300), 
		@ActiveNode nvarchar(128), 
		@cmd        nvarchar(600);
declare @Certs table
(
	RowNum      int identity(1, 1), 
	CertName    sysname, 
	issuer_name nvarchar(300));
declare @OLEfolder          int, 
		@OLEsource          varchar(255), 
		@OLEdescription     varchar(255), 
		@init               int, 
		@OLEfilesytemobject int, 
		@NewFolder          nvarchar(1000), 
		@FileExists         int; 

if not exists (select top 1 1
			   from master.sys.symmetric_keys
			   where name = '##MS_DatabaseMasterKey##') 
	create master key encryption by password = '55TRd&bB^20';

set @SQL = 'SELECT s.[name], s.[issuer_name] 
FROM [' + @Source_Instance + '].master.sys.certificates s 
LEFT JOIN master.sys.certificates d ON d.[name] = s.[name] 
WHERE LEFT(s.[name], 1) <> ''#'' AND d.[name] IS NULL';

begin try
	insert into @Certs (CertName, 
						issuer_name) 
	exec (@SQL);
end try
begin catch
	print 'Error reading Certificates from Instance [' + @Source_Instance + ']!';
	throw;
end catch;

------ Finding Active Node ------
begin try
	exec master..xp_regread @rootkey = 'HKEY_LOCAL_MACHINE', @RegistryKeyPath = 'SYSTEMCurrentControlSetControlComputerNameComputerName', @value_name = 'ComputerName', @value = @ActiveNode output;
end try
begin catch
	print 'Error reading Active Node name!';
	throw;
end catch;

set @NewFolder = '\' + @ActiveNode + 'C$Temp';
exec @init = sp_OACreate 'Scripting.FileSystemObject', @OLEfilesytemobject out; 

if @init <> 0
begin
	exec sp_OAGetErrorInfo @OLEfilesytemobject;
	return;
end; 

exec @init = sp_OAMethod @OLEfilesytemobject, 'FolderExists', @OLEfolder out, @NewFolder; 

if @OLEfolder = 0
begin
	exec @init = sp_OAMethod @OLEfilesytemobject, 'CreateFolder', @OLEfolder out, @NewFolder;
end; 
-- in case of error, raise it  
if @init <> 0
begin
	begin try
		exec sp_OAGetErrorInfo @OLEfilesytemobject, @OLEsource out, @OLEdescription out;
	end try
	begin catch
		print 'Error creating folder [' + @NewFolder + ']!';
		print @OLEdescription;
		throw;
	end catch;
end; 
execute @init = sp_OADestroy @OLEfilesytemobject;

set @RowNum = 1;
while @RowNum < (select MAX(RowNum) + 1
				 from @Certs) 
begin
	select @CertName = CertName, 
		   @CertDesc = issuer_name
	from @Certs
	where RowNum = @RowNum;
	-- backup Certificate, provide the password
	set @SQL = 'EXEC [' + @Source_Instance + '].master.sys.sp_executesql N''BACKUP CERTIFICATE ' + @CertName + ' 
	TO FILE=''''' + @NewFolder + @CertName + '.crt''''
	with private key (file = ''''' + @NewFolder + @CertName + '.key''''
	, encryption By Password = ''''<Password>'''')''';
	if @PrintOnly = 1
		print @SQL;
	else
	begin
		set @cmd = @NewFolder + @CertName + '.crt';
		exec xp_fileExist @cmd, @FileExists output;
		if @FileExists = 1
		begin
			set @cmd = 'xp_cmdshell ''del "' + @NewFolder + @CertName + '.crt"''';
			exec (@cmd);
		end;
		set @FileExists = 0;
		set @cmd = @NewFolder + @CertName + '.key';
		exec xp_fileExist @cmd, @FileExists output;
		if @FileExists = 1
		begin
			set @cmd = 'xp_cmdshell ''del "' + @NewFolder + @CertName + '.key"''';
			exec (@cmd);
		end;
		begin try
			exec sp_executesql @SQL;
		end try
		begin catch
			print 'Error backing up Certificate [' + @SQL + ']!';
			throw;
		end catch;
	end;

	set @SQL = 'CREATE CERTIFICATE ' + @CertName + ' FROM FILE =''C:Temp' + @CertName + '.crt''   
	WITH PRIVATE KEY (FILE = ''C:Temp' + @CertName + '.key''
    ,DECRYPTION BY PASSWORD = ''<Password>'')';
	if @PrintOnly = 1
		print @SQL;
	else
	begin try
		exec (@SQL);
	end try
	begin catch
		print 'Error creating Certificate [' + @SQL + ']!';
		throw;
	end catch;
	set @RowNum = @RowNum + 1;
end;
set @SQL = '';
print 'Successfully copied Certificates!';


/**************************************************************************************************************************************************
 STEP 9 - Restore user databases  *****************************************************************************************************************
**************************************************************************************************************************************************/

declare @RestoreDatabases table
(
	RowNum            int identity(1, 1), 
	RestoreScript     nvarchar(2000), 
	ChangeOwnerScript nvarchar(1000), 
	database_name     sysname);
declare @RestoreScript     nvarchar(2000), 
		@ChangeOwnerScript nvarchar(1000), 
		@LastBackUpTime    datetime, 
		@DatabaseName      sysname, 
		@MoveFiles         nvarchar(2000);--, @ServiceAccount sysname
declare @DatabasesList table
(
	RowNum         int identity(1, 1), 
	DatabaseName   sysname, 
	LastBackUpTime datetime);
declare @ForceFreshBackups bit = 1;  -- 1 = Force, 0 = use latest

-- check latest backup dates
set @SQL = 'SELECT sdb.[name] AS DatabaseName,
COALESCE(MAX(bus.backup_finish_date), GETDATE()-10) AS LastBackUpTime
FROM [' + @Source_Instance + '].master.sys.databases sdb
LEFT JOIN [' + @Source_Instance + '].msdb.dbo.backupset bus ON bus.database_name = sdb.[name]
WHERE sdb.[name] NOT IN (''master'', ''model'', ''msdb'', ''tempdb'')
AND sdb.database_id NOT IN (SELECT database_id FROM [' + @Source_Instance + '].master.sys.dm_hadr_database_replica_states WHERE is_primary_replica = 0 AND database_state IS NOT NULL)  -- exclude mirrored databases
GROUP BY sdb.[name]';

begin try
	insert into @DatabasesList (DatabaseName, 
								LastBackUpTime) 
	exec (@SQL);
end try
begin catch
	print 'Error reading backup history for dbs on Instance [' + @Source_Instance + ']!';
	throw;
end catch;

set @SQL = '';
set @RowNum = 1;
while @RowNum < (select MAX(RowNum) + 1
				 from @DatabasesList) 
begin
	select @LastBackUpTime = LastBackUpTime, 
		   @DatabaseName = DatabaseName
	from @DatabasesList
	where RowNum = @RowNum;
	if @LastBackUpTime < GETDATE() - 1
	   or @ForceFreshBackups = 1
	begin
		set @SQL = 'EXEC [' + @Source_Instance + '].master.sys.sp_executesql 
		N''BACKUP DATABASE [' + @DatabaseName + '] TO DISK = ''''' + @BackupDirectory + @DatabaseName + '.BAK'''' WITH NOFORMAT, INIT, SKIP, NOREWIND, NOUNLOAD, COMPRESSION''';

		if @PrintOnly = 1
			print @SQL;
		else
			execute sp_executesql @SQL;
	end;
	set @RowNum = @RowNum + 1;
end;

--SELECT @ServiceAccount = service_account
--FROM sys.dm_server_services WHERE servicename LIKE 'SQL Server (%'

declare @ParmDefinition nvarchar(300);
set @ParmDefinition = N'@ColValueOUT nvarchar(2000) OUTPUT';

set @SQL = 'SELECT ''RESTORE DATABASE ['' + bs.[database_name] + ''] FROM  DISK = N'''''' +
    bmf.physical_device_name + '''''' WITH  FILE = 1, REPLACE, RECOVERY'' RestoreScript,
	''ALTER AUTHORIZATION ON DATABASE::['' + bs.[database_name] + ''] TO [sa]'' ChangeOwnerScript, bs.[database_name] 
FROM [' + @Source_Instance + '].msdb.dbo.backupmediafamily bmf
INNER JOIN [' + @Source_Instance + '].msdb.dbo.backupset bs ON bmf.media_set_id = bs.media_set_id
INNER JOIN [' + @Source_Instance + '].master.sys.sysdatabases sd ON sd.[name] = bs.[database_name]
WHERE (
			bs.backup_set_id IN (
				SELECT MAX(ba.backup_set_id)
				FROM [' + @Source_Instance + '].msdb.dbo.backupset ba
				WHERE ba.[type] = ''D''
				GROUP BY ba.[database_name]
				)        
			)
AND bs.[database_name] NOT IN (''master'', ''model'', ''msdb'')
AND sd.dbid NOT IN (SELECT database_id FROM [' + @Source_Instance + '].master.sys.dm_hadr_database_replica_states WHERE is_primary_replica = 0 AND database_state IS NOT NULL)
ORDER BY bs.[database_name]';


begin try
	insert into @RestoreDatabases (RestoreScript, 
								   ChangeOwnerScript, 
								   database_name) 
	exec (@SQL);
end try
begin catch
	print 'Error reading Databases to restore from Instance [' + @Source_Instance + ']!';
	throw;
end catch;

declare @NewDataPhysicalName nvarchar(512);
exec master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SoftwareMicrosoftMSSQLServerMSSQLServer', N'DefaultData', @NewDataPhysicalName output;
set @NewDataPhysicalName = @NewDataPhysicalName + '';
declare @NewLogPhysicalName nvarchar(512);
exec master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SoftwareMicrosoftMSSQLServerMSSQLServer', N'DefaultLog', @NewLogPhysicalName output;
set @NewLogPhysicalName = @NewLogPhysicalName + '';

set @RowNum = 1;
while @RowNum < (select MAX(RowNum) + 1
				 from @RestoreDatabases) 
begin
	select @RestoreScript = RestoreScript, 
		   @ChangeOwnerScript = ChangeOwnerScript, 
		   @DatabaseName = database_name
	from @RestoreDatabases
	where RowNum = @RowNum;
	set @SQL = 'SELECT @ColValueOUT = STUFF((SELECT '', MOVE '''''' + [name] + '''''' TO '''''' + 
	CASE type_desc WHEN ''ROWS'' THEN ''' + @NewDataPhysicalName + ''' ELSE ''' + @NewLogPhysicalName + ''' END + 
	REPLACE(RIGHT([physical_name],CHARINDEX('''',REVERSE([physical_name])) - 1), ''' + @DatabaseName + ''',''' + @DatabaseName + ''') + ''''''''
                      FROM OPENDATASOURCE(''SQLNCLI'',''Data Source=' + @Source_Instance + ';Integrated Security=SSPI'').[' + @DatabaseName + '].sys.database_files			
                         FOR XML PATH('''')
                      ), 1, 2, '''')';

	begin try
		exec sp_executesql @SQL, @ParmDefinition, @ColValueOUT = @MoveFiles output;
	end try
	begin catch
		print 'Error creating Restore Script for Database [' + @DatabaseName + ']!';
		throw;
	end catch;

	set @RestoreScript = @RestoreScript + ', ' + @MoveFiles;
	if @PrintOnly = 1
		print @RestoreScript;
	else
	begin
		begin try
			exec sp_executesql @RestoreScript;
			exec sp_executesql @ChangeOwnerScript;
		end try
		begin catch
			print 'Error restoring database [' + @RestoreScript + ']!';
			throw;
		end catch;
	end;
	set @RowNum = @RowNum + 1;
end;


-- Fix orphan users
begin try
	exec master..sp_MSforeachdb 'USE ?
	DECLARE @SQL VARCHAR(200)
	DECLARE curSQL CURSOR
			FOR SELECT ''EXEC sp_change_users_login @Action=''''UPDATE_ONE'''', @UserNamePattern='''''' + name + '''''', @LoginName='''''' + name + ''''''''
				FROM sysusers WHERE issqluser = 1 AND [name] NOT LIKE ''#%''
					AND name NOT IN (''guest'', ''dbo'', ''sys'', ''INFORMATION_SCHEMA'', ''MS_DataCollectorInternalUser'')

	OPEN curSQL
	FETCH curSQL INTO @SQL

	WHILE @@FETCH_STATUS = 0
		  BEGIN
			EXEC (@SQL)
			FETCH curSQL INTO @SQL
		  END

	CLOSE curSQL
	DEALLOCATE curSQL';
end try
begin catch
-- do nothing
end catch;



-- Finish. Disable SQL Agent on migrated from Instance.
set @SQL = 'EXECUTE [' + @Source_Instance + '].master.sys.sp_configure ''Agent XPs'', 0';

begin try
	exec (@SQL);
end try
begin catch
	print 'Error changing ''Agent XPs'' to 0 on [' + @Source_Instance + ']!';
	throw;
end catch;
set @SQL = 'EXEC [' + @Source_Instance + '].master.sys.sp_executesql N''RECONFIGURE'';';
exec sp_executesql @SQL;	

exec master.dbo.sp_dropserver @server = @Source_Instance;

go
sp_configure 'xp_cmdshell', 0;
reconfigure;


/***********************************************************************
Delete Aliases to the Old instance manually if any! 
Disable SQL Agent on Old instance!
Update port numbers on new instances to match migrated from.

After renaming the instance, run: 
DECLARE @ServerName NVARCHAR(200)
SELECT @ServerName = CAST(SERVERPROPERTY('ServerName') AS NVARCHAR(200))
EXEC sp_addserver @ServerName, local
and Restart sql instance
***********************************************************************/