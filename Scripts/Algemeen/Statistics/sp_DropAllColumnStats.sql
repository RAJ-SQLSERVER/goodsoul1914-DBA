use [master];
go

if OBJECT_ID(N'sp_DropAllColumnStats') is not null
	drop procedure sp_DropAllColumnStats;
go

set ansi_nulls on;

set quoted_identifier on;
go

create procedure dbo.sp_DropAllColumnStats
(
	@schemaname sysname     = null,			
	-- Specific schema 
	@objectname sysname     = null,			
	-- Specific object: table/view 
	@columnname sysname     = null,			
	-- Specific column 
	@DropAll    nvarchar(5) = 'FALSE') 
as
begin
	set nocount on;
	set ansi_warnings off;

	declare @schemanamedelimited    nvarchar(520) = QUOTENAME(@schemaname), 
			@objectnamedelimited    nvarchar(520) = QUOTENAME(@objectname), 
			@columnnamedelimited    nvarchar(520) = QUOTENAME(@columnname), 
			@stattoanalyzedelimited nvarchar(520) = null;

	if @schemaname is null
	   or @objectname is null
	   or @columnname is null
	   or @DropAll is null
	begin
		raiserror('Proc:sp_DropAllColumnStats, @schemaname = %s, @objectname = %s, @columnname = %s, @dropall = %s. The @schemaname, @objectname, and @columnname parameters are ALL required. Do not supply a delimited value.', 16, -1, @schemanamedelimited, @objectnamedelimited, @columnnamedelimited, @dropall);
		return;
	end;

	if @schemaname is not null
	   and @objectname is not null
	   and @columnname is not null
	   and not exists
	(
		select *
		from INFORMATION_SCHEMA.COLUMNS as isc
		where isc.TABLE_SCHEMA = @schemaname
			  and isc.TABLE_NAME = @objectname
			  and isc.COLUMN_NAME = @columnname
	) 
	begin
		raiserror('Proc:sp_DropAllColumnStats, @schemaname = %s, @objectname = %s, @columnname = %s. Column:%s is not valid for schema.object:%s.%s. Check to make sure you''re in the correct database and that you did not supply an already delimited value. Additionally, these parameters are case-sensitive when the database is case-sensitive.', 16, -1, @schemanamedelimited, @objectnamedelimited, @columnnamedelimited, @columnnamedelimited, @schemanamedelimited, @objectnamedelimited);
		return;
	end;

	declare @schemaid        int, 
			@twopartname     nvarchar(520), 
			@objectid        int, 
			@statistictodrop nvarchar(776), 
			@execstring      nvarchar(max);

	select @schemaid = SCHEMA_ID(@schemaname), 
		   @twopartname = QUOTENAME(@schemaname, ']') + N'.' + QUOTENAME(@objectname, ']'), 
		   @objectid = OBJECT_ID(@twopartname);

	if UPPER(@DropAll) = 'FALSE'
	begin
		-- Get the list of all column-level statistics
		select @twopartname + N'.' + QUOTENAME(s.name, N']') as [Since @DropAll = False, the statistics will only be listed, NOT dropped:]
		from sys.stats as s
		where s.object_id = @objectid
			  and INDEX_COL(OBJECT_NAME(s.object_id), s.stats_id, 1) = @columnname
			  and INDEX_COL(OBJECT_NAME(s.object_id), s.stats_id, 2) is null
			  and ( INDEXPROPERTY(s.object_id, s.name, 'IsStatistics') = 1
					or INDEXPROPERTY(s.object_id, s.name, 'IsHypothetical') = 1
				  );
	end;

	if UPPER(@DropAll) = 'TRUE'
	begin	
		-- Cursor over all objects
		declare StatisticsToDropCursor cursor local fast_forward read_only
		for select @twopartname + N'.' + QUOTENAME(s.name, N']')
			from sys.stats as s
			where s.object_id = @objectid
				  and INDEX_COL(OBJECT_NAME(s.object_id), s.stats_id, 1) = @columnname
				  and INDEX_COL(OBJECT_NAME(s.object_id), s.stats_id, 2) is null
				  and s.name like 'SQLskills[_]FS%'
				  and ( INDEXPROPERTY(s.object_id, s.name, 'IsStatistics') = 1
						or INDEXPROPERTY(s.object_id, s.name, 'IsHypothetical') = 1
					  );

		open StatisticsToDropCursor;

		fetch StatisticsToDropCursor into @statistictodrop;

		while @@fetch_status = 0
		begin
			select @execstring = N'DROP STATISTICS ' + @statistictodrop;
			--SELECT @execstring
			exec (@execstring);
			fetch StatisticsToDropCursor into @statistictodrop;
		end;
	end;
end;
go

exec sys.sp_MS_marksystemobject 'sp_DropAllColumnStats';
go