-- Show user requests that are waiting
---------------------------------------------------------------------------------------------------

select er.session_id, 
	   er.status, 
	   er.wait_type, 
	   er.wait_time, 
	   er.wait_resource, 
	   er.last_wait_type, 
	   er.blocking_session_id
from sys.dm_exec_requests as er
	 join sys.dm_exec_sessions as es on es.session_id = er.session_id
										and es.is_user_process = 1
where wait_time = 0;
go