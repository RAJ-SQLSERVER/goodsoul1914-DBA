SELECT   type_desc,
         (
             SELECT name FROM sys.schemas WHERE schema_id = ob.schema_id
         ) AS "schema",
         CASE parent_object_id
             WHEN '0' THEN
                 name
             ELSE
                 OBJECT_NAME(parent_object_id) + '.' + name
         END AS "object_name",
         create_date,
         modify_date -- or create-date if there isn't one
FROM     sys.objects AS ob
WHERE    is_ms_shipped = 0 -- exclude system-objects
--AND [type] = 'P' -- just stored-procedures
ORDER BY modify_date DESC;