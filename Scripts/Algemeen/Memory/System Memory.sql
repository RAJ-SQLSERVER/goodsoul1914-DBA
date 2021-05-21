-- System memory
--------------------------------------------------------------------------------------------------
SELECT total_physical_memory_kb / 1024 AS [Physical Memory (MB)],
	available_physical_memory_kb / 1024 AS [Available Memory (MB)],
	total_page_file_kb / 1024 AS [Total Page File (MB)],
	available_page_file_kb / 1024 AS [Available Page File (MB)],
	system_cache_kb / 1024 AS [System Cache (MB)],
	system_memory_state_desc AS [System Memory State]
FROM sys.dm_os_sys_memory WITH (NOLOCK)
OPTION (RECOMPILE);
GO

-- What is the available physical memory?
--------------------------------------------------------------------------------------------------
SELECT physical_memory_kb,
	virtual_memory_kb,
	committed_kb,
	committed_target_kb,
	visible_target_kb
FROM sys.dm_os_sys_info;
GO

-- Additional memory information 
--------------------------------------------------------------------------------------------------
SELECT total_physical_memory_kb,
	available_physical_memory_kb,
	total_page_file_kb,
	available_page_file_kb,
	system_memory_state_desc
FROM sys.dm_os_sys_memory WITH (NOLOCK)
OPTION (RECOMPILE);
GO
