/*
	Clearing *JUST* the 'SQL Plans' based on *just* the amount of Adhoc/Prepared 
	single-use plans (2005 and higher):
*/

DECLARE @MB DECIMAL(19, 3),
        @Count BIGINT,
        @StrMB NVARCHAR(20);

SELECT @MB = SUM(   CAST((CASE
                              WHEN usecounts = 1 AND objtype IN ( 'Adhoc', 'Prepared' ) THEN size_in_bytes
                              ELSE 0
                          END
                         ) AS DECIMAL(12, 2))
                ) / 1024 / 1024,
       @Count = SUM(   CASE
                           WHEN usecounts = 1 AND objtype IN ( 'Adhoc', 'Prepared' ) THEN 1
                           ELSE 0
                       END
                   ),
       @StrMB = CONVERT(NVARCHAR(20), @MB)
FROM sys.dm_exec_cached_plans;

IF @MB > 10
BEGIN
    DBCC FREESYSTEMCACHE('SQL Plans');
    RAISERROR('%s MB was allocated to single-use plan cache. Single-use plans have been cleared.', 10, 1, @StrMB);
END;
ELSE
BEGIN
    RAISERROR('Only %s MB is allocated to single-use plan cache – no need to clear cache now.', 10, 1, @StrMB);
	-- Note: this is only a warning message and not an actual error.
END;
GO


/*
	Clearing *ALL* of your cache based on the total amount of wasted by 
	single-use plans (2005 and higher):
*/

DECLARE @MB DECIMAL(19, 3),
        @Count BIGINT,
        @StrMB NVARCHAR(20);

SELECT @MB = SUM(   CAST((CASE
                              WHEN usecounts = 1 THEN size_in_bytes
                              ELSE 0
                          END
                         ) AS DECIMAL(12, 2))
                ) / 1024 / 1024,
       @Count = SUM(   CASE
                           WHEN usecounts = 1 THEN 1
                           ELSE 0
                       END
                   ),
       @StrMB = CONVERT(NVARCHAR(20), @MB)
FROM sys.dm_exec_cached_plans;

IF @MB > 1000
    DBCC FREEPROCCACHE;
ELSE
    RAISERROR('Only %s MB is allocated to single-use plan cache – no need to clear cache now.', 10, 1, @StrMB);
GO
