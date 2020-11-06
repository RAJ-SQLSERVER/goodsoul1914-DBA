/*============================================================================
  File:     sp_CheckPlanCache

  Summary:  This procedure looks at cache and totals the single-use plans
			to report the percentage of memory consumed (and therefore wasted)
			from single-use plans.
			
  Date:     April 2010

  Version:	2008.
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SQLskills.com
============================================================================*/

USE master;
GO

IF OBJECTPROPERTY(OBJECT_ID('sp_CheckPlanCache'), 'IsProcedure') = 1
    DROP PROCEDURE dbo.sp_CheckPlanCache;
GO

CREATE PROCEDURE dbo.sp_CheckPlanCache
(
    @Percent DECIMAL(6, 3) OUTPUT,
    @WastedMB DECIMAL(19, 3) OUTPUT
)
AS
SET NOCOUNT ON;

DECLARE @ConfiguredMemory   DECIMAL(19, 3),
        @PhysicalMemory     DECIMAL(19, 3),
        @MemoryInUse        DECIMAL(19, 3),
        @SingleUsePlanCount BIGINT;

CREATE TABLE #ConfigurationOptions
(
    name NVARCHAR(35),
    minimum INT,
    maximum INT,
    config_value INT, -- in bytes
    run_value INT     -- in bytes
);
INSERT #ConfigurationOptions
EXEC ('sp_configure ''max server memory''');

SELECT @ConfiguredMemory = run_value / 1024 / 1024
FROM   #ConfigurationOptions
WHERE  name = 'max server memory (MB)';

SELECT @PhysicalMemory = total_physical_memory_kb / 1024
FROM   sys.dm_os_sys_memory;

SELECT @MemoryInUse = physical_memory_in_use_kb / 1024
FROM   sys.dm_os_process_memory;

SELECT @WastedMB = SUM(CAST((CASE
                                 WHEN usecounts = 1
                                      AND objtype IN ( 'Adhoc', 'Prepared' ) THEN
                                     size_in_bytes
                                 ELSE
                                     0
                             END
                            ) AS DECIMAL(12, 2))
                   ) / 1024 / 1024,
       @SingleUsePlanCount = SUM(CASE
                                     WHEN usecounts = 1
                                          AND objtype IN ( 'Adhoc', 'Prepared' ) THEN
                                         1
                                     ELSE
                                         0
                                 END
                             ),
       @Percent = @WastedMB / @MemoryInUse * 100
FROM   sys.dm_exec_cached_plans;

SELECT @PhysicalMemory AS [TotalPhysicalMemory (MB)],
       @ConfiguredMemory AS [TotalConfiguredMemory (MB)],
       @ConfiguredMemory / @PhysicalMemory * 100 AS [MaxMemoryAvailableToSQLServer (%)],
       @MemoryInUse AS [MemoryInUseBySQLServer (MB)],
       @WastedMB AS [TotalSingleUsePlanCache (MB)],
       @SingleUsePlanCount AS TotalNumberOfSingleUsePlans,
       @Percent AS [PercentOfConfiguredCacheWastedForSingleUsePlans (%)];
GO

EXEC sys.sp_MS_marksystemobject 'sp_CheckPlanCache';
GO

-----------------------------------------------------------------
-- Logic (in a job?) to decide whether or not to clear - using sproc...
-----------------------------------------------------------------

DECLARE @Percent    DECIMAL(6, 3),
        @WastedMB   DECIMAL(19, 3),
        @StrMB      NVARCHAR(20),
        @StrPercent NVARCHAR(20);

EXEC dbo.sp_CheckPlanCache @Percent OUTPUT, @WastedMB OUTPUT;

SELECT @StrMB = CONVERT(NVARCHAR(20), @WastedMB),
       @StrPercent = CONVERT(NVARCHAR(20), @Percent);

IF @Percent > 10
   OR @WastedMB > 10
BEGIN
    DBCC FREESYSTEMCACHE('SQL Plans');
    RAISERROR(
        '%s MB (%s percent) was allocated to single-use plan cache. Single-use plans have been cleared.', 10, 1, @StrMB, @StrPercent);
END;
ELSE
BEGIN
    RAISERROR(
        'Only %s MB (%s percent) is allocated to single-use plan cache - no need to clear cache now.', 10, 1, @StrMB, @StrPercent
    );
-- Note: this is only a warning message and not an actual error.
END;
GO