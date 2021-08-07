/* query to find SQL Agent jobs that are using a large amount of space in job step log table "sysjobstepslogs"
   tested on SQL Server 2016 (but will most likely work on 2012+) */
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT  /* SQL Agent job name */
		[job_name] = J.[name],
		/* SQL Agent job step identifier and name */
		S.[step_id], S.[step_name],
		/* "Size of the job step log in bytes" - rough conversion to MB */
		[log_size (MB)] = L.[log_size]/1024/1024,
		/* generate script which can be run to remove job step log */
		[clean up script] = 'EXEC msdb..sp_delete_jobsteplog @job_name = N''' + J.[name] + ''', @step_name = N''' + S.[step_name] + ''';'
FROM    msdb..sysjobs J INNER JOIN
		    msdb..sysjobsteps S ON
			    J.[job_id] = S.[job_id] INNER JOIN
			msdb..sysjobstepslogs L ON
				S.[step_uid] = L.[step_uid]
WHERE   /* job step log greater than 50MB - remove to see all */
		L.[log_size]/1024/1024 > 50
ORDER BY L.[log_size] DESC