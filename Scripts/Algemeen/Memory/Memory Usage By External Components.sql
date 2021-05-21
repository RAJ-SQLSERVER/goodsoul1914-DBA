-- Allocations that are internal to SQL Server use the SQL Server memory manager. 
-- Tracking the difference between process memory counters from sys.dm_os_process_memory and internal 
-- counters can indicate memory use from external components in the SQL Server memory space.
--
-- Memory brokers fairly distribute memory allocations between various components within SQL Server, 
-- based on current and projected usage. Memory brokers do not perform allocations. 
-- They only track allocations for computing distribution.
--
-- allocations_kb			to check total allocations.
-- predicted_allocations_kb	Prediction of allocation based on usage pattern.
-- target_allocations_kb	Recommended allocations based on memory setting. Broker will shrink or grow to this value.
-- last_notification		Indicate the last action like GROW, SHRINK, STABLE.
--------------------------------------------------------------------------------------------------
SELECT pool_id,
	memory_broker_type,
	allocations_kb,
	allocations_kb_per_sec,
	predicted_allocations_kb,
	target_allocations_kb,
	future_allocations_kb,
	overall_limit_kb,
	last_notification
FROM sys.dm_os_memory_brokers;
GO
