select *
from sys.query_store_plan
where query_plan like '%Shipments%';
go

select query_id, 
	   query_hash, 
	   query_sql_text, 
	   last_compile_start_time, 
	   last_execution_time, 
	   count_compiles, 
	   avg_compile_duration, 
	   avg_compile_memory_kb, 
	   statement_sql_handle
from sys.query_store_query as q
	 inner join sys.query_store_query_text as qt on qt.query_text_id = q.query_text_id
where q.query_id in (78, 103, 104);
go