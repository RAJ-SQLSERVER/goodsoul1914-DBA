/****************
	Disable all jobs
****************/

DECLARE @JobId NVARCHAR(600);
DECLARE Cur CURSOR FOR
SELECT job_id
FROM msdb..sysjobs_view AS j
WHERE name NOT LIKE 'DBA%'
      AND name NOT IN ( 'CommandLog Cleanup', 'Output File Cleanup', 'sp_delete_backuphistory', 'sp_purge_jobhistory' )
      AND j.enabled = 1;

OPEN Cur;
FETCH Cur
INTO @JobId;
WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC msdb.dbo.sp_update_job @job_id = @JobId, @enabled = 0;
    FETCH Cur
    INTO @JobId;
END;

CLOSE Cur;
DEALLOCATE Cur;


/***************
	Enable all jobs
***************/

DECLARE @JobId NVARCHAR(600);
DECLARE Cur CURSOR FOR
SELECT job_id
FROM msdb..sysjobs_view AS j
WHERE name NOT LIKE 'DBA%'
      AND name NOT IN ( 'CommandLog Cleanup', 'Output File Cleanup', 'sp_delete_backuphistory', 'sp_purge_jobhistory' )
      AND j.enabled = 0;

OPEN Cur;
FETCH Cur
INTO @JobId;
WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC msdb.dbo.sp_update_job @job_id = @JobId, @enabled = 1;
    FETCH Cur
    INTO @JobId;
END;

CLOSE Cur;
DEALLOCATE Cur;