-- Examining All Threads
-- ------------------------------------------------------------------------------------------------

select ot.scheduler_id, 
	   task_state, 
	   COUNT(*) as task_count
from sys.dm_os_tasks as ot
	 inner join sys.dm_exec_requests as er on ot.session_id = er.session_id
	 inner join sys.dm_exec_sessions as es on er.session_id = es.session_id
where es.is_user_process = 1
group by ot.scheduler_id, 
		 task_state
order by task_state, 
		 ot.scheduler_id;
go