-- Query to find top 50 high CPU queries and it's details
-- Author: Saleem Hakani (http://sqlcommunity.com)
-- ------------------------------------------------------------------------------------------------

select top 50 CONVERT(varchar, qs.creation_time, 109) as Plan_Compiled_On, 
			  qs.execution_count as 'Total Executions', 
			  qs.total_worker_time as 'Overall CPU Time Since Compiled', 
			  CONVERT(varchar, qs.last_execution_time, 109) as 'Last Execution Date/Time', 
			  CAST(qs.last_worker_time as varchar) + '   (' + CAST(qs.max_worker_time as varchar) + ' Highest ever)' as 'CPU Time for Last Execution (Milliseconds)', 
			  CONVERT(varchar, ( qs.last_worker_time / 1000 ) / ( 60 * 60 )) + ' Hrs (i.e. ' + CONVERT(varchar, ( qs.last_worker_time / 1000 ) / 60) + ' Mins & ' + CONVERT(varchar, ( qs.last_worker_time / 1000 ) % 60) + ' Seconds)' as 'Last Execution Duration', 
			  qs.last_rows as 'Rows returned', 
			  qs.total_logical_reads / 128 as 'Overall Logical Reads (MB)', 
			  qs.max_logical_reads / 128 as 'Highest Logical Reads (MB)', 
			  qs.last_logical_reads / 128 as 'Logical Reads from Last Execution (MB)', 
			  qs.total_physical_reads / 128 as 'Total Physical Reads Since Compiled (MB)', 
			  qs.last_dop as 'Last DOP used', 
			  qs.last_physical_reads / 128 as 'Physical Reads from Last Execution (MB)', 
			  t.[text] as 'Query Text', 
			  qp.query_plan as 'Query Execution Plan', 
			  DB_NAME(t.dbid) as 'Database Name', 
			  t.objectid as 'Object ID', 
			  t.encrypted as 'Is Query Encrypted', 
			  qs.plan_handle --Uncomment this if you want query plan handle
from sys.dm_exec_query_stats as qs
	 cross apply sys.dm_exec_sql_text (plan_handle) as t
	 cross apply sys.dm_exec_query_plan (plan_handle) as qp
order by qs.last_worker_time desc;
go

-- Statements with highest average CPU time
-- ------------------------------------------------------------------------------------------------

select top 50 qs.total_worker_time / qs.execution_count as [Avg CPU Time], 
			  SUBSTRING(qt.TEXT, qs.statement_start_offset / 2, ( case
																	  when qs.statement_end_offset = -1 then LEN(CONVERT(nvarchar(max), qt.TEXT)) * 2
																	  else qs.statement_end_offset
																  end - qs.statement_start_offset ) / 2) as query_text, 
			  qt.dbid, 
			  dbname = DB_NAME(qt.dbid), 
			  qt.objectid
from sys.dm_exec_query_stats as qs
	 cross apply sys.dm_exec_sql_text (qs.sql_handle) as qt
order by [Avg CPU Time] desc;
go

-- Finding Top 10 CPU-consuming Queries
---------------------------------------------------------------------------------------------------

select top (10) SUBSTRING(ST.TEXT, QS.statement_start_offset / 2 + 1, ( case statement_end_offset
																			when -1 then DATALENGTH(st.TEXT)
																			else QS.statement_end_offset
																		end - QS.statement_start_offset ) / 2 + 1) as statement_text, 
				execution_count, 
				total_worker_time / 1000 as total_worker_time_ms, 
				( total_worker_time / 1000 ) / execution_count as avg_worker_time_ms, 
				total_logical_reads, 
				total_logical_reads / execution_count as avg_logical_reads, 
				total_elapsed_time / 1000 as total_elapsed_time_ms, 
				( total_elapsed_time / 1000 ) / execution_count as avg_elapsed_time_ms, 
				qp.query_plan
from sys.dm_exec_query_stats as qs
	 cross apply sys.dm_exec_sql_text (qs.sql_handle) as st
	 cross apply sys.dm_exec_query_plan (qs.plan_handle) as qp
order by total_worker_time desc;
go