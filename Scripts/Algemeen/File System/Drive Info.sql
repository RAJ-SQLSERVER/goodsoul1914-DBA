select distinct 
	   vs.volume_mount_point, 
	   vs.file_system_type, 
	   vs.logical_volume_name, 
	   CONVERT(decimal(18, 2), vs.total_bytes / 1073741824.0) as [Total Size (GB)], 
	   CONVERT(decimal(18, 2), vs.available_bytes / 1073741824.0) as [Available Size (GB)], 
	   CONVERT(decimal(18, 2), vs.available_bytes * 1. / vs.total_bytes * 100.) as [Space Free %], 
	   vs.supports_compression, 
	   vs.is_compressed, 
	   vs.supports_sparse_files, 
	   vs.supports_alternate_streams
from sys.master_files as f with(nolock)
	 cross apply sys.dm_os_volume_stats (f.database_id, f.file_id) as vs
order by vs.volume_mount_point option(recompile);
go


WITH presel 
AS (
	SELECT database_id, 
		   file_id,
		   LEFT(mf1.physical_name,3) AS Volume, 
		   ROW_NUMBER() OVER (PARTITION BY LEFT(mf1.physical_name,3) ORDER BY mf1.database_id) AS RowNum
	FROM sys.master_files mf1)
, roundtwo 
AS (
	SELECT DISTINCT pr.database_id, pr.file_id
	FROM presel pr
	WHERE pr.RowNum = 1
)
SELECT ovs.logical_volume_name AS VolumeName, 
	   ovs.volume_mount_point AS DiskDrive, 
	   ovs.available_bytes AS FreeSpace, 
	   ovs.total_bytes AS CurrentSize
FROM roundtwo mf
CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.file_id) ovs;
GO


/* for mount points, something like this */
EXECUTE sys.xp_cmdshell 'wmic volume get name, freespace, capacity, label'
/* the base wmi query that does not support mount points */
EXECUTE xp_cmdshell 'wmic logicaldisk get name,freespace,size,volumename,blocksize'
go