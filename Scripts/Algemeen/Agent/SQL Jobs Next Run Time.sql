-- schedule_id, job_ids showing next run date/time with conversion for display
SELECT schedule_id,
	job_id,
	LEFT(CAST(next_run_date AS VARCHAR), 4) + '-' + SUBSTRING(CAST(next_run_date AS VARCHAR), 5, 2) + '-' + SUBSTRING(CAST(next_run_date AS VARCHAR), 7, 2) AS next_run_date,
	CASE 
		WHEN LEN(CAST(next_run_time AS VARCHAR)) = 6
			THEN SUBSTRING(CAST(next_run_time AS VARCHAR), 1, 2) + ':' + SUBSTRING(CAST(next_run_time AS VARCHAR), 3, 2) + ':' + SUBSTRING(CAST(next_run_time AS VARCHAR), 5, 2)
		WHEN LEN(CAST(next_run_time AS VARCHAR)) = 5
			THEN '0' + SUBSTRING(CAST(next_run_time AS VARCHAR), 1, 1) + ':' + SUBSTRING(CAST(next_run_time AS VARCHAR), 2, 2) + ':' + SUBSTRING(CAST(next_run_time AS VARCHAR), 4, 2)
		WHEN LEN(CAST(next_run_time AS VARCHAR)) = 4
			THEN '00:' + SUBSTRING(CAST(next_run_time AS VARCHAR), 1, 2) + ':' + SUBSTRING(CAST(next_run_time AS VARCHAR), 3, 2)
		WHEN LEN(CAST(next_run_time AS VARCHAR)) = 3
			THEN '00:' + '0' + SUBSTRING(CAST(next_run_time AS VARCHAR), 1, 1) + ':' + SUBSTRING(CAST(next_run_time AS VARCHAR), 2, 2)
		WHEN LEN(CAST(next_run_time AS VARCHAR)) = 2
			THEN '00:00:' + CAST(next_run_time AS VARCHAR)
		WHEN LEN(CAST(next_run_time AS VARCHAR)) = 1
			THEN '00:00:' + '0' + CAST(next_run_time AS VARCHAR)
		END AS next_run_time
FROM msdb.dbo.sysjobschedules
ORDER BY job_id;
