-------------------------------------------------------------------------------
-- Which database is consuming maximum io?
-------------------------------------------------------------------------------

SELECT DB_NAME(database_id) AS database_name,
       SUM(num_of_bytes_read / 1048576) AS read_io_mb,
       SUM(num_of_bytes_written / 1048576) AS write_io_mb,
       SUM((num_of_bytes_read + num_of_bytes_written) / 1048576) AS total_io_mb
FROM sys.dm_io_virtual_file_stats(NULL, NULL)
GROUP BY database_id
ORDER BY total_io_mb DESC;
GO

