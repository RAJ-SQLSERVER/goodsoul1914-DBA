-- Logical Writes
---------------------------------------------------------------------------------------------------

select top (50) p.name as [SP Name], 
				qs.total_logical_writes as TotalLogicalWrites, 
				qs.total_logical_writes / qs.execution_count as AvgLogicalWrites, 
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
	  and qs.total_logical_writes > 0
	  and DATEDIFF(Minute, qs.cached_time, GETDATE()) > 0
order by qs.total_logical_writes desc option(recompile);
go

-- Physical Writes
---------------------------------------------------------------------------------------------------

select top (50) p.name as [SP Name], 
				qs.total_physical_reads as TotalPhysicalReads, 
				qs.total_physical_reads / qs.execution_count as AvgPhysicalReads, 
				qs.execution_count, 
				qs.total_logical_reads, 
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
	  and qs.total_physical_reads > 0
order by qs.total_physical_reads desc, 
		 qs.total_logical_reads desc option(recompile);
go

-- Top 50 Stored Procedures by Average I/O
---------------------------------------------------------------------------------------------------

select top 50 s.name + '.' + p.name as [Procedure], 
			  qp.query_plan as [Plan], 
			  ( ps.total_logical_reads + ps.total_logical_writes ) / ps.execution_count as [Avg IO], 
			  ps.execution_count as [Exec Cnt], 
			  ps.cached_time as Cached, 
			  ps.last_execution_time as [Last Exec Time], 
			  ps.total_logical_reads as [Total Reads], 
			  ps.last_logical_reads as [Last Reads], 
			  ps.total_logical_writes as [Total Writes], 
			  ps.last_logical_writes as [Last Writes], 
			  ps.total_worker_time as [Total Worker Time], 
			  ps.last_worker_time as [Last Worker Time], 
			  ps.total_elapsed_time as [Total Elapsed Time], 
			  ps.last_elapsed_time as [Last Elapsed Time]
from sys.procedures as p with(nolock)
	 join sys.schemas as s with(nolock) on p.schema_id = s.schema_id
	 join sys.dm_exec_procedure_stats as ps with(nolock) on p.object_id = ps.object_id
	 outer apply sys.dm_exec_query_plan (ps.plan_handle) as qp
order by [Avg IO] desc option(recompile);
go