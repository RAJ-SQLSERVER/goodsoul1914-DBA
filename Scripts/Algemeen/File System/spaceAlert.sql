
-------------------------------------------------------------------------------
-- Alert on low space
-------------------------------------------------------------------------------
SELECT ovs.volume_mount_point AS drive,
       CAST(SUM(ovs.available_bytes) * 100 / SUM(ovs.total_bytes) AS INT) AS [free_%],
       AVG(ovs.available_bytes / 1024 / 1024 / 1024) free_gb
FROM sys.master_files f
    CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.[file_id]) AS ovs
GROUP BY ovs.volume_mount_point
ORDER BY ovs.volume_mount_point;
GO

