-- List all Locks of the Current Database 
---------------------------------------------------------------------------------------------------
SELECT TL.resource_type AS ResType,
	TL.resource_description AS ResDescr,
	TL.request_mode AS ReqMode,
	TL.request_type AS ReqType,
	TL.request_status AS ReqStatus,
	TL.request_owner_type AS ReqOwnerType,
	TAT.name AS TransName,
	TAT.transaction_begin_time AS TransBegin,
	DATEDIFF(ss, TAT.transaction_begin_time, GETDATE()) AS TransDura,
	ES.session_id AS S_Id,
	ES.login_name AS LoginName,
	COALESCE(OBJ.name, PAROBJ.name) AS ObjectName,
	PARIDX.name AS IndexName,
	ES.host_name AS HostName,
	ES.program_name AS ProgramName
FROM sys.dm_tran_locks AS TL
INNER JOIN sys.dm_exec_sessions AS ES ON TL.request_session_id = ES.session_id
LEFT JOIN sys.dm_tran_active_transactions AS TAT ON TL.request_owner_id = TAT.transaction_id
	AND TL.request_owner_type = 'TRANSACTION'
LEFT JOIN sys.objects AS OBJ ON TL.resource_associated_entity_id = OBJ.object_id
	AND TL.resource_type = 'OBJECT'
LEFT JOIN sys.partitions AS PAR ON TL.resource_associated_entity_id = PAR.hobt_id
	AND TL.resource_type IN ('PAGE', 'KEY', 'RID', 'HOBT')
LEFT JOIN sys.objects AS PAROBJ ON PAR.object_id = PAROBJ.object_id
LEFT JOIN sys.indexes AS PARIDX ON PAR.object_id = PARIDX.object_id
	AND PAR.index_id = PARIDX.index_id
WHERE TL.resource_database_id = DB_ID()
	AND ES.session_id <> @@Spid -- Exclude "my" session 
	-- optional filter  
	AND TL.request_mode <> 'S' -- Exclude simple shared locks 
ORDER BY TL.resource_type,
	TL.request_mode,
	TL.request_type,
	TL.request_status,
	ObjectName,
	ES.login_name;
GO

-- Identify locking and blocking at the row level
---------------------------------------------------------------------------------------------------
SELECT '[' + DB_NAME(ddios.database_id) + '].[' + su.name + '].[' + o.name + ']' AS [statement],
	i.name AS 'index_name',
	ddios.partition_number,
	ddios.row_lock_count,
	ddios.row_lock_wait_count,
	CAST(100.0 * ddios.row_lock_wait_count / ddios.row_lock_count AS DECIMAL(5, 2)) AS [%_times_blocked],
	ddios.row_lock_wait_in_ms,
	CAST(1.0 * ddios.row_lock_wait_in_ms / ddios.row_lock_wait_count AS DECIMAL(15, 2)) AS avg_row_lock_wait_in_ms
FROM sys.dm_db_index_operational_stats(DB_ID(), NULL, NULL, NULL) AS ddios
INNER JOIN sys.indexes AS i ON ddios.object_id = i.object_id
	AND i.index_id = ddios.index_id
INNER JOIN sys.objects AS o ON ddios.object_id = o.object_id
INNER JOIN sys.sysusers AS su ON o.schema_id = su.UID
WHERE ddios.row_lock_wait_count > 0
	AND OBJECTPROPERTY(ddios.object_id, 'IsUserTable') = 1
	AND i.index_id > 0
ORDER BY ddios.row_lock_wait_count DESC,
	su.name,
	o.name,
	i.name;
GO


