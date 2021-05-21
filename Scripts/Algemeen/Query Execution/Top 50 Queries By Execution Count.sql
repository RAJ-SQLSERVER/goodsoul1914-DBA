-- Execution counts
-- ------------------------------------------------------------------------------------------------

select top (50) LEFT(t.[text], 50) as [Short Query Text], 
				qs.execution_count as [Execution Count], 
				qs.total_logical_reads as [Total Logical Reads], 
				qs.total_logical_reads / qs.execution_count as [Avg Logical Reads], 
				qs.total_worker_time as [Total Worker Time], 
				qs.total_worker_time / qs.execution_count as [Avg Worker Time], 
				qs.total_elapsed_time as [Total Elapsed Time], 
				qs.total_elapsed_time / qs.execution_count as [Avg Elapsed Time],
				case
					when CONVERT(nvarchar(max), qp.query_plan) like N'%<MissingIndexes>%' then 1
					else 0
				end as [Has Missing Index], 
				qs.creation_time as [Creation Time], 
				t.[text] as [Complete Query Text], 
				qp.query_plan as [Query Plan]
from sys.dm_exec_query_stats as qs with(nolock)
	 cross apply sys.dm_exec_sql_text (plan_handle) as t
	 cross apply sys.dm_exec_query_plan (plan_handle) as qp
where t.dbid = DB_ID()
order by qs.execution_count desc option(recompile);
go

-- Most frequently run queries
---------------------------------------------------------------------------------------------------

select top (5) qsp.query_id, 
			   qsrt.count_executions, 
			   qsqt.query_sql_text
from sys.query_store_query as qsq
	 inner join sys.query_store_query_text as qsqt on qsqt.query_text_id = qsq.query_text_id
	 inner join sys.query_store_plan as qsp on qsp.query_id = qsq.query_id
	 inner join sys.query_store_runtime_stats as qsrt on qsrt.plan_id = qsp.plan_id
	 inner join sys.query_store_runtime_stats_interval as qsrsi on qsrsi.runtime_stats_interval_id = qsrt.runtime_stats_interval_id
where qsrsi.start_time >= '2020-01-01 00:00:00'
	  and qsrsi.start_time < '2020-01-01 19:00:00'
group by qsp.query_id, 
		 qsqt.query_sql_text, 
		 qsrt.count_executions
order by SUM(qsrt.count_executions) desc;
go