-- Capturing baseline disk I/O statistics 
SELECT DB_NAME (mf.database_id) AS "databaseName",
       mf.physical_name,
       divfs.num_of_reads,
       divfs.num_of_bytes_read,
       divfs.io_stall_read_ms,
       divfs.num_of_writes,
       divfs.num_of_bytes_written,
       divfs.io_stall_write_ms,
       divfs.io_stall,
       divfs.size_on_disk_bytes,
       GETDATE () AS "baselineDate"
INTO #baseline
FROM sys.dm_io_virtual_file_stats (NULL, NULL) AS divfs
JOIN sys.master_files AS mf
    ON mf.database_id = divfs.database_id
       AND mf.file_id = divfs.file_id;

-- Query against the `#baseline` table, returning some the read and write statistics
SELECT physical_name,
       num_of_reads,
       num_of_bytes_read,
       io_stall_read_ms,
       num_of_writes,
       num_of_bytes_written,
       io_stall_write_ms
FROM #baseline
WHERE databaseName = 'Baseline';

-- Capturing disk I/O statistics, since the baseline measurement
WITH currentLine AS
(
    SELECT DB_NAME (mf.database_id) AS "databaseName",
           mf.physical_name,
           divfs.num_of_reads,
           divfs.num_of_bytes_read,
           divfs.io_stall_read_ms,
           divfs.num_of_writes,
           divfs.num_of_bytes_written,
           divfs.io_stall_write_ms,
           divfs.io_stall,
           divfs.size_on_disk_bytes,
           GETDATE () AS "currentlineDate"
    FROM sys.dm_io_virtual_file_stats (NULL, NULL) AS divfs
    JOIN sys.master_files AS mf
        ON mf.database_id = divfs.database_id
           AND mf.file_id = divfs.file_id
)
SELECT currentLine.databaseName,
       LEFT(currentLine.physical_name, 1) AS "drive",
       currentLine.physical_name,
       DATEDIFF (MILLISECOND, baselineDate, currentLine.currentlineDate) AS "elapsed_ms",
       currentLine.io_stall - #baseline.io_stall AS "io_stall_ms",
       currentLine.io_stall_read_ms - #baseline.io_stall_read_ms AS "io_stall_read_ms",
       currentLine.io_stall_write_ms - #baseline.io_stall_write_ms AS "io_stall_write_ms",
       currentLine.num_of_reads - #baseline.num_of_reads AS "num_of_reads",
       currentLine.num_of_bytes_read - #baseline.num_of_bytes_read AS "num_of_bytes_read",
       currentLine.num_of_writes - #baseline.num_of_writes AS "num_of_writes",
       currentLine.num_of_bytes_written - #baseline.num_of_bytes_written AS "num_of_bytes_written"
FROM currentLine
INNER JOIN #baseline
    ON #baseline.databaseName = currentLine.databaseName
       AND #baseline.physical_name = currentLine.physical_name
WHERE #baseline.databaseName = 'Baseline';