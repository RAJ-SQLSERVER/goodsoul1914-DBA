
-- Look at Suspect Pages table
--
-- event_type value descriptions
-- 1 = 823 error caused by an operating system CRC error
--     or 824 error other than a bad checksum or a torn page (for example, a bad page ID)
-- 2 = Bad checksum
-- 3 = Torn page
-- 4 = Restored (The page was restored after it was marked bad)
-- 5 = Repaired (DBCC repaired the page)
-- 7 = Deallocated by DBCC
--
-- Ideally, this query returns no results. The table is limited to 1000 rows.
-- If you do get results here, you should do further investigation to determine the root cause
--
-- Manage the suspect_pages Table
-- https://bit.ly/2Fvr1c9
-- ------------------------------------------------------------------------------------------------

select DB_NAME(database_id) as [Database Name], 
	   file_id, 
	   page_id, 
	   event_type, 
	   error_count, 
	   last_update_date
from msdb.dbo.suspect_pages with(nolock)
order by database_id option(recompile);
go