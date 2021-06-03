IF ( SELECT COUNT(*) FROM Minion.IndexSettingsDB) = 0
BEGIN
    INSERT INTO Minion.IndexSettingsDB
    (
        [DBName],
        [Port],
        [Exclude],
        [ReindexGroupOrder],
        [ReindexOrder],
        [ReorgThreshold],
        [RebuildThreshold],
        [FILLFACTORopt],
        [PadIndex],
        [ONLINEopt],
        [SortInTempDB],
        [MAXDOPopt],
        [DataCompression],
        [GetRowCT],
        [GetPostFragLevel],
        [UpdateStatsOnDefrag],
        [StatScanOption],
        [IgnoreDupKey],
        [StatsNoRecompute],
        [AllowRowLocks],
        [AllowPageLocks],
        [WaitAtLowPriority],
        [MaxDurationInMins],
        [AbortAfterWait],
        [PushToMinion],
        [LogIndexPhysicalStats],
        [IndexScanMode],
        [DBPreCode],
        [DBPostCode],
        [TablePreCode],
        [TablePostCode],
        [LogProgress],
        [LogRetDays],
        [MinionTriggerPath],
        [RecoveryModel],
        [IncludeUsageDetails],
        [StmtPrefix],
        [StmtSuffix],
        [RebuildHeap]
    )
    SELECT 'MinionDefault' AS [DBName],
        NULL AS [Port],
        0 AS [Exclude],
        0 AS [ReindexGroupOrder],
        0 AS [ReindexOrder],
        10 AS [ReorgThreshold],
        20 AS [RebuildThreshold],
        90 AS [FILLFACTORopt],
        'ON' AS [PadIndex],
        NULL AS [ONLINEopt],
        NULL AS [SortInTempDB],
        NULL AS [MAXDOPopt],
        NULL AS [DataCompression],
        1 AS [GetRowCT],
        1 AS [GetPostFragLevel],
        1 AS [UpdateStatsOnDefrag],
        NULL AS [StatScanOption],
        NULL AS [IgnoreDupKey],
        NULL AS [StatsNoRecompute],
        NULL AS [AllowRowLocks],
        NULL AS [AllowPageLocks],
        NULL AS [WaitAtLowPriority],
        NULL AS [MaxDurationInMins],
        NULL AS [AbortAfterWait],
        NULL AS [PushToMinion],
        NULL AS [LogIndexPhysicalStats],
        NULL AS [IndexScanMode],
        NULL AS [DBPreCode],
        NULL AS [DBPostCode],
        NULL AS [TablePreCode],
        NULL AS [TablePostCode],
        1 AS [LogProgress],
        60 AS [LogRetDays],
        NULL AS [MinionTriggerPath],
        NULL AS [RecoveryModel],
        1 AS [IncludeUsageDetails],
        NULL AS [StmtPrefix],
        NULL AS [StmtSuffix],
        0 AS [RebuildHeap];
END;

--------------------------
IF ( SELECT COUNT(*) FROM Minion.IndexMaintSettingsServer ) = 0
BEGIN

    INSERT INTO Minion.IndexMaintSettingsServer
    (
        [DBType],
        [IndexOption],
        [ReorgMode],
        [RunPrepped],
        [PrepOnly],
        [Day],
        [BeginTime],
        [EndTime],
        [MaxForTimeframe],
        [FrequencyMins],
        [CurrentNumOps],
        [NumConcurrentOps],
        [DBInternalThreads],
        [TimeLimitInMins],
        [LastRunDateTime],
        [Include],
        [Exclude],
        [Schemas],
        [Tables],
        [BatchPreCode],
        [BatchPostCode],
        [Debug],
        [FailJobOnError],
        [FailJobOnWarning],
        [IsActive],
        [Comment]
    )
    SELECT 'All' AS [DBType],
        'ALL' AS [IndexOption],
        'ALL' AS [ReorgMode],
        0 AS [RunPrepped],
        0 AS [PrepOnly],
        'Saturday' AS [Day],
        '01:00:00' AS [BeginTime],
        '03:00:00' AS [EndTime],
        1 AS [MaxForTimeframe],
        NULL AS [FrequencyMins],
        0 AS [CurrentNumOps],
        NULL AS [NumConcurrentOps],
        NULL AS [DBInternalThreads],
        NULL AS [TimeLimitInMins],
        NULL AS [LastRunDateTime],
        NULL AS [Include],
        NULL AS [Exclude],
        NULL AS [Schemas],
        NULL AS [Tables],
        NULL AS [BatchPreCode],
        NULL AS [BatchPostCode],
        0 AS [Debug],
        0 AS [FailJobOnError],
        0 AS [FailJobOnWarning],
        1 AS [IsActive],
        'Saturday Rebuild' AS [Comment];

    INSERT INTO Minion.IndexMaintSettingsServer
    (
        [DBType],
        [IndexOption],
        [ReorgMode],
        [RunPrepped],
        [PrepOnly],
        [Day],
        [BeginTime],
        [EndTime],
        [MaxForTimeframe],
        [FrequencyMins],
        [CurrentNumOps],
        [NumConcurrentOps],
        [DBInternalThreads],
        [TimeLimitInMins],
        [LastRunDateTime],
        [Include],
        [Exclude],
        [Schemas],
        [Tables],
        [BatchPreCode],
        [BatchPostCode],
        [Debug],
        [FailJobOnError],
        [FailJobOnWarning],
        [IsActive],
        [Comment]
    )
    SELECT 'All' AS [DBType],
        'ALL' AS [IndexOption],
        'REORG' AS [ReorgMode],
        0 AS [RunPrepped],
        0 AS [PrepOnly],
        'Weekday' AS [Day],
        '23:00:00' AS [BeginTime],
        '23:59:00' AS [EndTime],
        1 AS [MaxForTimeframe],
        NULL AS [FrequencyMins],
        0 AS [CurrentNumOps],
        NULL AS [NumConcurrentOps],
        NULL AS [DBInternalThreads],
        NULL AS [TimeLimitInMins],
        NULL AS [LastRunDateTime],
        NULL AS [Include],
        NULL AS [Exclude],
        NULL AS [Schemas],
        NULL AS [Tables],
        NULL AS [BatchPreCode],
        NULL AS [BatchPostCode],
        0 AS [Debug],
        0 AS [FailJobOnError],
        0 AS [FailJobOnWarning],
        1 AS [IsActive],
        'Weekday Reorg' AS [Comment];

END;