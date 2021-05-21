-- Updates statistics for indexes that were never updated (Recompiles the table afterwards)
--
-- select * from sys.objects
-- select * from sys.sysindexes
-- select * from sys.schemas
---------------------------------------------------------------------------------------------------
DECLARE @sql NVARCHAR(max);

SELECT @sql = COALESCE(@sql, ';') + 'UPDATE STATISTICS [' + ss.name + '].[' + OBJECT_NAME(id) + '] ([' + si.name + ']) WITH FULLSCAN; 
EXEC SP_RECOMPILE ''[' + ss.name + '].[' + OBJECT_NAME(id) + ']'';'
FROM sys.sysindexes AS si
JOIN sys.objects AS so ON so.object_id = si.id
JOIN sys.schemas AS ss ON so.schema_id = ss.schema_id
WHERE indid > 0
	AND rowcnt > 0
	AND OBJECTPROPERTY(id, 'IsMsShipped') = 0
	AND STATS_DATE(id, indid) IS NULL;

--exec sp_executesql @sql;
SELECT @sql;
GO


