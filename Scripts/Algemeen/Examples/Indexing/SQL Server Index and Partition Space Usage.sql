create database FGExample;
go

use FGExample;
go

/************************************************
SQL Server Data Unevenly Distributed Across Files
************************************************/

alter database FGExample add filegroup UnevenDist;
go

alter database FGExample add file(name = N'Uneven1', size = 64, filegrowth = 20, maxsize = 1024, filename = N'D:\Documents\MSSQL\DATA\Uneven1.mdf') to filegroup UnevenDist;
alter database FGExample add file(name = N'Uneven2', size = 128, filegrowth = 10, maxsize = 1024, filename = N'D:\Documents\MSSQL\DATA\Uneven2.mdf') to filegroup UnevenDist;
go

create table dbo.tblUnevenDist
(
	id     int not null, 
	filler char(2000) not null
					  default '', 
	constraint PK_tblUnevenDist primary key(id) on UnevenDist) 
on UnevenDist;
go

create index IX_tblUnevenDist on dbo.tblUnevenDist
(id desc) 
	where id > 0 on [PRIMARY];
go

insert into dbo.tblUnevenDist (id) 
select object_id
from sys.all_objects;

alter database FGExample add file(name = N'Uneven3', size = 96, filegrowth = 10, filename = N'D:\Documents\MSSQL\DATA\Uneven3.mdf') to filegroup UnevenDist;
go

-- get filegroup files

declare @FileGroupName sysname = N'UnevenDist';
with src
	 as (select FG = fg.name, 
				FileID = f.file_id, 
				LogicalName = f.name, 
				[Path] = f.physical_name, 
				FileSizeMB = f.size / 128.0, 
				UsedSpaceMB = CONVERT(bigint, FILEPROPERTY(f.name, 'SpaceUsed')) / 128.0, 
				GrowthMB = case f.is_percent_growth
							   when 1 then null
						   else f.growth / 128.0
						   end, 
				MaxSizeMB = NULLIF(f.max_size, -1) / 128.0, 
				DriveSizeMB = vs.total_bytes / 1048576.0, 
				DriveFreeMB = vs.available_bytes / 1048576.0
		 from sys.database_files as f
			  inner join sys.filegroups as fg on f.data_space_id = fg.data_space_id
			  cross apply sys.dm_os_volume_stats(DB_ID(), f.file_id) as vs
		 where fg.name = COALESCE(@FileGroupName, fg.name))
	 select Filegroup = FG, 
			FileID, 
			LogicalName, 
			[Path], 
			FileSizeMB = CONVERT(decimal(18, 2), FileSizeMB), 
			FreeSpaceMB = CONVERT(decimal(18, 2), FileSizeMB - UsedSpaceMB), 
			[%] = CONVERT(decimal(5, 2), 100.0 * ( FileSizeMB - UsedSpaceMB ) / FileSizeMB), 
			GrowthMB = COALESCE(RTRIM(CONVERT(decimal(18, 2), GrowthMB)), '% warning!'), 
			MaxSizeMB = CONVERT(decimal(18, 2), MaxSizeMB), 
			DriveSizeMB = CONVERT(bigint, DriveSizeMB), 
			DriveFreeMB = CONVERT(bigint, DriveFreeMB), 
			[%] = CONVERT(decimal(5, 2), 100.0 * DriveFreeMB / DriveSizeMB)
	 from src
	 order by FG, 
			  LogicalName;

-- Looking at this output visually immediately points out five problems. Four of them are highlighted above; from left to right:
--
-- The files are all different sizes - For even distribution, you want these to be the same, 
--    otherwise small files never get touched and become wasteful.
-- One file is almost completely empty - This indicates either the file was recently added or 
--    it is not getting selected by proportional fill.
-- One file has a bigger autogrowth setting - If this file grows next, it could become a hotspot 
--    because it will have more free space than any other files that only grow by half that amount.
-- One file doesn’t have a max size - There may be reasons for this, but if only one file is uncapped, 
--    it has a potential to become the single bottleneck when the other files get closer to their capacity.
-- There are three files in this filegroup - Usually, you want to have a number of files that correlates 
--    in some way to the number of cores – not necessarily 1:1, maybe 1:2 or 1:8, but some even number. 
--    In this case maybe the machine has a single-socket with 6 cores, but still worth investigating to 
--    be sure this configuration is optimal.

/*************************************
SQL Server File Percentage Auto Growth
*************************************/

alter database FGExample add filegroup EvenDist;
go
 
alter database FGExample add file(name = N'Even1', size = 32, filegrowth = 10%, filename = N'D:\Documents\MSSQL\DATA\Even1.mdf') to filegroup EvenDist;

alter database FGExample add file(name = N'Even2', size = 32, filegrowth = 10, filename = N'D:\Documents\MSSQL\DATA\Even2.mdf') to filegroup EvenDist;

create table dbo.tblEvenDist
(
	id     int not null, 
	filler char(2000) not null
					  default '', 
	constraint PK_tblEvenDist primary key(id) on UnevenDist) 
on UnevenDist;
go
 
create index IX_tblEvenDist on dbo.tblUnevenDist
(id desc) 
	where id > 0 on [PRIMARY];
go
 
insert into dbo.tblEvenDist (id) 
select object_id
from sys.all_objects;

declare @FileGroupName sysname = N'UnevenDist';
with src
	 as (select FG = fg.name, 
				FileID = f.file_id, 
				LogicalName = f.name, 
				[Path] = f.physical_name, 
				FileSizeMB = f.size / 128.0, 
				UsedSpaceMB = CONVERT(bigint, FILEPROPERTY(f.name, 'SpaceUsed')) / 128.0, 
				GrowthMB = case f.is_percent_growth
							   when 1 then null
						   else f.growth / 128.0
						   end, 
				MaxSizeMB = NULLIF(f.max_size, -1) / 128.0, 
				DriveSizeMB = vs.total_bytes / 1048576.0, 
				DriveFreeMB = vs.available_bytes / 1048576.0
		 from sys.database_files as f
			  inner join sys.filegroups as fg on f.data_space_id = fg.data_space_id
			  cross apply sys.dm_os_volume_stats(DB_ID(), f.file_id) as vs
		 where fg.name = COALESCE(@FileGroupName, fg.name))
	 select Filegroup = FG, 
			FileID, 
			LogicalName, 
			[Path], 
			FileSizeMB = CONVERT(decimal(18, 2), FileSizeMB), 
			FreeSpaceMB = CONVERT(decimal(18, 2), FileSizeMB - UsedSpaceMB), 
			[%] = CONVERT(decimal(5, 2), 100.0 * ( FileSizeMB - UsedSpaceMB ) / FileSizeMB), 
			GrowthMB = COALESCE(RTRIM(CONVERT(decimal(18, 2), GrowthMB)), '% warning!'), 
			MaxSizeMB = CONVERT(decimal(18, 2), MaxSizeMB), 
			DriveSizeMB = CONVERT(bigint, DriveSizeMB), 
			DriveFreeMB = CONVERT(bigint, DriveFreeMB), 
			[%] = CONVERT(decimal(5, 2), 100.0 * DriveFreeMB / DriveSizeMB)
	 from src
	 order by FG, 
			  LogicalName;

/*****************************
SQL Server Filegroup is Skewed
*****************************/

alter database FGExample add filegroup Part1;
alter database FGExample add filegroup Part2;
alter database FGExample add filegroup Part3;
alter database FGExample add filegroup Part4;
go
 
alter database FGExample add file(name = N'P1', size = 16, filegrowth = 5, filename = N'D:\Documents\MSSQL\DATA\P1.mdf') to filegroup Part1;
alter database FGExample add file(name = N'P2', size = 16, filegrowth = 5, filename = N'D:\Documents\MSSQL\DATA\P2.mdf') to filegroup Part2;
alter database FGExample add file(name = N'P3', size = 16, filegrowth = 5, filename = N'D:\Documents\MSSQL\DATA\P3.mdf') to filegroup Part3;
alter database FGExample add file(name = N'P4a', size = 16, filegrowth = 5, filename = N'D:\Documents\MSSQL\DATA\P4a.mdf') to filegroup Part4;
go

create partition function PFInt (int) as range right for values (10, 20, 30);
create partition scheme PSInt as partition PFInt to (Part1, Part2, Part3, Part4);

create table dbo.PartExample
(
	id     int not null, 
	dt     datetime not null
					default GETDATE(), 
	filler char(4000) not null
					  default '', 
	index cix_pe clustered(id)) 
on PSInt(id);
go
 
create index ix_pe on dbo.PartExample
(id desc) 
	on [PRIMARY];
go
 
create index ix_dt on dbo.PartExample
(dt) 
	on [PRIMARY];
go

insert into dbo.PartExample (id) 
select case
		   when o > 1000000 then 5  --   331 rows
		   when o > 0 then 15 --   692 rows
		   when o > -10000 then 25 -- 3,106 rows
	   else 35
	   end               -- 6,779 rows
from (select object_id
	  from sys.all_columns) as t(o);

alter database FGExample add file(name = N'P4b', size = 16, filegrowth = 5, filename = N'D:\Documents\MSSQL\DATA\P4b.mdf') to filegroup Part4;

with src
	 as (select FG = fg.name, 
				FileID = f.file_id, 
				LogicalName = f.name, 
				[Path] = f.physical_name, 
				FileSizeMB = f.size / 128.0, 
				UsedSpaceMB = CONVERT(bigint, FILEPROPERTY(f.name, 'SpaceUsed')) / 128.0, 
				GrowthMB = case f.is_percent_growth
							   when 1 then null
							   else f.growth / 128.0
						   end, 
				MaxSizeMB = NULLIF(f.max_size, -1) / 128.0, 
				DriveSizeMB = vs.total_bytes / 1048576.0, 
				DriveFreeMB = vs.available_bytes / 1048576.0
		 from sys.database_files as f
			  inner join sys.filegroups as fg on f.data_space_id = fg.data_space_id
			  cross apply sys.dm_os_volume_stats(DB_ID(), f.file_id) as vs)
	 select Filegroup = FG, 
			FileID, 
			LogicalName, 
			[Path], 
			FileSizeMB = CONVERT(decimal(18, 2), FileSizeMB), 
			FreeSpaceMB = CONVERT(decimal(18, 2), FileSizeMB - UsedSpaceMB), 
			[%] = CONVERT(decimal(5, 2), 100.0 * ( FileSizeMB - UsedSpaceMB ) / FileSizeMB), 
			GrowthMB = COALESCE(RTRIM(CONVERT(decimal(18, 2), GrowthMB)), '% warning!'), 
			MaxSizeMB = CONVERT(decimal(18, 2), MaxSizeMB), 
			DriveSizeMB = CONVERT(bigint, DriveSizeMB), 
			DriveFreeMB = CONVERT(bigint, DriveFreeMB), 
			[%] = CONVERT(decimal(5, 2), 100.0 * DriveFreeMB / DriveSizeMB)
	 from src
	 order by FG, 
			  LogicalName;

declare @object_id int = OBJECT_ID(N'PartExample');
select FileID = extent_file_id, 
	   IndexID = index_id, 
	   SizeMB = CONVERT(decimal(18, 2), COUNT(allocated_page_page_id) * 8.192 / 1024)
from sys.dm_db_database_page_allocations(DB_ID(), @object_id, null, null, N'LIMITED')
group by extent_file_id, 
		 index_id;
go

declare @object_id int = OBJECT_ID(N'PartExample');
with dist
	 as (select FileID = extent_file_id, 
				IndexID = index_id, 
				SizeMB = CONVERT(decimal(18, 2), COUNT(allocated_page_page_id) * 8.192 / 1024)
		 from sys.dm_db_database_page_allocations(DB_ID(), @object_id, null, null, N'LIMITED') as pa
		 group by extent_file_id, 
				  index_id)
	 select p.FileID, 
			[cix_pe (index_id = 1)] = p.[1], 
			[ix_dt (2)] = p.[2]
	 from dist pivot(SUM(SizeMB) for IndexID in([1], 
												[2])) as p;
go

declare @object_id int = OBJECT_ID(N'PartExample');
with dist
	 as (select FileID = extent_file_id, 
				IndexID = index_id, 
				SizeMB = CONVERT(decimal(18, 2), COUNT(allocated_page_page_id) * 8.192 / 1024)
		 from sys.dm_db_database_page_allocations(DB_ID(), @object_id, null, null, N'LIMITED')
		 group by extent_file_id, 
				  index_id),
	 p
	 as (select FileID, 
				[1], 
				[2]
		 from dist pivot(SUM(SizeMB) for IndexID in([1], 
													[2])) as p),
	 finfo
	 as (select FG = fg.name, 
				FileID = f.file_id, 
				LogicalName = f.name, 
				[Path] = f.physical_name, 
				FileSizeMB = f.size / 128.0, 
				UsedSpaceMB = CONVERT(bigint, FILEPROPERTY(f.name, 'SpaceUsed')) / 128.0
		 from sys.database_files as f
			  inner join sys.filegroups as fg on f.data_space_id = fg.data_space_id)
	 select Filegroup = f.FG, 
			f.FileID, 
			f.LogicalName, 
			FileSizeMB = CONVERT(decimal(18, 2), f.FileSizeMB), 
			FreeSpaceMB = CONVERT(decimal(18, 2), f.FileSizeMB - f.UsedSpaceMB), 
			[%] = CONVERT(decimal(5, 2), 100.0 * ( f.FileSizeMB - f.UsedSpaceMB ) / f.FileSizeMB), 
			[cix_pe (index_id = 1)] = p.[1], 
			[ix_dt (2)] = p.[2]
	 from finfo as f
		  left outer join p on f.FileID = p.FileID
	 order by f.FileID;
go

create procedure dbo.AssessDistribution_ByTable 
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

exec dbo.AssessDistribution_ByTable @ObjectName = N'PartExample', @SchemaName = N'dbo', @DatabaseName = N'FGExample';

