use [master];
go

/**************************************************************
Author: Adrian Buckman
Last Revision: David Fowler
Revision date: 12/08/2019
Version: 3

www.sqlundercover.com 
**************************************************************/

create procedure sp_FailedJobs
(
	@FromDate datetime = null, 
	@ToDate   datetime = null) 
as
begin

	if @FromDate is null
	begin
		set @FromDate = DATEADD(Minute, -720, GETDATE());
	end;
	if @ToDate is null
	begin
		set @ToDate = GETDATE();
	end;

	select Jobs.name, 
		   Jobs.job_id, 
		   JobHistory.step_id, 
		   JobHistory.FailedRunDate, 
		   CAST(JobHistory.LastError as varchar(250)) as LastError
	from msdb.dbo.sysjobs as Jobs
	-- Get the most recent Failure Datetime for each failed job within @FromDate and @ToDate
		 cross apply
	(
		select top 1 JobHistory.step_id, 
					 JobHistory.run_date,
					 case JobHistory.run_date
						 when 0 then null
								else CONVERT(datetime, STUFF(STUFF(CAST(JobHistory.run_date as nchar(8)), 7, 0, '-'), 5, 0, '-') + N' ' + STUFF(STUFF(SUBSTRING(CAST(1000000 + JobHistory.run_time as nchar(7)), 2, 6), 5, 0, ':'), 3, 0, ':'), 120)
					 end as FailedRunDate, 
					 message as LastError
		from msdb.dbo.sysjobhistory as JobHistory
		where run_status = 0
			  and Jobs.job_id = JobHistory.job_id
		order by FailedRunDate desc, 
				 step_id desc
	) as JobHistory
	where Jobs.enabled = 1
		  and JobHistory.FailedRunDate >= @FromDate
		  and JobHistory.FailedRunDate <= @ToDate  
		  -- Check that each job has not succeeded since the last failure
		  and not exists
	(
		select LastSuccessfulrunDate
		from
		(
			select case JobHistory.run_date
					   when 0 then null
				   else CONVERT(datetime, STUFF(STUFF(CAST(JobHistory.run_date as nchar(8)), 7, 0, '-'), 5, 0, '-') + N' ' + STUFF(STUFF(SUBSTRING(CAST(1000000 + JobHistory.run_time as nchar(7)), 2, 6), 5, 0, ':'), 3, 0, ':'), 120)
				   end as LastSuccessfulrunDate
			from msdb.dbo.sysjobhistory as JobHistory
			where run_status = 1
				  and Jobs.job_id = JobHistory.job_id
		) as JobHistory2
		where JobHistory2.LastSuccessfulrunDate > JobHistory.FailedRunDate
	)  
		  -- Ensure that the job is not currently running  
		  and not exists
	(
		select session_id
		from msdb.dbo.sysjobactivity as JobActivity
		where Jobs.job_id = JobActivity.job_id
			  and stop_execution_date is null
			  and session_id =
		(
			select MAX(session_id)
			from msdb.dbo.sysjobactivity as JobActivity
			where Jobs.job_id = JobActivity.job_id
		)
	)  
		  -- Only show failed jobs where the Failed step is NOT configured to quit reporting success on error  
		  and not exists
	(
		select 1
		from msdb..sysjobsteps as ReportingSuccessSteps
		where Jobs.job_id = ReportingSuccessSteps.job_id
			  and JobHistory.step_id = ReportingSuccessSteps.step_id
			  and on_fail_action = 1 -- quit job reporting success
	)
	order by name asc;
end;