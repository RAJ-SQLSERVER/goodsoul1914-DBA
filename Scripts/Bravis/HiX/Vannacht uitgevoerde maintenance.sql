SELECT	[SchemaName]
		, [ObjectName]
		, [IndexName]
		, [IndexType]
		, [StatisticsName]
		, [CommandType]
		, [StartTime]
		, [EndTime]
		, [ErrorNumber]
		, [ErrorMessage]
FROM [ZKH_Maintenance].[dbo].[CommandLog]
WHERE DatabaseName = 'HIX_PRODUCTIE' AND DATEDIFF(day, StartTime, GETDATE()) < 1
ORDER BY StartTime DESC;
