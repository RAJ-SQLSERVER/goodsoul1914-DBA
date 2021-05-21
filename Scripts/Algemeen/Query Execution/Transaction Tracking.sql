-- Tracking transactions
-- ------------------------------------------------------------------------------------------------

select *
from sys.dm_tran_database_transactions
where database_id = DB_ID(N'AdventureWorks');
go

select s_tst.session_id, 
	   s_es.login_name as [Login Name], 
	   DB_NAME(s_tdt.database_id) as [Database], 
	   s_tdt.database_transaction_begin_time as [Begin Time], 
	   s_tdt.database_transaction_log_record_count as [Log Records], 
	   s_tdt.database_transaction_log_bytes_used as [Log Bytes], 
	   s_tdt.database_transaction_log_bytes_reserved as [Log Rsvd], 
	   s_est.[text] as [Last T-SQL Text], 
	   s_eqp.query_plan as [Last Plan]
from sys.dm_tran_database_transactions as s_tdt
	 join sys.dm_tran_session_transactions as s_tst on s_tst.transaction_id = s_tdt.transaction_id
	 join sys.dm_exec_sessions as s_es on s_es.session_id = s_tst.session_id
	 join sys.dm_exec_connections as s_ec on s_ec.session_id = s_tst.session_id
	 left outer join sys.dm_exec_requests as s_er on s_er.session_id = s_tst.session_id
	 cross apply sys.dm_exec_sql_text (s_ec.most_recent_sql_handle) as s_est
	 outer apply sys.dm_exec_query_plan (s_er.plan_handle) as s_eqp
where s_tdt.database_id = DB_ID(N'AdventureWorks')
order by [Begin Time] asc;
go