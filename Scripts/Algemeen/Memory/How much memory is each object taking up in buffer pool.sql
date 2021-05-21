-- list details of your current database 
-- and how much memory each object is taking in the buffer pool.
select SCHEMA_NAME(objects.schema_id) as SchemaName, 
	   objects.name as ObjectName, 
	   objects.type_desc as ObjectType, 
	   COUNT(*) as [Total Pages In Buffer], 
	   COUNT(*) * 8 / 1024 as [Buffer Size in MB], 
	   SUM(case dm_os_buffer_descriptors.is_modified
			   when 1 then 1
		   else 0
		   end) as [Dirty Pages], 
	   SUM(case dm_os_buffer_descriptors.is_modified
			   when 1 then 0
		   else 1
		   end) as [Clean Pages], 
	   SUM(case dm_os_buffer_descriptors.is_modified
			   when 1 then 1
		   else 0
		   end) * 8 / 1024 as [Dirty Page (MB)], 
	   SUM(case dm_os_buffer_descriptors.is_modified
			   when 1 then 0
		   else 1
		   end) * 8 / 1024 as [Clean Page (MB)]
from sys.dm_os_buffer_descriptors
inner join sys.allocation_units on allocation_units.allocation_unit_id = dm_os_buffer_descriptors.allocation_unit_id
inner join sys.partitions on allocation_units.container_id = partitions.hobt_id
							 and type in(1, 3)
							 or allocation_units.container_id = partitions.partition_id
								and type in(2)
inner join sys.objects on partitions.object_id = objects.object_id
where allocation_units.type in (1, 2, 3)
	  and objects.is_ms_shipped = 0
	  and dm_os_buffer_descriptors.database_id = DB_ID()
group by objects.schema_id, 
		 objects.name, 
		 objects.type_desc
order by [Total Pages In Buffer] desc;