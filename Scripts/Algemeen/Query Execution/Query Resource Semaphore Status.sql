-- Returns the information about the current query-resource semaphore status in SQL Server. 
-- sys.dm_exec_query_resource_semaphores provides general query-execution memory status and allows 
-- you to determine whether the system can access enough memory. This view complements memory 
-- information obtained from sys.dm_os_memory_clerks to provide a complete picture of server 
-- memory status. sys.dm_exec_query_resource_semaphores returns one row for the regular resource 
-- semaphore and another row for the small-query resource semaphore.
-- There are two requirements for a small-query semaphore:
--		* The memory grant requested should be less than 5 MB
--		* The query cost should be less than 3 cost units
---------------------------------------------------------------------------------------------------

select *
from sys.dm_exec_query_resource_semaphores;
go