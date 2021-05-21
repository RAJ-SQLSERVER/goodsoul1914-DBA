CREATE TABLE #SecretPlans (Phase INT, Task VARCHAR(50));
INSERT INTO #SecretPlans (Phase, Task)
VALUES (1, 'Collect underpants'),
       (2, 'To be determined'),
       (3, 'Profit!');

SELECT *
FROM #SecretPlans;
GO

/* Open another window and try to access the temo table */


USE tempdb;
GO

SELECT *
FROM sys.all_objects;
GO
-- #SecretPlans________________________________________________________________________________________________________000000000B7B


SELECT *
FROM #SecretPlans________________________________________________________________________________________________________000000000B7B;
GO


SELECT s.*
FROM sys.all_objects AS o
LEFT OUTER JOIN sys.stats AS s
    ON o.object_id = s.object_id
WHERE o.name = '#SecretPlans________________________________________________________________________________________________________000000000B7B';
GO
-- No stats yet!


SELECT *
FROM #SecretPlans
WHERE Task = 'Profit!';
GO


-------------------------------------------------------------------------------
-- Have statistics been created now?
-------------------------------------------------------------------------------
SELECT s.*
FROM sys.all_objects AS o
LEFT OUTER JOIN sys.stats AS s
    ON o.object_id = s.object_id
WHERE o.name = '#SecretPlans________________________________________________________________________________________________________000000000B7B';
GO
-- _WA_Sys_00000002_AE277C55


-------------------------------------------------------------------------------
-- Show statistic details
-------------------------------------------------------------------------------
DBCC SHOW_STATISTICS(#SecretPlans, _WA_Sys_00000002_AE277C55);

-- or more modern...

SELECT hist.*
FROM sys.all_objects AS o
LEFT OUTER JOIN sys.stats AS s
    ON o.object_id = s.object_id
CROSS APPLY sys.dm_db_stats_histogram (o.object_id, s.stats_id) AS hist
WHERE o.name = '#SecretPlans________________________________________________________________________________________________________000000000B7B';
GO
--range_high_key
--Collect underpants
--Profit!
--To be determined


-------------------------------------------------------------------------------
-- Show statistics for all user tables
-------------------------------------------------------------------------------
SELECT o.name AS "temp_table_name",
       hist.*
FROM sys.all_objects AS o
LEFT OUTER JOIN sys.stats AS s
    ON o.object_id = s.object_id
CROSS APPLY sys.dm_db_stats_histogram (o.object_id, s.stats_id) AS hist
WHERE o.type_desc = 'USER_TABLE';
GO


-------------------------------------------------------------------------------
-- Check out what's happening in TempDB
-------------------------------------------------------------------------------
SELECT o.name AS "temp_table_name",
       c.name AS "column_name",
       c.column_id,
       hist.object_id,
       hist.step_number,
       hist.range_high_key,
       hist.range_rows,
       hist.equal_rows,
       hist.distinct_range_rows,
       hist.average_range_rows
FROM sys.all_objects AS o
LEFT OUTER JOIN sys.stats AS s
    ON o.object_id = s.object_id
LEFT OUTER JOIN sys.stats_columns AS sc
    ON o.object_id = sc.object_id
       AND s.stats_id = sc.stats_id
LEFT OUTER JOIN sys.all_columns AS c
    ON o.object_id = c.object_id
       AND sc.column_id = c.column_id
CROSS APPLY sys.dm_db_stats_histogram (o.object_id, s.stats_id) AS hist
WHERE o.type_desc = 'USER_TABLE'
ORDER BY o.name,
         c.column_id,
         hist.stats_id,
         hist.step_number;
GO


-------------------------------------------------------------------------------
-- Clean up
-------------------------------------------------------------------------------
DROP TABLE #SecretPlans;
GO
