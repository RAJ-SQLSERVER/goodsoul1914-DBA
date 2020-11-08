IF OBJECTPROPERTY(OBJECT_ID('sp_CheckPlanCache'), 'IsProcedure') = 1
    DROP PROCEDURE sp_CheckPlanCache;
GO

CREATE PROCEDURE dbo.sp_CheckPlanCache
(
    @Percent DECIMAL(6, 3) OUTPUT,
    @WastedMB DECIMAL(19, 3) OUTPUT
)
AS
BEGIN
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

    SELECT @ConfiguredMemory = c.run_value / 1024 / 1024
    FROM   #ConfigurationOptions AS c
    WHERE  c.name = 'max server memory (MB)';

    SELECT @PhysicalMemory = omem.total_physical_memory_kb / 1024
    FROM   sys.dm_os_sys_memory AS omem;

    SELECT @MemoryInUse = pmem.physical_memory_in_use_kb / 1024
    FROM   sys.dm_os_process_memory AS pmem;

    SELECT @WastedMB = SUM(   CAST((CASE
                                        WHEN cp.usecounts = 1
                                             AND cp.objtype IN ( 'Adhoc', 'Prepared' ) THEN
                                            cp.size_in_bytes
                                        ELSE
                                            0
                                    END
                                   ) AS DECIMAL(18, 2))
                          ) / 1024 / 1024,
           @SingleUsePlanCount = SUM(   CASE
                                            WHEN cp.usecounts = 1
                                                 AND cp.objtype IN ( 'Adhoc', 'Prepared' ) THEN
                                                1
                                            ELSE
                                                0
                                        END
                                    ),
           @Percent = @WastedMB / @MemoryInUse * 100
    FROM   sys.dm_exec_cached_plans AS cp;

    SELECT @PhysicalMemory AS "TotalPhysicalMemory (MB)",
           @ConfiguredMemory AS "TotalConfiguredMemory (MB)",
           @ConfiguredMemory / @PhysicalMemory * 100 AS "MaxMemoryAvailableToSQLServer (%)",
           @MemoryInUse AS "MemoryInUseBySQLServer (MB)",
           @WastedMB AS "TotalSingleUsePlanCache (MB)",
           @SingleUsePlanCount AS "TotalNumberOfSingleUsePlans",
           @Percent AS "PercentOfConfiguredCacheWastedForSingleUsePlans (%)";
END;
GO

--EXEC sys.sp_MS_marksystemobject 'sp_CheckPlanCache';
--GO