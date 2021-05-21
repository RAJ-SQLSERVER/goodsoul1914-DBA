-- List Dirty Pages In Memory
select DB_NAME(dm_os_buffer_descriptors.database_id) as DatabaseName, 
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
inner join sys.databases on dm_os_buffer_descriptors.database_id = databases.database_id
group by DB_NAME(dm_os_buffer_descriptors.database_id)
order by [Total Pages In Buffer] desc;