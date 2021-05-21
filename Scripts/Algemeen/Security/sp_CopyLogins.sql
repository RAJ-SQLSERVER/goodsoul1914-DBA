/********************************************************************************
Credit for Original code goes to Robert L Davis aka SQLSoldier.

In the original stored procedure, if the endpoint_id's of an endpoint differ
between the source and destination servers, and the user running the procedure
has permissions on the endpoint, the procedure may try to grant permissions again
and throw an error saying "you cant grant permissions to yourself". This version
fixes that bug.
********************************************************************************/

/*********************************************************************************************************************
Source server: Server from which you are copying logins
Destination server: Server to which you are copying logins

1. Execute code on destination server to create the stored procedure in the master database.
2. Create a linked server on the destination server that references the source server.
3. Execute the stored procedure on the destination server using the linked server name as the @PartnerServer parameter
4. Optionally include @debug=1 to output the commands that would be executed without actually executing them.

Example: 
exec dba_CopyLogins @PartnerServer = 'PrimaryReplica'
*********************************************************************************************************************/

use [master];
go

/************************************************************************************************
***** Object:  StoredProcedure [dbo].[dba_CopyLogins]    Script Date: 8/28/2018 12:03:12 PM *****
************************************************************************************************/

set ansi_nulls on;
go

set quoted_identifier on;
go


create procedure dbo.sp_CopyLogins 
	@PartnerServer sysname, 
	@Debug         bit     = 0
as
begin
	-- V2 28-Aug-2018 - Dont try to grant permissions on endpoints if the user running this SP already has them,
	--	 and the endpoint_ids are different between the partnerserver and local server.
	declare @MaxID              int, 
			@CurrID             int, 
			@SQL                nvarchar(max), 
			@LoginName          sysname, 
			@IsDisabled         int, 
			@Type               char(1), 
			@SID                varbinary(85), 
			@SIDString          nvarchar(100), 
			@PasswordHash       varbinary(256), 
			@PasswordHashString nvarchar(300), 
			@RoleName           sysname, 
			@Machine            sysname, 
			@PermState          nvarchar(60), 
			@PermName           sysname, 
			@Class              tinyint, 
			@MajorID            int, 
			@ErrNumber          int, 
			@ErrSeverity        int, 
			@ErrState           int, 
			@ErrProcedure       sysname, 
			@ErrLine            int, 
			@ErrMsg             nvarchar(2048);
	declare @Logins table
	(
		LoginID      int identity(1, 1) not null primary key, 
		Name         sysname not null, 
		SID          varbinary(85) not null, 
		IsDisabled   int not null, 
		Type         char(1) not null, 
		PasswordHash varbinary(256) null);
	declare @Roles table
	(
		RoleID    int identity(1, 1) not null primary key, 
		RoleName  sysname not null, 
		LoginName sysname not null);
	declare @Perms table
	(
		PermID          int identity(1, 1) not null primary key, 
		LoginName       sysname not null, 
		PermState       nvarchar(60) not null, 
		PermName        sysname not null, 
		Class           tinyint not null, 
		ClassDesc       nvarchar(60) not null, 
		MajorID         int not null, 
		SubLoginName    sysname null, 
		SubEndPointName sysname null);

	set nocount on;

	if CHARINDEX('\', @PartnerServer) > 0
	begin
		set @Machine = LEFT(@PartnerServer, CHARINDEX('\', @PartnerServer) - 1);
	end;
	else
	begin
		set @Machine = @PartnerServer;
	end;

	-- Get all Windows logins from principal server
	set @SQL = 'Select P.name, P.sid, P.is_disabled, P.type, L.password_hash' + CHAR(10) + 'From ' + QUOTENAME(@PartnerServer) + '.master.sys.server_principals P' + CHAR(10) + 'Left Join ' + QUOTENAME(@PartnerServer) + '.master.sys.sql_logins L On L.principal_id = P.principal_id' + CHAR(10) + 'Where P.type In (''U'', ''G'', ''S'')' + CHAR(10) + 'And P.name <> ''sa''' + CHAR(10) + 'And P.name Not Like ''##%'' and p.name not like ''NT SERVICE\%''' + CHAR(10) + 'And CharIndex(''' + @Machine + '\'', P.name) = 0;';

	insert into @Logins (NAME, 
						 SID, 
						 IsDisabled, 
						 Type, 
						 PasswordHash) 
	exec sp_executesql @SQL;

	-- Get all roles from principal server
	set @SQL = 'Select RoleP.name, LoginP.name' + CHAR(10) + 'From ' + QUOTENAME(@PartnerServer) + '.master.sys.server_role_members RM' + CHAR(10) + 'Inner Join ' + QUOTENAME(@PartnerServer) + '.master.sys.server_principals RoleP' + CHAR(10) + CHAR(9) + 'On RoleP.principal_id = RM.role_principal_id' + CHAR(10) + 'Inner Join ' + QUOTENAME(@PartnerServer) + '.master.sys.server_principals LoginP' + CHAR(10) + CHAR(9) + 'On LoginP.principal_id = RM.member_principal_id' + CHAR(10) + 'Where LoginP.type In (''U'', ''G'', ''S'')' + CHAR(10) + 'And LoginP.name <> ''sa''' + CHAR(10) + 'And LoginP.name Not Like ''##%'' and LoginP.name not like ''NT Service\%''' + CHAR(10) + 'And RoleP.type = ''R''' + CHAR(10) + 'And CharIndex(''' + @Machine + '\'', LoginP.name) = 0;';

	insert into @Roles (RoleName, 
						LoginName) 
	exec sp_executesql @SQL;

	-- Get all explicitly granted permissions
	set @SQL = 'Select P.name Collate database_default,' + CHAR(10) + '	SP.state_desc, SP.permission_name, SP.class, SP.class_desc, SP.major_id,' + CHAR(10) + '	SubP.name Collate database_default,' + CHAR(10) + '	SubEP.name Collate database_default' + CHAR(10) + 'From ' + QUOTENAME(@PartnerServer) + '.master.sys.server_principals P' + CHAR(10) + 'Inner Join ' + QUOTENAME(@PartnerServer) + '.master.sys.server_permissions SP' + CHAR(10) + CHAR(9) + 'On SP.grantee_principal_id = P.principal_id' + CHAR(10) + 'Left Join ' + QUOTENAME(@PartnerServer) + '.master.sys.server_principals SubP' + CHAR(10) + CHAR(9) + 'On SubP.principal_id = SP.major_id And SP.class = 101' + CHAR(10) + 'Left Join ' + QUOTENAME(@PartnerServer) + '.master.sys.endpoints SubEP' + CHAR(10) + CHAR(9) + 'On SubEP.endpoint_id = SP.major_id And SP.class = 105' + CHAR(10) + 'Where P.type In (''U'', ''G'', ''S'')' + CHAR(10) + 'And P.name <> ''sa''' + CHAR(10) + 'And P.name Not Like ''##%'' and p.name not like ''NT Service\%''' + CHAR(10) + 'And CharIndex(''' + @Machine + '\'', P.name) = 0;';

	insert into @Perms (LoginName, 
						PermState, 
						PermName, 
						Class, 
						ClassDesc, 
						MajorID, 
						SubLoginName, 
						SubEndPointName) 
	exec sp_executesql @SQL;

	select @MaxID = MAX(LoginID), 
		   @CurrID = 1
	from @Logins;

	while @CurrID <= @MaxID
	begin
		select @LoginName = NAME, 
			   @IsDisabled = IsDisabled, 
			   @Type = Type, 
			   @SID = SID, 
			   @PasswordHash = PasswordHash
		from @Logins
		where LoginID = @CurrID;

		if not exists (select 1
					   from sys.server_principals
					   where NAME = @LoginName) 
		begin
			set @SQL = 'Create Login ' + QUOTENAME(@LoginName);

			if @Type in('U', 'G')
			begin
				set @SQL = @SQL + ' From Windows;';
			end;
			else
			begin
				set @PasswordHashString = '0x' + CAST('' as xml).value('xs:hexBinary(sql:variable("@PasswordHash"))', 'nvarchar(300)');
				set @SQL = @SQL + ' With Password = ' + @PasswordHashString + ' HASHED, ';
				set @SIDString = '0x' + CAST('' as xml).value('xs:hexBinary(sql:variable("@SID"))', 'nvarchar(100)');
				set @SQL = @SQL + 'SID = ' + @SIDString + ';';
			end;

			if @Debug = 0
			begin
				begin try
					exec sp_executesql @SQL;
				end try
				begin catch
					set @ErrNumber = ERROR_NUMBER();
					set @ErrSeverity = ERROR_SEVERITY();
					set @ErrState = ERROR_STATE();
					set @ErrProcedure = ERROR_PROCEDURE();
					set @ErrLine = ERROR_LINE();
					set @ErrMsg = ERROR_MESSAGE();

					raiserror(@ErrMsg, 1, 1);
				end catch;
			end;
			else
			begin
				print @SQL;
			end;

			if @IsDisabled = 1
			begin
				set @SQL = 'Alter Login ' + QUOTENAME(@LoginName) + ' Disable;';

				if @Debug = 0
				begin
					begin try
						exec sp_executesql @SQL;
					end try
					begin catch
						set @ErrNumber = ERROR_NUMBER();
						set @ErrSeverity = ERROR_SEVERITY();
						set @ErrState = ERROR_STATE();
						set @ErrProcedure = ERROR_PROCEDURE();
						set @ErrLine = ERROR_LINE();
						set @ErrMsg = ERROR_MESSAGE();

						raiserror(@ErrMsg, 1, 1);
					end catch;
				end;
				else
				begin
					print @SQL;
				end;
			end;
		end;

		set @CurrID = @CurrID + 1;
	end;

	select @MaxID = MAX(RoleID), 
		   @CurrID = 1
	from @Roles;

	while @CurrID <= @MaxID
	begin
		select @LoginName = LoginName, 
			   @RoleName = RoleName
		from @Roles
		where RoleID = @CurrID;

		if not exists (select 1
					   from sys.server_role_members as RM
							inner join sys.server_principals as RoleP on RoleP.principal_id = RM.role_principal_id
							inner join sys.server_principals as LoginP on LoginP.principal_id = RM.member_principal_id
					   where LoginP.type in ('U', 'G', 'S')
							 and RoleP.type = 'R'
							 and RoleP.NAME = @RoleName
							 and LoginP.NAME = @LoginName) 
		begin
			set @SQL = 'alter server role ' + QUOTENAME(@RoleName) + ' add member ' + QUOTENAME(@LoginName);

			if @Debug = 0
				exec sp_executesql @SQL;
			else
				print @SQL;
		end;

		set @CurrID = @CurrID + 1;
	end;

	-- Explicitly granted permissions - bug fixes below
	declare @SubEndpointName sysname; -- Added
	select @MaxID = MAX(PermID), 
		   @CurrID = 1
	from @Perms;

	while @CurrID <= @MaxID
	begin
		select @PermState = PermState, 
			   @PermName = PermName, 
			   @Class = Class, 
			   @LoginName = LoginName, 
			   @MajorID = MajorID, 
			   @SubEndpointName = SubEndPointName, -- Added 
			   @SQL = PermState + SPACE(1) + PermName + SPACE(1) + case Class
																	   when 101 then 'On Login::' + QUOTENAME(SubLoginName)
																	   when 105 then 'On ' + ClassDesc + '::' + QUOTENAME(SubEndPointName)
																   else ''
																   end + ' To ' + QUOTENAME(LoginName) + ';'
		from @Perms
		where PermID = @CurrID;

		if not exists (select 1
					   from sys.server_principals as P
							inner join sys.server_permissions as SP on SP.grantee_principal_id = P.principal_id
							left join sys.endpoints as SEP on SEP.endpoint_id = SP.major_id --Added
					   where SP.state_desc = @PermState
							 and SP.permission_name = @PermName
							 and SP.class = @Class
							 and P.NAME = @LoginName
							 --				AND SP.major_id = @MajorID -- Original line commented out
							 and ( SP.major_id = @MajorID
								   or SEP.name = @SubEndpointName
								 ) -- Added OR condition
					   )
		begin
			if @Debug = 0
			begin
				begin try
					exec sp_executesql @SQL;
				end try
				begin catch
					set @ErrNumber = ERROR_NUMBER();
					set @ErrSeverity = ERROR_SEVERITY();
					set @ErrState = ERROR_STATE();
					set @ErrProcedure = ERROR_PROCEDURE();
					set @ErrLine = ERROR_LINE();
					set @ErrMsg = ERROR_MESSAGE();
					raiserror(@ErrMsg, 1, 1);
				end catch;
			end;
			else
			begin
				print @SQL;
			end;
		end;

		set @CurrID = @CurrID + 1;
	end;

	set nocount off;
end;

go