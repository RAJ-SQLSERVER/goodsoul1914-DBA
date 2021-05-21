-- Process memory consumption
--
-- An internal component named the SQLOS creates node structures that mimic hardware
-- processor locality. These structures can be changed by using soft-NUMA to create
-- custom node layouts
--------------------------------------------------------------------------------------------------
SELECT physical_memory_in_use_kb / 1024 AS physical_memory_in_use_MB,
	large_page_allocations_kb / 1024 AS large_page_allocations_MB,
	locked_page_allocations_kb / 1024 AS locked_page_allocations_MB,
	total_virtual_address_space_kb / 1024 AS total_virtual_address_space_MB,
	virtual_address_space_reserved_kb / 1024 AS virtual_address_space_reserved_MB,
	virtual_address_space_committed_kb / 1024 AS virtual_address_space_committed_MB,
	virtual_address_space_available_kb / 1024 AS virtual_address_space_available_MB,
	available_commit_limit_kb / 1024 AS available_commit_limit_MB
FROM sys.dm_os_process_memory;
GO
