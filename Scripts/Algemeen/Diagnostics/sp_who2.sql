
-- A better version of sp_who2
---------------------------------------------------------------------------------------------------

select des.session_id, 
	   des.status, 
	   des.login_name, 
	   des.HOST_NAME, 
	   der.blocking_session_id, 
	   DB_NAME(der.database_id) as database_name, 
	   der.command, 
	   des.cpu_time, 
	   des.reads, 
	   des.writes, 
	   DEC.last_write, 
	   des.program_name, 
	   der.wait_type, 
	   der.wait_time, 
	   der.last_wait_type, 
	   der.wait_resource,
	   case des.transaction_isolation_level
		   when 0 then 'Unspecified'
		   when 1 then 'ReadUncommitted'
		   when 2 then 'ReadCommitted'
		   when 3 then 'Repeatable'
		   when 4 then 'Serializable'
		   when 5 then 'Snapshot'
	   end as transaction_isolation_level, 
	   OBJECT_NAME(dest.objectid, der.database_id) as OBJECT_NAME, 
	   SUBSTRING(dest.TEXT, der.statement_start_offset / 2, ( case
																  when der.statement_end_offset = -1 then DATALENGTH(dest.TEXT)
																  else der.statement_end_offset
															  end - der.statement_start_offset ) / 2) as [executing statement], 
	   deqp.query_plan
from sys.dm_exec_sessions as des
	 left join sys.dm_exec_requests as der on des.session_id = der.session_id
	 left join sys.dm_exec_connections as DEC on des.session_id = DEC.session_id
	 cross apply sys.dm_exec_sql_text (der.sql_handle) as dest
	 cross apply sys.dm_exec_query_plan (der.plan_handle) as deqp
where des.session_id <> @@SPID
order by des.session_id;
go