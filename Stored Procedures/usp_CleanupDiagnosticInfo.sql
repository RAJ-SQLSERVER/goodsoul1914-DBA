IF OBJECT_ID('usp_CleanupDiagnosticInfo') IS NOT NULL
    DROP PROCEDURE dbo.usp_CleanupDiagnosticInfo;
GO

CREATE PROCEDURE usp_CleanupDiagnosticInfo
(@Weeks INT)
AS
BEGIN
    DECLARE @iWeeks INT = COALESCE(@Weeks, 4);

	IF OBJECT_ID('dbo.AgentLog') IS NOT NULL
    BEGIN
        DELETE dbo.AgentLog
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.ConfigurationValues') IS NOT NULL
    BEGIN
        DELETE dbo.ConfigurationValues
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;
    
    IF OBJECT_ID('dbo.DatabaseInfo') IS NOT NULL
    BEGIN
        DELETE dbo.DatabaseInfo
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

	IF OBJECT_ID('dbo.DatabasePrincipals') IS NOT NULL
    BEGIN
        DELETE dbo.DatabasePrincipals
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

	IF OBJECT_ID('dbo.ErrorLog') IS NOT NULL
    BEGIN
        DELETE dbo.ErrorLog
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.IndexUsageStats') IS NOT NULL
    BEGIN
        DELETE dbo.IndexUsageStats
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

	IF OBJECT_ID('dbo.ServerPrincipals') IS NOT NULL
    BEGIN
        DELETE dbo.ServerPrincipals
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.ServerProperties') IS NOT NULL
    BEGIN
        DELETE dbo.ServerProperties
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.VersionInfo') IS NOT NULL
    BEGIN
        DELETE dbo.VersionInfo
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.GlobalTraceFlags') IS NOT NULL
    BEGIN
        DELETE dbo.GlobalTraceFlags
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.ProcessMemory') IS NOT NULL
    BEGIN
        DELETE dbo.ProcessMemory
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.ServicesInfo') IS NOT NULL
    BEGIN
        DELETE dbo.ServicesInfo
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.StatisticsInfo') IS NOT NULL
    BEGIN
        DELETE dbo.StatisticsInfo
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.AgentJobs') IS NOT NULL
    BEGIN
        DELETE dbo.AgentJobs
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.AgentAlerts') IS NOT NULL
    BEGIN
        DELETE dbo.AgentAlerts
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.NUMAInfo') IS NOT NULL
    BEGIN
        DELETE dbo.NUMAInfo
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.SystemMemory') IS NOT NULL
    BEGIN
        DELETE dbo.SystemMemory
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.HardwareInfo') IS NOT NULL
    BEGIN
        DELETE dbo.HardwareInfo
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.MemoryDumpInfo') IS NOT NULL
    BEGIN
        DELETE dbo.MemoryDumpInfo
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.SuspectPages') IS NOT NULL
    BEGIN
        DELETE dbo.SuspectPages
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.DatabaseFilenamesAndPaths') IS NOT NULL
    BEGIN
        DELETE dbo.DatabaseFilenamesAndPaths
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.FixedDrives') IS NOT NULL
    BEGIN
        DELETE dbo.FixedDrives
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.VolumeInfo') IS NOT NULL
    BEGIN
        DELETE dbo.VolumeInfo
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.DriveLevelLatency') IS NOT NULL
    BEGIN
        DELETE dbo.DriveLevelLatency
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.IOLatencyByFile') IS NOT NULL
    BEGIN
        DELETE dbo.IOLatencyByFile
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.IOWarnings') IS NOT NULL
    BEGIN
        DELETE dbo.IOWarnings
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.DatabaseProperties') IS NOT NULL
    BEGIN
        DELETE dbo.DatabaseProperties
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.MissingIndexes') IS NOT NULL
    BEGIN
        DELETE dbo.MissingIndexes
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.VLFCounts') IS NOT NULL
    BEGIN
        DELETE dbo.VLFCounts
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.CPUUsageByDatabase') IS NOT NULL
    BEGIN
        DELETE dbo.CPUUsageByDatabase
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.IOUsageByDatabase') IS NOT NULL
    BEGIN
        DELETE dbo.IOUsageByDatabase
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.TotalBufferUsageByDatabase') IS NOT NULL
    BEGIN
        DELETE dbo.TotalBufferUsageByDatabase
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.TopWaits') IS NOT NULL
    BEGIN
        DELETE dbo.TopWaits
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.ConnectionCountsByIPAddress') IS NOT NULL
    BEGIN
        DELETE dbo.ConnectionCountsByIPAddress
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.CPUUtilizationHistory') IS NOT NULL
    BEGIN
        DELETE dbo.CPUUtilizationHistory
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.PLEByNUMANode') IS NOT NULL
    BEGIN
        DELETE dbo.PLEByNUMANode
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.MemoryClerkUsage') IS NOT NULL
    BEGIN
        DELETE dbo.MemoryClerkUsage
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

	IF OBJECT_ID('dbo.AgentJobErrors') IS NOT NULL
    BEGIN
        DELETE dbo.AgentJobErrors
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.UDFStatsByDatabase') IS NOT NULL
    BEGIN
        DELETE dbo.UDFStatsByDatabase
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.IdentityColumns') IS NOT NULL
    BEGIN
        DELETE dbo.IdentityColumns
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.DatabaseTriggers') IS NOT NULL
    BEGIN
        DELETE dbo.DatabaseTriggers
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;

    IF OBJECT_ID('dbo.PerformanceCounters') IS NOT NULL
    BEGIN
        DELETE dbo.PerformanceCounters
        WHERE CollectionTime < DATEADD(WEEK, -1 * @iWeeks, GETDATE());
    END;
END;