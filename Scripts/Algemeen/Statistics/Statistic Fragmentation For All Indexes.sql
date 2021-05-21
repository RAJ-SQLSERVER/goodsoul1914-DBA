-- Statistic Fragmentation For All Database Objects
-- ------------------------------------------------------------------------------------------------
SELECT OBJECT_NAME(IDX.OBJECT_ID) AS Table_Name,
	IDX.name AS Index_Name,
	IDXPS.index_type_desc AS Index_Type,
	IDXPS.avg_fragmentation_in_percent AS Fragmentation_Percentage
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) AS IDXPS
INNER JOIN sys.indexes AS IDX ON IDX.object_id = IDXPS.object_id
	AND IDX.index_id = IDXPS.index_id
ORDER BY Fragmentation_Percentage DESC;
GO


