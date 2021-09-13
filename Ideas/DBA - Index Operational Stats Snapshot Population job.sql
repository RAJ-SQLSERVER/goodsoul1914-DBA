USE [msdb]
GO

/****** Object:  Job [DBA - Index Operational Stats Snapshot Population]    Script Date: 13-9-2021 11:26:52 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 13-9-2021 11:26:52 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Index Operational Stats Snapshot Population', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'DT-RSD-01\mboom', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Index Operational Stats Snapshot Population]    Script Date: 13-9-2021 11:26:52 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Index Operational Stats Snapshot Population', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'INSERT INTO dbo.index_operational_stats_snapshot
SELECT GETDATE (),
       database_id,
       object_id,
       index_id,
       partition_number,
       leaf_insert_count,
       leaf_delete_count,
       leaf_update_count,
       leaf_ghost_count,
       nonleaf_insert_count,
       nonleaf_delete_count,
       nonleaf_update_count,
       leaf_allocation_count,
       nonleaf_allocation_count,
       leaf_page_merge_count,
       nonleaf_page_merge_count,
       range_scan_count,
       singleton_lookup_count,
       forwarded_fetch_count,
       lob_fetch_in_pages,
       lob_fetch_in_bytes,
       lob_orphan_create_count,
       lob_orphan_insert_count,
       row_overflow_fetch_in_pages,
       row_overflow_fetch_in_bytes,
       column_value_push_off_row_count,
       column_value_pull_in_row_count,
       row_lock_count,
       row_lock_wait_count,
       row_lock_wait_in_ms,
       page_lock_count,
       page_lock_wait_count,
       page_lock_wait_in_ms,
       index_lock_promotion_attempt_count,
       index_lock_promotion_count,
       page_latch_wait_count,
       page_latch_wait_in_ms,
       page_io_latch_wait_count,
       page_io_latch_wait_in_ms,
       tree_page_latch_wait_count,
       tree_page_latch_wait_in_ms,
       tree_page_io_latch_wait_count,
       tree_page_io_latch_wait_in_ms,
       page_compression_attempt_count,
       page_compression_success_count
FROM sys.dm_db_index_operational_stats (NULL, NULL, NULL, NULL);', 
		@database_name=N'IndexingMethod', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Index Operational Stats Snapshot Population - Step 2]    Script Date: 13-9-2021 11:26:52 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Index Operational Stats Snapshot Population - Step 2', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'WITH IndexOperationalCTE AS
(
    SELECT DENSE_RANK () OVER (ORDER BY create_date DESC) AS "HistoryID",
           create_date,
           database_id,
           object_id,
           index_id,
           partition_number,
           leaf_insert_count,
           leaf_delete_count,
           leaf_update_count,
           leaf_ghost_count,
           nonleaf_insert_count,
           nonleaf_delete_count,
           nonleaf_update_count,
           leaf_allocation_count,
           nonleaf_allocation_count,
           leaf_page_merge_count,
           nonleaf_page_merge_count,
           range_scan_count,
           singleton_lookup_count,
           forwarded_fetch_count,
           lob_fetch_in_pages,
           lob_fetch_in_bytes,
           lob_orphan_create_count,
           lob_orphan_insert_count,
           row_overflow_fetch_in_pages,
           row_overflow_fetch_in_bytes,
           column_value_push_off_row_count,
           column_value_pull_in_row_count,
           row_lock_count,
           row_lock_wait_count,
           row_lock_wait_in_ms,
           page_lock_count,
           page_lock_wait_count,
           page_lock_wait_in_ms,
           index_lock_promotion_attempt_count,
           index_lock_promotion_count,
           page_latch_wait_count,
           page_latch_wait_in_ms,
           page_io_latch_wait_count,
           page_io_latch_wait_in_ms,
           tree_page_latch_wait_count,
           tree_page_latch_wait_in_ms,
           tree_page_io_latch_wait_count,
           tree_page_io_latch_wait_in_ms,
           page_compression_attempt_count,
           page_compression_success_count
    FROM dbo.index_operational_stats_snapshot
)
INSERT INTO dbo.index_operational_stats_history
SELECT i1.create_date,
       i1.database_id,
       i1.object_id,
       i1.index_id,
       i1.partition_number,
       i1.leaf_insert_count - COALESCE (i2.leaf_insert_count, 0),
       i1.leaf_delete_count - COALESCE (i2.leaf_delete_count, 0),
       i1.leaf_update_count - COALESCE (i2.leaf_update_count, 0),
       i1.leaf_ghost_count - COALESCE (i2.leaf_ghost_count, 0),
       i1.nonleaf_insert_count - COALESCE (i2.nonleaf_insert_count, 0),
       i1.nonleaf_delete_count - COALESCE (i2.nonleaf_delete_count, 0),
       i1.nonleaf_update_count - COALESCE (i2.nonleaf_update_count, 0),
       i1.leaf_allocation_count - COALESCE (i2.leaf_allocation_count, 0),
       i1.nonleaf_allocation_count - COALESCE (i2.nonleaf_allocation_count, 0),
       i1.leaf_page_merge_count - COALESCE (i2.leaf_page_merge_count, 0),
       i1.nonleaf_page_merge_count - COALESCE (i2.nonleaf_page_merge_count, 0),
       i1.range_scan_count - COALESCE (i2.range_scan_count, 0),
       i1.singleton_lookup_count - COALESCE (i2.singleton_lookup_count, 0),
       i1.forwarded_fetch_count - COALESCE (i2.forwarded_fetch_count, 0),
       i1.lob_fetch_in_pages - COALESCE (i2.lob_fetch_in_pages, 0),
       i1.lob_fetch_in_bytes - COALESCE (i2.lob_fetch_in_bytes, 0),
       i1.lob_orphan_create_count - COALESCE (i2.lob_orphan_create_count, 0),
       i1.lob_orphan_insert_count - COALESCE (i2.lob_orphan_insert_count, 0),
       i1.row_overflow_fetch_in_pages - COALESCE (i2.row_overflow_fetch_in_pages, 0),
       i1.row_overflow_fetch_in_bytes - COALESCE (i2.row_overflow_fetch_in_bytes, 0),
       i1.column_value_push_off_row_count - COALESCE (i2.column_value_push_off_row_count, 0),
       i1.column_value_pull_in_row_count - COALESCE (i2.column_value_pull_in_row_count, 0),
       i1.row_lock_count - COALESCE (i2.row_lock_count, 0),
       i1.row_lock_wait_count - COALESCE (i2.row_lock_wait_count, 0),
       i1.row_lock_wait_in_ms - COALESCE (i2.row_lock_wait_in_ms, 0),
       i1.page_lock_count - COALESCE (i2.page_lock_count, 0),
       i1.page_lock_wait_count - COALESCE (i2.page_lock_wait_count, 0),
       i1.page_lock_wait_in_ms - COALESCE (i2.page_lock_wait_in_ms, 0),
       i1.index_lock_promotion_attempt_count - COALESCE (i2.index_lock_promotion_attempt_count, 0),
       i1.index_lock_promotion_count - COALESCE (i2.index_lock_promotion_count, 0),
       i1.page_latch_wait_count - COALESCE (i2.page_latch_wait_count, 0),
       i1.page_latch_wait_in_ms - COALESCE (i2.page_latch_wait_in_ms, 0),
       i1.page_io_latch_wait_count - COALESCE (i2.page_io_latch_wait_count, 0),
       i1.page_io_latch_wait_in_ms - COALESCE (i2.page_io_latch_wait_in_ms, 0),
       i1.tree_page_latch_wait_count - COALESCE (i2.tree_page_latch_wait_count, 0),
       i1.tree_page_latch_wait_in_ms - COALESCE (i2.tree_page_latch_wait_in_ms, 0),
       i1.tree_page_io_latch_wait_count - COALESCE (i2.tree_page_io_latch_wait_count, 0),
       i1.tree_page_io_latch_wait_in_ms - COALESCE (i2.tree_page_io_latch_wait_in_ms, 0),
       i1.page_compression_attempt_count - COALESCE (i2.page_compression_attempt_count, 0),
       i1.page_compression_success_count - COALESCE (i2.page_compression_success_count, 0)
FROM IndexOperationalCTE AS i1
LEFT OUTER JOIN IndexOperationalCTE AS i2
    ON i1.database_id = i2.database_id
       AND i1.object_id = i2.object_id
       AND i1.index_id = i2.index_id
       AND i1.partition_number = i2.partition_number
       AND i2.HistoryID = 2

       --Verify no rows are less than 0
       AND NOT (
               i1.leaf_insert_count - COALESCE (i2.leaf_insert_count, 0) < 0
               AND i1.leaf_delete_count - COALESCE (i2.leaf_delete_count, 0) < 0
               AND i1.leaf_update_count - COALESCE (i2.leaf_update_count, 0) < 0
               AND i1.leaf_ghost_count - COALESCE (i2.leaf_ghost_count, 0) < 0
               AND i1.nonleaf_insert_count - COALESCE (i2.nonleaf_insert_count, 0) < 0
               AND i1.nonleaf_delete_count - COALESCE (i2.nonleaf_delete_count, 0) < 0
               AND i1.nonleaf_update_count - COALESCE (i2.nonleaf_update_count, 0) < 0
               AND i1.leaf_allocation_count - COALESCE (i2.leaf_allocation_count, 0) < 0
               AND i1.nonleaf_allocation_count - COALESCE (i2.nonleaf_allocation_count, 0) < 0
               AND i1.leaf_page_merge_count - COALESCE (i2.leaf_page_merge_count, 0) < 0
               AND i1.nonleaf_page_merge_count - COALESCE (i2.nonleaf_page_merge_count, 0) < 0
               AND i1.range_scan_count - COALESCE (i2.range_scan_count, 0) < 0
               AND i1.singleton_lookup_count - COALESCE (i2.singleton_lookup_count, 0) < 0
               AND i1.forwarded_fetch_count - COALESCE (i2.forwarded_fetch_count, 0) < 0
               AND i1.lob_fetch_in_pages - COALESCE (i2.lob_fetch_in_pages, 0) < 0
               AND i1.lob_fetch_in_bytes - COALESCE (i2.lob_fetch_in_bytes, 0) < 0
               AND i1.lob_orphan_create_count - COALESCE (i2.lob_orphan_create_count, 0) < 0
               AND i1.lob_orphan_insert_count - COALESCE (i2.lob_orphan_insert_count, 0) < 0
               AND i1.row_overflow_fetch_in_pages - COALESCE (i2.row_overflow_fetch_in_pages, 0) < 0
               AND i1.row_overflow_fetch_in_bytes - COALESCE (i2.row_overflow_fetch_in_bytes, 0) < 0
               AND i1.column_value_push_off_row_count - COALESCE (i2.column_value_push_off_row_count, 0) < 0
               AND i1.column_value_pull_in_row_count - COALESCE (i2.column_value_pull_in_row_count, 0) < 0
               AND i1.row_lock_count - COALESCE (i2.row_lock_count, 0) < 0
               AND i1.row_lock_wait_count - COALESCE (i2.row_lock_wait_count, 0) < 0
               AND i1.row_lock_wait_in_ms - COALESCE (i2.row_lock_wait_in_ms, 0) < 0
               AND i1.page_lock_count - COALESCE (i2.page_lock_count, 0) < 0
               AND i1.page_lock_wait_count - COALESCE (i2.page_lock_wait_count, 0) < 0
               AND i1.page_lock_wait_in_ms - COALESCE (i2.page_lock_wait_in_ms, 0) < 0
               AND i1.index_lock_promotion_attempt_count - COALESCE (i2.index_lock_promotion_attempt_count, 0) < 0
               AND i1.index_lock_promotion_count - COALESCE (i2.index_lock_promotion_count, 0) < 0
               AND i1.page_latch_wait_count - COALESCE (i2.page_latch_wait_count, 0) < 0
               AND i1.page_latch_wait_in_ms - COALESCE (i2.page_latch_wait_in_ms, 0) < 0
               AND i1.page_io_latch_wait_count - COALESCE (i2.page_io_latch_wait_count, 0) < 0
               AND i1.page_io_latch_wait_in_ms - COALESCE (i2.page_io_latch_wait_in_ms, 0) < 0
               AND i1.tree_page_latch_wait_count - COALESCE (i2.tree_page_latch_wait_count, 0) < 0
               AND i1.tree_page_latch_wait_in_ms - COALESCE (i2.tree_page_latch_wait_in_ms, 0) < 0
               AND i1.tree_page_io_latch_wait_count - COALESCE (i2.tree_page_io_latch_wait_count, 0) < 0
               AND i1.tree_page_io_latch_wait_in_ms - COALESCE (i2.tree_page_io_latch_wait_in_ms, 0) < 0
               AND i1.page_compression_attempt_count - COALESCE (i2.page_compression_attempt_count, 0) < 0
               AND i1.page_compression_success_count - COALESCE (i2.page_compression_success_count, 0) < 0
           )
WHERE i1.HistoryID = 1
      --Only include rows are greater than 0
      AND (
          i1.leaf_insert_count - COALESCE (i2.leaf_insert_count, 0) > 0
          OR i1.leaf_delete_count - COALESCE (i2.leaf_delete_count, 0) > 0
          OR i1.leaf_update_count - COALESCE (i2.leaf_update_count, 0) > 0
          OR i1.leaf_ghost_count - COALESCE (i2.leaf_ghost_count, 0) > 0
          OR i1.nonleaf_insert_count - COALESCE (i2.nonleaf_insert_count, 0) > 0
          OR i1.nonleaf_delete_count - COALESCE (i2.nonleaf_delete_count, 0) > 0
          OR i1.nonleaf_update_count - COALESCE (i2.nonleaf_update_count, 0) > 0
          OR i1.leaf_allocation_count - COALESCE (i2.leaf_allocation_count, 0) > 0
          OR i1.nonleaf_allocation_count - COALESCE (i2.nonleaf_allocation_count, 0) > 0
          OR i1.leaf_page_merge_count - COALESCE (i2.leaf_page_merge_count, 0) > 0
          OR i1.nonleaf_page_merge_count - COALESCE (i2.nonleaf_page_merge_count, 0) > 0
          OR i1.range_scan_count - COALESCE (i2.range_scan_count, 0) > 0
          OR i1.singleton_lookup_count - COALESCE (i2.singleton_lookup_count, 0) > 0
          OR i1.forwarded_fetch_count - COALESCE (i2.forwarded_fetch_count, 0) > 0
          OR i1.lob_fetch_in_pages - COALESCE (i2.lob_fetch_in_pages, 0) > 0
          OR i1.lob_fetch_in_bytes - COALESCE (i2.lob_fetch_in_bytes, 0) > 0
          OR i1.lob_orphan_create_count - COALESCE (i2.lob_orphan_create_count, 0) > 0
          OR i1.lob_orphan_insert_count - COALESCE (i2.lob_orphan_insert_count, 0) > 0
          OR i1.row_overflow_fetch_in_pages - COALESCE (i2.row_overflow_fetch_in_pages, 0) > 0
          OR i1.row_overflow_fetch_in_bytes - COALESCE (i2.row_overflow_fetch_in_bytes, 0) > 0
          OR i1.column_value_push_off_row_count - COALESCE (i2.column_value_push_off_row_count, 0) > 0
          OR i1.column_value_pull_in_row_count - COALESCE (i2.column_value_pull_in_row_count, 0) > 0
          OR i1.row_lock_count - COALESCE (i2.row_lock_count, 0) > 0
          OR i1.row_lock_wait_count - COALESCE (i2.row_lock_wait_count, 0) > 0
          OR i1.row_lock_wait_in_ms - COALESCE (i2.row_lock_wait_in_ms, 0) > 0
          OR i1.page_lock_count - COALESCE (i2.page_lock_count, 0) > 0
          OR i1.page_lock_wait_count - COALESCE (i2.page_lock_wait_count, 0) > 0
          OR i1.page_lock_wait_in_ms - COALESCE (i2.page_lock_wait_in_ms, 0) > 0
          OR i1.index_lock_promotion_attempt_count - COALESCE (i2.index_lock_promotion_attempt_count, 0) > 0
          OR i1.index_lock_promotion_count - COALESCE (i2.index_lock_promotion_count, 0) > 0
          OR i1.page_latch_wait_count - COALESCE (i2.page_latch_wait_count, 0) > 0
          OR i1.page_latch_wait_in_ms - COALESCE (i2.page_latch_wait_in_ms, 0) > 0
          OR i1.page_io_latch_wait_count - COALESCE (i2.page_io_latch_wait_count, 0) > 0
          OR i1.page_io_latch_wait_in_ms - COALESCE (i2.page_io_latch_wait_in_ms, 0) > 0
          OR i1.tree_page_latch_wait_count - COALESCE (i2.tree_page_latch_wait_count, 0) > 0
          OR i1.tree_page_latch_wait_in_ms - COALESCE (i2.tree_page_latch_wait_in_ms, 0) > 0
          OR i1.tree_page_io_latch_wait_count - COALESCE (i2.tree_page_io_latch_wait_count, 0) > 0
          OR i1.tree_page_io_latch_wait_in_ms - COALESCE (i2.tree_page_io_latch_wait_in_ms, 0) > 0
          OR i1.page_compression_attempt_count - COALESCE (i2.page_compression_attempt_count, 0) > 0
          OR i1.page_compression_success_count - COALESCE (i2.page_compression_success_count, 0) > 0
      );', 
		@database_name=N'IndexingMethod', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 4 hours', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=4, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20210910, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'e330391a-dcd0-470b-9ecd-58e630f02aec'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


