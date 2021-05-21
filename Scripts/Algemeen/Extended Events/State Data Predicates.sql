/**********************
		State Data Predicates
**********************/

select p.name as package_name, 
	   o.name as source_name, 
	   o.description
from sys.dm_xe_objects as o
	 inner join sys.dm_xe_packages as p on o.package_guid = p.guid
where( p.capabilities is null
	   or p.capabilities&1 = 0
	 )
	 and ( o.capabilities is null
		   or o.capabilities&1 = 0
		 )
	 and o.object_type = N'pred_source';
go