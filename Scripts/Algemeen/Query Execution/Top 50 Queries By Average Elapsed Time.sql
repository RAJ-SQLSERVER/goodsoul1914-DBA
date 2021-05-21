-- Get Top Average Elapsed Time Queries For Entire Instance
--
-- Helps you find the highest average elapsed time queries across the entire instance
-- Can also help track down parameter sniffing issues
---------------------------------------------------------------------------------------------------

select top (50) DB_NAME(t.dbid) as [Database Name], 
				qs.total_elapsed_time / qs.execution_count as [Avg Elapsed Time], 
				qs.min_elapsed_time, 
				qs.max_elapsed_time, 
				qs.last_elapsed_time, 
				qs.execution_count as [Execution Count], 
				qs.total_logical_reads / qs.execution_count as [Avg Logical Reads], 
				qs.total_physical_reads / qs.execution_count as [Avg Physical Reads], 
				qs.total_worker_time / qs.execution_count as [Avg Worker Time],
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
order by qs.total_elapsed_time / qs.execution_count desc option(recompile);
go

-- Finding the most expensive statements in your database
-- ------------------------------------------------------------------------------------------------

select top 20 DatabaseName = DB_NAME(CONVERT(int, epa.value)), 
			  [Execution count] = qs.execution_count, 
			  CpuPerExecution = total_worker_time / qs.execution_count, 
			  TotalCPU = total_worker_time, 
			  IOPerExecution = ( total_logical_reads + total_logical_writes ) / qs.execution_count, 
			  TotalIO = total_logical_reads + total_logical_writes, 
			  AverageElapsedTime = total_elapsed_time / qs.execution_count, 
			  AverageTimeBlocked = ( total_elapsed_time - total_worker_time ) / qs.execution_count, 
			  AverageRowsReturned = total_rows / qs.execution_count, 
			  [Query Text] = SUBSTRING(qt.text, qs.statement_start_offset / 2 + 1, ( case
																						 when qs.statement_end_offset = -1 then LEN(CONVERT(nvarchar(max), qt.text)) * 2
																						 else qs.statement_end_offset
																					 end - qs.statement_start_offset ) / 2), 
			  [Parent Query] = qt.text, 
			  [Execution Plan] = p.query_plan, 
			  [Creation Time] = qs.creation_time, 
			  [Last Execution Time] = qs.last_execution_time
from sys.dm_exec_query_stats as qs
	 cross apply sys.dm_exec_sql_text (qs.sql_handle) as qt
	 outer apply sys.dm_exec_query_plan (qs.plan_handle) as p
	 outer apply sys.dm_exec_plan_attributes (plan_handle) as epa
where epa.attribute = 'dbid'
	  and epa.value = DB_ID()
order by AverageElapsedTime desc;
go