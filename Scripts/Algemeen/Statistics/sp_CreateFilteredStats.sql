use [master];
go

if OBJECT_ID(N'sp_CreateFilteredStats') is not null
	drop procedure sp_CreateFilteredStats;
go

set ansi_nulls on;

set quoted_identifier on;
go

create procedure dbo.sp_CreateFilteredStats
(
	@schemaname    sysname    = null,			
	-- Specific schema 
	@objectname    sysname    = null,			
	-- Specific object: table/view 
	@columnname    sysname    = null,			
	-- Specific column 
	@filteredstats tinyint    = 10,
	-- this is the number of filtered statistics
	-- to create. For simplicity, you cannot
	-- create more filtered stats than there are
	-- steps within the histogram (mostly because
	-- not all data is uniform). Maybe in V2.
	-- And, 10 isn't necessarily 10. Because the 
	-- number might not divide easily there are 
	-- likely to be n + 1. And, if @everincreasing
	-- is 1 then you'll get n + 2. 
	-- (the default of 10 may create 11 or 12 stats) 
	@fullscan      varchar(8) = null,
	-- Should be FULLSCAN or SAMPLE
	-- On the creation of the filtered stat
	-- Let SQL Server decide to fullscan or sample
	-- If you want to set FULLSCAN then you can 
	-- override the default 
	@samplepercent tinyint    = null
-- If @samplepercent is defined then @fullscan
-- must be SAMPLE.
)
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
	begin
		raiserror('Proc:sp_CreateFilteredStats, @schemaname = %s, @objectname = %s, @columnname = %s. The @schemaname, @objectname, and @columnname parameters are ALL required. Do not supply a delimited value.', 16, -1, @schemanamedelimited, @objectnamedelimited, @columnnamedelimited);
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
		raiserror('Proc:sp_CreateFilteredStats, @schemaname = %s, @objectname = %s, @columnname = %s. Column:%s is not valid for schema.object:%s.%s. Check to make sure you''re in the correct database and that you did not supply an already delimited value. Additionally, these parameters are case-sensitive when the database is case-sensitive.', 16, -1, @schemanamedelimited, @objectnamedelimited, @columnnamedelimited, @columnnamedelimited, @schemanamedelimited, @objectnamedelimited);
		return;
	end;

	raiserror('-------------------------------------------------------------------------------------------------------------', 10, 1);
	raiserror('Creating filtered statistic for @schemaname = %s, @objectname = %s, @columnname = %s.', 10, 1, @schemanamedelimited, @objectnamedelimited, @columnnamedelimited);

	declare @schemaid               int, 
			@twopartname            nvarchar(520), 
			@objectid               int, 
			@colid                  smallint, 
			@coldef                 nvarchar(100), 
			@coldefcollationforcast nvarchar(100), 
			@usecollation           bit           = 0, 
			@stattoanalyze          sysname, 
			@statsdate              datetime, 
			@histtoanalyze          sysname, 
			@execstring             nvarchar(max), 
			@fetchrate              tinyint, 
			@fetchcounter           tinyint       = 0, 
			@rowsgreaterdiff        tinyint, 
			@rowsgreaterfactor      tinyint, 
			@histsteps              tinyint, 
			@minstepsfrompercent    tinyint, 
			@factorforraiserror     varchar(6);

	select @schemaid = SCHEMA_ID(@schemaname), 
		   @twopartname = QUOTENAME(@schemaname, ']') + N'.' + QUOTENAME(@objectname, ']'), 
		   @objectid = OBJECT_ID(@twopartname);

	select @colid =
	(
		select sc.column_id
		from sys.columns as sc
		where sc.object_id = @objectid
			  and sc.name = @columnname
	), 
		   @coldef = case
						 when isc.DATA_TYPE in('tinyint', 'smallint', 'int', 'bigint') then isc.DATA_TYPE
						 when isc.DATA_TYPE in('char', 'varchar', 'nchar', 'nvarchar') then isc.DATA_TYPE + '(' + CONVERT(varchar, isc.CHARACTER_MAXIMUM_LENGTH) + ') ' 
					 --+ ') COLLATE ' 
					 --+ [isc].[COLLATION_NAME]
						 when isc.DATA_TYPE in('datetime2', 'datetimeoffset', 'time') then isc.DATA_TYPE + '(' + CONVERT(varchar, isc.DATETIME_PRECISION) + ')'
						 when isc.DATA_TYPE in('numeric', 'decimal') then isc.DATA_TYPE + '(' + CONVERT(varchar, isc.NUMERIC_PRECISION) + ', ' + CONVERT(varchar, isc.NUMERIC_SCALE) + ')'
						 when isc.DATA_TYPE in('float', 'decimal') then isc.DATA_TYPE + '(' + CONVERT(varchar, isc.NUMERIC_PRECISION) + ')'
						 when isc.DATA_TYPE = 'uniqueidentifier' then 'char(36)'			
					 --WHEN [isc].[DATA_TYPE] IN ('bit', 'money', 'smallmoney', 'date', 'datetime', 'real', 'smalldatetime', 'hierarchyid', 'sql_variant')
					 else isc.DATA_TYPE
					 end, 
		   @coldefcollationforcast = case
										 when isc.DATA_TYPE in('char', 'varchar', 'nchar', 'nvarchar') then isc.DATA_TYPE + '(' + CONVERT(varchar, isc.CHARACTER_MAXIMUM_LENGTH) + ')) COLLATE ' + isc.COLLATION_NAME
									 else ''
									 end
	from INFORMATION_SCHEMA.COLUMNS as isc
	where isc.TABLE_SCHEMA = @schemaname
		  and isc.TABLE_NAME = @objectname
		  and isc.COLUMN_NAME = @columnname;

	if @coldef = 'XML'
	begin
		raiserror('Proc:sp_CreateFilteredStats, @schemaname = %s, @objectname = %s, @columnname = %s. Column:%s is of type XML. This is not a valid data type for filtered statistic creation.', 16, -1, @schemanamedelimited, @objectnamedelimited, @columnnamedelimited, @columnnamedelimited);
		return;
	end;

	if @coldef = 'hierarchyid'
	begin
		raiserror('Proc:sp_CreateFilteredStats, @schemaname = %s, @objectname = %s, @columnname = %s. Column:%s is of type hierarchyid. This is not a valid data type for filtered statistic creation.', 16, -1, @schemanamedelimited, @objectnamedelimited, @columnnamedelimited, @columnnamedelimited);
		return;
	end;

	if @coldefcollationforcast <> ''
		select @usecollation = 1;

	-------------------------------------
	-- First test
	--SELECT @schemaid
	--	, @twopartname
	--	, @objectid
	--	, @colid
	--	, @coldef
	-------------------------------------
	-- Get the statistic on which our filtered stats will be based:
	select top 1 @stattoanalyze = s.name, 
				 @stattoanalyzedelimited = QUOTENAME(s.name, N']'), 
				 @statsdate = STATS_DATE(s.object_id, s.stats_id)
	from sys.stats as s
	where s.object_id = @objectid
		  and INDEX_COL(OBJECT_NAME(s.object_id), s.stats_id, 1) = @columnname
		  and s.has_filter = 0
		  and STATS_DATE(s.object_id, s.stats_id) =
	(
		select MAX(STATS_DATE(ssc.object_id, ssc.stats_id))
		from sys.stats as ssc
		where ssc.object_id = @objectid
			  and ssc.has_filter = 0
			  and INDEX_COL(OBJECT_NAME(ssc.object_id), ssc.stats_id, 1) = @columnname
	);

	-------------------------------------
	-- Second test
	--SELECT @stattoanalyze, @stattoanalyzedelimited, @statsdate
	-------------------------------------
	-- Create a "permanent" temp table in tempdb to hold a copy of the histogram
	-- Why "permanent" - because we need to use EXEC (@string) a temp table won't work.

	if OBJECT_ID('tempdb..CurrentHistogramForFilteredStats') is not null
		drop table tempdb..CurrentHistogramForFilteredStats;

	select @execstring = N'CREATE TABLE [tempdb]..[CurrentHistogramForFilteredStats]' + N' ( RANGE_HI_KEY ' + @coldef + ' NULL,
		RANGE_ROWS				bigint,
		EQ_ROWS					bigint,
		DISTINCT_RANGE_ROWS		bigint,
		AVG_RANGE_ROWS			decimal(28,4));';
	--SELECT @execstring
	exec (@execstring);

	select @execstring = N'INSERT [tempdb]..[CurrentHistogramForFilteredStats] ' + N' EXEC (''DBCC SHOW_STATISTICS(''''' + @schemaname + '.' + @objectname + N''''',''''' + @stattoanalyze + N''''') WITH HISTOGRAM, NO_INFOMSGS'')';
	--SELECT @execstring
	exec (@execstring);

	--SELECT * FROM [tempdb]..[CurrentHistogramForFilteredStats]
	-- Clean up all other SINGLE column filtered stats 
	-- and non-filtered column-level stats for this column
	exec sp_DropAllColumnStats @schemaname = @schemaname, @objectname = @objectname, @columnname = @columnname, @DropAll = 'TRUE';

	select @histsteps = COUNT(*)
	from tempdb..CurrentHistogramForFilteredStats;

	if @histsteps < @filteredstats
	begin
		raiserror('Proc:sp_CreateFilteredStats, @schemaname = %s, @objectname = %s, @columnname = %s. The histogram:%s has only %d steps. You must create your filtered statistics manually.', 16, -1, @schemanamedelimited, @objectnamedelimited, @columnnamedelimited, @stattoanalyze, @histsteps);
		return;
	end;

	-- This will define the specific step values that we'll use:
	select @fetchrate = FLOOR(@histsteps / ( @filteredstats * 1.00 ));

	-- Cursor over the rows 
	-- starting with fetch first
	-- then, stepping at the @fetchrate
	-- stopping at @fetchrate = @filteredstats
	-- then, doing a final one for less than fetch last

	declare @MinValue sql_variant = null, 
			@MaxValue sql_variant = null;

	-- Open cursor over histogram rows
	declare [HistogramCursor] cursor local static read_only
	for select Range_HI_KEY
		from tempdb..CurrentHistogramForFilteredStats;

	open [HistogramCursor];

	fetch first from [HistogramCursor] into @MinValue;

	fetch relative @fetchrate from [HistogramCursor] into @MaxValue;

	while @fetchcounter < @filteredstats
	begin
		if @MaxValue > @MinValue
			exec sp_CreateFilteredStatsString @schemaname = @schemaname, @objectname = @objectname, @columnname = @columnname, @twopartname = @twopartname, @MinValue = @MinValue, @MaxValue = @MaxValue, @coldef = @coldef, @coldefcollationforcast = @coldefcollationforcast, @usecollation = @usecollation, @fullscan = @fullscan, @samplepercent = @samplepercent;

		select @MinValue = @MaxValue;
		fetch relative @fetchrate from [HistogramCursor] into @MaxValue;
		select @fetchcounter = @fetchcounter + 1;
	end;

	-- Create last statistic on actual set
	fetch last from [HistogramCursor] into @MaxValue;

	--SELECT @MinValue AS [Min], @MaxValue AS [Max]

	if @MaxValue > @MinValue
		exec sp_CreateFilteredStatsString @schemaname = @schemaname, @objectname = @objectname, @columnname = @columnname, @twopartname = @twopartname, @MinValue = @MinValue, @MaxValue = @MaxValue, @coldef = @coldef, @coldefcollationforcast = @coldefcollationforcast, @usecollation = @usecollation, @fullscan = @fullscan, @samplepercent = @samplepercent;

	-- Create final statistic on future set growth 
	select @MinValue = @MaxValue, 
		   @MaxValue = null;

	exec sp_CreateFilteredStatsString @schemaname = @schemaname, @objectname = @objectname, @columnname = @columnname, @twopartname = @twopartname, @MinValue = @MinValue, @MaxValue = null -- this will make it unbounded
	, @coldef = @coldef, @coldefcollationforcast = @coldefcollationforcast, @usecollation = @usecollation, @fullscan = @fullscan, @samplepercent = @samplepercent;

	close [HistogramCursor];
	deallocate [HistogramCursor];

	begin
		drop table tempdb..CurrentHistogramForFilteredStats;
	end;
end;
go

exec sys.sp_MS_marksystemobject N'sp_CreateFilteredStats';
go