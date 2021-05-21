-- Top n longest running procedures
-- ------------------------------------------------------------------------------------------------

select top 10 ProcedureName = t.TEXT, 
			  ExecutionCount = s.execution_count, 
			  AvgExecutionTime = ISNULL(s.total_elapsed_time / s.execution_count, 0), 
			  AvgWorkerTime = s.total_worker_time / s.execution_count, 
			  TotalWorkerTime = s.total_worker_time, 
			  MaxLogicalReads = s.max_logical_reads, 
			  MaxLogicalWrites = s.max_logical_writes, 
			  CreationDateTime = s.creation_time, 
			  CallsPerSecond = ISNULL(s.execution_count / DATEDIFF(second, s.creation_time, GETDATE()), 0)
from sys.dm_exec_query_stats as s
	 cross apply sys.dm_exec_sql_text (s.sql_handle) as t
order by s.total_elapsed_time desc;
go

-- Long running queries
---------------------------------------------------------------------------------------------------

declare @xml nvarchar(max);

declare @body nvarchar(max);
-- specify long running query duration threshold

declare @longrunningthreshold int;

set @longrunningthreshold = 2;
-- step 1: collect long running query details.

with cte
	 as (select Session_id = spid, 
				Session_start_time =
		 (
			 select start_time
			 from sys.dm_exec_requests
			 where spid = session_id
		 ), 
				Session_status = LTRIM(RTRIM(status)), 
				Session_duration = DATEDIFF(mi,
		 (
			 select start_time
			 from sys.dm_exec_requests
			 where spid = session_id
		 ), GETDATE()), 
				Session_query = SUBSTRING(st.TEXT, qs.stmt_start / 2 + 1, ( case qs.stmt_end
																				when -1 then DATALENGTH(st.TEXT)
																				else qs.stmt_end
																			end - qs.stmt_start ) / 2 + 1)
		 from sys.sysprocesses as qs
			  cross apply sys.Dm_exec_sql_text (sql_handle) as st
		 where st.TEXT <> 'WAITFOR(RECEIVE conversation_handle, service_contract_name, message_type_name, message_body FROM ExternalMailQueue INTO @msgs), TIMEOUT @rec_timeout -- Check if there was some error in reading from queue')
	 -- step 2: generate html table 
	 select @xml = CAST(
	 (
		 select session_id as 'td', 
				'', 
				session_duration as 'td', 
				'', 
				session_status as 'td', 
				'', 
				session_query as 'td'
		 from cte
		 where session_duration > = @longrunningthreshold for xml path('tr'), elements
	 ) as nvarchar(max));

-- step 3: do rest of html formatting

set @body = '<html><body><H2>Long Running Queries ( Limit > 2 Minute )</H2><table border=1 BORDERCOLOR="Black"><tr><th align="centre">Session_id</th><th>Session_Duration(Minute)</th><th>Session_status</th><th>Session_query</th></tr>';

set @body = @body + @xml + '</table></body></html>';

select @xml;

-- step 4: send email if a long running query is found.

if @xml is not null
begin
	exec msdb.dbo.Sp_send_dbmail @profile_name = 'GPHIXSQL01', @body = @body, @body_format = 'html', @recipients = 'r.meijer@bravis.nl;m.boomaars@bravis.nl', @subject = 'ALERT: Long Running Queries';
end;