-- Lists all the packages registered with the extended events engine
---------------------------------------------------------------------------------------------------

select name, 
	   description, 
	   capabilities_desc
from sys.dm_xe_packages;
go