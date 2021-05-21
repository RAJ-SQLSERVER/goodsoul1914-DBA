-- Detailed overview of latches we've been waiting for?
-- ------------------------------------------------------------------------------------------------
WITH [Latches]
AS (
	SELECT latch_class,
		wait_time_ms / 1000.0 AS WaitS,
		waiting_requests_count AS WaitCount,
		100.0 * wait_time_ms / SUM(wait_time_ms) OVER () AS Percentage,
		ROW_NUMBER() OVER (
			ORDER BY wait_time_ms DESC
			) AS RowNum
	FROM sys.dm_os_latch_stats
	WHERE latch_class NOT IN ('BUFFER')
		--AND [wait_time_ms] > 0   
	)
SELECT MAX(W1.latch_class) AS LatchClass,
	CAST(MAX(W1.WaitS) AS DECIMAL(14, 2)) AS Wait_S,
	MAX(W1.WaitCount) AS WaitCount,
	CAST(MAX(W1.Percentage) AS DECIMAL(14, 2)) AS Percentage,
	CAST(MAX(W1.WaitS) / MAX(W1.WaitCount) AS DECIMAL(14, 4)) AS AvgWait_S
FROM Latches AS W1
INNER JOIN Latches AS W2 ON W2.RowNum <= W1.RowNum
GROUP BY W1.RowNum,
	W1.latch_class,
	W1.WaitS,
	W1.WaitCount,
	W1.Percentage
HAVING SUM(W2.Percentage) - W1.Percentage < 95;
GO

-- Identify latch waits
---------------------------------------------------------------------------------------------------
SELECT '[' + DB_NAME() + '].[' + OBJECT_SCHEMA_NAME(ddios.object_id) + '].[' + OBJECT_NAME(ddios.object_id) + ']' AS object_name,
	i.name AS index_name,
	ddios.page_io_latch_wait_count,
	ddios.page_io_latch_wait_in_ms,
	ddios.page_io_latch_wait_in_ms / ddios.page_io_latch_wait_count AS avg_page_io_latch_wait_in_ms
FROM sys.dm_db_index_operational_stats(DB_ID(), NULL, NULL, NULL) AS ddios
INNER JOIN sys.indexes AS i ON ddios.object_id = i.object_id
	AND i.index_id = ddios.index_id
WHERE ddios.page_io_latch_wait_count > 0
	AND OBJECTPROPERTY(i.object_id, 'IsUserTable') = 1
ORDER BY ddios.page_io_latch_wait_count DESC,
	avg_page_io_latch_wait_in_ms DESC;
GO
