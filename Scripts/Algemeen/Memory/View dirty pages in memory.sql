
-- View the dirty pages in memory
select database_name = d.name, 
	   OBJECT_NAME = case au.TYPE
						 when 1 then o1.name
						 when 2 then o2.name
						 when 3 then o1.name
					 end, 
	   OBJECT_ID = case au.TYPE
					   when 1 then p1.OBJECT_ID
					   when 2 then p2.OBJECT_ID
					   when 3 then p1.OBJECT_ID
				   end, 
	   index_id = case au.TYPE
					  when 1 then p1.index_id
					  when 2 then p2.index_id
					  when 3 then p1.index_id
				  end, 
	   bd.FILE_ID, 
	   bd.page_id, 
	   bd.page_type, 
	   bd.page_level
from sys.dm_os_buffer_descriptors as bd
inner join sys.databases as d on bd.database_id = d.database_id
inner join sys.allocation_units as au on bd.allocation_unit_id = au.allocation_unit_id
left join sys.partitions as p1 on au.container_id = p1.hobt_id
left join sys.partitions as p2 on au.container_id = p2.partition_id
left join sys.objects as o1 on p1.OBJECT_ID = o1.OBJECT_ID
left join sys.objects as o2 on p2.OBJECT_ID = o2.OBJECT_ID
where is_modified = 1;
