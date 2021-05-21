-- Returns the status of each hand for a specific cache clock
-- 
-- SQL Server stores information in memory in a structure called a memory cache. 
-- The information in the cache can be data, index entries, compiled procedure 
-- plans, and a variety of other types of  SQL Server information. 
-- To avoid re-creating the information, it is retained the memory cache as 
-- long as possible and is ordinarily removed from the cache when it is too old 
-- to be useful, or when the memory space is needed for new information. 
--
-- The process that removes old information is called a memory sweep. 
-- The memory sweep is a frequent activity, but is not continuous. A clock 
-- algorithm controls the sweep of the memory cache. Each clock can control 
-- several memory sweeps, which are called hands. The memory-cache clock hand 
-- is the current location of one of the hands of a memory sweep.
-------------------------------------------------------------------------------
SELECT   name,
         type,
         clock_hand,
         clock_status,
         rounds_count,
         removed_all_rounds_count,
         updated_last_round_count,
         removed_last_round_count,
         last_round_start_time
FROM     sys.dm_os_memory_cache_clock_hands
ORDER BY removed_last_round_count DESC;
GO



SELECT   name,
         type,
         SUM(pages_kb) AS "Size",
         SUM(pages_in_use_kb) AS "Used_Size",
         SUM(entries_count) AS "Entries",
         SUM(entries_in_use_count) AS "Used_Entries"
FROM     sys.dm_os_memory_cache_counters
GROUP BY name,
         type
ORDER BY 4 DESC;