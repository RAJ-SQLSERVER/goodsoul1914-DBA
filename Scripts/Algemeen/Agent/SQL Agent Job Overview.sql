-- SQL Server Agent Job Overview 
WITH sess
AS (
	SELECT session_id
	FROM msdb.dbo.syssessions AS SESS
	WHERE SESS.agent_start_date = (
			SELECT MAX(agent_start_date)
			FROM msdb.dbo.syssessions
			)
	),
hist
AS (
	SELECT JOBHIST.job_id,
		MAX(JOBHIST.run_date) AS LastExecutionDate,
		SUM(CASE 
				WHEN JOBHIST.run_status = 1
					THEN 1
				ELSE 0
				END) AS RunsSuccessfull,
		SUM(CASE 
				WHEN JOBHIST.run_status = 0
					THEN 1
				ELSE 0
				END) AS RunsError
	FROM msdb.dbo.sysjobhistory AS JOBHIST
	WHERE JOBHIST.step_id = 0
	GROUP BY JOBHIST.job_id
	),
lasthist
AS (
	SELECT LASTHIST.job_id,
		LASTHIST.run_status AS LastRunStatus
	FROM msdb.dbo.sysjobhistory AS LASTHIST
	WHERE LASTHIST.instance_id = (
			SELECT MAX(SUB.instance_id) AS MaxId
			FROM msdb.dbo.sysjobhistory AS SUB
			WHERE SUB.job_id = LASTHIST.job_id
			)
	)
SELECT JOB.name AS JobName,
	JOB.Description AS JobDescription,
	CAT.name AS Category,
	JOB.enabled AS IsJobEnabled,
	ISNULL(SCH.enabled, 0) AS IsScheduled,
	(
		SELECT COUNT(*)
		FROM msdb.dbo.sysjobsteps AS STP
		WHERE STP.job_id = JOB.job_id
		) AS StepsCnt,
	hist.RunsSuccessfull,
	hist.RunsError,
	CASE ISNULL(LASTACT.run_status, CASE 
				WHEN SJA.start_execution_date IS NULL
					THEN - 2
				ELSE - 1
				END)
		WHEN - 2
			THEN 'No recent activity'
		WHEN - 1
			THEN 'Is running'
		WHEN 0
			THEN 'Failed'
		WHEN 1
			THEN 'Succeeded'
		WHEN 2
			THEN 'Retry'
		WHEN 3
			THEN 'Canceled'
		WHEN 4
			THEN 'In progress'
		ELSE 'Unkown'
		END AS LastActivityStatus,
	CASE lasthist.LastRunStatus
		WHEN 0
			THEN 'Failed'
		WHEN 1
			THEN 'Succeeded'
		WHEN 2
			THEN 'Retry'
		WHEN 3
			THEN 'Canceled'
		WHEN 4
			THEN 'In progress'
		ELSE 'Unkown'
		END AS LastRunStatus,
	hist.LastExecutionDate,
	JSD.next_run_date AS NextScheduledRunDate
FROM msdb.dbo.sysjobs AS JOB
INNER JOIN msdb.dbo.syscategories AS CAT ON JOB.category_id = CAT.category_id
LEFT JOIN hist ON JOB.job_id = hist.job_id
LEFT JOIN msdb.dbo.sysjobschedules AS JSD ON JOB.job_id = JSD.job_id
LEFT JOIN msdb.dbo.sysschedules AS SCH ON JSD.schedule_id = SCH.schedule_id
CROSS APPLY sess
INNER JOIN msdb.dbo.sysjobactivity AS SJA ON JOB.job_id = SJA.job_id
	AND sess.session_id = SJA.session_id
LEFT JOIN msdb.dbo.sysjobhistory AS LASTACT ON SJA.job_history_id = LASTACT.instance_id
LEFT JOIN lasthist ON JOB.job_id = lasthist.job_id
ORDER BY JobName;
