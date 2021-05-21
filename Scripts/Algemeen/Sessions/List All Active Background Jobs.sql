/*
 List All Active Background Jobs
*/

select time_queued as JobCreationTime, 
	   session_id as SessionID, 
	   job_id as JobID, 
	   database_id as DatabaseID, 
	   request_type as RequestType, 
	   in_progress as InProgress
from sys.dm_exec_background_job_queue;


-- KILL STATS JOB 60 -- Change 60 to your sessionid