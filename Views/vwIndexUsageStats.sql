SELECT [CollectionTime],
       ROW_NUMBER() OVER(PARTITION BY TableName, IndexName ORDER BY CollectionTime) AS CollectionNumber,
       [SchemaName],
       [TableName],
       [IndexName],
       [UserSeeks],
       [UserScans],
       [UserLookups],
       [UserUpdates]
FROM [DBA].[dbo].[IndexUsageStats]
WHERE DatabaseName = 'HIX_PRODUCTIE'
ORDER BY TableName,
         IndexName;