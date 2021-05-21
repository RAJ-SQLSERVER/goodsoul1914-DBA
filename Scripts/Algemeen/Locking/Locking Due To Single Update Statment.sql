-- Locking due to single UPDATE statement against a user table in SQL Server
---------------------------------------------------------------------------------------------------
SELECT resource_type,
	DB_NAME(resource_database_id) AS [Database Name],
	CASE 
		WHEN DTL.resource_type IN ('DATABASE', 'FILE', 'METADATA')
			THEN DTL.resource_type
		WHEN DTL.resource_type = 'OBJECT'
			THEN OBJECT_NAME(DTL.resource_associated_entity_id, DTL.resource_database_id)
		WHEN DTL.resource_type IN ('KEY', 'PAGE', 'RID')
			THEN (
					SELECT OBJECT_NAME(object_id)
					FROM sys.partitions
					WHERE sys.partitions.hobt_id = DTL.resource_associated_entity_id
					)
		ELSE 'Unidentified'
		END AS requested_object_name,
	request_mode,
	resource_description
FROM sys.dm_tran_locks AS DTL
WHERE DTL.resource_type <> 'DATABASE';
GO


