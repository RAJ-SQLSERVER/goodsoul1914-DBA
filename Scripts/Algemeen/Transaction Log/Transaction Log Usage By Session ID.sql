-- Transaction Log Usage By Session ID
-- ------------------------------------------------------------------------------------------------

select DB_NAME(tdt.database_id) as DatabaseName, 
	   d.recovery_model_desc as RecoveryModel, 
	   d.log_reuse_wait_desc as LogReuseWait, 
	   es.original_login_name as OriginalLoginName, 
	   es.program_name as ProgramName, 
	   es.session_id as SessionID, 
	   er.blocking_session_id as BlockingSessionId, 
	   er.wait_type as WaitType, 
	   er.last_wait_type as LastWaitType, 
	   er.status as status, 
	   tat.transaction_id as TransactionID, 
	   tat.transaction_begin_time as TransactionBeginTime, 
	   tdt.database_transaction_begin_time as DatabaseTransactionBeginTime, 
	   tst.open_transaction_count as OpenTransactionCount,
	   case tdt.database_transaction_state
		   when 1 then 'The transaction has not been initialized.'
		   when 3 then 'The transaction has been initialized but has not generated any log records.'
		   when 4 then 'The transaction has generated log records.'
		   when 5 then 'The transaction has been prepared.'
		   when 10 then 'The transaction has been committed.'
		   when 11 then 'The transaction has been rolled back.'
		   when 12 then 'The transaction is being committed. In this state the log record is being generated, but it has not been materialized or persisted.'
		   else null --http://msdn.microsoft.com/en-us/library/ms186957.aspx 
	   end as DatabaseTransactionStateDesc, 
	   est.[text] as StatementText, 
	   tdt.database_transaction_log_record_count as DatabaseTransactionLogRecordCount, 
	   tdt.database_transaction_log_bytes_used as DatabaseTransactionLogBytesUsed, 
	   tdt.database_transaction_log_bytes_reserved as DatabaseTransactionLogBytesReserved, 
	   tdt.database_transaction_log_bytes_used_system as DatabaseTransactionLogBytesUsedSystem, 
	   tdt.database_transaction_log_bytes_reserved_system as DatabaseTransactionLogBytesReservedSystem, 
	   tdt.database_transaction_begin_lsn as DatabaseTransactionBeginLsn, 
	   tdt.database_transaction_last_lsn as DatabaseTransactionLastLsn
from sys.dm_exec_sessions as es
	 inner join sys.dm_tran_session_transactions as tst on es.session_id = tst.session_id
	 inner join sys.dm_tran_database_transactions as tdt on tst.transaction_id = tdt.transaction_id
	 inner join sys.dm_tran_active_transactions as tat on tat.transaction_id = tdt.transaction_id
	 inner join sys.databases as d on d.database_id = tdt.database_id
	 left outer join sys.dm_exec_requests as er on es.session_id = er.session_id
	 left outer join sys.dm_exec_connections as ec on ec.session_id = es.session_id
	 --AND   ec.[most_recent_sql_handle] <> 0x 
	 outer apply sys.dm_exec_sql_text (ec.most_recent_sql_handle) as est
--WHERE tdt.[database_transaction_state] >= 4 
order by tdt.database_transaction_begin_lsn;
go