USE Credit;

/* ----------------------------------------------------------------------------
 sys.dm_db_index_physical_stats – Day 1 – One DMV a day
---------------------------------------------------------------------------- */
SELECT     DB_NAME(ips.database_id) AS DBName,
           OBJECT_NAME(i.id) AS TableName,
           i.name AS IndexName,
           ips.avg_fragmentation_in_percent,
           ips.fragment_count,
           ips.page_count,
           ips.record_count
FROM       sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('member'), NULL, NULL, 'DETAILED') AS ips
INNER JOIN sys.sysindexes AS i ON ips.index_id = i.indid
                                  AND i.id = OBJECT_ID('member');
GO

/*

LIMITED – Fastest scan which scans only the non-leaf level pages of the index.

SAMPLED – 1 % of the total pages is sampled to get the stats. 
		  Up to 10000 pages, this scans all pages.

DETAILED – This scans al the pages in the index and is considered most heavy 
		   scan.

*/


/* ----------------------------------------------------------------------------
 sys.dm_db_index_usage_stats – Day 2 – One DMV a Day

 Sys.dm_db_index_usage_stats is a dynamic management view and has the data 
 cumulative since the instance restart for all the indexes which are used at 
 least once. First time the index is used a record is added to the view and 
 all the counters/values are set to zero. When an index is used for seek, 
 scan, lookup or is updated the respective column is incremented. 
---------------------------------------------------------------------------- */

SET NOCOUNT ON;
GO

-- Create dump table for select
IF EXISTS (SELECT 1 FROM tempdb.dbo.sysobjects WHERE name LIKE '#dump%')
    DROP TABLE #dump;

SELECT *
INTO   #dump
FROM   dbo.member
WHERE  1 = 0;

-- Take a dump of sys.dm_db_index_usage_stats
IF EXISTS (SELECT 1 FROM tempdb.dbo.sysobjects WHERE name LIKE '#x1%')
    DROP TABLE #x1;

SELECT *
INTO   #x1
FROM   sys.dm_db_index_usage_stats
WHERE  database_id = 6
       AND object_id = 245575913
       AND index_id = 1;

-- run a index seek operation 100 times
DECLARE @i INT = 0;

WHILE @i < 100
BEGIN

    INSERT INTO #dump
    SELECT *
    FROM   dbo.member
    WHERE  member_no = 10;
    SET @i = @i + 1;
END;

-- Check the differential change in user_seeks count
SELECT     curr.user_seeks - old.user_seeks AS Total_Seeks,
           old.last_user_seek AS last_Seek,
           curr.last_user_seek AS curr_seek
FROM       sys.dm_db_index_usage_stats AS curr
INNER JOIN #x1 AS old ON curr.database_id = old.database_id
                         AND curr.object_id = old.object_id
                         AND curr.index_id = old.index_id;

SET NOCOUNT OFF;
GO

