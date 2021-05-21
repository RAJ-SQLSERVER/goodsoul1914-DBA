-- SQL Server NUMA Node information
--
-- Gives you some useful information about the composition and relative load on your NUMA nodes
-- You want to see an equal number of schedulers on each NUMA node
-- Watch out if SQL Server 2017 Standard Edition has been installed 
-- on a physical or virtual machine with more than four sockets or more than 24 physical cores
-- sys.dm_os_nodes (Transact-SQL)
-- https://bit.ly/2pn5Mw8
-- Balancing Your Available SQL Server Core Licenses Evenly Across NUMA Nodes
-- https://bit.ly/2vfC4Rq
---------------------------------------------------------------------------------------------------

select node_id, 
	   node_state_desc, 
	   memory_node_id, 
	   processor_group, 
	   cpu_count, 
	   online_scheduler_count, 
	   idle_scheduler_count, 
	   active_worker_count, 
	   avg_load_balance, 
	   resource_monitor_state
from sys.dm_os_nodes with(nolock)
where node_state_desc <> N'ONLINE DAC' option(recompile);
go