create procedure dbo.sp_AssessDistributionForMultipleTables 
	@DatabaseName  nvarchar(260), 
	@TableCount    tinyint       = 5, 
	@PrimaryFactor char(4)       = 'rows' -- or 'size'
as
begin
	set nocount on;
	if DB_ID(@DatabaseName) is null
	begin
		raiserror(N'Database %s does not exist.', 11, 1, @DatabaseName);
		return;
	end;
	declare @sql            nvarchar(max)  = N';WITH x AS (SELECT TOP (@TableCount) object_id, ', 
			@SchemaName     sysname, 
			@ObjectName     sysname, 
			@RowOrPageCount int, 
			@c              cursor, 
			@Context        nvarchar(1024) = COALESCE(QUOTENAME(@DatabaseName) + N'.', N'') + N'sys.sp_executesql';
	declare @t table
	(
		rn             tinyint
		primary key, 
		SchemaName     sysname, 
		ObjectName     sysname, 
		RowOrPageCount int);
	if @PrimaryFactor = 'rows'
	begin
		set @sql+=N'c = SUM(rows) FROM sys.partitions';
	end;
	if @PrimaryFactor = 'size'
	begin
		set @sql+=N'c = COUNT(*) FROM sys.dm_db_database_page_allocations
                                    (DB_ID(), NULL, NULL, NULL, N''LIMITED'')';
	end;
	set @sql+=N'    WHERE OBJECTPROPERTY(object_id, N''IsMsShipped'') = 0
                      -- AND index_id IN (0,1)
                    GROUP BY object_id
                    ORDER BY c DESC
                 )
                 SELECT rn             = ROW_NUMBER() OVER (ORDER BY x.c DESC),
                        SchemaName     = s.name, 
                        ObjectName     = o.name,
                        RowOrPageCount = x.c
                   FROM x
                   INNER JOIN sys.objects AS o ON x.object_id = o.object_id
                   INNER JOIN sys.schemas AS s ON o.schema_id = s.schema_id;';
	insert into @t
	exec @Context @sql, N'@TableCount int', @TableCount;
	if @@ROWCOUNT = 0
	begin
		raiserror(N'No tables found.', 11, 1);
		return;
	end;
	set @c = cursor forward_only static read_only
	for select SchemaName, 
			   ObjectName, 
			   RowOrPageCount
		from @t
		order by rn;
	open @c;
	fetch next from @c into @SchemaName, 
							@ObjectName, 
							@RowOrPageCount;
	while @@FETCH_STATUS <> -1
	begin
		select obj = QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@ObjectName), 
			   factor = @PrimaryFactor, 
			   num = @RowOrPageCount;
		exec dbo.sp_AssessDistributionByTable @ObjectName = @ObjectName, @SchemaName = @SchemaName, @DatabaseName = @DatabaseName;
		fetch next from @c into @SchemaName, 
								@ObjectName, 
								@RowOrPageCount;
	end;
end;
go