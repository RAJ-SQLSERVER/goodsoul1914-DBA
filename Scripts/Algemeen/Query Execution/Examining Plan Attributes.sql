-- Examining plan attributes
---------------------------------------------------------------------------------------------------

select CAST(depa.attribute as varchar(30)) as attribute, 
	   CAST(depa.value as varchar(30)) as value, 
	   depa.is_cache_key
from
(
	select top 1 *
	from sys.dm_exec_cached_plans
	order by usecounts desc
) as decp
outer apply sys.dm_exec_plan_attributes(decp.plan_handle) as depa
where is_cache_key = 1
order by usecounts desc;
go