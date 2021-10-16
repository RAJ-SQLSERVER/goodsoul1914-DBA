/* Monitoring SQL Server blocking problems */

IF OBJECT_ID('tempdb..#EX_FilePath') IS NOT NULL
    DROP TABLE #EX_FilePath;
GO

SELECT s.name,
       CAST(t.target_data AS XML).value ('(EventFileTarget/File/@name)[1]', 'VARCHAR(MAX)') AS "fileName"
INTO #EX_FilePath
FROM sys.dm_xe_sessions AS s
INNER JOIN sys.dm_xe_session_targets AS t
    ON s.address = t.event_session_address
WHERE t.target_name = 'event_file';
DECLARE @EventFileTarget AS NVARCHAR(500);
SELECT @EventFileTarget = fileName
FROM #EX_FilePath
WHERE name = 'system_health';
SELECT *
FROM (
    SELECT n.value ('(@name)[1]', 'varchar(50)') AS "event_name",
           n.value ('(@package)[1]', 'varchar(50)') AS "package_name",
           n.value ('(@timestamp)[1]', 'datetime2') AS "utc_timestamp",
           n.value ('(data[@name="wait_type"]/text)[1]', 'nvarchar(max)') AS "wait_type",
           n.value ('(action[@name="session_id"]/value)[1]', 'bigint') AS "session_id",
           n.value ('(data[@name="duration"]/value)[1]', 'bigint') / 1000 AS "duration_ms",
           n.value ('(action[@name="sql_text"]/value)[1]', 'nvarchar(max)') AS "sql_text"
    FROM (
        SELECT CAST(event_data AS XML) AS "event_data"
        FROM sys.fn_xe_file_target_read_file (@EventFileTarget, NULL, NULL, NULL)
    ) AS ed
    CROSS APPLY ed.event_data.nodes ('event') AS q(n)
) AS TMP_TBL
WHERE event_name = 'wait_info'
	  AND wait_type LIKE 'LCK%'
ORDER BY utc_timestamp DESC;
GO
