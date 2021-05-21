/******************************************************************************
Author: David Fowler
Revision date: 3 July 2019
Version: 1

www.sqlundercover.com 
******************************************************************************/

create proc sp_DriveSpace 
	@xp_fixeddrivesCompat bit        = 0, -- return results matching the format of xp_fixeddrives, allows use as a drop in replacement for xp_fixeddrives
	@unit                 varchar(4) = 'GB' -- BYTE, KB, MB, GB or TB - ignored if @xp_fixeddrivesCompat = 1
as
begin

	if OBJECT_ID('tempdb..#driveinfo') is not null
		drop table #driveinfo;

	-- check for valid unit value
	if @unit not in('BYTE', 'KB', 'MB', 'TB', 'GB')
		raiserror(N'Invalid Unit Specified, Must Be BYTE, KB, MB, GB or TB', 15, 1);

	-- set divisor, to be used when converting units
	declare @divisor bigint;
	select @divisor = case @unit
						  when 'BYTE' then 1
						  when 'KB' then 1024
						  when 'MB' then POWER(1024, 2)
						  when 'GB' then POWER(1024, 3)
						  when 'TB' then POWER(CAST(1024 as bigint), 4)
					  end;

	create table #driveinfo
	(
		volume_mount_point  nvarchar(512), 
		available_bytes     bigint, 
		total_bytes         bigint, 
		logical_volume_name nvarchar(512));

	-- DistinctDrives derived table updated to show all database_id and file_id combinations grouped by file path.
	-- Row number is applied so that we can filter just one database_id and file_id combination per file path and then these 
	-- combinations are passed to the sys.dm_os_volume_stats system TVF , the reason for the filtering within the derived table is
	-- to reduce the number of executions performed by the TVF because on instances with lots of databases this can slow execution.

	insert into #driveinfo (volume_mount_point, 
							available_bytes, 
							total_bytes, 
							logical_volume_name) 
	select distinct 
		   volumestats.volume_mount_point, 
		   volumestats.available_bytes, 
		   volumestats.total_bytes, 
		   logical_volume_name
	from
	(
		select database_id, 
			   file_id, 
			   ROW_NUMBER() over(partition by SUBSTRING(physical_name, 1, LEN(physical_name) - CHARINDEX('\', REVERSE(physical_name)) + 1)
			   order by SUBSTRING(physical_name, 1, LEN(physical_name) - CHARINDEX('\', REVERSE(physical_name)) + 1) asc) as RowNum
		from sys.master_files
		where database_id in
		(
			select database_id
			from sys.databases
			where state = 0
		)
	) as DistinctDrives
	cross apply sys.dm_os_volume_stats(DistinctDrives.database_id, DistinctDrives.file_id) as volumestats
	where DistinctDrives.RowNum = 1;

	if @xp_fixeddrivesCompat = 1
	begin
		-- if @xp_fixeddrivesCompat, return results matching the format of xp_fixeddrives
		select volume_mount_point, 
			   available_bytes / 1024 / 1024 as [MB free]
		from #driveinfo;
	end;
	else
	begin
		select volume_mount_point, 
			   CAST(CAST(available_bytes as decimal(20, 2)) / @divisor as decimal(20, 2)) as Available, 
			   CAST(CAST(total_bytes as decimal(20, 2)) / @divisor as decimal(20, 2)) as Total, 
			   CAST(available_bytes as decimal(20, 2)) / CAST(total_bytes as decimal(20, 2)) * 100 as PercentFree
		from #driveinfo;
	end;
end;