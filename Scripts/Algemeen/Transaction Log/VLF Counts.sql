SELECT [name] AS [Database Name],
	[VLF Count]
FROM sys.databases AS db WITH (NOLOCK)
CROSS APPLY (
	SELECT file_id,
		COUNT(*) AS [VLF Count]
	FROM sys.dm_db_log_info(db.database_id)
	GROUP BY file_id
	) AS li
ORDER BY [VLF Count] DESC
OPTION (RECOMPILE);
