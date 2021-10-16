-- Investigating locking and blocking based on waiting tasks
---------------------------------------------------------------------------------------------------
SELECT DTL.resource_type AS "resource type",
       CASE
           WHEN DTL.resource_type IN ( 'DATABASE', 'FILE', 'METADATA' ) THEN DTL.resource_type
           WHEN DTL.resource_type = 'OBJECT' THEN OBJECT_NAME (DTL.resource_associated_entity_id)
           WHEN DTL.resource_type IN ( 'KEY', 'PAGE', 'RID' ) THEN (
               SELECT OBJECT_NAME (object_id)
               FROM sys.partitions
               WHERE sys.partitions.hobt_id = DTL.resource_associated_entity_id
           )
           ELSE 'Unidentified'
       END AS "Parent Object",
       DTL.request_mode AS "Lock Type",
       DTL.request_status AS "Request Status",
       DOWT.wait_duration_ms AS "wait duration ms",
       DOWT.wait_type AS "wait type",
       DOWT.session_id AS "blocked session id",
       DES_blocked.login_name AS "blocked_user",
       SUBSTRING (
           DEST_Blocked.text,
           DER.statement_start_offset / 2,
           (CASE
                WHEN DER.statement_end_offset = -1 THEN DATALENGTH (DEST_Blocked.text)
                ELSE DER.statement_end_offset
            END - DER.statement_start_offset
           ) / 2
       ) AS "blocked_command",
       DOWT.blocking_session_id AS "blocking session id",
       DES_blocking.login_name AS "blocking user",
       DEST_Blocking.text AS "blocking command",
       DOWT.resource_description AS "blocking resource detail"
FROM sys.dm_tran_locks AS DTL
INNER JOIN sys.dm_os_waiting_tasks AS DOWT
    ON DTL.lock_owner_address = DOWT.resource_address
INNER JOIN sys.dm_exec_requests AS DER
    ON DOWT.session_id = DER.session_id
INNER JOIN sys.dm_exec_sessions AS DES_blocked
    ON DOWT.session_id = DES_blocked.session_id
INNER JOIN sys.dm_exec_sessions AS DES_blocking
    ON DOWT.blocking_session_id = DES_blocking.session_id
INNER JOIN sys.dm_exec_connections AS DEC
    ON DTL.request_session_id = DEC.most_recent_session_id
CROSS APPLY sys.dm_exec_sql_text (DEC.most_recent_sql_handle) AS DEST_Blocking
CROSS APPLY sys.dm_exec_sql_text (DER.sql_handle) AS DEST_Blocked
WHERE DTL.resource_database_id = DB_ID ();
GO