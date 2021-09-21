-- Listing 9-4. IO performance script
SELECT DB_NAME (vfs.database_id) AS "Database",
       mf.physical_name AS "PhysicalName",
       CASE
           WHEN num_of_reads = 0 THEN 0
           ELSE (io_stall_read_ms / num_of_reads)
       END AS "ReadLatency",
       CASE
           WHEN num_of_writes = 0 THEN 0
           ELSE (io_stall_write_ms / num_of_writes)
       END AS "WriteLatency",
       CASE
           WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0
           ELSE (io_stall / (num_of_reads + num_of_writes))
       END AS "Latency",
       CASE
           WHEN num_of_reads = 0 THEN 0
           ELSE (num_of_bytes_read / num_of_reads)
       END AS "AvgBPerRead",
       CASE
           WHEN num_of_writes = 0 THEN 0
           ELSE (num_of_bytes_written / num_of_writes)
       END AS "AvgBPerWrite",
       CASE
           WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0
           ELSE ((num_of_bytes_read + num_of_bytes_written) / (num_of_reads + num_of_writes))
       END AS "AvgBPerTransfer"
FROM sys.dm_io_virtual_file_stats (NULL, NULL) AS vfs
JOIN sys.master_files AS mf
    ON vfs.database_id = mf.database_id
       AND vfs.file_id = mf.file_id
-- WHERE [vfs].[file_id] = 2 -- log files
ORDER BY Latency DESC;
-- ORDER BY [ReadLatency] DESC
-- ORDER BY [WriteLatency] DESC;
GO