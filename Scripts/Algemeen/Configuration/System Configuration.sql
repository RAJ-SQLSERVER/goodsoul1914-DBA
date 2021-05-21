-- System configuration
---------------------------------------------------------------------------------------------------

select name, 
	   value, 
	   value_in_use, 
	   minimum, 
	   maximum, 
	   description, 
	   is_dynamic, 
	   is_advanced
from sys.configurations with(nolock)
order by name option(recompile);
go