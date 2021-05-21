-- Returns information about currently active lock manager resources in SQL Server 2019 (15.x). 
-- Each row represents a currently active request to the lock manager for a lock that has been 
-- granted or is waiting to be granted.
--
-- The columns in the result set are divided into two main groups: resource and request. 
-- The resource group describes the resource on which the lock request is being made, and the 
-- request group describes the lock request.
--
-- resource_type					Type of resource on which the lock is applied.
-- resource_database_id				The database ID to which the resource belongs.
-- resource_description				Additional description of the resource.
-- resource_associated_entity_id	ID of the entity to which the resource is associated. This includes Object ID, HOBT ID or Allocation Unit ID based on the resource type.
-- resource_lock_partition			Partition of the resource on which lock is acquired.
-- request_mode						Granted requests are shown as grant. Waiting requests show the mode of request.
-- request_type						It is always LOCK.
-- request_status					Status of the requested lock. The values can be GRANTED, CONVERT, WAIT, LOW_PRIORITY_CONVERT/WAIT or ABORT_BLOCKERS.
-- request_session_id				Session IS of the requested session. -2 is used for orphaned transactions and -3 is used for deferred transactions.
-- request_request_id				Execution contect of the request to which the lock request belongs.
-- request_owner_type				Entity type that owns the request. Possible values are TRANSACTION, SESSION, SHARED_TRANSACTION_WORKSPACE, EXCLUSIVE_TRANSACTION_WORKSPACE and NOTIFICATION_OBJECT.
-- request_owner_id					ID of the owner of the resource. E.g.: Transaction ID.
-- lock_owner_address				Maps to resource_address in sys.dm_os_waiting_tasks.
--
---------------------------------------------------------------------------------------------------
SELECT Resource_type,
	Resource_database_id,
	Resource_description,
	Resource_associated_entity_id,
	Resource_lock_partition,
	Request_mode,
	Request_type,
	Request_status,
	Request_session_id,
	Request_request_id,
	Request_owner_type,
	Request_owner_id,
	Lock_owner_address
FROM sys.dm_tran_locks
WHERE request_session_id = @@SPID;
GO


