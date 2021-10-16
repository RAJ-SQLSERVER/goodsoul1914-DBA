-- Find single-use, ad-hoc and prepared queries that are bloating the plan cache
--
-- Gives you the text, type and size of single-use ad-hoc 
-- and prepared queries that waste space in the plan cache
-- Enabling 'optimize for ad hoc workloads' for the instance can help 
-- Running DBCC FREESYSTEMCACHE ('SQL Plans') periodically may be required to better control this
-- Enabling forced parameterization for the database can help, but test first!
--
-- Plan cache, adhoc workloads and clearing the single-use plan cache bloat
-- https://bit.ly/2EfYOkl
--
-- ------------------------------------------------------------------------------------------------

SELECT TOP (50) DB_NAME (t.dbid) AS "Database Name",
                t.text AS "Query Text",
                cp.objtype AS "Object Type",
                cp.size_in_bytes / 1024 AS "Plan Size in KB"
FROM sys.dm_exec_cached_plans AS cp WITH (NOLOCK)
CROSS APPLY sys.dm_exec_sql_text (plan_handle) AS t
WHERE cp.cacheobjtype = N'Compiled Plan'
      AND cp.objtype IN ( N'Adhoc', N'Prepared' )
      AND cp.usecounts = 1
ORDER BY cp.size_in_bytes DESC,
         DB_NAME (t.dbid)
OPTION (RECOMPILE);
GO

-- Find single-use, ad hoc queries that are bloating the plan cache
---------------------------------------------------------------------------------------------------

SELECT TOP (100) text,
                 cp.size_in_bytes
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_sql_text (plan_handle)
WHERE cp.cacheobjtype = 'Compiled Plan'
      AND cp.objtype = 'Adhoc'
      AND cp.usecounts = 1
ORDER BY cp.size_in_bytes DESC;
GO

