USE msdb;
GO
SELECT JOB.name AS "JobName",
       CASE
           WHEN JOB.enabled = 1 THEN 'Enable'
           ELSE 'Disable'
       END AS "JobStatus",
       JOB.description AS "Job_Description",
       SCH.name AS "ScheduleName",
       CASE
           WHEN SCH.enabled = 1 THEN 'Enable'
           WHEN SCH.enabled = 0 THEN 'Disable'
           ELSE 'Not Schedule'
       END AS "ScheduleStatus",
       SCH.active_start_date,
       SCH.active_end_date,
       SCH.active_start_time,
       SCH.active_end_time
FROM dbo.sysjobs AS JOB
LEFT JOIN dbo.sysjobschedules AS JS
    ON JOB.job_id = JS.job_id
LEFT JOIN dbo.sysschedules AS SCH
    ON JS.schedule_id = SCH.schedule_id;