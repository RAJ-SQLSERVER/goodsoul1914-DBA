-----------------------------------------------------------------------------------------------------------------------------
-- Script to grant a user read-only access to all the databases at on go in a SQL Server instance except the system databases and 
-- the Log shipped databases(secondary :read-only)
---Created by : Gaurav Deep Singh Juneja
-----------------------------------------------------------------------------------------------------------------------------

--STEP 1 : Create the Login (Windows or SQL) which needs the db_datareader access.
-----------------------------------------------------------------------------------------------------------------------------
--create login [domain\username] from windows;
--create login [username] with password='######' ,CHECK_EXPIRATION = OFF,  CHECK_POLICY = OFF;  

use master;
go

declare @DatabaseName nvarchar(100);
declare @SQL nvarchar(max);
declare @User varchar(64);
set @User = '[username]'; -- Replace Your User here

print 'The following user has been selected to have read-only access on all user databases except system databases and log shipped databases:  ' + @user;


declare Grant_Permission cursor local
for select name
	from sys.databases
	where name not in ('master', 'model', 'msdb', 'tempdb', 'resource')
		  and state_desc = 'ONLINE'
		  and is_read_only <> 1
	order by name;
open Grant_Permission;  
fetch next from Grant_Permission into @DatabaseName;  
while @@FETCH_STATUS = 0
begin
	select @SQL = 'USE ' + '[' + @DatabaseName + ']' + '; ' + 'CREATE USER ' + @User + 'FOR LOGIN ' + @User + '; EXEC sp_addrolemember N''db_datareader'', ' + @User + '';
	print @SQL;
	exec sp_executesql @SQL;

	print ''; -- This is to give a line space between two databases execute prints.

	fetch next from Grant_Permission into @DatabaseName;
end;  

close Grant_Permission;  
deallocate Grant_Permission;