-- list of jobs; selected info about jobs
SELECT job_id,
	name,
	enabled,
	date_created,
	date_modified
FROM msdb.dbo.sysjobs
ORDER BY date_created;
