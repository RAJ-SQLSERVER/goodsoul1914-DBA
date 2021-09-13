-- Filtering out blocked and blocking session information
SELECT tl1.resource_type AS "Resource Type",
       DB_NAME (tl1.resource_database_id) AS "DB Name",
       CASE tl1.resource_type
           WHEN 'OBJECT' THEN OBJECT_NAME (tl1.resource_associated_entity_id, tl1.resource_database_id)
           WHEN 'DATABASE' THEN 'DB'
           ELSE CASE
                    WHEN tl1.resource_database_id = DB_ID () THEN (
                        SELECT OBJECT_NAME (object_id, tl1.resource_database_id)
                        FROM sys.partitions
                        WHERE hobt_id = tl1.resource_associated_entity_id
                    )
                    ELSE '(Run under DB context)'
                END
       END AS "Object",
       tl1.resource_description AS "Resource",
       tl1.request_session_id AS "Session",
       tl1.request_mode AS "Mode",
       tl1.request_status AS "Status",
       wt.wait_duration_ms AS "Wait (ms)",
       qi.sql,
       qi.query_plan
FROM sys.dm_tran_locks AS tl1 WITH (NOLOCK)
JOIN sys.dm_tran_locks AS tl2 WITH (NOLOCK)
    ON tl1.resource_associated_entity_id = tl2.resource_associated_entity_id
LEFT OUTER JOIN sys.dm_os_waiting_tasks AS wt WITH (NOLOCK)
    ON tl1.lock_owner_address = wt.resource_address
       AND tl1.request_status = 'WAIT'
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
    WHERE tl1.request_session_id = er.session_id
) AS qi
WHERE tl1.request_status <> tl2.request_status
      AND (
          tl1.resource_description = tl2.resource_description
          OR (tl1.resource_description IS NULL AND tl2.resource_description IS NULL)
      )
OPTION (RECOMPILE);