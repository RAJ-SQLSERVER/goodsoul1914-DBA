
-- Returns a mapping of internal numeric keys to human-readable text
---------------------------------------------------------------------------------------------------

select *
from sys.dm_xe_map_values
where name like 'wait_types';
go