-- Get index blocking wait stats
SELECT t.name AS "tableName",
       i.name AS "indexName",
       ios.row_lock_wait_count,
       ios.row_lock_wait_in_ms,
       ios.page_lock_wait_count,
       ios.page_lock_wait_in_ms
FROM sys.dm_db_index_operational_stats (DB_ID (), NULL, NULL, NULL) AS ios
JOIN sys.indexes AS i
    ON i.object_id = ios.object_id
       AND i.index_id = ios.index_id
JOIN sys.tables AS t
    ON ios.object_id = t.object_id
WHERE ios.row_lock_wait_in_ms + ios.page_lock_wait_in_ms > 0
ORDER BY ios.row_lock_wait_in_ms + ios.page_lock_wait_in_ms DESC;


BEGIN TRY
    DROP TABLE #IndexBlockingWaitStats;
END TRY
BEGIN CATCH
-- swallow error
END CATCH;

SELECT object_id,
       index_id,
       row_lock_wait_count,
       row_lock_wait_in_ms,
       page_lock_wait_count,
       page_lock_wait_in_ms
INTO #IndexBlockingWaitStats
FROM sys.dm_db_index_operational_stats (DB_ID (), NULL, NULL, NULL);


-- Get delta results
SELECT t.name AS "tableName",
       i.name AS "indexName",
       ios.row_lock_wait_count - iossnapshot.row_lock_wait_count AS "row_lock_wait_count",
       ios.row_lock_wait_in_ms - iossnapshot.row_lock_wait_in_ms AS "row_lock_wait_in_ms",
       ios.page_lock_wait_count - iossnapshot.page_lock_wait_count AS "page_lock_wait_count",
       ios.page_lock_wait_in_ms - iossnapshot.page_lock_wait_in_ms AS "page_lock_wait_in_ms"
FROM sys.dm_db_index_operational_stats (DB_ID (), NULL, NULL, NULL) AS ios
JOIN #IndexBlockingWaitStats AS iossnapshot
    ON iossnapshot.object_id = ios.object_id
       AND iossnapshot.index_id = ios.index_id
JOIN sys.indexes AS i
    ON i.object_id = ios.object_id
       AND i.index_id = ios.index_id
JOIN sys.tables AS t
    ON ios.object_id = t.object_id
CROSS APPLY (
    SELECT (ios.row_lock_wait_in_ms + ios.page_lock_wait_in_ms)
           - (iossnapshot.row_lock_wait_in_ms + iossnapshot.page_lock_wait_in_ms)
) AS calc(totalwaittime)
WHERE totalwaittime > 0
ORDER BY totalwaittime DESC;