-- SQL Server Process Address space info
--
-- You want to see 0 for process_physical_memory_low
-- You want to see 0 for process_virtual_memory_low
-- This indicates that you are not under internal memory pressure
-- If locked_page_allocations_kb > 0, then LPIM is enabled
--
-- How to enable the "locked pages" feature in SQL Server 2012
-- https://bit.ly/2F5UjOA
--
-- Memory Management Architecture Guide
-- https://bit.ly/2JKkadC
--
--------------------------------------------------------------------------------------------------
SELECT physical_memory_in_use_kb / 1024 AS [SQL Server Memory Usage (MB)],
	locked_page_allocations_kb / 1024 AS [SQL Server Locked Pages Allocation (MB)],
	large_page_allocations_kb / 1024 AS [SQL Server Large Pages Allocation (MB)],
	page_fault_count,
	memory_utilization_percentage,
	available_commit_limit_kb,
	process_physical_memory_low,
	process_virtual_memory_low
FROM sys.dm_os_process_memory WITH (NOLOCK)
OPTION (RECOMPILE);
GO
