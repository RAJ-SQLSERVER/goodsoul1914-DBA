create procedure dbo.sp_FlexibleUpdateStatistics 
	@MaxExecutionTime     int     = 10,		-- Script will stop if execution time exceeds this parameter (in minutes)
	@Debug                tinyint = 1,		-- Debug mode = 1, execution mode = 0... It only prints the statements in debug mode
	@ConsoleMode          tinyint = 1,		-- If 1, It will also print additional messages at execution mode. It should be better to set as 0 when running with SQL Agent Job.
	@MinModificationCount int     = 10000,	-- Script will update statistics only if the statistics modified rowscount is greater than @MinModificationCount
	@OnlyIndexStats       tinyint = 0		-- If you want to ignore auto created statistics (WA_Sys*) , set this parameter to 1
as
begin

	set nocount on;

	-- Internal variables
	declare @Counter int = 0;
	declare @DatabaseId int;
	declare @DatabaseName sysname;
	declare @AllStartTime datetime = GETDATE();
	declare @UpdateStatStartTime datetime;
	declare @ObjectName nvarchar(500);
	declare @StatisticsName nvarchar(500);
	declare @SQL nvarchar(max);
	declare @StatisticsSQL nvarchar(max);

	create table #Statistics
	(
		Id                int identity primary key, 
		DatabaseName      varchar(100) not null, 
		SchemaName        varchar(255) not null, 
		TableName         varchar(255) not null, 
		StatisticsName    nvarchar(255) not null, 
		LastUpdated       datetime, 
		DaysBefore        bigint, 
		ActualRows        bigint, 
		ModificationCount bigint, 
		ObjectName as '[' + DatabaseName + '].[' + SchemaName + '].[' + TableName + ']' persisted, 
		StatisticsSQL as 'UPDATE STATISTICS ' + '[' + DatabaseName + '].[' + SchemaName + '].[' + TableName + ']' + ' [' + StatisticsName + '];' persisted);

	-- Here we can alter the query to fetch the only databases which we want to alter their indexes
	declare Db_Cursor cursor
	for select database_id, 
			   name
		from sys.databases
		where name not in ('master', 'model', 'tempdb', 'distribution')
			  and is_read_only <> 1;


	open Db_Cursor;
	fetch next from Db_Cursor into @DatabaseId, 
								   @DatabaseName;

	while @@FETCH_STATUS = 0
	begin

		set @SQL = '
		USE ' + @DatabaseName + ';
	
		INSERT #Statistics(DatabaseName, SchemaName, TableName,  StatisticsName, LastUpdated, DaysBefore, ActualRows, ModificationCount)
		SELECT
			DatabaseName = ''' + @DatabaseName + ''' ,
			SchemaName = sch.name,
			TableName = o.name,
			StatisticsName = [s].[name],
			LastUpdated = [sp].[last_updated],
			DaysBefore = DATEDIFF(day, [sp].[last_updated], GETDATE()),
			ActualRows = [sp].[rows],
			ModificationCount = [sp].[modification_counter] 
		FROM [sys].[stats] AS [s] 
			inner join sys.stats_columns sc
				on s.stats_id=sc.stats_id and s.object_id=sc.object_id
			inner join sys.columns c
				on c.object_id=sc.object_id and c.column_id=sc.column_id
			inner join sys.objects o
				on s.object_id=o.object_id
			inner join sys.schemas sch
				on o.schema_id=sch.schema_id
			OUTER APPLY sys.dm_db_stats_properties ([s].[object_id],[s].[stats_id]) AS [sp]
		WHERE [sp].[modification_counter] > ' + CONVERT(nvarchar(20), @MinModificationCount) + case
																								   when @OnlyIndexStats = 1 then 'AND [s].[name] NOT LIKE ''_WA_Sys_%'' '
																							   else ' '
																							   end + '
		 OPTION (MAXDOP 1)';

		execute sp_executesql @SQL;
		fetch next from Db_Cursor into @DatabaseId, 
									   @DatabaseName;
	end;

	close Db_Cursor;
	deallocate Db_Cursor;

	create nonclustered index IX_Statistics_tmp_ObjectName on #Statistics
	(ObjectName asc) 
		include (StatisticsName, LastUpdated, DaysBefore, ActualRows, ModificationCount, StatisticsSQL);

	select ObjectName, 
		   StatisticsName
	into #Multiple
	from #Statistics as s
	group by ObjectName, 
			 StatisticsName
	having COUNT(*) > 1;

	delete from #Statistics
	where Id in (select Id
				 from #Statistics as s
					  inner join #Multiple as m on m.ObjectName = s.ObjectName
												   and m.StatisticsName = s.StatisticsName
				 where s.Id not in (select top 1 s1.Id
									from #Multiple as m1
										 inner join #Statistics as s1 on m1.ObjectName = s1.ObjectName
																		 and m1.StatisticsName = s1.StatisticsName
									order by s1.LastUpdated) );

	if @OnlyIndexStats = 1
	begin
		delete from #Statistics
		where StatisticsName like '_WA_Sys_%';
	end;


	if @Debug = 1
	   or @ConsoleMode = 1
	begin
		select *
		from #Statistics as S
		order by( ModificationCount / 100 + 1 ) * ( DaysBefore + 1 ) desc;
	end;

	-- Reorganize the indexes by the most fragmented and most accessed
	declare Stats_Cursor cursor
	for select ObjectName, 
			   StatisticsName, 
			   StatisticsSQL
		from #Statistics as S
		order by( ModificationCount / 100 + 1 ) * ( DaysBefore + 1 ) desc;
	open Stats_Cursor;
	fetch next from Stats_Cursor into @ObjectName, 
									  @StatisticsName, 
									  @StatisticsSQL;


	while @@FETCH_STATUS = 0
	begin

		if DATEDIFF(second, @AllStartTime, GETDATE()) >= @MaxExecutionTime * 60
		begin
			break;
		end;

		set @Counter+=1;

		if @Debug = 1
		begin
			print @StatisticsSQL;
			print '---------------------------------';
			print '';
		end;
		else
		begin
			set @UpdateStatStartTime = GETDATE();
			if @ConsoleMode = 1
			   or @Debug = 1
			begin
				print CONVERT(varchar(23), @UpdateStatStartTime, 120) + ' Updating stats ' + @ObjectName;
				print 'Update stats statement: ' + @StatisticsSQL;
			end;

			execute sp_executesql @StatisticsSQL;


			if @ConsoleMode = 1
			   or @Debug = 1
			begin
				print CONVERT(varchar(23), GETDATE(), 120) + ' stats updated in ' + CONVERT(varchar(10), DATEDIFF(second, @UpdateStatStartTime, GETDATE())) + ' seconds';
				print '---------------------------------------------------------------------------------------';
				print '';
			end;

		end;

		fetch next from Stats_Cursor into @ObjectName, 
										  @StatisticsName, 
										  @StatisticsSQL;

	end;
	close Stats_Cursor;
	deallocate Stats_Cursor;

	drop table #Multiple;
	drop table #Statistics;
end;
go