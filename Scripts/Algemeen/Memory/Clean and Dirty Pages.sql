-- How many clean and dirty pages in the buffer pool per-database
--
-- A clean page is one that has not been changed since it was read into 
-- memory or last written to disk. A dirty page is one that has not been 
-- written to disk since it was last changed. Dirty pages are not dropped 
-- by DBCC DROPCLEANBUFFERS, they are only made clean by writing them to disk 
-- (either through one of the various kinds of checkpoints or by the lazy writer)
--
-- If you want to ensure that all pages from a database are flushed from 
-- memory, you need to first perform a manual CHECKPOINT of that database 
-- and then run DBCC DROPCLEANBUFFERS
-------------------------------------------------------------------------------
SELECT *,
	DirtyPageCount * 8 / 1024 AS DirtyPageMB,
	CleanPageCount * 8 / 1024 AS CleanPageMB
FROM (
	SELECT CASE 
			WHEN database_id = 32767
				THEN N'Resource Database'
			ELSE DB_NAME(database_id)
			END AS DatabaseName,
		SUM(CASE 
				WHEN is_modified = 1
					THEN 1
				ELSE 0
				END) AS DirtyPageCount,
		SUM(CASE 
				WHEN is_modified = 1
					THEN 0
				ELSE 1
				END) AS CleanPageCount
	FROM sys.dm_os_buffer_descriptors
	GROUP BY database_id
	) AS buffers
ORDER BY DatabaseName;
GO

-- 
-------------------------------------------------------------------------------
SELECT CASE 
		WHEN database_id = 32767
			THEN 'Resource Database'
		ELSE DB_NAME(database_id)
		END AS [Database Name],
	SUM(CASE 
			WHEN is_modified = 1
				THEN 1
			ELSE 0
			END) AS DirtyPageCount,
	SUM(CASE 
			WHEN is_modified = 1
				THEN 0
			ELSE 1
			END) AS CleanPageCount
FROM sys.dm_os_buffer_descriptors
GROUP BY database_id
ORDER BY DB_NAME(database_id);
GO
