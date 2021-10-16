/*
Find out which agent jobs executed in a time frame
*/

USE msdb;
GO

DECLARE @StartCheckDateTime DATETIME = '2021-10-01 01:00:00';
DECLARE @EndCheckDateTime DATETIME = '2021-10-01 03:00:00';

SELECT sysjobs.name AS "JobName",
       sysjobhistory.step_name AS "JobStepName",
       sysjobhistory.step_id AS "JobStepId",
       Vars.StartDateTime,
       Vars2.EndDateTime,
       *
FROM msdb.dbo.sysjobhistory
JOIN msdb.dbo.sysjobs
    ON sysjobhistory.job_id = sysjobs.job_id
CROSS APPLY (
    SELECT msdb.dbo.agent_datetime (sysjobhistory.run_date, sysjobhistory.run_time) AS "StartDateTime",
           (sysjobhistory.run_duration / 10000 * 3600) /*Hours*/
           + ((sysjobhistory.run_duration % 10000) / 100 * 60) /*Minutes*/ + (sysjobhistory.run_duration % 100) /*Seconds*/ AS "RunDurationSec"
) AS Vars
CROSS APPLY (
    SELECT DATEADD (SECOND, Vars.RunDurationSec, Vars.StartDateTime) AS "EndDateTime"
) AS Vars2
WHERE Vars.StartDateTime <= @EndCheckDateTime
      AND Vars2.EndDateTime >= @StartCheckDateTime
      AND sysjobhistory.step_id <> 0;