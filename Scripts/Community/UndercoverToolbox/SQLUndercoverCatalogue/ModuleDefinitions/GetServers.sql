--Undercover Catalogue
--David Fowler
--Version 0.4.0 - 25 November 2019
--Module: Servers
--Script: Get

BEGIN


SELECT 
@@SERVERNAME AS ServerName, 
CAST(SERVERPROPERTY('collation') AS NVARCHAR(128)) AS Collation,
CAST(SERVERPROPERTY('Edition') AS NVARCHAR(128)) AS Edition, 
CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128)) AS VersionNo,
sqlserver_start_time AS ServerStartTime,
[cost threshold for parallelism] AS CostThreshold,
[max worker threads] AS MaxWorkerThreads,
[max degree of parallelism] AS [MaxDOP],
cpu_count AS CPUCount,
NULL AS NUMACount, --not implemented, needs a version check
physical_memory_kb / 1024 AS PhysicalMemoryMB,
[max server memory (MB)] AS MaxMemoryMB,
[min server memory (MB)] AS MinMemoryMB,
NULL AS MemoryModel,  --not implemented, needs a version check
CAST(SERVERPROPERTY('IsClustered') AS BIT) AS IsClustered,
virtual_machine_type_desc AS VMType
FROM sys.dm_os_sys_info,
(
	SELECT [max worker threads],[cost threshold for parallelism],[max degree of parallelism],[min server memory (MB)],[max server memory (MB)]
	FROM 
	(SELECT name, CAST(value_in_use AS INT) AS value_in_use
	FROM sys.configurations
	WHERE name in ('max worker threads','cost threshold for parallelism','max degree of parallelism','min server memory (MB)','max server memory (MB)')) AS Source
	PIVOT
	(
	MAX(value_in_use)
	FOR name IN ([max worker threads],[cost threshold for parallelism],[max degree of parallelism],[min server memory (MB)],[max server memory (MB)])
	)AS PivotTable
) AS config
END
