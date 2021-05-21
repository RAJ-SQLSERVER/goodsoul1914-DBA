-- Transaction log I/O latencies (Jimmy May)
-- ------------------------------------------------------------------------------------------------

select  --virtual file latency
ReadLatency = case
				  when num_of_reads = 0 then 0
				  else io_stall_read_ms / num_of_reads
			  end, 
WriteLatency = case
				   when num_of_writes = 0 then 0
				   else io_stall_write_ms / num_of_writes
			   end, 
Latency = case
			  when num_of_reads = 0
				   and num_of_writes = 0 then 0
			  else io_stall / ( num_of_reads + num_of_writes )
		  end,
--avg bytes per IOP
AvgBPerRead = case
				  when num_of_reads = 0 then 0
				  else num_of_bytes_read / num_of_reads
			  end, 
AvgBPerWrite = case
				   when io_stall_write_ms = 0 then 0
				   else num_of_bytes_written / num_of_writes
			   end, 
AvgBPerTransfer = case
					  when num_of_reads = 0
						   and num_of_writes = 0 then 0
					  else( num_of_bytes_read + num_of_bytes_written ) / ( num_of_reads + num_of_writes )
				  end, 
LEFT(mf.physical_name, 2) as Drive, 
DB_NAME(vfs.database_id) as DB, 
vfs.*, 
mf.physical_name
from sys.dm_io_virtual_file_stats (null, null) as vfs
	 join sys.master_files as mf on vfs.database_id = mf.database_id
									and vfs.file_id = mf.file_id
where vfs.file_id = 2 -- log files
-- ORDER BY [Latency] DESC
-- ORDER BY [ReadLatency] DESC
order by WriteLatency desc;
go