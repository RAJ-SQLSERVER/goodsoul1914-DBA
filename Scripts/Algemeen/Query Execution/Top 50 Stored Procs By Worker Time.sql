-- Worker Time
---------------------------------------------------------------------------------------------------

select top (25) p.name as [SP Name], 
				qs.total_worker_time as TotalWorkerTime, 
				qs.total_worker_time / qs.execution_count as AvgWorkerTime, 
				qs.execution_count, 
				ISNULL(qs.execution_count / DATEDIFF(Minute, qs.cached_time, GETDATE()), 0) as [Calls/Minute], 
				qs.total_elapsed_time, 
				qs.total_elapsed_time / qs.execution_count as avg_elapsed_time,
				case
					when CONVERT(nvarchar(max), qp.query_plan) like N'%<MissingIndexes>%' then 1
					else 0
				end as [Has Missing Index], 
				FORMAT(qs.last_execution_time, 'yyyy-MM-dd HH:mm:ss', 'en-US') as [Last Execution Time], 
				FORMAT(qs.cached_time, 'yyyy-MM-dd HH:mm:ss', 'en-US') as [Plan Cached Time]
from sys.procedures as p with(nolock)
	 inner join sys.dm_exec_procedure_stats as qs with(nolock) on p.object_id = qs.object_id
	 cross apply sys.dm_exec_query_plan (qs.plan_handle) as qp
where qs.database_id = DB_ID()
	  and DATEDIFF(Minute, qs.cached_time, GETDATE()) > 0
order by qs.total_worker_time desc option(recompile);
go