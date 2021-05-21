use msdb;
go

select name, 
	   description, 
	   help_link
from dbo.syspolicy_policies_internal
order by date_created, 
		 name;
go

select a.name as 'Policy', 
	   c.name as 'Condition', 
	   c.facet
from msdb.dbo.syspolicy_policies_internal as a
inner join msdb.dbo.syspolicy_policies_internal as b on a.policy_id = b.policy_id
inner join msdb.dbo.syspolicy_conditions as c on b.condition_id = c.condition_id
order by a.Name;
go