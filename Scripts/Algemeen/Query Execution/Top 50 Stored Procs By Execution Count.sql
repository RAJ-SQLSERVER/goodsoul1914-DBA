-- Top Cached Stored Procedures By Execution Count
--
-- Tells you which cached stored procedures are called most often
-- This helps you characterize and baseline your workload
---------------------------------------------------------------------------------------------------

select top (50) p.name as [SP Name], 
				 qs.execution_count as [Execution Count], 
				 ISNULL(qs.execution_count / DATEDIFF(Minute, qs.cached_time, GETDATE()), 0) as [Calls/Minute], 
				 qs.total_elapsed_time / qs.execution_count as [Avg Elapsed Time], 
				 qs.total_worker_time / qs.execution_count as [Avg Worker Time], 
				 qs.total_logical_reads / qs.execution_count as [Avg Logical Reads],
				 case
					 when CONVERT(nvarchar(max), qp.query_plan) like N'%<MissingIndexes>%' then 1
					 else 0
				 end as [Has Missing Index], 
				 FORMAT(qs.last_execution_time, 'yyyy-MM-dd HH:mm:ss', 'en-US') as [Last Execution Time], 
				 FORMAT(qs.cached_time, 'yyyy-MM-dd HH:mm:ss', 'en-US') as [Plan Cached Time], 
				 qp.query_plan as [Query Plan]
from sys.procedures as p with(nolock)
	 inner join sys.dm_exec_procedure_stats as qs with(nolock) on p.object_id = qs.object_id
	 cross apply sys.dm_exec_query_plan (qs.plan_handle) as qp
where qs.database_id = DB_ID()
	  and DATEDIFF(Minute, qs.cached_time, GETDATE()) > 0
order by qs.execution_count desc option(recompile);
go
