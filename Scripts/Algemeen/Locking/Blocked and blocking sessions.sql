SELECT tl.resource_type AS "Resource Type",
       DB_NAME (tl.resource_database_id) AS "DB Name",
       CASE tl.resource_type
           WHEN 'OBJECT' THEN OBJECT_NAME (tl.resource_associated_entity_id, tl.resource_database_id)
           WHEN 'DATABASE' THEN 'DB'
           ELSE CASE
                    WHEN tl.resource_database_id = DB_ID () THEN (
                        SELECT OBJECT_NAME (object_id, tl.resource_database_id)
                        FROM sys.partitions
                        WHERE hobt_id = tl.resource_associated_entity_id
                    )
                    ELSE '(Run under DB context)'
                END
       END AS "Object",
       tl.resource_description AS "Resource",
       tl.request_session_id AS "Session",
       tl.request_mode AS "Mode",
       tl.request_status AS "Status",
       wt.wait_duration_ms AS "Wait (ms)",
       qi.sql,
       qi.query_plan
FROM sys.dm_tran_locks AS tl WITH (NOLOCK)
LEFT OUTER JOIN sys.dm_os_waiting_tasks AS wt WITH (NOLOCK)
    ON tl.lock_owner_address = wt.resource_address
       AND tl.request_status = 'WAIT'
OUTER APPLY (
    SELECT SUBSTRING (s.text,
                      (er.statement_start_offset / 2) + 1,
                      ((CASE er.statement_end_offset
                            WHEN -1 THEN DATALENGTH (s.text)
                            ELSE er.statement_end_offset
                        END - er.statement_start_offset
                       ) / 2
                      ) + 1
           ) AS "sql",
           qp.query_plan
    FROM sys.dm_exec_requests AS er WITH (NOLOCK)
    CROSS APPLY sys.dm_exec_sql_text (er.sql_handle) AS s
    CROSS APPLY sys.dm_exec_query_plan (er.plan_handle) AS qp
    WHERE tl.request_session_id = er.session_id
) AS qi
WHERE tl.request_session_id <> @@spid
ORDER BY tl.request_session_id
OPTION (RECOMPILE);