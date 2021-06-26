;WITH jobListCTE
AS (
	SELECT j.name AS job_name
		,msdb.dbo.agent_datetime(run_date, run_time) AS run_datetime
		,RIGHT('000000' + CONVERT(VARCHAR(6), run_duration), 6) AS run_duration
		,message
	FROM msdb..sysjobhistory h
	INNER JOIN msdb..sysjobs j ON h.job_id = j.job_id
	WHERE h.step_name = '(Job outcome)'
	)
SELECT job_name AS [JobStep]
	,run_datetime AS [StartDateTime]
	,SUBSTRING(run_duration, 1, 2) + ':' + SUBSTRING(run_duration, 3, 2) + ':' + SUBSTRING(run_duration, 5, 2) AS [Duration]
	,message
FROM jobListCTE
ORDER BY run_datetime DESC
	,job_name;
