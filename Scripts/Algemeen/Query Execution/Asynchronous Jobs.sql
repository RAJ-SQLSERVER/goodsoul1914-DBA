-- Returns a Row For Each Query Processor Job that is scheduled for asynchronous 
-- (background) execution.
--
-- time_queued		time when the job is queued.
-- database_id		database on which this job will execute.
-- object_id		1 to 4 -> Currently used 1 and 2 for object id and statistics id. 
--							  3 and 4 are for internal use.
-- Error_code		Last error code only if reinserted due to failure.
-- Retry_count		Number of times the job is reinserted due to any failures or lack of resources.
-- In_progress		started = 1, queued and waiting = 0.
-- Session_id		to relate to session_id in sys.dm_exec_sessions.
-- 
---------------------------------------------------------------------------------------------------

SELECT time_queued,
       job_id,
       database_id,
       object_id1,
       object_id2,
       object_id3,
       object_id4,
       error_code,
       request_type,
       retry_count,
       in_progress,
       session_id
FROM sys.dm_exec_background_job_queue;
GO

-- Returns a row that provides aggregate statistics for each query processor job submitted for 
-- asynchronous (background) execution.
-- 
-- queue_max_len					Length of the background job queue.
-- enqueued_count					Total number of requests queued to the queue.
-- started_count					Number of requests started execution. There can be few which are queued but never started due to resource crunch or other reasons.
-- ended_count						requests either ended successfully or failed.
-- failed_lock_count				requests failed due to blocking or deadlock.
-- failed_other_count				requests failed due to other reasons.
-- failed_giveup_count				requests failed after retrying the limited number of times.
-- enqueued_failed_full_count		Number of failures because of queue being full.
-- enqueued_failed_duplicate_count	Number of attempts which are duplicated as previous request is already in queue.
-- elapsed_avg_time					Average time for requests in the queue (ms).
-- elapsed_max_ms					The maximum time taken by any request in the queue.
-- 
---------------------------------------------------------------------------------------------------

SELECT queue_max_len,
       enqueued_count,
       started_count,
       ended_count,
       failed_lock_count,
       failed_other_count,
       failed_giveup_count,
       enqueue_failed_full_count,
       enqueue_failed_duplicate_count,
       elapsed_avg_ms,
       elapsed_max_ms
FROM sys.dm_exec_background_job_queue_stats;
GO