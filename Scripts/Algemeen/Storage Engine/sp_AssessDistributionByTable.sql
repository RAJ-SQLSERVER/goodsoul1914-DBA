create procedure dbo.sp_AssessDistributionByTable 
	@ObjectName    sysname, 
	@SchemaName    sysname       = N'dbo', 
	@DatabaseName  nvarchar(260) = null, 
	@FileGroupName nvarchar(260) = null
as
begin
	set nocount on;
	declare @sql            nvarchar(max)  = N'SELECT @oi = OBJECT_ID(@on);', 
			@ObjectID       int, 
			@PivotColNames  nvarchar(max)  = N'', 
			@PrettyHeaders  nvarchar(max)  = N'', 
			@MaxHeaders     nvarchar(max)  = N'', 
			@Context        nvarchar(1024) = COALESCE(QUOTENAME(@DatabaseName) + N'.', '') + N'sys.sp_executesql', 
			@FullObjectName nvarchar(520)  = QUOTENAME(COALESCE(@SchemaName, N'dbo')) + N'.' + QUOTENAME(@ObjectName);
	exec @Context @sql, N'@on nvarchar(512), @oi int OUTPUT', @FullObjectName, @ObjectID output;
	if @ObjectID is null
	begin
		raiserror(N'%s does not exist in db %s.', 11, 1, @FullObjectName, @DatabaseName);
		return;
	end;
	set @sql = N'SELECT 
    @pcn += N'','' + QUOTENAME(index_id),
    @mh  += N'','' + QUOTENAME(index_id) + '' = MAX('' + QUOTENAME(index_id) + '')'',
    @ph  += N'', ['' + COALESCE([name],''(heap'') 
         +  N'' ('' + CASE WHEN index_id < 2 THEN ''id '' ELSE '''' END 
         + RTRIM(index_id) + '') size] = ps.['' + RTRIM(index_id) + '']''
         + CASE WHEN EXISTS (SELECT 1 FROM sys.partitions WHERE 
             [object_id] = @oi AND index_id = i.index_id AND partition_number > 1)
            THEN N'', [part cnt ('' + RTRIM(index_id) + N'')] = pc.['' + RTRIM(index_id) + '']'' 
            ELSE '''' END 
    FROM sys.indexes AS i WHERE [object_id] = @oi;';
	exec @Context @sql, N'@oi int, @pcn nvarchar(max) OUTPUT, @ph nvarchar(max) OUTPUT, @mh nvarchar(max) OUTPUT', @ObjectID, @PivotColNames output, @PrettyHeaders output, @MaxHeaders output;
	set @sql = N';WITH dst AS (
      SELECT FileID  = extent_file_id, 
             IndexID = index_id, 
             SizeMB  = CONVERT(decimal(18,2),COUNT(allocated_page_page_id)*8.192/1024),
             PartitionCount = COUNT(DISTINCT partition_id)
      FROM sys.dm_db_database_page_allocations(DB_ID(), @ObjectID, NULL, NULL, N''LIMITED'')
      GROUP BY extent_file_id, index_id
    ),
    ps AS (SELECT FileID, $pcn$ FROM dst PIVOT (SUM(SizeMB) FOR IndexID IN ($pcn$)) p),
    pc AS (SELECT FileID, $mh$ FROM (SELECT FileID, $pcn$ FROM dst 
           PIVOT (MAX(PartitionCount) FOR IndexID IN ($pcn$)) p) AS x GROUP BY FileID),
    finfo AS (
      SELECT FG          = fg.name, 
             FileID      = f.file_id,
             LogicalName = f.name,
             [Path]      = f.physical_name, 
             FileSizeMB  = f.size/128.0, 
             UsedSpaceMB = CONVERT(bigint, FILEPROPERTY(f.[name], N''SpaceUsed''))/128.0,
             GrowthMB    = CASE f.is_percent_growth WHEN 1 THEN NULL ELSE f.growth/128.0 END,
             MaxSizeMB   = NULLIF(f.max_size, -1)/128.0,
             DriveSizeMB = vs.total_bytes/1048576.0,
             DriveFreeMB = vs.available_bytes/1048576.0
      FROM sys.database_files AS f
      INNER JOIN sys.filegroups AS fg ON f.data_space_id = fg.data_space_id
      CROSS APPLY sys.dm_os_volume_stats(DB_ID(), f.file_id) AS vs
      WHERE fg.name = COALESCE(@FileGroupName, fg.name)
    )
    SELECT 
      [Filegroup] = f.FG, 
      f.FileID,     
      f.LogicalName,
      f.[Path],
      FileSizeMB  = CONVERT(decimal(18,2), f.FileSizeMB),
      FreeSpaceMB = CONVERT(decimal(18,2), f.FileSizeMB - f.UsedSpaceMB),
      [% Free]    = CONVERT(decimal(5,2), 100.0*(f.FileSizeMB - f.UsedSpaceMB) / f.FileSizeMB),
      GrowthMB    = COALESCE(RTRIM(CONVERT(decimal(18,2), GrowthMB)), ''% warning!''),
      MaxSizeMB   = CONVERT(decimal(18,2), f.MaxSizeMB)
      $ph$,
      DriveSizeMB = CONVERT(bigint, DriveSizeMB),
      DriveFreeMB = CONVERT(bigint, DriveFreeMB),
      [% Free]    = CONVERT(decimal(5,2), 100.0*(DriveFreeMB)/DriveSizeMB)
    FROM finfo AS f 
    LEFT OUTER JOIN ps ON f.FileID = ps.FileID
    LEFT OUTER JOIN pc ON f.FileID = pc.FileID
    ORDER BY [Filegroup], f.FileID;';
	set @sql = REPLACE(REPLACE(REPLACE(@sql, N'$ph$', @PrettyHeaders), N'$pcn$', STUFF(@PivotColNames, 1, 1, N'')), N'$mh$', STUFF(@MaxHeaders, 1, 1, N''));
	print @sql;
	exec @Context @sql, N'@ObjectID int, @FileGroupName sysname', @ObjectID, @FileGroupName;
end;
go		

