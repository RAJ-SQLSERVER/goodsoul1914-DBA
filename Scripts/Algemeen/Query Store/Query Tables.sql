-- Query Tables
---------------------------------------------------------------------------------------------------

select q.query_id, 
	   q.last_execution_time, 
	   qt.query_sql_text, 
	   qsrt.avg_duration, 
	   qsrt.count_executions, 
	   qsrt.avg_cpu_time, 
	   qsrt.avg_logical_io_reads, 
	   qsrtsi.start_time
from sys.query_store_query as q
	 inner join sys.query_store_query_text as qt on qt.query_text_id = q.query_text_id
	 inner join sys.query_store_plan as qsp on qsp.query_id = q.query_id
	 inner join sys.query_store_runtime_stats as qsrt on qsrt.plan_id = qsp.plan_id
	 inner join sys.query_store_runtime_stats_interval as qsrtsi on qsrtsi.runtime_stats_interval_id = qsrt.runtime_stats_interval_id
where qt.query_sql_text like '%dbo.TransitLog%'
	  and qt.query_sql_text not like '%sys.query_store_query%';
go