--	DROP TABLE  dbo.SqlAgentJobs
--	TRUNCATE TABLE  dbo.SqlAgentJobs

create table dbo.SqlAgentJobs
(
	ID                           int identity(1, 1), 
	JobName                      varchar(255) not null, 
	Instance_Id                  bigint, 
	[Expected-Max-Duration(Min)] bigint, 
	Ignore                       bit default 0, 
	[Running Since]              datetime2, 
	[Running Since(Hrs)] as CAST(DATEDIFF(MINUTE, [Running Since], GETDATE()) / 60 as numeric(20, 1)), 
	[<3-Hrs]                     bigint, 
	[3-Hrs]                      bigint, 
	[6-Hrs]                      bigint, 
	[9-Hrs]                      bigint, 
	[12-Hrs]                     bigint, 
	[18-Hrs]                     bigint, 
	[24-Hrs]                     bigint, 
	[36-Hrs]                     bigint, 
	[48-Hrs]                     bigint, 
	CollectionTime               datetime2 default GETDATE());
go

--alter table dbo.SqlAgentJobs alter column [Running Since(Hrs)] as CAST(datediff(MINUTE,[Running Since],getdate())/60 AS numeric(20,1))
--go

--INSERT dbo.SqlAgentJobs
--(JobName, [Expected-Max-Duration(Min)],[Ignore])
--SELECT	[JobName] = j.name, 
--		[Expected-Max-Duration(Min)] = AVG( ((run_duration/10000*3600 + (run_duration/100)%100*60 + run_duration%100 + 31 ) / 60) ),
--		[Ignore] = (CASE WHEN EXISTS (select  v.name as jobname, c.name as category from msdb.dbo.sysjobs_view as v left join msdb.dbo.syscategories as c on c.category_id = v.category_id where c.name like 'repl%' AND v.name = j.name) then 1 else 0 end)
--FROM	msdb.dbo.sysjobhistory AS h
--INNER JOIN msdb.dbo.sysjobs AS j
--	ON	h.job_id = j.job_id
--WHERE	h.step_id = 0
--AND j.name NOT IN (select t.JobName from dbo.SqlAgentJobs as t)
--GROUP BY j.name
--ORDER BY [Expected-Max-Duration(Min)] DESC;
--GO

--update dbo.SqlAgentJobs
--set [Expected-Max-Duration(Min)] = 180
--where Ignore = 0
--and [Expected-Max-Duration(Min)] > 180

--update dbo.SqlAgentJobs
--set Ignore = 1
--where JobName like 'DBA%'

--SELECT * 
--FROM dbo.SqlAgentJobs 
--where Ignore = 0


--select * FROM dbo.SqlAgentJobs where Ignore = 0;

set nocount on;

if OBJECT_ID('tempdb..#JobPastHistory') is not null
	drop table #JobPastHistory;;
with t_history
	 as (
	
/*******************************************************
 Find Job Execution History more recent from Base Table 
*******************************************************/

	 select j.name as JobName, 
			h.instance_id, 
			h.run_date, 
			Total_mins = ( run_duration / 10000 ) * 60 + ( run_duration / 100 % 100 ) + ( case
																							  when run_duration % 100 > 29 then 1
																						  else 0
																						  end )
	 from msdb..sysjobs as j
		  inner join msdb..sysjobhistory as h on h.job_id = j.job_id
	 where step_id = 0
		   and exists (select 1
					   from dbo.SqlAgentJobs as b
					   where b.JobName = j.name
							 and b.Ignore = 0
							 and h.instance_id > ISNULL(b.instance_id, 0)) )
	 select *, 
			TimeRange = case
							when Total_mins / 60 >= 48 then '48-Hrs'
							when Total_mins / 60 >= 36 then '36-Hrs'
							when Total_mins / 60 >= 24 then '24-Hrs'
							when Total_mins / 60 >= 18 then '18-Hrs'
							when Total_mins / 60 >= 12 then '12-Hrs'
							when Total_mins / 60 >= 9 then '9-Hrs'
							when Total_mins / 60 >= 6 then '6-Hrs'
							when Total_mins / 60 >= 3 then '3-Hrs'
						else '<3-Hrs'
						end
	 into #JobPastHistory
	 from t_history;

if OBJECT_ID('tempdb..#JobActivityMonitor') is not null
	drop table #JobActivityMonitor;;
with t_pivot
	 as (select JobName, 
				[<3-Hrs], 
				[3-Hrs], 
				[6-Hrs], 
				[9-Hrs], 
				[12-Hrs], 
				[18-Hrs], 
				[24-Hrs], 
				[36-Hrs], 
				[48-Hrs]
		 from (select JobName, 
					  instance_id, 
					  TimeRange
			   from #JobPastHistory) as up pivot(COUNT(instance_id) for TimeRange in([<3-Hrs], 
																					 [3-Hrs], 
																					 [6-Hrs], 
																					 [9-Hrs], 
																					 [12-Hrs], 
																					 [18-Hrs], 
																					 [24-Hrs], 
																					 [36-Hrs], 
																					 [48-Hrs])) as pvt),
	 t_history_info
	 as (select jp.JobName, 
				jh.max_instance_id as instance_id, 
				[<3-Hrs], 
				[3-Hrs], 
				[6-Hrs], 
				[9-Hrs], 
				[12-Hrs], 
				[18-Hrs], 
				[24-Hrs], 
				[36-Hrs], 
				[48-Hrs]
		 from t_pivot as jp
			  join (select JobName, 
						   MAX(instance_id) as max_instance_id
					from #JobPastHistory
					group by JobName) as jh on jp.JobName = jh.JobName),
	 t_jobActivityMonitor
	 as (select ja.job_id, 
				j.name as JobName, 
				ja.start_execution_date, 
				ISNULL(last_executed_step_id, 0) + 1 as current_executed_step_id, 
				Js.step_name
		 from msdb.dbo.sysjobactivity as ja
			  left join msdb.dbo.sysjobhistory as jh on ja.job_history_id = jh.instance_id
			  join msdb.dbo.sysjobs as j on ja.job_id = j.job_id
			  join msdb.dbo.sysjobsteps as js on ja.job_id = js.job_id
												 and ISNULL(ja.last_executed_step_id, 0) + 1 = js.step_id
		 where ja.session_id = (select top 1 session_id
								from msdb.dbo.syssessions
								order by agent_start_date desc)
			   and start_execution_date is not null
			   and stop_execution_date is null)
	 select JobName = COALESCE(a.JobName, h.JobName), 
			h.instance_id, 
			[Running Since] = a.start_execution_date, 
			[<3-Hrs], 
			[3-Hrs], 
			[6-Hrs], 
			[9-Hrs], 
			[12-Hrs], 
			[18-Hrs], 
			[24-Hrs], 
			[36-Hrs], 
			[48-Hrs]
	 into #JobActivityMonitor
	 from t_jobActivityMonitor as a
		  full outer join t_history_info as h on h.JobName = a.JobName;

-- Step 01 - Remove Previous Running Jobs ([Running Since] = NULL)
update dbo.SqlAgentJobs
set [Running Since] = null
where [Running Since] is not null;

-- Step 02 - Update table with current Running Jobs
update b
set [Running Since] = a.[Running Since]
from dbo.SqlAgentJobs b
	 join #JobActivityMonitor a on a.JobName = b.JobName
								   and a.[Running Since] is not null;

-- Step 03 - Update other columns like Instance_Id, [<3-Hrs], [3-Hrs], [6-Hrs], [9-Hrs], [18-Hrs], [24-Hrs], [36-Hrs], [48-Hrs]
update b
set Instance_Id = a.instance_id, [<3-Hrs] = ISNULL(b.[<3-Hrs], 0) + ISNULL(a.[<3-Hrs], 0), [3-Hrs] = ISNULL(b.[3-Hrs], 0) + ISNULL(a.[3-Hrs], 0), [6-Hrs] = ISNULL(b.[6-Hrs], 0) + ISNULL(a.[6-Hrs], 0), [9-Hrs] = ISNULL(b.[9-Hrs], 0) + ISNULL(a.[9-Hrs], 0), [12-Hrs] = ISNULL(b.[12-Hrs], 0) + ISNULL(a.[12-Hrs], 0), [18-Hrs] = ISNULL(b.[18-Hrs], 0) + ISNULL(a.[18-Hrs], 0), [24-Hrs] = ISNULL(b.[24-Hrs], 0) + ISNULL(a.[24-Hrs], 0), [36-Hrs] = ISNULL(b.[36-Hrs], 0) + ISNULL(a.[36-Hrs], 0), [48-Hrs] = ISNULL(b.[48-Hrs], 0) + ISNULL(a.[48-Hrs], 0)
from dbo.SqlAgentJobs b
	 join #JobActivityMonitor a on a.JobName = b.JobName
								   and a.instance_id is not null;

-- Step 04 - Drop Mail
declare @tableHTML nvarchar(max);
declare @subject varchar(200);

set @subject = 'Long Running Jobs - ' + CAST(CAST(GETDATE() as date) as varchar(20));
--SELECT @subject

set @tableHTML = N'
<style>
#JobActivity {
    font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
    border-collapse: collapse;
    width: 100%;
}
#JobActivity td, #JobActivity th {
    border: 1px solid #ddd;
    padding: 8px;
}
#JobActivity tr:nth-child(even){background-color: #f2f2f2;}
#JobActivity tr:hover {background-color: #ddd;}
#JobActivity th {
    padding-top: 12px;
    padding-bottom: 12px;
    text-align: left;
    background-color: #4CAF50;
    color: white;
}
</style>' + N'<H1>' + @subject + '</H1>' + N'<table border="1" id="JobActivity">' + --N'<caption>Currently Running Jobs that Need Attention</caption>'+
				 N'<thead>
		  <tr><th rowspan=2>JobName</th>' + N'<th rowspan=2>Expected-Duration<br>(Minutes)</th>' + N'<th rowspan=2>Running Since</th>' + N'<th rowspan=2>Running Since(Hrs)</th>' + N'<th colspan=9>No of times Job crossed below Thresholds</th>
		  </tr>
		  <tr>' + N'<th>< 3 Hrs</th>' + N'<th>> 3 Hrs</th>' + N'<th>> 6 Hrs</th>' + N'<th>> 9 Hrs</th>' + N'<th>> 12 Hrs</th>' + N'<th>> 18 Hrs</th>' + N'<th>> 24 Hrs</th>' + N'<th>> 36 Hrs</th>' + N'<th>> 48 Hrs</th>
		  </tr>
	  </thead>' + N'<tbody>' + CAST( (select td = JobName, 
											 '', 
											 td = CAST([Expected-Max-Duration(Min)] as varchar(20)), 
											 '', 
											 td = CAST([Running Since] as varchar(30)), 
											 '', 
											 td = CAST([Running Since(Hrs)] as varchar(20)), 
											 '', 
											 td = CAST(ISNULL([<3-Hrs], 0) as varchar(20)), 
											 '', 
											 td = CAST(ISNULL([3-Hrs], 0) as varchar(20)), 
											 '', 
											 td = CAST(ISNULL([6-Hrs], 0) as varchar(20)), 
											 '', 
											 td = CAST(ISNULL([9-Hrs], 0) as varchar(20)), 
											 '', 
											 td = CAST(ISNULL([12-Hrs], 0) as varchar(20)), 
											 '', 
											 td = CAST(ISNULL([18-Hrs], 0) as varchar(20)), 
											 '', 
											 td = CAST(ISNULL([24-Hrs], 0) as varchar(20)), 
											 '', 
											 td = CAST(ISNULL([36-Hrs], 0) as varchar(20)), 
											 '', 
											 td = CAST(ISNULL([48-Hrs], 0) as varchar(20))
									  from dbo.SqlAgentJobs as j
									  where j.Ignore = 0
											and j.[Running Since] is not null
											and j.[Running Since(Hrs)] >= 3.0 for xml path('tr'), type) as nvarchar(max)) + N'</tbody></table>
	
<p></p><br><br>
Thanks & Regards,<br>
SQLAlerts<br>
-- Alert from job [Long Running Jobs]
	';  

if @tableHTML is not null
begin
	exec msdb.dbo.sp_send_dbmail @recipients = 'mboomaars@gmail.com', @subject = @subject, @body = @tableHTML, @body_format = 'HTML';
end;
else
	print 'No Long Running job found.';


select *
from dbo.SqlAgentJobs as j
where j.Ignore = 0
	  and j.[Running Since] is not null;
--AND (DATEDIFF(MINUTE,[Running Since],GETDATE()) > [Expected-Max-Duration(Min)] AND DATEDIFF(MINUTE,[Running Since],GETDATE()) > 60)