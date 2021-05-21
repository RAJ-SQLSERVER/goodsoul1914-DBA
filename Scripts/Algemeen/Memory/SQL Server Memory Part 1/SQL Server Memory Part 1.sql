/*
SQL Server Memory by Amit Bansal (Recorded Webinar)



*/

-- Physical RAM
SELECT physical_memory_in_use_kb,
       large_page_allocations_kb,
       locked_page_allocations_kb,
       total_virtual_address_space_kb,
       virtual_address_space_reserved_kb,
       virtual_address_space_committed_kb,
       virtual_address_space_available_kb,
       page_fault_count,
       memory_utilization_percentage,
       available_commit_limit_kb,
       process_physical_memory_low,
       process_virtual_memory_low
FROM sys.dm_os_process_memory
GO

SELECT total_physical_memory_kb,
       available_physical_memory_kb,
       total_page_file_kb,
       available_page_file_kb,
       system_cache_kb,
       kernel_paged_pool_kb,
       kernel_nonpaged_pool_kb,
       system_high_memory_signal_state,
       system_low_memory_signal_state,
       system_memory_state_desc
FROM sys.dm_os_sys_memory
GO

-- Non-Uniform Memory Architecture (NUMA) nodes
SELECT node_id,
       node_state_desc,
       memory_object_address,
       memory_clerk_address,
       io_completion_worker_address,
       memory_node_id,
       cpu_affinity_mask,
       online_scheduler_count,
       idle_scheduler_count,
       active_worker_count,
       avg_load_balance,
       timer_task_affinity_mask,
       permanent_task_affinity_mask,
       resource_monitor_state,
       online_scheduler_mask,
       processor_group,
       cpu_count
FROM sys.dm_os_nodes;
GO

/* 
Three-layer memory architecture 
*/

-- Memory Nodes (1 per NUMA nodes) [Talk to Windows through API calls]
--
-- 2 types of allocators:
--		* Base allocators
--			- VirtualAlloc()
--			- VirtualAllocEx()
--			- AllocateUserPhysicalPages()
--
--		* Structured allocators
--			- HeapAlloc()
--			- Malloc()
--			- New()
--
SELECT memory_node_id,
       virtual_address_space_reserved_kb,
       virtual_address_space_committed_kb,
       locked_page_allocations_kb,
       pages_kb,
       shared_memory_reserved_kb,
       shared_memory_committed_kb,
       cpu_affinity_mask,
       online_scheduler_mask,
       processor_group,
       foreign_committed_kb,
       target_kb
FROM sys.dm_os_memory_nodes
GO


-- Memory Clerks [Talk to the Memory Nodes]
--		* Buffer Pool
--		* General
--		* ObjectStore
--		* UserStore
--		* CacheStore
--			CACHESTORE_OBJCP (Object Plans)
--			CACHESTORE_SQLCP (Ad-hoc Plans)
--			CACHESTORE_PHDR (Bound Trees)
--			CACHESTORE_XPROC (Extended Proc)
-- 
SELECT memory_clerk_address,
       type,
       name,
       memory_node_id,
       pages_kb,
       virtual_memory_reserved_kb,
       virtual_memory_committed_kb,
       awe_allocated_kb,
       shared_memory_reserved_kb,
       shared_memory_committed_kb,
       page_size_in_bytes,
       page_allocator_address,
       host_address
FROM sys.dm_os_memory_clerks
GO

SELECT *
FROM sys.dm_os_memory_cache_clock_hands
GO -- The clock system

	-- CacheStore
	SELECT cache_address,
           name,
           type,
           pages_kb,
           pages_in_use_kb,
           entries_count,
           entries_in_use_count
	FROM sys.dm_os_memory_cache_counters
	GO

	SELECT cache_address,
           name,
           type,
           entry_address,
           entry_data_address,
           in_use_count,
           is_dirty,
           disk_ios_count,
           context_switches_count,
           original_cost,
           current_cost,
           memory_object_address,
           pages_kb,
           entry_data,
           pool_id,
           time_to_generate,
           use_count,
           average_time_between_uses,
           time_since_last_use,
           probability_of_reuse,
           value
	FROM sys.dm_os_memory_cache_entries
	GO

	SELECT bucketid,
           refcounts,
           usecounts,
           size_in_bytes,
           memory_object_address,
           cacheobjtype,
           objtype,
           plan_handle,
           pool_id,
           parent_plan_handle
	FROM sys.dm_exec_cached_plans
	GO

	SELECT pool_id,
           memory_broker_type,
           allocations_kb,
           allocations_kb_per_sec,
           predicted_allocations_kb,
           target_allocations_kb,
           future_allocations_kb,
           overall_limit_kb,
           last_notification
	FROM sys.dm_os_memory_brokers
	GO
    

-- Memory Objects [Talk to the Memory Clerks]
--
-- 
SELECT memory_object_address,
       parent_address,
       pages_in_bytes,
       creation_options,
       bytes_used,
       type,
       name,
       memory_node_id,
       creation_time,
       page_size_in_bytes,
       max_pages_in_bytes,
       page_allocator_address,
       creation_stack_address,
       sequence_num,
       partition_type,
       partition_type_desc,
       contention_factor,
       waiting_tasks_count,
       exclusive_access_count
FROM sys.dm_os_memory_objects
GO


-- Memory Models
--
--	* Conventional (default)
--	* Locked (LPIM)
--	* Large (memory will be allocated in bigger chunks and all memory will be consumed upfront)


-- Resource Monitor
-- 
-- Constantly watching what is going on inside SQLOS
-- 
SELECT ring_buffer_address,
       ring_buffer_type,
       timestamp,
       record
FROM sys.dm_os_ring_buffers
GO

