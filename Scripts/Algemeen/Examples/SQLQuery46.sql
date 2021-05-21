--\
---) Number of buckets for each of the plan cache stores
--/

select type as 'plan cache store', 
	   buckets_count
from sys.dm_os_memory_cache_hash_tables
where type in ('CACHESTORE_OBJCP', 'CACHESTORE_SQLCP', 'CACHESTORE_PHDR', 'CACHESTORE_XPROC');
go

--\
---) Plan handle information
--/

select plan_handle, 
	   pvt.set_options, 
	   pvt.object_id, 
	   pvt.sql_handle
from
(
	select plan_handle, 
		   epa.attribute, 
		   epa.value
	from sys.dm_exec_cached_plans
		 outer apply sys.dm_exec_plan_attributes(plan_handle) as epa
	where cacheobjtype = 'Compiled Plan'
) as ecpa pivot(MAX(ecpa.value) for ecpa.attribute in("set_options", 
													  "object_id", 
													  "sql_handle")) as pvt;
go

--\
---) 
--/

select st.TEXT, 
	   qs.sql_handle, 
	   qs.plan_handle
from sys.dm_exec_query_stats as qs
	 cross apply sys.dm_exec_sql_text(sql_handle) as st;
go

--\
---) 
--/

select st.TEXT, 
	   cp.plan_handle, 
	   cp.usecounts, 
	   cp.size_in_bytes, 
	   cp.cacheobjtype, 
	   cp.objtype
from sys.dm_exec_cached_plans as cp
	 cross apply sys.dm_exec_sql_text(cp.plan_handle) as st
order by cp.usecounts desc;

--\
---) 
--/

select TEXT, 
	   plan_handle, 
	   d.usecounts, 
	   d.cacheobjtype
from sys.dm_exec_cached_plans
	 cross apply sys.dm_exec_sql_text(plan_handle)
	 cross apply sys.dm_exec_cached_plan_dependent_objects(plan_handle) as d;

--\
---) 10 longest-running queries
--/

select top 10 SUBSTRING(TEXT, statement_start_offset / 2 + 1, ( case statement_end_offset
																	when -1 then DATALENGTH(TEXT)
																else statement_end_offset
																end - statement_start_offset ) / 2 + 1) as query_text, 
			  *
from sys.dm_exec_requests
	 cross apply sys.dm_exec_sql_text(sql_handle)
order by total_elapsed_time desc;

--\
---) 10 most expensive queries
--/

select top 10 SUBSTRING(TEXT, statement_start_offset / 2 + 1, ( case statement_end_offset
																	when -1 then DATALENGTH(TEXT)
																else statement_end_offset
																end - statement_start_offset ) / 2 + 1) as query_text, 
			  *
from sys.dm_exec_query_stats
	 cross apply sys.dm_exec_sql_text(sql_handle)
	 cross apply sys.dm_exec_query_plan(plan_handle)
order by total_elapsed_time / execution_count desc;

--\
---) Local Memory Pressure: determine the number of buckets in the hash tables for the object store and the SQL store, and the number of entries in each of those stores
--/

select type as 'plan cache store', 
	   buckets_count
from sys.dm_os_memory_cache_hash_tables
where type in ('CACHESTORE_OBJCP', 'CACHESTORE_SQLCP');

select type, 
	   COUNT(*) as total_entries
from sys.dm_os_memory_cache_entries
where type in ('CACHESTORE_SQLCP', 'CACHESTORE_OBJCP')
group by type;

--\
---) Costing of Cache Entries
--/

select TEXT, 
	   objtype, 
	   refcounts, 
	   usecounts, 
	   size_in_bytes, 
	   disk_ios_count, 
	   context_switches_count, 
	   original_cost, 
	   current_cost
from sys.dm_exec_cached_plans as p
	 cross apply sys.dm_exec_sql_text(plan_handle)
	 join sys.dm_os_memory_cache_entries as e on p.memory_object_address = e.memory_object_address
where cacheobjtype = 'Compiled Plan'
	  and type in ('CACHESTORE_SQLCP', 'CACHESTORE_OBJCP')
order by objtype desc, 
		 usecounts desc;