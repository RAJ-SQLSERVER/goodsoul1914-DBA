-- SQL Server instance up time
select sqlserver_start_time
from sys.dm_os_sys_info;

-- Trivial plan
-- No joins, obvious plan
-- Search 0 - Transaction Processing
-- Serial plan, low cost (<.2)
-- Search 1 - Quick Plan
-- Cost < 1.0
-- Search 2 - Full Optimization
-- Parallelism considered
-- All rules evaluated
select counter, 
	   occurrence, 
	   [value]
from sys.dm_exec_query_optimizer_info
where counter in ('trivial plan', 'search 0', 'search 1', 'search 2');

-- Is this what you expected?

-- Hint usage?
select counter, 
	   occurrence, 
	   [value]
from sys.dm_exec_query_optimizer_info
where counter in ('order hint', 'join hint');
