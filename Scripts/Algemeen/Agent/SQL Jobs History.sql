-- job_ids with job steps showing last run date/time 
-- before and after conversion for display
SELECT sysjobsteps.job_id,
	sysjobsteps.step_id,
	sysjobsteps.step_name,
	sysjobsteps.last_run_date,
	LEFT(CAST(sysjobsteps.last_run_date AS VARCHAR), 4) + '-' + SUBSTRING(CAST(sysjobsteps.last_run_date AS VARCHAR), 5, 2) + '-' + SUBSTRING(CAST(sysjobsteps.last_run_date AS VARCHAR), 7, 2) AS converted_last_run_date,
	sysjobsteps.last_run_time,
	CASE 
		WHEN LEN(CAST(sysjobsteps.last_run_time AS VARCHAR)) = 6
			THEN SUBSTRING(CAST(sysjobsteps.last_run_time AS VARCHAR), 1, 2) + ':' + SUBSTRING(CAST(sysjobsteps.last_run_time AS VARCHAR), 3, 2) + ':' + SUBSTRING(CAST(sysjobsteps.last_run_time AS VARCHAR), 5, 2)
		WHEN LEN(CAST(sysjobsteps.last_run_time AS VARCHAR)) = 5
			THEN '0' + SUBSTRING(CAST(sysjobsteps.last_run_time AS VARCHAR), 1, 1) + ':' + SUBSTRING(CAST(sysjobsteps.last_run_time AS VARCHAR), 2, 2) + ':' + SUBSTRING(CAST(sysjobsteps.last_run_time AS VARCHAR), 4, 2)
		WHEN LEN(CAST(sysjobsteps.last_run_time AS VARCHAR)) = 4
			THEN '00:' + SUBSTRING(CAST(sysjobsteps.last_run_time AS VARCHAR), 1, 2) + ':' + SUBSTRING(CAST(sysjobsteps.last_run_time AS VARCHAR), 3, 2)
		WHEN LEN(CAST(sysjobsteps.last_run_time AS VARCHAR)) = 3
			THEN '00:' + '0' + SUBSTRING(CAST(sysjobsteps.last_run_time AS VARCHAR), 1, 1) + ':' + SUBSTRING(CAST(sysjobsteps.last_run_time AS VARCHAR), 2, 2)
		WHEN LEN(CAST(sysjobsteps.last_run_time AS VARCHAR)) = 2
			THEN '00:00:' + CAST(sysjobsteps.last_run_time AS VARCHAR)
		WHEN LEN(CAST(sysjobsteps.last_run_time AS VARCHAR)) = 1
			THEN '00:00:' + '0' + CAST(sysjobsteps.last_run_time AS VARCHAR)
		END AS converted_last_run_time
FROM msdb.dbo.sysjobsteps
ORDER BY job_id,
	step_id;
