-- Get lock waits for current database
-- This query is helpful for troubleshooting blocking and deadlocking issues
---------------------------------------------------------------------------------------------------

select o.name as table_name, 
	   i.name as index_name, 
	   ios.index_id, 
	   ios.partition_number, 
	   SUM(ios.row_lock_wait_count) as total_row_lock_waits, 
	   SUM(ios.row_lock_wait_in_ms) as total_row_lock_wait_in_ms, 
	   SUM(ios.page_lock_wait_count) as total_page_lock_waits, 
	   SUM(ios.page_lock_wait_in_ms) as total_page_lock_wait_in_ms, 
	   SUM(ios.page_lock_wait_in_ms) + SUM(row_lock_wait_in_ms) as total_lock_wait_in_ms
from sys.dm_db_index_operational_stats (DB_ID(), null, null, null) as ios
	 inner join sys.objects as o with(nolock) on ios.object_id = o.object_id
	 inner join sys.indexes as i with(nolock) on ios.object_id = i.object_id
												 and ios.index_id = i.index_id
where o.object_id > 100
group by o.name, 
		 i.name, 
		 ios.index_id, 
		 ios.partition_number
having SUM(ios.page_lock_wait_in_ms) + SUM(row_lock_wait_in_ms) > 0
order by total_lock_wait_in_ms desc option(recompile);
go

-- Investigating locking waits
---------------------------------------------------------------------------------------------------

select wait_type, 
	   waiting_tasks_count, 
	   wait_time_ms, 
	   max_wait_time_ms
from sys.dm_os_wait_stats
where wait_type like 'LCK%'
	  and Waiting_tasks_count > 0
order by waiting_tasks_count desc;
go