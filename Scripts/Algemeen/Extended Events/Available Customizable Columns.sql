/***************************************
		Look at available customizable columns
***************************************/

select o.name as event_name, 
	   oc.name as column_name, 
	   oc.column_value, 
	   oc.description
from sys.dm_xe_packages as p
	 inner join sys.dm_xe_objects as o on p.guid = o.package_guid
	 inner join sys.dm_xe_object_columns as oc on o.package_guid = oc.object_package_guid
												  and o.name = oc.object_name
where( p.capabilities is null
	   or p.capabilities&1 = 0
	 )
	 and ( o.capabilities is null
		   or o.capabilities&1 = 0
		 )
	 and ( oc.capabilities is null
		   or oc.capabilities&1 = 0
		 )
	 and o.object_type = N'event'
	 and oc.column_type = N'customizable';
go