SELECT sj.name,
       sjh.message,
       sjh.run_status,
       sjh.run_date,
       sjh.run_time,
       sjh.run_duration,
       ROUND (ajt.average_run_duration, 2) AS "avg_run_duration"
FROM msdb..sysjobhistory AS sjh
LEFT JOIN (
    SELECT job_id,
           AVG (CAST(run_duration AS FLOAT)) AS "average_run_duration"
    FROM msdb..sysjobhistory
    WHERE step_id = 0
    GROUP BY job_id
) AS ajt
    ON sjh.job_id = ajt.job_id
JOIN msdb..sysjobs AS sj
    ON sj.job_id = sjh.job_id
WHERE step_id = 0
      AND instance_id IN ( SELECT MAX (instance_id) FROM msdb..sysjobhistory GROUP BY job_id ) --comment next line to see all jobs else only the jobs which have run yesterday 
--and sjh.run_date >CONVERT(varchar(8),GETDATE()-1,112)  
ORDER BY name;
