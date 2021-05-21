-- Overview of Locks per Database and Type 
SELECT DB.name AS DatabaseName,
	TL.request_mode AS ReqMode,
	TL.request_type AS ReqType,
	TL.request_status AS ReqStatus,
	TL.request_owner_type AS ReqOwner,
	COUNT(*) AS LocksCount
FROM sys.databases AS DB
INNER JOIN sys.dm_tran_locks AS TL ON DB.database_id = TL.resource_database_id
GROUP BY DB.name,
	TL.request_mode,
	TL.request_type,
	TL.request_status,
	TL.request_owner_type;
