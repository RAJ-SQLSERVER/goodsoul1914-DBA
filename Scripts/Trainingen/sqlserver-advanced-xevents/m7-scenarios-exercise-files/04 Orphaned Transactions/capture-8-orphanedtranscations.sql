IF EXISTS(SELECT * 
		  FROM sys.server_event_sessions 
		  WHERE name='OrphanedTransactions')
    DROP EVENT SESSION [OrphanedTransactions] ON SERVER;
CREATE EVENT SESSION [OrphanedTransactions]
ON SERVER
ADD EVENT sqlserver.database_transaction_begin(
	ACTION	
	(	sqlserver.session_id, 
		sqlserver.database_id, 
		sqlserver.tsql_stack, 
		package0.collect_system_time)),
ADD EVENT sqlserver.database_transaction_end(
	ACTION	
	(	sqlserver.session_id, 
		sqlserver.database_id, 
		sqlserver.tsql_stack, 
		package0.collect_system_time))
ADD TARGET package0.pair_matching
( SET begin_event = 'sqlserver.database_transaction_begin',
  begin_matching_actions = 'sqlserver.session_id',
  end_event = 'sqlserver.database_transaction_end',
  end_matching_actions = 'sqlserver.session_id',
  respond_to_memory_pressure = 0)
WITH (MAX_DISPATCH_LATENCY=5 SECONDS, TRACK_CAUSALITY=ON)
GO
ALTER EVENT SESSION [OrphanedTransactions]
ON SERVER
STATE=START
GO

