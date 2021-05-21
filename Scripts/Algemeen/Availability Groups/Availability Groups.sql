-- AG Cluster
------------------------------------------------------------------------------------------------

select cluster_name, 
	   quorum_type_desc, 
	   quorum_state_desc
from sys.dm_hadr_cluster with(nolock) option(recompile);
go

-- AG Status
------------------------------------------------------------------------------------------------

select ag.name as [AG Name], 
	   ar.replica_server_name, 
	   ar.availability_mode_desc, 
	   adc.database_name, 
	   drs.is_local, 
	   drs.is_primary_replica, 
	   drs.synchronization_state_desc, 
	   drs.is_commit_participant, 
	   drs.synchronization_health_desc, 
	   drs.recovery_lsn, 
	   drs.truncation_lsn, 
	   drs.last_sent_lsn, 
	   drs.last_sent_time, 
	   drs.last_received_lsn, 
	   drs.last_received_time, 
	   drs.last_hardened_lsn, 
	   drs.last_hardened_time, 
	   drs.last_redone_lsn, 
	   drs.last_redone_time, 
	   drs.log_send_queue_size, 
	   drs.log_send_rate, 
	   drs.redo_queue_size, 
	   drs.redo_rate, 
	   drs.filestream_send_rate, 
	   drs.end_of_log_lsn, 
	   drs.last_commit_lsn, 
	   drs.last_commit_time, 
	   drs.database_state_desc
from sys.dm_hadr_database_replica_states as drs with(nolock)
	 inner join sys.availability_databases_cluster as adc with(nolock) on drs.group_id = adc.group_id
																		  and drs.group_database_id = adc.group_database_id
	 inner join sys.availability_groups as ag with(nolock) on ag.group_id = drs.group_id
	 inner join sys.availability_replicas as ar with(nolock) on drs.group_id = ar.group_id
																and drs.replica_id = ar.replica_id
order by ag.name, 
		 ar.replica_server_name, 
		 adc.database_name option(recompile);
go