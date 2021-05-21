--	https://www.sqlskills.com/blogs/kimberly/plan-cache-adhoc-workloads-and-clearing-the-single-use-plan-cache-bloat/
--	https://www.sqlskills.com/blogs/kimberly/plan-cache-and-optimizing-for-adhoc-workloads/
--	https://www.sqlshack.com/searching-the-sql-server-query-plan-cache/
--	https://sqlperformance.com/2014/10/t-sql-queries/performance-tuning-whole-plan

/**************************
 Query plans with Warnings 
**************************/

with xmlnamespaces(default 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
	 select top 20 dm_exec_sql_text.text as sql_text, 
				   CAST(CAST(dm_exec_query_stats.execution_count as decimal) / CAST(case
																						when DATEDIFF(HOUR, dm_exec_query_stats.creation_time, CURRENT_TIMESTAMP) = 0 then 1
																					else DATEDIFF(HOUR, dm_exec_query_stats.creation_time, CURRENT_TIMESTAMP)
																					end as decimal) as int) as executions_per_hour, 
				   dm_exec_query_stats.creation_time, 
				   dm_exec_query_stats.execution_count, 
				   CAST(CAST(dm_exec_query_stats.total_worker_time as decimal) / CAST(dm_exec_query_stats.execution_count as decimal) as int) as cpu_per_execution, 
				   CAST(CAST(dm_exec_query_stats.total_logical_reads as decimal) / CAST(dm_exec_query_stats.execution_count as decimal) as int) as logical_reads_per_execution, 
				   CAST(CAST(dm_exec_query_stats.total_elapsed_time as decimal) / CAST(dm_exec_query_stats.execution_count as decimal) as int) as elapsed_time_per_execution, 
				   dm_exec_query_stats.total_worker_time as total_cpu_time, 
				   dm_exec_query_stats.max_worker_time as max_cpu_time, 
				   dm_exec_query_stats.total_elapsed_time, 
				   dm_exec_query_stats.max_elapsed_time, 
				   dm_exec_query_stats.total_logical_reads, 
				   dm_exec_query_stats.max_logical_reads, 
				   dm_exec_query_stats.total_physical_reads, 
				   dm_exec_query_stats.max_physical_reads, 
				   dm_exec_query_plan.query_plan
	 from sys.dm_exec_query_stats
		  cross apply sys.dm_exec_sql_text(dm_exec_query_stats.sql_handle)
		  cross apply sys.dm_exec_query_plan(dm_exec_query_stats.plan_handle)
	 where query_plan.exist('//Warnings') = 1
		   and query_plan.exist('//ColumnReference[@Database = "[AMGMusic]"]') = 1
	 order by dm_exec_query_stats.total_worker_time desc;
 
/**************************************
 Plans with Table/Clustered Index Scan 
**************************************/

with xmlnamespaces(default 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
	 select dm_exec_sql_text.text as sql_text, 
			CAST(CAST(dm_exec_query_stats.execution_count as decimal) / CAST(case
																				 when DATEDIFF(HOUR, dm_exec_query_stats.creation_time, CURRENT_TIMESTAMP) = 0 then 1
																			 else DATEDIFF(HOUR, dm_exec_query_stats.creation_time, CURRENT_TIMESTAMP)
																			 end as decimal) as int) as executions_per_hour, 
			dm_exec_query_stats.creation_time, 
			dm_exec_query_stats.execution_count, 
			CAST(CAST(dm_exec_query_stats.total_worker_time as decimal) / CAST(dm_exec_query_stats.execution_count as decimal) as int) as cpu_per_execution, 
			CAST(CAST(dm_exec_query_stats.total_logical_reads as decimal) / CAST(dm_exec_query_stats.execution_count as decimal) as int) as logical_reads_per_execution, 
			CAST(CAST(dm_exec_query_stats.total_elapsed_time as decimal) / CAST(dm_exec_query_stats.execution_count as decimal) as int) as elapsed_time_per_execution, 
			dm_exec_query_stats.total_worker_time as total_cpu_time, 
			dm_exec_query_stats.max_worker_time as max_cpu_time, 
			dm_exec_query_stats.total_elapsed_time, 
			dm_exec_query_stats.max_elapsed_time, 
			dm_exec_query_stats.total_logical_reads, 
			dm_exec_query_stats.max_logical_reads, 
			dm_exec_query_stats.total_physical_reads, 
			dm_exec_query_stats.max_physical_reads, 
			dm_exec_query_plan.query_plan
	 from sys.dm_exec_query_stats
		  cross apply sys.dm_exec_sql_text(dm_exec_query_stats.sql_handle)
		  cross apply sys.dm_exec_query_plan(dm_exec_query_stats.plan_handle)
	 where( query_plan.exist('//RelOp[@PhysicalOp = "Index Scan"]') = 1
			or query_plan.exist('//RelOp[@PhysicalOp = "Clustered Index Scan"]') = 1
		  )
		  and query_plan.exist('//ColumnReference[@Database = "[AdventureWorks2014]"]') = 1
	 order by dm_exec_query_stats.total_worker_time desc;