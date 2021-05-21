-- 
SELECT objtype AS [CacheType],
	COUNT_BIG(*) AS [Total Plans],
	SUM(CAST(size_in_bytes AS DECIMAL(18, 2))) / 1024 / 1024 AS [Total MBs],
	AVG(usecounts) AS [Avg Use Count],
	SUM(CAST((
				CASE 
					WHEN usecounts = 1
						THEN size_in_bytes
					ELSE 0
					END
				) AS DECIMAL(18, 2))) / 1024 / 1024 AS [Total MBs � USE Count 1],
	SUM(CASE 
			WHEN usecounts = 1
				THEN 1
			ELSE 0
			END) AS [Total Plans � USE Count 1]
FROM sys.dm_exec_cached_plans
GROUP BY objtype
ORDER BY [Total MBs � USE Count 1] DESC;

--  single-use plans in the plan cache
SELECT TEXT,
	cp.objtype,
	cp.size_in_bytes
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
WHERE cp.cacheobjtype = N'Compiled Plan'
	AND cp.objtype IN (N'Adhoc', N'Prepared')
	AND cp.usecounts = 1
ORDER BY cp.size_in_bytes DESC
OPTION (RECOMPILE);

-- 
SELECT objtype AS [CacheType],
	count_big(*) AS [Total Plans],
	sum(cast(size_in_bytes AS DECIMAL(18, 2))) / 1024 / 1024 AS [Total MBs],
	avg(usecounts) AS [Avg Use Count],
	sum(cast((
				CASE 
					WHEN usecounts = 1
						THEN size_in_bytes
					ELSE 0
					END
				) AS DECIMAL(18, 2))) / 1024 / 1024 AS [Total MBs - USE Count 1],
	sum(CASE 
			WHEN usecounts = 1
				THEN 1
			ELSE 0
			END) AS [Total Plans - USE Count 1]
FROM sys.dm_exec_cached_plans
GROUP BY objtype
ORDER BY [Total MBs - USE Count 1] DESC

SELECT EventTime,
	record.value('(/Record/ResourceMonitor/Notification)[1]', 'varchar(max)') AS [Type],
	record.value('(/Record/ResourceMonitor/IndicatorsProcess)[1]', 'int') AS [IndicatorsProcess],
	record.value('(/Record/ResourceMonitor/IndicatorsSystem)[1]', 'int') AS [IndicatorsSystem],
	record.value('(/Record/MemoryRecord/AvailablePhysicalMemory)[1]', 'bigint') AS [Avail Phys Mem, Kb],
	record.value('(/Record/MemoryRecord/AvailableVirtualAddressSpace)[1]', 'bigint') AS [Avail VAS, Kb]
FROM (
	SELECT DATEADD(ss, (- 1 * ((cpu_ticks / CONVERT(FLOAT, (cpu_ticks / ms_ticks))) - [timestamp]) / 1000), GETDATE()) AS EventTime,
		CONVERT(XML, record) AS record
	FROM sys.dm_os_ring_buffers
	CROSS JOIN sys.dm_os_sys_info
	WHERE ring_buffer_type = 'RING_BUFFER_RESOURCE_MONITOR'
	) AS tab
ORDER BY EventTime DESC;
