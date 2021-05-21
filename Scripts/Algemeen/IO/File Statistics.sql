-- Stats by file
-- ------------------------------------------------------------------------------------------------

SELECT DB_NAME(DB_ID()) AS [Database Name],
       df.name AS [Logical Name],
       vfs.file_id,
       df.type_desc,
       df.physical_name AS [Physical Name],
       CAST(vfs.size_on_disk_bytes / 1048576.0 AS DECIMAL(16, 2)) AS [Size on Disk (MB)],
       vfs.num_of_reads,
       vfs.num_of_writes,
       vfs.io_stall_read_ms,
       vfs.io_stall_write_ms,
       CAST(100. * vfs.io_stall_read_ms / (vfs.io_stall_read_ms + vfs.io_stall_write_ms) AS DECIMAL(16, 1)) AS [IO Stall Reads Pct],
       CAST(100. * vfs.io_stall_write_ms / (vfs.io_stall_write_ms + vfs.io_stall_read_ms) AS DECIMAL(16, 1)) AS [IO Stall Writes Pct],
       vfs.num_of_reads + vfs.num_of_writes AS [Writes + Reads],
       CAST(vfs.num_of_bytes_read / 1048576.0 AS DECIMAL(16, 2)) AS [MB Read],
       CAST(vfs.num_of_bytes_written / 1048576.0 AS DECIMAL(16, 2)) AS [MB Written],
       CAST(100. * vfs.num_of_reads / (vfs.num_of_reads + vfs.num_of_writes) AS DECIMAL(16, 1)) AS [# Reads Pct],
       CAST(100. * vfs.num_of_writes / (vfs.num_of_reads + vfs.num_of_writes) AS DECIMAL(16, 1)) AS [# Write Pct],
       CAST(100. * vfs.num_of_bytes_read / (vfs.num_of_bytes_read + vfs.num_of_bytes_written) AS DECIMAL(16, 1)) AS [Read Bytes Pct],
       CAST(100. * vfs.num_of_bytes_written / (vfs.num_of_bytes_read + vfs.num_of_bytes_written) AS DECIMAL(16, 1)) AS [Written Bytes Pct]
FROM sys.dm_io_virtual_file_stats(DB_ID(), NULL) AS vfs
    INNER JOIN sys.database_files AS df WITH (nolock)
        ON vfs.file_id = df.file_id
OPTION (recompile);
go

-- Retrieve file statistics information about the created database files
---------------------------------------------------------------------------------------------------

DECLARE @dbId INT;

SELECT @dbId = database_id
FROM sys.databases
WHERE name = 'MultipleFileGroups';

SELECT sys.database_files.type_desc,
       sys.database_files.physical_name,
       sys.dm_io_virtual_file_stats.*
FROM sys.dm_io_virtual_file_stats(@dbId, NULL)
    INNER JOIN sys.database_files
        ON sys.database_files.file_id = sys.dm_io_virtual_file_stats.file_id;
go