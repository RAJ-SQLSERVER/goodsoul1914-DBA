select session_id, 
	   node_id, 
	   physical_operator_name, 
	   estimate_row_count, 
	   row_count
from sys.dm_exec_query_profiles
order by node_id;

select t.text, 
	   p.query_plan, 
	   s.last_execution_time, 
	   p.query_plan.value('(//@EstimateRows)[1]', 'varchar(128)') as estimated_rows, 
	   s.last_rows
from sys.dm_exec_query_stats as s
	 cross apply sys.dm_exec_sql_text(sql_handle) as t
	 cross apply sys.dm_exec_query_plan(plan_handle) as p
where DATEDIFF(mi, s.last_execution_time, GETDATE()) < 1;
go