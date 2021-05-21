-- Latencies for individual log files
-- ------------------------------------------------------------------------------------------------

select DB_NAME(vfs.database_id) as DBName, 
	   mf.name as FileName, 
	   mf.type_desc as FileType, 
	   pior.io_type, 
	   pior.io_offset, 
	   pior.io_pending_ms_ticks
from sys.dm_io_pending_io_requests as pior
	 join sys.dm_io_virtual_file_stats (null, null) as vfs on vfs.file_handle = pior.io_handle
	 join sys.master_files as mf on mf.database_id = vfs.database_id
									and mf.file_id = vfs.file_id
where pior.io_pending = 1
order by pior.io_offset;
go