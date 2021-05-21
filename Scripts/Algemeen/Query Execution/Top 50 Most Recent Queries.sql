-- Top 50 most recent queries
-- ------------------------------------------------------------------------------------------------

select top 50 DB_NAME(ST.dbid) as [database], 
			  execution_count, 
			  total_worker_time / execution_count as avg_cpu, 
			  total_elapsed_time / execution_count as avg_time, 
			  total_logical_reads / execution_count as avg_reads, 
			  total_logical_writes / execution_count as avg_writes, 
			  SUBSTRING(ST.TEXT, QS.statement_start_offset / 2 + 1, ( case QS.statement_end_offset
																		  when -1 then DATALENGTH(ST.TEXT)
																		  else QS.statement_end_offset
																	  end - QS.statement_start_offset ) / 2 + 1) as request, 
			  query_plan
from sys.dm_exec_query_stats as QS
	 cross apply sys.dm_exec_sql_text (QS.sql_handle) as ST
	 cross apply sys.dm_exec_query_plan (QS.plan_handle) as QP
--WHERE	DB_NAME(ST.[dbid]) = 'Credit'
order by total_elapsed_time desc;
go