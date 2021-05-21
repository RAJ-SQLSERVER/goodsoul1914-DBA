
-- Finding statements running in the database right now (including if statement is blocked by another)
--------------------------------------------------------------------------------------------------

select DatabaseName = DB_NAME(rq.database_id), 
	   s.session_id, 
	   rq.status, 
	   SqlStatement = SUBSTRING(qt.text, rq.statement_start_offset / 2, ( case
																			  when rq.statement_end_offset = -1 then LEN(CONVERT(nvarchar(max), qt.text)) * 2
																			  else rq.statement_end_offset
																		  end - rq.statement_start_offset ) / 2), 
	   ClientHost = s.host_name, 
	   ClientProgram = s.program_name, 
	   ClientProcessId = s.host_process_id, 
	   SqlLoginUser = s.login_name, 
	   DurationInSeconds = DATEDIFF(s, rq.start_time, GETDATE()), 
	   rq.start_time, 
	   rq.cpu_time, 
	   rq.logical_reads, 
	   rq.writes, 
	   ParentStatement = qt.text, 
	   p.query_plan, 
	   rq.wait_type, 
	   BlockingSessionId = bs.session_id, 
	   BlockingHostname = bs.host_name, 
	   BlockingProgram = bs.program_name, 
	   BlockingClientProcessId = bs.host_process_id, 
	   BlockingSql = SUBSTRING(bt.text, brq.statement_start_offset / 2, ( case
																			  when brq.statement_end_offset = -1 then LEN(CONVERT(nvarchar(max), bt.text)) * 2
																			  else brq.statement_end_offset
																		  end - brq.statement_start_offset ) / 2)
from sys.dm_exec_sessions as s
	 inner join sys.dm_exec_requests as rq on s.session_id = rq.session_id
	 cross apply sys.dm_exec_sql_text (rq.sql_handle) as qt
	 outer apply sys.dm_exec_query_plan (rq.plan_handle) as p
	 left outer join sys.dm_exec_sessions as bs on rq.blocking_session_id = bs.session_id
	 left outer join sys.dm_exec_requests as brq on rq.blocking_session_id = brq.session_id
	 outer apply sys.dm_exec_sql_text (brq.sql_handle) as bt
where s.is_user_process = 1
	  and s.session_id <> @@spid
	  and rq.database_id = DB_ID()  -- Comment out to look at all databases
order by rq.start_time asc;
go
