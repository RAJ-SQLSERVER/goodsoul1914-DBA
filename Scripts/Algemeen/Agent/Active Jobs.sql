-- Overview of running jobs incl. time elapsed
---------------------------------------------------------------------------------------------------
CREATE TABLE #enum_job
(
    Job_ID UNIQUEIDENTIFIER,
    Last_Run_Date INT,
    Last_Run_Time INT,
    Next_Run_Date INT,
    Next_Run_Time INT,
    Next_Run_Schedule_ID INT,
    Requested_To_Run INT,
    Request_Source INT,
    Request_Source_ID VARCHAR(100),
    Running INT,
    Current_Step INT,
    Current_Retry_Attempt INT,
    STATE INT
);

INSERT INTO #enum_job
EXEC master.dbo.xp_sqlagent_enum_jobs 1, garbage;

SELECT R.name,
       R.last_run_date,
       R.RunningForTime,
       GETDATE() AS NOW
FROM #enum_job AS a
    INNER JOIN
    (
        SELECT j.name,
               j.job_id,
               ja.run_requested_date AS last_run_date,
               DATEDIFF(mi, ja.run_requested_date, GETDATE()) AS RunningFor,
               CASE LEN(CONVERT(VARCHAR(5), DATEDIFF(MI, ja.run_requested_date, GETDATE()) / 60))
                   WHEN 1 THEN
                       '0' + CONVERT(VARCHAR(5), DATEDIFF(mi, ja.run_requested_date, GETDATE()) / 60)
                   ELSE
                       CONVERT(VARCHAR(5), DATEDIFF(mi, ja.run_requested_date, GETDATE()) / 60)
               END + ':' + CASE LEN(CONVERT(VARCHAR(5), DATEDIFF(MI, ja.run_requested_date, GETDATE()) % 60))
                               WHEN 1 THEN
                                   '0' + CONVERT(VARCHAR(5), DATEDIFF(mi, ja.run_requested_date, GETDATE()) % 60)
                               ELSE
                                   CONVERT(VARCHAR(5), DATEDIFF(mi, ja.run_requested_date, GETDATE()) % 60)
                           END + ':'
               + CASE LEN(CONVERT(VARCHAR(5), DATEDIFF(SS, ja.run_requested_date, GETDATE()) % 60))
                     WHEN 1 THEN
                         '0' + CONVERT(VARCHAR(5), DATEDIFF(ss, ja.run_requested_date, GETDATE()) % 60)
                     ELSE
                         CONVERT(VARCHAR(5), DATEDIFF(ss, ja.run_requested_date, GETDATE()) % 60)
                 END AS RunningForTime
        FROM msdb.dbo.sysjobactivity AS ja
            LEFT OUTER JOIN msdb.dbo.sysjobhistory AS jh
                ON ja.job_history_id = jh.instance_id
            INNER JOIN msdb.dbo.sysjobs_view AS j
                ON ja.job_id = j.job_id
        WHERE ja.session_id =
        (
            SELECT MAX(session_id) AS EXPR1 FROM msdb.dbo.sysjobactivity
        )
    ) AS R
        ON R.job_id = a.Job_ID
           AND a.Running = 1;

DROP TABLE #enum_job;
GO

-- Overview of running jobs
---------------------------------------------------------------------------------------------------
SELECT ja.job_id,
       j.name AS job_name,
       ja.start_execution_date,
       ISNULL(last_executed_step_id, 0) + 1 AS current_executed_step_id,
       js.step_name
FROM msdb.dbo.sysjobactivity AS ja
    LEFT JOIN msdb.dbo.sysjobhistory AS jh
        ON ja.job_history_id = jh.instance_id
    JOIN msdb.dbo.sysjobs AS j
        ON ja.job_id = j.job_id
    JOIN msdb.dbo.sysjobsteps AS js
        ON ja.job_id = js.job_id
           AND ISNULL(ja.last_executed_step_id, 0) + 1 = js.step_id
WHERE ja.session_id =
(
    SELECT TOP 1
           session_id
    FROM msdb.dbo.syssessions
    ORDER BY agent_start_date DESC
)
      AND start_execution_date IS NOT NULL
      AND stop_execution_date IS NULL;
