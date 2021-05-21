use master;
go

/********************************
EXEC sp_ShrinkAllUserDatabases
********************************/

if exists (select top 1 1
		   from sys.procedures
		   where name = 'sp_ShrinkAllUserDatabases') 
	drop proc sp_ShrinkAllUserDatabases;
go

create proc sp_ShrinkAllUserDatabases
as
begin

	declare @DBs table
	(
		database_id nvarchar(max), 
		name        nvarchar(max));

	insert into @DBs
	select database_id, 
		   name
	from sys.databases
	where name not in ('master', 'model', 'tempdb', 'msdb', 'Resource');

	declare @DB_ID         nvarchar(max), 
			@DB_NAME       nvarchar(max), 
			@LOG_FILENAME  nvarchar(max), 
			@DATA_FILENAME nvarchar(max);

	while exists (select top 1 1
				  from @DBs) 
	begin
		set @DB_ID = (select top 1 database_id
					  from @DBs);
		set @DB_NAME = (select top 1 name
						from @DBs);
		set @DATA_FILENAME = (select top 1 name
							  from sys.master_files
							  where database_id = @DB_ID
									and type = 0);
		set @LOG_FILENAME = (select top 1 name
							 from sys.master_files
							 where database_id = @DB_ID
								   and type = 1);

		exec ('ALTER DATABASE ['+@DB_NAME+'] SET RECOVERY SIMPLE');
		exec ('USE ['+@DB_NAME+'] ; DBCC SHRINKFILE (['+@LOG_FILENAME+'], 1)');
		exec ('USE ['+@DB_NAME+'] ; DBCC SHRINKFILE (['+@DATA_FILENAME+'], 1)');
		exec ('ALTER DATABASE ['+@DB_NAME+'] SET RECOVERY FULL');

		delete @DBs
		where database_id = @DB_ID;
	end;
end;

go

exec sp_ShrinkAllUserDatabases;
go