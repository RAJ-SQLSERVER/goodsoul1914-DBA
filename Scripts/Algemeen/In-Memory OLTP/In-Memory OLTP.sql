-- Reports the database-level memory consumers in the In-Memory OLTP database engine. 
-- The view returns a row for each memory consumer that the database engine uses. 
-- Use this DMV to see how the memory is distributed across different internal objects.
--
-- Memory_consumer_type_desc
--    VARHEAP (variable length heap)
--    HASH (index)
--    PGPOOL (one consumer for runtime operations. E.g.: table variables)
-- Memory_consumer_desc
--    VARHEAP	Database heap: used for user data allocations for a database.
--				Database system heap: used for non-user data allocations for a database.
--				Range index heap: private heap for range indexes.
--    HASH		No description.
--    PGPOOL	Database 64K page pool. Only one row and one description.
-- Object_id			Id of the object
-- Index_id				Id of the index
-- Allocated_bytes		Bytes reserved for this consumer
-- Used_bytes			Actual bytes used
-- Allocation_count		number of allocations for this consumer
----------------------------------------------------------------------------------------------

select memory_consumer_type_desc, 
	   memory_consumer_desc, 
	   object_id, 
	   index_id, 
	   allocated_bytes, 
	   used_bytes, 
	   allocation_count
from sys.dm_db_xtp_memory_consumers;
go

-- Reports the database-level memory consumers in the In-Memory OLTP database engine. 
-- The view returns a row for each memory consumer that the database engine uses. 
-- Use this DMV to see how the memory is distributed across different internal objects. 
----------------------------------------------------------------------------------------------

select xmc.memory_consumer_type_desc, 
	   xmc.memory_consumer_desc, 
	   OBJECT_NAME(xmc.object_id) as objName, 
	   i.name as indName, 
	   xmc.allocated_bytes, 
	   xmc.used_bytes, 
	   xmc.allocation_count
from sys.dm_db_xtp_memory_consumers as xmc
	 inner join sys.indexes as i on xmc.index_id = i.index_id
									and xmc.object_id = i.object_id;
go

-- Reports the active transactions in the In-Memory OLTP database engine
-- 
-- xtp_transaction_id	Id used for this transaction in the XTP transaction manager.
-- transaction_id		Can be used to link with sys.dm_tran_active_transactions. Value is 0 for XTP-only transactions.
-- session_id			Session which owns this transaction.
-- begin_tsn			Begin transaction sequence number of the transaction.
-- end_tsn				End transaction sequence number of the transaction.
-- state_desc			Status of the transaction. Values can be ACTIVE, COMMITTED, ABORTED, VALIDATING.
-- result_desc			Provides the outcome of the transaction. Possible values are IN PROGRESS, SUCCESS, ERROR, COMMIT DEPENDENCY, VALIDATION FAILED (RR), VALIDATION FAILED (SR), ROLLBACK
-- 
----------------------------------------------------------------------------------------------

select xtp_transaction_id, 
	   transaction_id, 
	   session_id, 
	   begin_tsn, 
	   end_tsn, 
	   state_desc, 
	   result_desc
from sys.dm_db_xtp_transactions;
go

-- Reports statistics about transactions that have run since the server started
-- 
-- total_counts			Total transactions which executed in In-Memory OLTP engine.
-- read_only_count		Count of read-only transactions.
-- total_aborts			Number of transactions which aborted.
-- validation_failure	Number of times a transaction aborts due to validation failure.
-- dependencies_failed	Number of times a transaction has aborted as the dependent transaction aborted.
-- savepoints_created	Number of savepoints created. Every atomic block creates a savepoint.
-- savepoint_rollbacks	Number of times a rollback occurred on previous savepoint.
-- log_bytes_written	Number of log bytes written in to In-Memory log records.
-- log_IO_count			Number of transactions that need log IO. This is only considered with durable tables.
----------------------------------------------------------------------------------------------

select total_count, 
	   read_only_count, 
	   total_aborts, 
	   validation_failures, 
	   dependencies_failed, 
	   savepoint_create, 
	   savepoint_rollbacks, 
	   log_bytes_written, 
	   log_IO_count
from sys.dm_xtp_transaction_stats;
go

-- Displays information about checkpoint files, including file size, physical location 
-- and the transaction ID
-- 
-- file_type_desc			Data or Delta
-- internal_storage_slot	In index storage array this is the index of the file.
-- state_desc				This explains the state of the file. Possible values are as below.
--    PRECREATED					These are allocated when In-Memory is enabled. This is created on similar principals of tempdb. You will have equal number of data and delta files equal to number of cores. Each pair of data and delta files is called Checkpoint File Pairs (CFP). The minimum is 8 files each. This will save time in making new allocations during transactions.
--    UNDER CONSTRUCTION			These are CFPs which hold new inserted or deleted rows after last checkpoint.
--    ACTIVE						This contains the rows from last closed checkpoint. This contains the rows which are needed when applying active part of transaction log at database restart.
--    MERGE_TARGET					This is marked during the merge operation. Once merge is complete they turn to ACTIVE.
--    MERGE_SOURCE					This is the source to which the target will be merged.
--    REQUIRED FOR BACKUP/HA		Once merge is complete and the table is durable, the source is marked to this state. This allows database consistency with backups.
--    IN TRANSITION TO TOMBSTONE	These are CFPs which are no longer needed and can be garbage collected.
--    TOMBSTONE						These are marked for garbage collection and waiting for filestream garbage collector.
-- lower_bound_tsn			The lower bound of the transaction sequence number. Used for merging the files.
-- upper_bound_tsn			The upper bound of the transaction sequence number. Used for merging the files.
-- 
----------------------------------------------------------------------------------------------

select *
from sys.dm_db_xtp_checkpoint_files;
go

-- Returns statistics about the In-Memory OLTP checkpoint operations in the current database. 
-- If the database has no In-Memory OLTP objects, returns an empty result set.
----------------------------------------------------------------------------------------------

select *
from sys.dm_db_xtp_checkpoint_stats;
go

-- These statistics are useful for understanding and tuning the bucket counts. It can also be 
-- used to detect cases where the index key has many duplicates.
--
-- A large average chain length indicates that many rows are hashed to the same bucket. 
-- This could happen because:
--
--		If the number of empty buckets is low or the average and maximum chain lengths are similar, 
--		it is likely that the total bucket count is too low. This causes many different index keys 
--		to hash to the same bucket.
--
--		If the number of empty buckets is high or the maximum chain length is high relative to 
--		the average chain length, it is likely that there are many rows with duplicate index key 
--		values or there is a skew in the key values. All rows with the same index key value hash 
--		to the same bucket, hence there is a long chain length in that bucket.
--
-- Long chain lengths can significantly impact the performance of all DML operations on 
-- individual rows, including SELECT and INSERT. Short chain lengths along with a high empty 
-- bucket count are in indication of a bucket_count that is too high. This decreases the 
-- performance of index scans
----------------------------------------------------------------------------------------------

select OBJECT_NAME(object_id) as name, 
	   index_id, 
	   total_bucket_count, 
	   empty_bucket_count, 
	   avg_chain_length, 
	   max_chain_length
from sys.dm_db_xtp_hash_index_stats;
go

-- 
-- rows_examined				Total number of rows checked by the garbage collector since the instance startup.
-- rows_no_sweep_needed			The rows which are less accessed are only cleaned by idle worker. This is also termed as dusty corner scan.
-- rows_first_in_bucket			Number of rows that are the first row in the hash bucket which are scanned.
-- rows_first_in_bucket_removed	Number of such first rows in hash bucket which are removed.
-- rows_marked_for_unlink		Number of rows which are marked as unlinked in their indexes. This is determined by checking refcount having 0.
-- parallel_assist_count		Number of garbage rows which are processed by the user transaction.
-- idle_worker_count			Number of garbage rows which are processed by the user transaction.
-- sweep_scans_started			Number of dusty corner scans that the idle worker has performed.
-- sweep_scans_retries			Retries of the dusty corner scans in case of any issues. High number for this may indicate problems for garbage collection subsystem.
-- sweep_rows_touched			Rows which are read by the idle thread during dusty corner scans.
-- sweep_rows_expiring			Number of expiring rows read by dusty corner processing.
-- sweep_rows_expired			Number of expired rows read by dusty corner processing.
-- sweep_rows_expired_removed	Number of expired rows removed by dusty corner processing.
----------------------------------------------------------------------------------------------

select *
from sys.dm_xtp_gc_stats;
go

-- Provides information (the overall statistics) about the current behavior of the 
-- In-Memory OLTP garbage-collection process.
--
-- Rows are garbage collected as part of regular transaction processing, or by the main 
-- garbage collection thread, which is referred to as the idle worker. When a user transaction 
-- commits, it dequeues one work item from the garbage collection queue 
-- (sys.dm_xtp_gc_queue_stats (Transact-SQL)). Any rows that could be garbage collected but 
-- were not accessed by main user transaction are garbage collected by the idle worker, as 
-- part of the dusty corner scan (a scan for areas of the index that are less accessed).
----------------------------------------------------------------------------------------------

select *
from sys.dm_xtp_gc_queue_stats;
go

-- Outputs the current state of committed transactions that have deleted one or more rows. 
-- The idle garbage collection thread wakes every minute or when the number of committed DML 
-- transactions exceeds an internal threshold since the last garbage collection cycle. 
-- As part of the garbage collection cycle, it moves the transactions that have committed into 
-- one or more queues associated with generations. The transactions that have generated stale 
-- versions are grouped in a unit of 16 transactions across 16 generations as follows:
--
--		Generation-0: This stores all transactions that committed earlier than the oldest 
--		active transaction. Row versions generated by these transactions are immediately 
--		available for garbage collection.
--
--		Generations 1-14: Stores transactions with timestamp greater than the oldest active 
--		transaction. The row versions cannot be garbage collected. Each generation can hold up 
--		to 16 transactions. A total of 224 (14 * 16) transactions can exist in these generations.
--
--		Generation 15: The remaining transactions with timestamp greater than the oldest active 
--		transaction go to generation 15. Similar to generation-0, there is no limit of number 
--		of transactions in generation-15.
--
-- When there is memory pressure, the garbage collection thread updates the oldest active 
-- transaction hint aggressively, which forces garbage collection.
----------------------------------------------------------------------------------------------

select cycle_id, 
	   ticks_at_cycle_start, 
	   ticks_at_cycle_end, 
	   base_generation, 
	   xacts_copied_to_local, 
	   xacts_in_gen_0, 
	   xacts_in_gen_1, 
	   xacts_in_gen_15
from sys.dm_db_xtp_gc_cycle_stats;
go

-- Returns memory usage statistics for each In-Memory OLTP table (user and system) in the 
-- current database. The system tables have negative object IDs and are used to store run-time 
-- information for the In-Memory OLTP engine. Unlike user objects, system tables are internal 
-- and only exist in-memory, therefore, they are not visible through catalog views. 
-- System tables are used to store information such as meta-data for all data/delta files in 
-- storage, merge requests, watermarks for delta files to filter rows, dropped tables, and 
-- relevant information for recovery and backups. Given that the In-Memory OLTP engine can 
-- have up to 8,192 data and delta file pairs, for large in-memory databases, the memory taken 
-- by system tables can be a few megabytes.
----------------------------------------------------------------------------------------------

select OBJECT_NAME(object_id) as tblName, 
	   memory_allocated_for_table_kb, 
	   memory_used_by_table_kb, 
	   memory_allocated_for_indexes_kb, 
	   memory_used_by_indexes_kb
from sys.dm_db_xtp_table_memory_stats;
go

-- sys.dm_db_xtp_nonclustered_index_stats includes statistics about operations on nonclustered 
-- indexes in memory-optimized tables. sys.dm_db_xtp_nonclustered_index_stats contains one row 
-- for each nonclustered index on a memory-optimized table in the current database.
----------------------------------------------------------------------------------------------

select OBJECT_NAME(xnis.object_id) as tableName, 
	   i.name as indName, 
	   delta_pages as deltaP, 
	   internal_pages as internalP, 
	   leaf_pages as leafP, 
	   outstanding_retired_nodes, 
	   page_update_count as pageUp, 
	   page_update_retry_count as pageUpRe, 
	   page_consolidation_count as pageCon, 
	   page_consolidation_retry_count as pageConRe, 
	   page_split_count as pageSpl, 
	   page_split_retry_count as pageSplRe, 
	   key_split_count as keySpl, 
	   key_split_retry_count as keySplRe, 
	   page_merge_count as pageMrg, 
	   page_merge_retry_count as pageMrgRe, 
	   key_merge_count as keyMrg, 
	   key_merge_retry_count as keyMrgRe
from sys.dm_db_xtp_nonclustered_index_stats as xnis
	 inner join sys.indexes as i on xnis.object_id = i.object_id
									and xnis.index_id = i.index_id;
go

-- Contains statistics collected since the last database restart
-- 
-- scans_started		As the name suggests this is number of scans started on the index. This also includes the scans for inserts. So this is not the measure of just the selects for direct selects, updates and deletes.
-- rows_returned		This is the rows returned by the storage engine by all scan operations. The filters at client level are not considered. Another important point is the scans for Insert does not return any rows. 
----------------------------------------------------------------------------------------------

select OBJECT_NAME(xis.object_id) as tableName, 
	   i.name as indName, 
	   scans_started, 
	   rows_returned
from sys.dm_db_xtp_index_stats as xis
	 inner join sys.indexes as i on i.object_id = xis.object_id
									and i.index_id = xis.index_id
where OBJECT_NAME(xis.object_id) like 'inMem%';
go