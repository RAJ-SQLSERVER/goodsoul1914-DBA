
-------------------------------------BEGIN CheckDBCheckTableResult-------------------------------
IF NOT EXISTS (SELECT *  FROM sys.indexes  WHERE name='clustExecDateDBName' 
    AND object_id = OBJECT_ID('Minion.CheckDBCheckTableResult'))
BEGIN
CREATE CLUSTERED INDEX [clustExecDateDBName] ON [Minion].[CheckDBCheckTableResult]
(
	[ExecutionDateTime] ASC,
	[DBName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END

IF NOT EXISTS (SELECT *  FROM sys.indexes  WHERE name='nonDBSchemaTable' 
    AND object_id = OBJECT_ID('Minion.CheckDBCheckTableResult'))
BEGIN
CREATE NONCLUSTERED INDEX [nonDBSchemaTable] ON [Minion].[CheckDBCheckTableResult]
(
	[DBName] ASC,
	[SchemaName] ASC,
	[TableName] ASC
)
INCLUDE ( 	[ExecutionDateTime]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END


-------------------------------------END CheckDBCheckTableResult---------------------------------

-------------------------------------BEGIN CheckDBCheckTableThreadQueue-------------------------------
IF NOT EXISTS (SELECT *  FROM sys.indexes  WHERE name='clustExecDateDBName' 
    AND object_id = OBJECT_ID('Minion.CheckDBCheckTableThreadQueue'))
BEGIN
CREATE CLUSTERED INDEX [clustExecDateDBName] ON [Minion].[CheckDBCheckTableThreadQueue]
(
	[ExecutionDateTime] ASC,
	[DBName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END
-------------------------------------END CheckDBCheckTableThreadQueue---------------------------------


-------------------------------------BEGIN CheckDBLog-------------------------------
IF NOT EXISTS (SELECT *  FROM sys.indexes  WHERE name='clustExecDate' 
    AND object_id = OBJECT_ID('Minion.CheckDBLog'))
BEGIN
CREATE CLUSTERED INDEX [clustExecDate] ON [Minion].CheckDBLog
(
	[ExecutionDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END
-------------------------------------END CheckDBLog---------------------------------


-------------------------------------BEGIN CheckDBLogDetails-------------------------------
IF NOT EXISTS (SELECT *  FROM sys.indexes  WHERE name='clustID' 
    AND object_id = OBJECT_ID('Minion.CheckDBLogDetails'))
BEGIN
CREATE UNIQUE CLUSTERED INDEX [clustID] ON [Minion].[CheckDBLogDetails]
(
	[ID] ASC
)WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
END

IF NOT EXISTS (SELECT *  FROM sys.indexes  WHERE name='nonExecDBOp' 
    AND object_id = OBJECT_ID('Minion.CheckDBLogDetails'))
BEGIN
CREATE NONCLUSTERED INDEX [nonExecDBOp] ON [Minion].[CheckDBLogDetails]
(
	[ExecutionDateTime] ASC,
	[CheckDBName] ASC,
	[OpName] ASC
)
INCLUDE ( 	[ID]) WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
END

IF NOT EXISTS (SELECT *  FROM sys.indexes  WHERE name='nonExecStatusDBName' 
    AND object_id = OBJECT_ID('Minion.CheckDBLogDetails'))
BEGIN
CREATE NONCLUSTERED INDEX [nonExecStatusDBName] ON [Minion].[CheckDBLogDetails]
(
	[ExecutionDateTime] ASC,
	[DBName] ASC
)
INCLUDE ( 	[STATUS]) WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
END

IF NOT EXISTS (SELECT *  FROM sys.indexes  WHERE name='nonOpEndTime' 
    AND object_id = OBJECT_ID('Minion.CheckDBLogDetails'))
BEGIN
CREATE NONCLUSTERED INDEX [nonOpEndTime] ON [Minion].[CheckDBLogDetails]
(
	[OpEndTime] DESC,
	[DBName] ASC,
	[OpName] ASC,
	[SchemaName] ASC,
	[TableName] ASC
)
WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
END
-------------------------------------END CheckDBLogDetails---------------------------------

-------------------------------------BEGIN CheckDBResult---------------------------------
IF NOT EXISTS (SELECT *  FROM sys.indexes  WHERE name='ClustExecDBName' 
    AND object_id = OBJECT_ID('Minion.CheckDBResult'))
BEGIN
CREATE CLUSTERED INDEX [ClustExecDBName] ON [Minion].[CheckDBResult]
(
	[ExecutionDateTime] ASC,
	[DBName] ASC
)WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
END
-------------------------------------END CheckDBResult-----------------------------------

-------------------------------------BEGIN CheckDBRotationDBs---------------------------------
IF NOT EXISTS (SELECT *  FROM sys.indexes  WHERE name='clustExecDateDBName' 
    AND object_id = OBJECT_ID('Minion.CheckDBRotationDBs'))
BEGIN
CREATE CLUSTERED INDEX [clustExecDateDBName] ON [Minion].[CheckDBRotationDBs]
(
	[ExecutionDateTime] ASC,
	[DBName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END
-------------------------------------END CheckDBRotationDBs-----------------------------------

-------------------------------------BEGIN CheckDBRotationTables---------------------------------
IF NOT EXISTS (SELECT *  FROM sys.indexes  WHERE name='clustExecDateDBName' 
    AND object_id = OBJECT_ID('Minion.CheckDBRotationTables'))
BEGIN
CREATE CLUSTERED INDEX [clustExecDateDBName] ON [Minion].[CheckDBRotationTables]
(
	[ExecutionDateTime] ASC,
	[DBName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END
-------------------------------------END CheckDBRotationTables-----------------------------------

-------------------------------------BEGIN CheckDBSnapshotLog---------------------------------
IF NOT EXISTS (SELECT *  FROM sys.indexes  WHERE name='clustExecDate' 
    AND object_id = OBJECT_ID('Minion.CheckDBSnapshotLog'))
BEGIN
CREATE CLUSTERED INDEX [clustExecDate] ON [Minion].[CheckDBSnapshotLog]
(
	[ExecutionDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END
-------------------------------------END CheckDBSnapshotLog-----------------------------------

-------------------------------------BEGIN CheckDBTableSizeTemp---------------------------------
IF NOT EXISTS (SELECT *  FROM sys.indexes  WHERE name='clustExecDateDBName' 
    AND object_id = OBJECT_ID('Minion.CheckDBTableSizeTemp'))
BEGIN
CREATE CLUSTERED INDEX [clustExecDateDBName] ON [Minion].[CheckDBTableSizeTemp]
(
	[ExecutionDateTime] ASC,
	[DBName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END
-------------------------------------END CheckDBTableSizeTemp-----------------------------------


-------------------------------------BEGIN CheckDBThreadQueue---------------------------------
IF NOT EXISTS (SELECT *  FROM sys.indexes  WHERE name='clustExecDateDBName' 
    AND object_id = OBJECT_ID('Minion.CheckDBThreadQueue'))
BEGIN
CREATE CLUSTERED INDEX [clustExecDateDBName] ON [Minion].[CheckDBThreadQueue]
(
	[ExecutionDateTime] ASC,
	[DBName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END
-------------------------------------END CheckDBThreadQueue-----------------------------------






