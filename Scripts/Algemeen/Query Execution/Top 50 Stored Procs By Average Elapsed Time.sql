-- Top 50 Cached Stored Procedures By Avg Elapsed Time
--
-- This helps you find high average elapsed time cached stored procedures that
-- may be easy to optimize with standard query tuning techniques
---------------------------------------------------------------------------------------------------

select top (25) p.name as [SP Name], 
				qs.total_elapsed_time / qs.execution_count as avg_elapsed_time, 
				qs.min_elapsed_time, 
				qs.max_elapsed_time, 
				qs.last_elapsed_time, 
				qs.total_elapsed_time, 
				qs.execution_count, 
				ISNULL(qs.execution_count / DATEDIFF(Minute, qs.cached_time, GETDATE()), 0) as [Calls/Minute], 
				qs.total_worker_time / qs.execution_count as AvgWorkerTime, 
				qs.total_worker_time as TotalWorkerTime,
				case
					when CONVERT(nvarchar(max), qp.query_plan) like N'%<MissingIndexes>%' then 1
					else 0
				end as [Has Missing Index], 
				FORMAT(qs.last_execution_time, 'yyyy-MM-dd HH:mm:ss', 'en-US') as [Last Execution Time], 
				FORMAT(qs.cached_time, 'yyyy-MM-dd HH:mm:ss', 'en-US') as [Plan Cached Time], 
				qp.query_plan as [Query Plan] -- Uncomment if you want the Query Plan
from sys.procedures as p with(nolock)
	 inner join sys.dm_exec_procedure_stats as qs with(nolock) on p.object_id = qs.object_id
	 cross apply sys.dm_exec_query_plan (qs.plan_handle) as qp
where qs.database_id = DB_ID()
	  and DATEDIFF(Minute, qs.cached_time, GETDATE()) > 0
order by avg_elapsed_time desc option(recompile);
go

--

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
-- WHERE ...
order by s.total_elapsed_time desc;