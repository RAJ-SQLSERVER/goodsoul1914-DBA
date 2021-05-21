-- Suspended Threads Detailed (What is happening right now?) 
-- ------------------------------------------------------------------------------------------------

select owt.session_id, 
	   owt.exec_context_id, 
	   ot.scheduler_id, 
	   owt.wait_duration_ms, 
	   owt.wait_type, 
	   owt.blocking_session_id, 
	   owt.resource_description,
	   case owt.wait_type
		   when N'CXPACKET' then RIGHT(owt.resource_description, CHARINDEX(N'=', REVERSE(owt.resource_description)) - 1)
		   else null
	   end as [Node ID], 
	   es.program_name, 
	   est.text, 
	   er.database_id, 
	   eqp.query_plan, 
	   er.cpu_time
from sys.dm_os_waiting_tasks as owt
	 inner join sys.dm_os_tasks as ot on owt.waiting_task_address = ot.task_address
	 inner join sys.dm_exec_sessions as es on owt.session_id = es.session_id
	 inner join sys.dm_exec_requests as er on es.session_id = er.session_id
	 outer apply sys.dm_exec_sql_text (er.sql_handle) as est
	 outer apply sys.dm_exec_query_plan (er.plan_handle) as eqp
where es.is_user_process = 1
order by owt.session_id, 
		 owt.exec_context_id;
go