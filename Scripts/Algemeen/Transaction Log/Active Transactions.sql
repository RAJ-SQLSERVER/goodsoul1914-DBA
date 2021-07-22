-- Basic DMV

select *
from sys.dm_tran_database_transactions
where database_id = DB_ID(N'iCONSENSE');
go

-- All active transactions
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
where s_tdt.database_id = DB_ID(N'iCONSENSE')
order by [Begin Time] asc;
go

-- Show transaction log information about current transactions
---------------------------------------------------------------------------------------------------
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
where s_tdt.database_id = DB_ID()
order by [Begin Time] asc;
go

-- Returns correlation information for associated transactions and sessions.
---------------------------------------------------------------------------------------------------
select session_id, 
	   transaction_id, 
	   transaction_descriptor, 
	   enlist_count, 
	   is_user_transaction, 
	   is_local, 
	   is_enlisted, 
	   is_bound, 
	   open_transaction_count
from sys.dm_tran_session_transactions
where session_id = @@SPID; 
go

-- Returns a single row that displays the state information of the transaction in the 
-- current session.
---------------------------------------------------------------------------------------------------
select transaction_id as tranId, 
	   transaction_sequence_num as seqNo, 
	   transaction_is_snapshot as isSnap, 
	   first_snapshot_sequence_num as [1stSnapSeqNo], 
	   last_transaction_sequence_num as lastSeqNo, 
	   first_useful_sequence_num as [1stUsefulSeqNo]
from sys.dm_tran_current_transaction;
go

-- Gathering information about the open transaction.
---------------------------------------------------------------------------------------------------
select st.session_id, 
	   st.is_user_transaction, 
	   dt.database_transaction_begin_time, 
	   dt.database_transaction_log_record_count, 
	   dt.database_transaction_log_bytes_used
from sys.dm_tran_session_transactions as st
	 join sys.dm_tran_database_transactions as dt on st.transaction_id = dt.transaction_id
													 and dt.database_id = DB_ID('master')
where st.session_id = @@SPID;
go

-- Transaction log impact of active transactions
---------------------------------------------------------------------------------------------------
select DTST.session_id, 
	   DES.login_name as [Login Name], 
	   DB_NAME(DTDT.database_id) as [Database], 
	   DTDT.database_transaction_begin_time as [Begin Time], 
	   DATEDIFF(ms, DTDT.database_transaction_begin_time, GETDATE()) as [Duration ms],
	   case DTAT.transaction_type
		   when 1 then 'Read/write'
		   when 2 then 'Read-only'
		   when 3 then 'System'
		   when 4 then 'Distributed'
	   end as [Transaction Type],
	   case DTAT.transaction_state
		   when 0 then 'Not fully initialized'
		   when 1 then 'Initialized, not started'
		   when 2 then 'Active'
		   when 3 then 'Ended'
		   when 4 then 'Commit initiated'
		   when 5 then 'Prepared, awaiting resolution'
		   when 6 then 'Committed'
		   when 7 then 'Rolling back'
		   when 8 then 'Rolled back'
	   end as [Transaction State], 
	   DTDT.database_transaction_log_record_count as [Log Records], 
	   DTDT.database_transaction_log_bytes_used as [Log Bytes Used], 
	   DTDT.database_transaction_log_bytes_reserved as [Log Bytes RSVPd], 
	   DEST.[text] as [Last Transaction Text], 
	   DEQP.query_plan as [Last Query Plan]
from sys.dm_tran_database_transactions as DTDT
	 inner join sys.dm_tran_session_transactions as DTST on DTST.transaction_id = DTDT.transaction_id
	 inner join sys.dm_tran_active_transactions as DTAT on DTST.transaction_id = DTAT.transaction_id
	 inner join sys.dm_exec_sessions as DES on DES.session_id = DTST.session_id
	 inner join sys.dm_exec_connections as DEC on DEC.session_id = DTST.session_id
	 left join sys.dm_exec_requests as DER on DER.session_id = DTST.session_id
	 cross apply sys.dm_exec_sql_text (DEC.most_recent_sql_handle) as DEST
	 outer apply sys.dm_exec_query_plan (DER.plan_handle) as DEQP
order by DTDT.database_transaction_log_bytes_used desc;
--ORDER BY [Duration ms] DESC
go

-- Returns information about transactions at the database level
--
-- * Can see how much transaction log space has been reserved for a transaction
-- * Can see how much total transaction log space is required for a transaction
--
-- database_transaction_log_record_count			Number of log records for the transaction
-- database_transaction_replicate_record_count		Number of log records that will be replicated
-- database_transaction_log_bytes_reserved			Log space reserved by the transaction
-- database_transaction_log_bytes_used				Log space used by the transaction
-- database_transaction_log_bytes_reserved_system	Log space reserved by system on behalf of the transaction
-- database_transaction_log_bytes_used_system		Log space used by system on behalf of the transaction
---------------------------------------------------------------------------------------------------
select transaction_id, 
	   DB_NAME(database_id) as DBName, 
	   database_transaction_begin_time,
	   case database_transaction_type
		   when 1 then 'Read/Write'
		   when 2 then 'Read-Only'
		   when 3 then 'System'
		   else 'Unknown Type - ' + CONVERT(varchar(50), database_transaction_type)
	   end as TranType,
	   case database_transaction_state
		   when 1 then 'Uninitialized'
		   when 3 then 'Not Started'
		   when 4 then 'Active'
		   when 5 then 'Prepared'
		   when 10 then 'Committed'
		   when 11 then 'Rolled Back'
		   when 12 then 'Comitting'
		   else 'Unknown State - ' + CONVERT(varchar(50), database_transaction_state)
	   end as TranState, 
	   database_transaction_log_record_count as LogRecords, 
	   database_transaction_replicate_record_count as ReplLogRcrds, 
	   database_transaction_log_bytes_reserved / 1024.0 as LogResrvdKB, 
	   database_transaction_log_bytes_used / 1024.0 as LogUsedKB, 
	   database_transaction_log_bytes_reserved_system / 1024.0 as SysLogResrvdKB, 
	   database_transaction_log_bytes_used_system / 1024.0 as SysLogUsedKB
from sys.dm_tran_database_transactions
where database_id not in (1, 2, 3, 4, 32767);
go