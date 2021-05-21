-- Drops all indexes and statistics in a schema or table
--------------------------------------------------------------------------------------------------

create procedure dbo.sp_DropIndexes 
	@schemaname nvarchar(255) = 'dbo', 
	@tablename  nvarchar(255) = null
as
begin
	set nocount on;
	create table #commands
	(
		ID      int identity(1, 1) primary key clustered , 
		Command nvarchar(2000));
	declare @currentcommand nvarchar(2000);
	insert into #commands (Command) 
	select 'DROP INDEX [' + i.name + '] ON [' + SCHEMA_NAME(t.schema_id) + '].[' + t.name + ']'
	from sys.tables as t
		 inner join sys.indexes as i on t.object_id = i.object_id
	where i.type = 2
		  and SCHEMA_NAME(t.schema_id) = COALESCE(@schemaname, SCHEMA_NAME(t.schema_id))
		  and t.name = COALESCE(@tablename, t.name);
	insert into #commands (Command) 
	select 'DROP STATISTICS ' + SCHEMA_NAME(t.schema_id) + '.' + OBJECT_NAME(s.object_id) + '.' + s.name
	from sys.stats as s
		 inner join sys.tables as t on s.object_id = t.object_id
	where not exists
	(
		select *
		from sys.indexes as i
		where i.name = s.name
	)
		  and SCHEMA_NAME(t.schema_id) = COALESCE(@schemaname, SCHEMA_NAME(t.schema_id))
		  and t.name = COALESCE(@tablename, t.name)
		  and OBJECT_NAME(s.object_id) not like 'sys%';
	declare result_cursor cursor
	for select Command
		from #commands;
	open result_cursor;
	fetch next from result_cursor into @currentcommand;
	while @@fetch_status = 0
	begin
		print @currentcommand;
		exec (@currentcommand);
		fetch next from result_cursor into @currentcommand;
	end;
	--end loop
	--clean up
	close result_cursor;
	deallocate result_cursor;
end;
go