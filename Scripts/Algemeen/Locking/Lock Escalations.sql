-- Identify lock escalations
---------------------------------------------------------------------------------------------------
SELECT OBJECT_NAME(ddios.object_id, ddios.database_id) AS object_name,
	i.name AS index_name,
	ddios.index_id,
	ddios.partition_number,
	ddios.index_lock_promotion_attempt_count,
	ddios.index_lock_promotion_count,
	ddios.index_lock_promotion_attempt_count / ddios.index_lock_promotion_count AS percent_success
FROM sys.dm_db_index_operational_stats(DB_ID(), NULL, NULL, NULL) AS ddios
INNER JOIN sys.indexes AS i ON ddios.object_id = i.object_id
	AND ddios.index_id = i.index_id
WHERE ddios.index_lock_promotion_count > 0
ORDER BY index_lock_promotion_count DESC;
GO


