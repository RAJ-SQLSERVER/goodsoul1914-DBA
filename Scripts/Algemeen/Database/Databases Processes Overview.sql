-- Databases Processes Overview 
---------------------------------------------------------------------------------------------------
WITH pro
AS (
	SELECT PRO.dbid,
		COUNT(*) AS Processes,
		SUM(PRO.cpu) AS CPU,
		SUM(PRO.physical_io) AS PhysicalIO,
		SUM(PRO.memusage) AS MemUsage,
		MAX(PRO.last_batch) AS LastBatch,
		SUM(PRO.open_tran) AS OPENTRAN,
		COUNT(DISTINCT PRO.sid) AS Users,
		COUNT(DISTINCT PRO.hostname) AS Host
	FROM sys.sysprocesses AS PRO
	GROUP BY PRO.dbid
	)
SELECT DB.name AS DatabaseName,
	pro.*,
	DB.log_reuse_wait_desc AS LogReUse
FROM sys.databases AS DB
LEFT JOIN pro ON DB.database_id = pro.dbid
ORDER BY DB.name;
