EXEC sys.xp_readerrorlog 0, 1, N'detected', N'socket';
-- SQL Server detected 2 sockets with 24 cores per socket ...

DECLARE @Sockets INT = 2;
DECLARE @PhysicalCoresPerSocket INT = 24;
DECLARE @TicksPerSpin INT = 4;

DECLARE @SpinlockSnapshot TABLE
(
    SpinLockName VARCHAR(100),
    SpinTotal BIGINT
);

INSERT @SpinlockSnapshot (SpinLockName, SpinTotal)
SELECT name,
       spins
FROM   sys.dm_os_spinlock_stats
WHERE  spins > 0;

DECLARE @Ticks BIGINT;
SELECT @Ticks = cpu_ticks
FROM   sys.dm_os_sys_info;

WAITFOR DELAY '00:00:10';

DECLARE @TotalTicksInInterval BIGINT;
DECLARE @CPU_GHz NUMERIC(20, 2);

SELECT @TotalTicksInInterval = (cpu_ticks - @Ticks) * @Sockets * @PhysicalCoresPerSocket,
       @CPU_GHz = (cpu_ticks - @Ticks) / 10000000000.0
FROM   sys.dm_os_sys_info;

SELECT   ISNULL(Snap.SpinLockName, 'Total') AS "Spinlock Name",
         SUM(Stat.spins - Snap.SpinTotal) AS "Spins In Interval",
         @TotalTicksInInterval AS "Ticks In Interval",
         @CPU_GHz AS "Measured CPU GHz",
         100.0 * SUM(Stat.spins - Snap.SpinTotal) * @TicksPerSpin / @TotalTicksInInterval AS "%"
FROM     @SpinlockSnapshot AS Snap
JOIN     sys.dm_os_spinlock_stats AS Stat
    ON Snap.SpinLockName = Stat.name
GROUP BY ROLLUP(Snap.SpinLockName)
HAVING   SUM(Stat.spins - Snap.SpinTotal) > 0
ORDER BY [Spins In Interval] DESC;