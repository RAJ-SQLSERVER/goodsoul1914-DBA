-- Catalog views
---------------------------------------------------------------------------------------------------

select q.query_id, 
	   q.query_hash, 
	   q.initial_compile_start_time, 
	   q.last_compile_start_time, 
	   q.last_execution_time, 
	   qt.query_sql_text
from sys.query_store_query as q
	 inner join sys.query_store_query_text as qt on qt.query_text_id = q.query_text_id
where qt.query_sql_text like '%OriginStation%';
go