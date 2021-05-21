-- Finding the top 10 wait events (cumulative).
---------------------------------------------------------------------------------------------------

select top (10) wait_type, 
				waiting_tasks_count, 
				wait_time_ms - signal_wait_time_ms as resource_wait_time, 
				max_wait_time_ms,
				case waiting_tasks_count
					when 0 then 0
					else wait_time_ms / waiting_tasks_count
				end as avg_wait_time
from sys.dm_os_wait_stats
where wait_type not like '%SLEEP%' -- remove eg. SLEEP_TASK 
	  and wait_type not like 'XE%' -- and LAZYWRITER_SLEEP waits
	  and wait_type not in ('KSOURCE_WAKEUP', 'BROKER_TASK_STOP', 'FT_IFTS_SCHEDULER_IDLE_WAIT', 'SQLTRACE_BUFFER_FLUSH', 'CLR_AUTO_EVENT', 'BROKER_EVENTHANDLER', 'BAD_PAGE_PROCESS', 'BROKER_TRANSMITTER', 'CHECKPOINT_QUEUE', 'DBMIRROR_EVENTS_QUEUE', 'SQLTRACE_BUFFER_FLUSH', 'CLR_MANUAL_EVENT', 'ONDEMAND_TASK_QUEUE', 'REQUEST_FOR_DEADLOCK_SEARCH', 'LOGMGR_QUEUE', 'BROKER_RECEIVE_WAITFOR', 'PREEMPTIVE_OS_GETPROCADDRESS', 'PREEMPTIVE_OS_AUTHENTICATIONOPS', 'BROKER_TO_FLUSH') -- remove system waits  
order by wait_time_ms desc;
go