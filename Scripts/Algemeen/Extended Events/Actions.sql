/********
		Actions
********/

select p.name as package_name, 
	   o.name as action_name, 
	   o.description
from sys.dm_xe_packages as p
	 inner join sys.dm_xe_objects as o on p.guid = o.package_guid
where( p.capabilities is null
	   or p.capabilities&1 = 0
	 )
	 and ( o.capabilities is null
		   or o.capabilities&1 = 0
		 )
	 and o.object_type = N'action';
go