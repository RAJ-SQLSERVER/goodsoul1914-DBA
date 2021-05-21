IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'nonDBNameTableID')
	CREATE INDEX nonDBNameTableID
	ON Minion.IndexTableFrag (DBName, TableID, IndexID) 
	INCLUDE (ONLINEopt)
    WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF,
             ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90
         );
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'nonExecDateDBName')
    CREATE NONCLUSTERED INDEX [nonExecDateDBName]
    ON [Minion].[IndexTableFrag] ([ExecutionDateTime] ASC)
    INCLUDE
    (
        [DBName],
        [SchemaName],
        [TableName]
    )
    WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF,
             ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90
         );
GO




/****** Object:  Index [nonExecDateDBName]    Script Date: 2/23/2017 2:41:58 PM ******/
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'nonExecDateDBName2')
    DROP INDEX [nonExecDateDBName] ON [Minion].[IndexMaintLogDetails];
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'nonExecDateDBNameLogDet')
    CREATE NONCLUSTERED INDEX [nonExecDateDBNameLogDet]
    ON [Minion].[IndexMaintLogDetails]
    (
        [ExecutionDateTime] ASC,
        [DBName] ASC,
        [SchemaName] ASC,
        [TableName] ASC,
        [IndexName] ASC
    )
    INCLUDE ([Warnings])
    WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF,
             ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90
         );
GO



/****** Object:  Index [ixIndexMaintLogDate]    Script Date: 2/23/2017 2:42:09 PM ******/
IF NOT EXISTS
(
    SELECT *
    FROM sys.indexes
    WHERE name = 'ixIndexMaintLogDate'
)
    CREATE NONCLUSTERED INDEX [ixIndexMaintLogDate]
    ON [Minion].[IndexMaintLog]
    (
        [ExecutionDateTime] ASC,
        [DBName] ASC
    )
    WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF,
             ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90
         );
GO

