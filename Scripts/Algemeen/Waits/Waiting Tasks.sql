-- Waiting Tasks
-- ------------------------------------------------------------------------------------------------

select owt.session_id, 
	   owt.exec_context_id, 
	   owt.wait_duration_ms, 
	   owt.wait_type, 
	   owt.blocking_session_id, 
	   owt.resource_description, 
	   es.program_name, 
	   est.[text], 
	   est.dbid, 
	   eqp.query_plan, 
	   es.cpu_time, 
	   es.memory_usage
from sys.dm_os_waiting_tasks as owt
	 inner join sys.dm_exec_sessions as es on owt.session_id = es.session_id
	 inner join sys.dm_exec_requests as er on es.session_id = er.session_id
	 outer apply sys.dm_exec_sql_text (er.sql_handle) as est
	 outer apply sys.dm_exec_query_plan (er.plan_handle) as eqp
where es.is_user_process = 1
order by owt.session_id, 
		 owt.exec_context_id;
go