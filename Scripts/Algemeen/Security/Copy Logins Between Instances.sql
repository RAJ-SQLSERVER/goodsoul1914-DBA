use master;
go

if OBJECT_ID('sp_hexadecimal') is not null
	drop procedure sp_hexadecimal;
go

create procedure sp_hexadecimal 
	@binvalue varbinary(256), 
	@hexvalue varchar(514) output
as
begin
	declare @charvalue varchar(514);
	declare @i int;
	declare @length int;
	declare @hexstring char(16);
	select @charvalue = '0x';
	select @i = 1;
	select @length = DATALENGTH(@binvalue);
	select @hexstring = '0123456789ABCDEF';
	while @i <= @length
	begin
		declare @tempint int;
		declare @firstint int;
		declare @secondint int;
		select @tempint = CONVERT(int, SUBSTRING(@binvalue, @i, 1));
		select @firstint = FLOOR(@tempint / 16);
		select @secondint = @tempint - @firstint * 16;
		select @charvalue = @charvalue + SUBSTRING(@hexstring, @firstint + 1, 1) + SUBSTRING(@hexstring, @secondint + 1, 1);
		select @i = @i + 1;
	end;

	select @hexvalue = @charvalue;
end;
go

if OBJECT_ID('sp_help_revlogin') is not null
	drop procedure sp_help_revlogin;
go

create procedure sp_help_revlogin 
	@login_name sysname = null
as
begin
	declare @name sysname;
	declare @type varchar(1);
	declare @hasaccess int;
	declare @denylogin int;
	declare @is_disabled int;
	declare @PWD_varbinary varbinary(256);
	declare @PWD_string varchar(514);
	declare @SID_varbinary varbinary(85);
	declare @SID_string varchar(514);
	declare @tmpstr varchar(1024);
	declare @is_policy_checked varchar(3);
	declare @is_expiration_checked varchar(3);

	declare @defaultdb sysname;

	if @login_name is null
		declare login_curs cursor
		for select p.sid, 
				   p.name, 
				   p.type, 
				   p.is_disabled, 
				   p.default_database_name, 
				   l.hasaccess, 
				   l.denylogin
			from sys.server_principals as p
				 left join sys.syslogins as l on l.name = p.name
			where p.type in ('S', 'G', 'U')
				  and p.name <> 'sa';
		else
		declare login_curs cursor
		for select p.sid, 
				   p.name, 
				   p.type, 
				   p.is_disabled, 
				   p.default_database_name, 
				   l.hasaccess, 
				   l.denylogin
			from sys.server_principals as p
				 left join sys.syslogins as l on l.name = p.name
			where p.type in ('S', 'G', 'U')
				  and p.name = @login_name;
	open login_curs;

	fetch next from login_curs into @SID_varbinary, 
									@name, 
									@type, 
									@is_disabled, 
									@defaultdb, 
									@hasaccess, 
									@denylogin;
	if @@fetch_status = -1
	begin
		print 'No login(s) found.';
		close login_curs;
		deallocate login_curs;
		return -1;
	end;
	set @tmpstr = '/* sp_help_revlogin script ';
	print @tmpstr;
	set @tmpstr = '** Generated ' + CONVERT(varchar, GETDATE()) + ' on ' + @@SERVERNAME + ' */';
	print @tmpstr;
	print '';
	while @@fetch_status <> -1
	begin
		if @@fetch_status <> -2
		begin
			print '';
			set @tmpstr = '-- Login: ' + @name;
			print @tmpstr;
			if @type in('G', 'U')
			begin -- NT authenticated account/group

				set @tmpstr = 'CREATE LOGIN ' + QUOTENAME(@name) + ' FROM WINDOWS WITH DEFAULT_DATABASE = [' + @defaultdb + ']';
			end;
				else
			begin -- SQL Server authentication
				-- obtain password and sid
				set @PWD_varbinary = CAST(LOGINPROPERTY(@name, 'PasswordHash') as varbinary(256));
				exec sp_hexadecimal @PWD_varbinary, @PWD_string out;
				exec sp_hexadecimal @SID_varbinary, @SID_string out;

				-- obtain password policy state
				select @is_policy_checked = case is_policy_checked
												when 1 then 'ON'
												when 0 then 'OFF'
												else null
											end
				from sys.sql_logins
				where name = @name;
				select @is_expiration_checked = case is_expiration_checked
													when 1 then 'ON'
													when 0 then 'OFF'
													else null
												end
				from sys.sql_logins
				where name = @name;

				set @tmpstr = 'CREATE LOGIN ' + QUOTENAME(@name) + ' WITH PASSWORD = ' + @PWD_string + ' HASHED, SID = ' + @SID_string + ', DEFAULT_DATABASE = [' + @defaultdb + ']';

				if @is_policy_checked is not null
				begin
					set @tmpstr = @tmpstr + ', CHECK_POLICY = ' + @is_policy_checked;
				end;
				if @is_expiration_checked is not null
				begin
					set @tmpstr = @tmpstr + ', CHECK_EXPIRATION = ' + @is_expiration_checked;
				end;
			end;
			if @denylogin = 1
			begin -- login is denied access
				set @tmpstr = @tmpstr + '; DENY CONNECT SQL TO ' + QUOTENAME(@name);
			end;
				else
				if @hasaccess = 0
				begin -- login exists but does not have access
					set @tmpstr = @tmpstr + '; REVOKE CONNECT SQL TO ' + QUOTENAME(@name);
				end;
			if @is_disabled = 1
			begin -- login is disabled
				set @tmpstr = @tmpstr + '; ALTER LOGIN ' + QUOTENAME(@name) + ' DISABLE';
			end;
			print @tmpstr;
		end;

		fetch next from login_curs into @SID_varbinary, 
										@name, 
										@type, 
										@is_disabled, 
										@defaultdb, 
										@hasaccess, 
										@denylogin;
	end;
	close login_curs;
	deallocate login_curs;
	return 0;
end;
go