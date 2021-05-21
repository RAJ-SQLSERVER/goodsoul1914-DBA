use [master];
go

set ansi_nulls on;
go

set quoted_identifier on;
go

if OBJECT_ID('sp_TableCount') is null
begin
	exec ('CREATE PROCEDURE sp_TableCount AS');
end;
go

/*********************************************************************************************************************************
Procedure Name: sp_TableCount
Author: Adrian Buckman
Revision date: 06/11/2019
Version: 2

© www.sqlundercover.com 
*********************************************************************************************************************************/

alter procedure dbo.sp_TableCount
(
	@Databasename nvarchar(128) = null, 
	@Schemaname   nvarchar(128) = null, 
	@Tablename    nvarchar(128) = null, 
	@Sortorder    nvarchar(30)  = null, -- VALID OPTIONS 'Schema' 'Table' 'Rows' 'Delta' 'Size'
	@Top          int           = null, 
	@Interval     tinyint       = null, 
	@Getsizes     bit           = 0) 
as
begin

	set nocount on;

	declare @Sql nvarchar(4000);
	declare @Delay varchar(8);

	if OBJECT_ID('tempdb.dbo.#RowCounts') is not null
		drop table #RowCounts;

	create table #RowCounts
	(
		Schemaname  nvarchar(128), 
		Tablename   nvarchar(128), 
		TotalRows   bigint, 
		SizeMB      money, 
		StorageInfo xml, 
		IndexTypes  varchar(256));

	-- Show debug info:
	print 'Parameter values:';
	print '@Databasename: ' + ISNULL(@Databasename, 'NULL');
	print '@Schemaname: ' + ISNULL(@Schemaname, 'NULL');
	print '@Tablename: ' + ISNULL(@Tablename, 'NULL');
	print '@Sortorder: ' + ISNULL(@Sortorder, 'NULL');
	print '@Top: ' + ISNULL(CAST(@Top as varchar(20)), 'NULL');
	print '@Interval ' + ISNULL(CAST(@Interval as varchar(3)), 'NULL');
	print '@Getsizes ' + ISNULL(CAST(@Getsizes as char(1)), 'NULL');

	if @Databasename is null
	begin
		set @Databasename = DB_NAME();
	end;

	-- Ensure database exists.
	if DB_ID(@Databasename) is null
	begin
		raiserror('Invalid databasename', 11, 0);
		return;
	end;

	-- Delta maximum is 60 seconds 
	if @Interval > 60
	begin
		set @Interval = 60;
		print '@Interval was changed to the maximum value of 60 seconds';
	end;

	-- Set delay for WAITFOR
	if @Interval is not null
	   and @Interval > 0
	begin
		set @Delay = case
						 when @Interval = 60 then '00:01:00'
						 when @Interval < 10 then '00:00:0' + CAST(@Interval as varchar(2))
					 else '00:00:' + CAST(@Interval as varchar(2))
					 end;
	end;

	-- UPPER @Sortorder
	if @Sortorder is not null
	begin
		set @Sortorder = UPPER(@Sortorder);

		if @Sortorder not in('SCHEMA', 'TABLE', 'ROWS', 'DELTA', 'SIZE')
		begin
			raiserror('Valid options for @Sortorder are ''Schema'' ''Table'' ''Rows'' ''Delta'' ''Size''', 11, 0);
			return;
		end;

		if @Sortorder = 'DELTA'
		   and ( @Interval is null
				 or @Interval = 0
			   )
		begin
			raiserror('@Sortorder = Delta is invalid with @Interval is null or zero', 11, 0);
			return;
		end;

		if @Getsizes = 0
		   and @Sortorder = 'SIZE'
		begin
			print '@Sortorder = ''Size'' is not compatible with @Getsizes = 0, using default sortorder';
		end;
	end;

	set @Sql = N'
SELECT' + case
			  when @Top is not null then ' TOP (' + CAST(@Top as varchar(20)) + ')'
		  else ''
		  end + '
schemas.name AS Schemaname,
tables.name AS Tablename,
partitions.rows AS TotalRows,
' + case
		when @Getsizes = 1 then 'ISNULL((SELECT SUM((CAST(total_pages AS MONEY)*8)/1024)
FROM [' + @Databasename + '].sys.allocation_units Allocunits 
WHERE partitions.partition_id = Allocunits.container_id ),0.00) AS SizeMB,'
	else ''
	end + 'CAST(Allocunits.PageInfo AS XML) AS StorageInfo,
ISNULL((SELECT type_desc + '': ''+CAST(COUNT(*) AS VARCHAR(6))+ ''  '' 
	FROM [' + @Databasename + '].sys.indexes 
	WHERE object_id = tables.object_id AND indexes.type > 0 
	GROUP BY type_desc 
	ORDER BY type_desc 
	FOR XML PATH('''')),''HEAP'') AS IndexTypes
FROM [' + @Databasename + '].sys.tables
INNER JOIN [' + @Databasename + '].sys.schemas ON tables.schema_id = schemas.schema_id
INNER JOIN [' + @Databasename + '].sys.partitions ON tables.object_id = partitions.object_id
CROSS APPLY (SELECT type_desc 
			+ N'': Total pages: ''
			+CAST(total_pages AS NVARCHAR(10))
			+ '' ''
			+CHAR(13)+CHAR(10)
			+N'' Used pages: ''
			+CAST(used_pages AS NVARCHAR(10))
			+ '' ''
			+CHAR(13)+CHAR(10)
			+N'' Total Size: ''
			+CAST((total_pages*8)/1024 AS NVARCHAR(10))
			+N''MB''
			+N'' ''
			FROM [' + @Databasename + '].sys.allocation_units Allocunits 
			WHERE partitions.partition_id = Allocunits.container_id 
			ORDER BY type_desc ASC
			FOR XML PATH('''')) Allocunits (PageInfo)
WHERE index_id IN (0,1)' + case
							   when @Tablename is null then ''
						   else '
AND tables.name = @Tablename'
						   end + case
									 when @Schemaname is null then ''
								 else '
AND schemas.name = @Schemaname'
								 end + '
ORDER BY ' + case
				 when @Sortorder = 'SCHEMA' then 'schemas.name ASC,tables.name ASC;'
				 when @Sortorder = 'TABLE' then 'tables.name ASC;'
				 when @Sortorder = 'ROWS' then 'partitions.rows DESC'
				 when @Getsizes = 1
					  and @Sortorder = 'SIZE' then 'SizeMB DESC'
			 else 'schemas.name ASC,tables.name ASC;'
			 end;

	print '
Dynamic SQL:';
	print @Sql;

	if @Interval is null
	   or @Interval = 0
	begin
		exec sp_executesql @Sql, N'@Tablename NVARCHAR(128), @Schemaname NVARCHAR(128)', @Tablename = @Tablename, @Schemaname = @Schemaname;
	end;
	else
	begin
		if @Getsizes = 0
		begin
			insert into #RowCounts (Schemaname, 
									Tablename, 
									TotalRows, 
									StorageInfo, 
									IndexTypes) 
			exec sp_executesql @Sql, N'@Tablename NVARCHAR(128), @Schemaname NVARCHAR(128)', @Tablename = @Tablename, @Schemaname = @Schemaname;
		end;

		if @Getsizes = 1
		begin
			insert into #RowCounts (Schemaname, 
									Tablename, 
									TotalRows, 
									SizeMB, 
									StorageInfo, 
									IndexTypes) 
			exec sp_executesql @Sql, N'@Tablename NVARCHAR(128), @Schemaname NVARCHAR(128)', @Tablename = @Tablename, @Schemaname = @Schemaname;
		end;

		waitfor delay @Delay;

		set @Sql = N'
SELECT' + case
			  when @Top is not null then ' TOP (' + CAST(@Top as varchar(20)) + ')'
		  else ''
		  end + '
schemas.name AS Schemaname,
tables.name AS Tablename,
#RowCounts.TotalRows AS TotalRows,
partitions.rows-#RowCounts.TotalRows AS TotalRows_Delta,
' + case
		when @Getsizes = 1 then '#RowCounts.SizeMB,
INULL((SELECT SUM((CAST(total_pages AS MONEY)*8)/1024)
FROM [' + @Databasename + '].sys.allocation_units Allocunits 
WHERE partitions.partition_id = Allocunits.container_id ),0.00)-#RowCounts.SizeMB AS SizeMB_Delta,'
	else ''
	end + '
#RowCounts.StorageInfo,
#RowCounts.IndexTypes
FROM [' + @Databasename + '].sys.tables
INNER JOIN [' + @Databasename + '].sys.schemas ON tables.schema_id = schemas.schema_id
INNER JOIN [' + @Databasename + '].sys.partitions ON tables.object_id = partitions.object_id
INNER JOIN #RowCounts ON tables.name = #RowCounts.Tablename COLLATE DATABASE_DEFAULT AND schemas.name = #RowCounts.Schemaname COLLATE DATABASE_DEFAULT
WHERE index_id IN (0,1)' + case
							   when @Tablename is null then ''
						   else '
AND tables.name = @Tablename'
						   end + case
									 when @Schemaname is null then ''
								 else '
AND schemas.name = @Schemaname'
								 end + '
ORDER BY ' + case
				 when @Sortorder = 'SCHEMA' then 'schemas.name ASC,tables.name ASC;'
				 when @Sortorder = 'TABLE' then 'tables.name ASC;'
				 when @Sortorder = 'ROWS' then 'partitions.rows DESC'
				 when @Sortorder = 'DELTA' then 'ABS(partitions.rows-#RowCounts.TotalRows) DESC'
				 when @Getsizes = 1
					  and @Sortorder = 'SIZE' then 'SizeMB DESC'
			 else 'schemas.name ASC,tables.name ASC;'
			 end;

		exec sp_executesql @Sql, N'@Tablename NVARCHAR(128), @Schemaname NVARCHAR(128)', @Tablename = @Tablename, @Schemaname = @Schemaname;
	end;
end;