-- Last Running Query Based On SPID
-- ------------------------------------------------------------------------------------------------

declare @sqltext varbinary(128);

select @sqltext = sql_handle
from sys.sysprocesses
where spid = @@SPID;

select TEXT, 
	   USER
from sys.dm_exec_sql_text (@sqltext);
go

-- Returns Information About Requests Executing in SQL Server.
---------------------------------------------------------------------------------------------------

select er.session_id, 
	   SUBSTRING(est.TEXT, statement_start_offset / 2 + 1, ( case
																 when er.statement_end_offset = -1 then DATALENGTH(est.TEXT)
																 else er.statement_end_offset
															 end - er.statement_start_offset ) / 2 + 1) as current_stmnt, 
	   TEXT as batch, 
	   CAST(etqp.query_plan as xml) as stmnt_plan
from sys.dm_exec_requests as er
	 cross apply sys.dm_exec_sql_text (er.sql_handle) as est
	 cross apply sys.dm_exec_text_query_plan (er.plan_handle, er.statement_start_offset, er.statement_end_offset) as etqp
where session_id = @@SPID; 
go