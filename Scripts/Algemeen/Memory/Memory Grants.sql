-- Memory Grants information
-------------------------------------------------------------------------------
SELECT session_id,
	request_id,
	scheduler_id,
	dop,
	request_time,
	grant_time,
	requested_memory_kb,
	granted_memory_kb,
	required_memory_kb,
	used_memory_kb,
	max_used_memory_kb,
	query_cost,
	timeout_sec,
	resource_semaphore_id,
	queue_id,
	wait_order,
	is_next_candidate,
	wait_time_ms,
	plan_handle,
	sql_handle,
	group_id,
	pool_id,
	is_small,
	ideal_memory_kb
FROM sys.dm_exec_query_memory_grants;
GO

-- Grants pending
-------------------------------------------------------------------------------
SELECT @@SERVERNAME AS [Server Name],
	RTRIM(object_name) AS [Object Name],
	cntr_value AS [Memory Grants Pending]
FROM sys.dm_os_performance_counters WITH (NOLOCK)
WHERE object_name LIKE N'%Memory Manager%' -- Handles named instances
	AND counter_name = N'Memory Grants Pending'
OPTION (RECOMPILE);
GO

-- Memory Grants Pending value for current instance
--
-- Run multiple times, and run periodically if you suspect you are under memory 
-- pressure Memory Grants Pending above zero for a sustained period is a very 
-- strong indicator of internal memory pressure
-- ----------------------------------------------------------------------------
SELECT @@SERVERNAME AS [Server Name],
	RTRIM(object_name) AS [Object Name],
	cntr_value AS [Memory Grants Pending]
FROM sys.dm_os_performance_counters WITH (NOLOCK)
WHERE object_name LIKE N'%Memory Manager%' -- Handles named instances
	AND counter_name = N'Memory Grants Pending'
OPTION (RECOMPILE);
GO

-- Returns information about all queries that have requested and are waiting for 
-- a memory grant or have been given a memory grant. Queries that do not 
-- require a memory grant will not appear in this view. For example, sort and 
-- hash join operations have memory grants for query execution, while queries 
-- without an ORDER BY clause will not have a memory grant.
-------------------------------------------------------------------------------
SELECT *
FROM sys.dm_exec_query_memory_grants;
GO

-- Semaphores
SELECT resource_semaphore_id,
	target_memory_kb,
	max_target_memory_kb,
	total_memory_kb,
	available_memory_kb,
	granted_memory_kb,
	used_memory_kb,
	grantee_count,
	waiter_count,
	timeout_error_count,
	forced_grant_count,
	pool_id
FROM sys.dm_exec_query_resource_semaphores;
GO
