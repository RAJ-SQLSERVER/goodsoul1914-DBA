-- Detailed aggregated historical wait statistics for all wait types since last server 
-- restart or counter clearing (What has happened?)
-- ------------------------------------------------------------------------------------------------

select *
from sys.dm_os_wait_stats
order by wait_time_ms desc;
go