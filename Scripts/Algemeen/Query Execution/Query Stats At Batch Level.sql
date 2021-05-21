-- Grouping by sql_handle to see query stats at the batch level
---------------------------------------------------------------------------------------------------

select top 100 SUM(total_logical_reads) as total_logical_reads, 
			   COUNT(*) as num_queries, -- number of individual queries in batch
			   --not all usages need be equivalent, in the case of looping or branching code
			   MAX(execution_count) as execution_count, 
			   MAX(execText.TEXT) as queryText
from sys.dm_exec_query_stats as deqs
	 cross apply sys.dm_exec_sql_text (deqs.sql_handle) as execText
group by deqs.sql_handle
having AVG(total_logical_reads / execution_count) <> SUM(total_logical_reads) / SUM(execution_count)
order by 1 desc;
go