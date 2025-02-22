
-- Finding the read/write ratio
-- The higher the write% the more OLTP-ish your system is

SELECT DB_NAME (DB_ID ()) AS "Database Name",
       file_id,
       num_of_reads,
       num_of_writes,
       num_of_bytes_read,
       num_of_bytes_written,
       CAST(100. * num_of_reads / (num_of_reads + num_of_writes) AS DECIMAL(10, 1)) AS "# Reads Pct",
       CAST(100. * num_of_writes / (num_of_reads + num_of_writes) AS DECIMAL(10, 1)) AS "# Write Pct",
       CAST(100. * num_of_bytes_read / (num_of_bytes_read + num_of_bytes_written) AS DECIMAL(10, 1)) AS "Read Bytes Pct",
       CAST(100. * num_of_bytes_written / (num_of_bytes_read + num_of_bytes_written) AS DECIMAL(10, 1)) AS "Written Bytes Pct"
FROM sys.dm_io_virtual_file_stats (DB_ID (), NULL);
