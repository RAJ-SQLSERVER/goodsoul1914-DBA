/********************
		Show mapped columns
********************/

select oc.name as column_name, 
	   oc.type_name as type_name, 
	   o2.object_type as object_type
from sys.dm_xe_packages as p
	 inner join sys.dm_xe_objects as o on p.guid = o.package_guid
	 inner join sys.dm_xe_object_columns as oc on o.name = oc.object_name
												  and o.package_guid = oc.object_package_guid
	 inner join sys.dm_xe_objects as o2 on oc.type_name = o2.name
										   and oc.type_package_guid = o2.package_guid
										   and o2.object_type in('map', 'type')
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
	 and o.name = N'wait_info'
	 and oc.column_type = N'data';
go