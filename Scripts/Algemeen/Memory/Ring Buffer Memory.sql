-- Ring buffer memory-related queries
--
-- At this point?
-- * Consider increasing 'max server memory'
-- * Look at high I/O driving queries 
-- * Examine plans for optimization 
-- ------------------------------------------------------------------------------------------------
SELECT record.value('(/Record/@id)[1]', 'int') AS ID,
	tab.TIMESTAMP,
	EventTime,
	record.value('(/Record/ResourceMonitor/Notification)[1]', 'varchar(max)') AS Type,
	record.value('(/Record/ResourceMonitor/IndicatorsProcess)[1]', 'int') AS IndicatorsProcess,
	record.value('(/Record/ResourceMonitor/IndicatorsSystem)[1]', 'int') AS IndicatorsSystem,
	record.value('(/Record/ResourceMonitor/NodeId)[1]', 'int') AS NodeId,
	record.value('(/Record/MemoryNode/CommittedMemory)[1]', 'bigint') AS SQL_CommittedMemoryKB,
	record.value('(/Record/MemoryNode/SinglePagesMemory)[1]', 'bigint') AS SinglePagesMemory,
	record.value('(/Record/MemoryNode/MultiplePagesMemory)[1]', 'bigint') AS MultiplePagesMemory,
	record.value('(/Record/MemoryRecord/MemoryUtilization)[1]', 'bigint') AS [MemoryUtilization%],
	record.value('(/Record/MemoryRecord/AvailablePhysicalMemory)[1]', 'bigint') AS AvailablePhysicalMemoryKB,
	record.value('(/Record/ResourceMonitor/Effect[@type="APPLY_LOWPM"]/@state)[1]', 'nvarchar(50)') AS APPLY_LOWPM_State,
	record.value('(/Record/ResourceMonitor/Effect[@type="APPLY_LOWPM"]/@reversed)[1]', 'bit') AS APPLY_LOWPM_Reversed,
	record.value('(/Record/ResourceMonitor/Effect[@type="APPLY_LOWPM"])[1]', 'bigint') AS APPLY_LOWPM_Time,
	record.value('(/Record/ResourceMonitor/Effect[@type="APPLY_HIGHPM"]/@state)[1]', 'nvarchar(50)') AS APPLY_HIGHPM_State,
	record.value('(/Record/ResourceMonitor/Effect[@type="APPLY_HIGHPM"]/@reversed)[1]', 'bit') AS APPLY_HIGHPM_Reversed,
	record.value('(/Record/ResourceMonitor/Effect[@type="APPLY_HIGHPM"])[1]', 'bigint') AS APPLY_HIGHPM_Time,
	record.value('(/Record/ResourceMonitor/Effect[@type="REVERT_HIGHPM"]/@state)[1]', 'nvarchar(50)') AS REVERT_HIGHPM_State,
	record.value('(/Record/ResourceMonitor/Effect[@type="REVERT_HIGHPM"]/@reversed)[1]', 'bit') AS REVERT_HIGHPM_Reversed,
	record.value('(/Record/ResourceMonitor/Effect[@type="REVERT_HIGHPM"])[1]', 'bigint') AS REVERT_HIGHPM_Time,
	record.value('(/Record/MemoryNode/ReservedMemory)[1]', 'bigint') AS SQL_ReservedMemoryKB,
	record.value('(/Record/MemoryNode/SharedMemory)[1]', 'bigint') AS SQL_SharedMemoryKB,
	record.value('(/Record/MemoryNode/AWEMemory)[1]', 'bigint') AS SQL_AWEMemoryKB,
	record.value('(/Record/MemoryRecord/TotalPhysicalMemory)[1]', 'bigint') AS TotalPhysicalMemoryKB,
	record.value('(/Record/MemoryRecord/TotalPageFile)[1]', 'bigint') AS TotalPageFileKB,
	record.value('(/Record/MemoryRecord/AvailablePageFile)[1]', 'bigint') AS AvailablePageFileKB,
	record.value('(/Record/MemoryRecord/TotalVirtualAddressSpace)[1]', 'bigint') AS TotalVirtualAddressSpaceKB,
	record.value('(/Record/MemoryRecord/AvailableVirtualAddressSpace)[1]', 'bigint') AS AvailableVirtualAddressSpaceKB,
	record.value('(/Record/MemoryRecord/AvailableExtendedVirtualAddressSpace)[1]', 'bigint') AS AvailableExtendedVirtualAddressSpaceKB
FROM (
	SELECT TIMESTAMP,
		DATEADD(ss, (- 1 * (cpu_ticks / CONVERT(FLOAT, cpu_ticks / ms_ticks) - TIMESTAMP) / 1000), GETDATE()) AS EventTime,
		CONVERT(XML, record) AS record
	FROM sys.dm_os_ring_buffers
	CROSS JOIN sys.dm_os_sys_info
	WHERE ring_buffer_type = 'RING_BUFFER_RESOURCE_MONITOR'
	) AS tab
ORDER BY ID DESC;
GO
