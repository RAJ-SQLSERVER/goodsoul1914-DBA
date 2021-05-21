SELECT *
FROM sys.dm_exec_cached_plans
WHERE objtype = 'Proc'

SELECT name,
	type,
	clock_hand,
	clock_status,
	rounds_count,
	removed_all_rounds_count,
	updated_last_round_count,
	removed_last_round_count,
	last_round_start_time
FROM sys.dm_os_memory_cache_clock_hands
ORDER BY removed_last_round_count DESC

SELECT *
FROM sys.dm_os_ring_buffers

--CACHESTORE_OBJCP are compiled plans for stored procedures, functions and triggers.
--CACHESTORE_SQLCP are cached SQL statements or batches that aren't in stored procedures, functions and triggers.  This includes any dynamic SQL or raw SELECT statements sent to the server.
--CACHESTORE_PHDR are algebrizer trees for views, constraints and defaults (Bound trees).  An algebrizer tree is the parsed SQL text that resolves the table and column names.
SELECT *
FROM sys.dm_os_memory_clerks

SELECT *
FROM sys.dm_os_memory_cache_entries

--DBCC FREESYSTEMCACHE ('TokenAndPermUserStore')
SELECT TOP 100 objtype,
	usecounts,
	p.size_in_bytes / 1024 'IN KB',
	LEFT([sql].[text], 100) AS [text]
FROM sys.dm_exec_cached_plans p
OUTER APPLY sys.dm_exec_sql_text(p.plan_handle) sql
ORDER BY usecounts DESC

SELECT count(*) AS Buffered_Page_Count,
	count(*) * 8192 / (1024 * 1024) AS Buffer_Pool_MB
FROM sys.dm_os_buffer_descriptors

-- Query to find different type of objects are in plan cache:
-- Overview of the size of the plan cache used by object type
-- Queries which substitute place holders in place of actual values are called Prepared statements
SELECT objtype AS 'Cached Object Type',
	COUNT(*) AS 'Number of Plans',
	SUM(CAST(size_in_bytes AS BIGINT)) / 1024 / 1024 AS 'Plan Cache Size (MB)',
	AVG(usecounts) AS 'Avg Use Count'
FROM sys.dm_exec_cached_plans
GROUP BY objtype
ORDER BY 'Plan Cache Size (MB)' DESC

-- Adhoc,prepared queries which are bloating plancache and are used only once:
SELECT q.query_hash,
	q.number_of_entries,
	t.TEXT AS sample_query,
	p.query_plan AS sample_plan
FROM (
	SELECT TOP 20 query_hash,
		count(*) AS number_of_entries,
		min(sql_handle) AS sample_sql_handle,
		min(plan_handle) AS sample_plan_handle
	FROM sys.dm_exec_query_stats
	GROUP BY query_hash
	HAVING count(*) > 1
	ORDER BY count(*) DESC
	) AS q
CROSS APPLY sys.dm_exec_sql_text(q.sample_sql_handle) AS t
CROSS APPLY sys.dm_exec_query_plan(q.sample_plan_handle) AS p

-- To Delete statements which are bloating plan cache:
DECLARE @MB DECIMAL(19, 3),
	@Count BIGINT,
	@StrMB NVARCHAR(20)

SELECT @MB = sum(cast((
				CASE 
					WHEN usecounts = 1
						AND objtype IN ('Adhoc', 'Prepared')
						THEN size_in_bytes
					ELSE 0
					END
				) AS DECIMAL(12, 2))) / 1024 / 1024,
	@Count = sum(CASE 
			WHEN usecounts = 1
				AND objtype IN ('Adhoc', 'Prepared')
				THEN 1
			ELSE 0
			END),
	@StrMB = convert(NVARCHAR(20), @MB)
FROM sys.dm_exec_cached_plans

IF @MB > 10
BEGIN
	DBCC FREESYSTEMCACHE ('SQL Plans')

	RAISERROR (
			'%s MB was allocated to single-use plan cache. Single-use plans have been cleared.',
			10,
			1,
			@StrMB
			)
END
ELSE
BEGIN
	RAISERROR (
			'Only %s MB is allocated to single-use plan cache � no need to clear cache now.',
			10,
			1,
			@StrMB
			)
		-- Note: this is only a warning message and not an actual error.
END
GO

-- A Small Collection of Useful DBCC Commands
-- Glenn Berry 
-- August 2010
-- http://glennberrysqlperformance.spaces.live.com/
-- Twitter: GlennAlanBerry
-- Clears out contents of buffer cache
-- Use caution before doing this on a production system!
DBCC DROPCLEANBUFFERS;

-- Clears procedure cache on entire SQL instance
DBCC FREEPROCCACHE;

-- Remove the specific plan from the cache using the plan handle
DBCC FREEPROCCACHE (0x060006001ECA270EC0215D05000000000000000000000000);

-- Clear ad-hoc SQL plans for entire SQL instance
DBCC FREESYSTEMCACHE ('SQL Plans');

-- Clears TokenAndPermUserStore cache on entire SQL instance
DBCC FREESYSTEMCACHE ('TokenAndPermUserStore');

-- Releases all unused cache entries from all caches. ALL specifies all supported caches
-- Asynchronously frees currently used entries from their respective caches after they become unused
DBCC FREESYSTEMCACHE ('ALL')
WITH MARK_IN_USE_FOR_REMOVAL;

-- Determine the id of the current database
-- and flush the procedure cache for only that database
DECLARE @intDBID AS INT = (
		SELECT DB_ID()
		);

DBCC FLUSHPROCINDB(@intDBID);

-- Clear Wait Stats for entire instance
DBCC SQLPERF (
		'sys.dm_os_wait_stats',
		CLEAR
		);

-- Get VLF count for transaction log for the current database,
-- number of rows equals VLF count. Lower is better!
DBCC LOGINFO;

-- Returns lots of useful information about memory usage
DBCC MEMORYSTATUS;

-- Find oldest open transaction
DBCC OPENTRAN;

-- Get input buffer for a SPID
DBCC INPUTBUFFER (21);

-- Check trace status for instance
DBCC TRACESTATUS (- 1)
