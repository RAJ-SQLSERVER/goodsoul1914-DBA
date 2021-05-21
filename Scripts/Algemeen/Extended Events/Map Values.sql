/***********
		Map Values
***********/

select mv.name, 
	   mv.map_key, 
	   mv.map_value
from sys.dm_xe_map_values as mv
where mv.name = N'wait_types';
go
