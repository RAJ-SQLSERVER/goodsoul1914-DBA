-- Current IO and CPU Workload 
SET NOCOUNT ON;

-- Clean up temp table, if still exists. 
IF NOT OBJECT_ID('tempdb..#processes') IS NULL
    DROP TABLE #processes;
GO

-- Create snapshot of current processes in a temp table 
SELECT PRC.spid,
       PRC.login_time,
       PRC.ecid,
       PRC.[sid],
       PRC.cpu,
       PRC.physical_io
INTO #processes
FROM sys.sysprocesses AS PRC
WHERE PRC.spid <> @@SPID; -- Exclude own process 
GO

-- Wait a few seconds before comparing snapshot 
-- with current processes 
WAITFOR DELAY '00:00:02'; -- 2 seconds 
GO

-- Get total difference to calculate percentage values. 
DECLARE @cpuDiff INT,
        @ioDiff INT;

SELECT @cpuDiff = SUM(ACT.cpu - SNP.cpu),
       @ioDiff = SUM(ACT.physical_io - SNP.physical_io)
FROM sys.sysprocesses AS ACT
    INNER JOIN #processes AS SNP
        ON ACT.spid = SNP.spid
           AND ACT.[sid] = SNP.[sid]
WHERE ACT.spid <> @@SPID -- Exclude own process 
      AND SNP.ecid <= 1;

-- Join snapshot and current process to get delta values. 
SELECT ACT.cpu - SNP.cpu AS CpuDiff,
       ACT.physical_io - SNP.physical_io AS IoDiff,
       CASE
           WHEN @cpuDiff = 0.0 THEN
               0.0
           ELSE
               CONVERT(DECIMAL(10, 2), 100.0 * (ACT.cpu - SNP.cpu) / @cpuDiff)
       END AS [Cpu %],
       CASE
           WHEN @ioDiff = 0 THEN
               0.0
           ELSE
               CONVERT(DECIMAL(10, 2), 100.0 * (ACT.physical_io - SNP.physical_io) / @ioDiff)
       END AS [IO %],
       ACT.spid AS Spid,
       ACT.waitresource AS WaitResource,
       DB.name AS DataBaseName,
       ACT.hostname AS HostName,
       ACT.[program_name] AS ProgramName,
       ACT.loginame AS LoginName,
       ACT.cmd AS Command,
       EST.[text] AS SQLStatement
FROM sys.sysprocesses AS ACT
    INNER JOIN #processes AS SNP
        ON ACT.spid = SNP.spid
           AND ACT.[sid] = SNP.[sid]
           AND ACT.login_time = SNP.login_time
    LEFT JOIN sys.databases AS DB
        ON ACT.dbid = DB.database_id
    CROSS APPLY sys.dm_exec_sql_text(ACT.sql_handle) AS EST
WHERE ACT.spid <> @@SPID -- Exclude own process 
      AND SNP.ecid <= 1
      AND
      (
          (ACT.cpu - SNP.cpu) > 0
          OR (ACT.physical_io - SNP.physical_io) > 0
      )
ORDER BY ACT.cpu - SNP.cpu + ACT.physical_io - SNP.physical_io DESC;
GO

-- Clean up temp table 
DROP TABLE #processes;
GO


