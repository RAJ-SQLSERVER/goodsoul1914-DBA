SELECT osn.node_id,
	osn.memory_node_id,
	osn.node_state_desc,
	omn.locked_page_allocations_kb
FROM sys.dm_os_memory_nodes omn
INNER JOIN sys.dm_os_nodes osn ON (omn.memory_node_id = osn.memory_node_id)
WHERE osn.node_state_desc <> 'ONLINE DAC'

SELECT (physical_memory_in_use_kb / 1024) Memory_usedby_Sqlserver_MB,
	(locked_page_allocations_kb / 1024) Locked_pages_used_Sqlserver_MB,
	(total_virtual_address_space_kb / 1024) Total_VAS_in_MB,
	process_physical_memory_low,
	process_virtual_memory_low
FROM sys.dm_os_process_memory

-- failed login attempts
DECLARE @dftrc NVARCHAR(256)

SELECT @dftrc = CAST(value AS NVARCHAR(256))
FROM fn_trace_getinfo(DEFAULT)
WHERE property = 2

SELECT *
FROM fn_trace_gettable(@dftrc, DEFAULT)
WHERE EventClass = 20
ORDER BY starttime DESC

SELECT CONVERT(VARCHAR(30), GETDATE(), 121) AS [RunTime],
	dateadd(ms, rbf.[timestamp] - tme.ms_ticks, GETDATE()) AS [Notification_Time],
	cast(record AS XML).value('(//SPID)[1]', 'bigint') AS SPID,
	cast(record AS XML).value('(//ErrorCode)[1]', 'varchar(255)') AS Error_Code,
	cast(record AS XML).value('(//CallingAPIName)[1]', 'varchar(255)') AS [CallingAPIName],
	cast(record AS XML).value('(//APIName)[1]', 'varchar(255)') AS [APIName],
	cast(record AS XML).value('(//Record/@id)[1]', 'bigint') AS [Record Id],
	cast(record AS XML).value('(//Record/@type)[1]', 'varchar(30)') AS [Type],
	cast(record AS XML).value('(//Record/@time)[1]', 'bigint') AS [Record Time],
	tme.ms_ticks AS [Current Time]
FROM sys.dm_os_ring_buffers rbf
CROSS JOIN sys.dm_os_sys_info tme
WHERE rbf.ring_buffer_type = 'RING_BUFFER_SECURITY_ERROR'
ORDER BY rbf.TIMESTAMP ASC;

SELECT *
FROM sys.dm_os_wait_stats
ORDER BY waiting_tasks_count DESC
