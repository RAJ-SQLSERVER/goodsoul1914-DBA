USE [DBA]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwDatabaseProperties]
AS
SELECT CollectionTime,
       ROW_NUMBER() OVER (PARTITION BY DatabaseName ORDER BY CollectionTime) AS CollectionNumber,
       DatabaseName,
       DatabaseOwner,
       RecoveryModel,
       State,
       Containment,
       LogReuseWaitDescription,
       LogSizeMB,
       LogUsedMB,
       LogUsedPercentage,
       DBCompatibilityLevel,
       IsMixedPageAllocationOn,
       PageVerifyOption,
       IsAutoCreateStatsOn,
       IsAutoUpdateStatsOn,
       IsAutoUpdateStatsAsyncOn,
       IsParameterizationForced,
       SnapshotIsolationStateDesc,
       IsReadCommittedSnapshotOn,
       IsAutoCloseOn,
       IsAutoShrinkOn,
       TargetRecoveryTimeInSeconds,
       IsCDCEnabled,
       IsPublished,
       IsDistributor,
       GroupDatabaseID,
       ReplicaID,
       IsSyncWithBackup,
       IsSupplementalLoggingEnabled,
       IsEncrypted,
       EncryptionState,
       PercentComplete,
       KeyAlgorithm,
       KeyLength
FROM DBA.dbo.DatabaseProperties;         
GO
