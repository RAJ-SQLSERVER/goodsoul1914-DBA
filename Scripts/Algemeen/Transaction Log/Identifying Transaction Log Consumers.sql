-- Identifying Transaction Log Consumers
--------------------------------------------------------------------------------------------------
select tst.session_id, 
	   s.login_name as [Login Name], 
	   DB_NAME(tdt.database_id) as [Database], 
	   tdt.database_transaction_begin_time as [Begin Time], 
	   tdt.database_transaction_log_record_count as [Log Records], 
	   tdt.database_transaction_log_bytes_used as [Log Bytes Used], 
	   tdt.database_transaction_log_bytes_reserved as [Log Bytes Rsvd], 
	   SUBSTRING(st.TEXT, r.statement_start_offset / 2 + 1, ( case r.statement_end_offset
																  when -1 then DATALENGTH(st.TEXT)
																  else r.statement_end_offset
															  end - r.statement_start_offset ) / 2 + 1) as statement_text, 
	   qp.query_plan as [Last Plan]
from sys.dm_tran_database_transactions as tdt
	 join sys.dm_tran_session_transactions as tst on tst.transaction_id = tdt.transaction_id
	 join sys.dm_exec_sessions as s on s.session_id = tst.session_id
	 join sys.dm_exec_connections as c on c.session_id = tst.session_id
	 left outer join sys.dm_exec_requests as r on r.session_id = tst.session_id
	 cross apply sys.dm_exec_sql_text (c.most_recent_sql_handle) as st
	 outer apply sys.dm_exec_query_plan (r.plan_handle) as qp
where tdt.database_transaction_log_record_count > 0
order by [Log Bytes Used] desc;
go