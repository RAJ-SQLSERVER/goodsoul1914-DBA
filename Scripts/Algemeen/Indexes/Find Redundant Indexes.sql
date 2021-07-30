;WITH ind AS
(
    SELECT a.object_id,
           a.index_id,
           CAST(col_list.list AS VARCHAR(MAX)) AS "list"
    FROM (SELECT DISTINCT object_id, index_id FROM sys.index_columns) AS a
    CROSS APPLY (
        SELECT TOP 100 PERCENT CAST(column_id AS VARCHAR(16)) + ',' AS "text()"
        FROM sys.index_columns AS b
        JOIN sys.indexes AS i
            ON b.object_id = i.object_id
               AND b.index_id = i.index_id
        WHERE a.object_id = b.object_id
              AND a.index_id = b.index_id
              AND i.is_primary_key = 0
              AND b.is_included_column = 0
        ORDER BY b.key_ordinal ASC
        FOR XML PATH (''), TYPE
    ) AS col_list(list)
)
SELECT DB_NAME () AS "DatabaseName",
       OBJECT_SCHEMA_NAME (a.object_id) AS "SchemaName",
       OBJECT_NAME (a.object_id) AS "TableName",
       asi.rowcnt AS "RowCount",
       asi.name AS "FatherIndex",
       bsi.name AS "RedundantIndex",
       (
           SELECT TOP 100 PERCENT QUOTENAME (c.name) + ' ' + CASE
                                                                 WHEN ic.is_included_column = 1 THEN N'(INCLUDE)'
                                                                 WHEN ic.is_descending_key = 1 THEN N'DESC'
                                                                 ELSE N'ASC'
                                                             END + ',' AS "text()"
           FROM sys.index_columns AS ic
           INNER JOIN sys.columns AS c
               ON c.object_id = ic.object_id
                  AND ic.column_id = c.column_id
           WHERE a.object_id = ic.object_id
                 AND a.index_id = ic.index_id
           ORDER BY ic.is_included_column ASC,
                    ic.key_ordinal ASC
           FOR XML PATH ('')
       ) AS "FatherIndexColumns",
       (
           SELECT TOP 100 PERCENT QUOTENAME (c.name) + ' ' + CASE
                                                                 WHEN ic.is_included_column = 1 THEN N'(INCLUDE)'
                                                                 WHEN ic.is_descending_key = 1 THEN N'DESC'
                                                                 ELSE N'ASC'
                                                             END + ',' AS "text()"
           FROM sys.index_columns AS ic
           INNER JOIN sys.columns AS c
               ON c.object_id = ic.object_id
                  AND ic.column_id = c.column_id
           WHERE b.object_id = ic.object_id
                 AND b.index_id = ic.index_id
           ORDER BY ic.is_included_column ASC,
                    ic.key_ordinal ASC
           FOR XML PATH ('')
       ) AS "RedundantIndexColumns",
       asi.dpages * 8 AS "FatherIndex_InRowDataKB",
       bsi.dpages * 8 AS "RedundantIndex_InRowDataKB",
       usa.user_seeks AS "FatherIndex_UserSeeks",
       usb.user_seeks AS "RedundantIndex_UserSeeks",
       usa.user_scans AS "FatherIndex_UserScans",
       usb.user_scans AS "RedundantIndex_UserScans",
       usa.user_updates AS "FatherIndex_UserUpdates",
       usb.user_updates AS "RedundantIndex_UserUpdates",
       usa.last_user_seek AS "FatherIndex_LastUserSeeks",
       usb.last_user_seek AS "RedundantIndex_LastUserSeeks",
       usa.last_user_scan AS "FatherIndex_LastUserScans",
       usb.last_user_scan AS "RedundantIndex_LastUserScans",
       usa.last_user_update AS "FatherIndex_LastUserUpdates",
       usb.last_user_update AS "RedundantIndex_LastUserUpdates"
FROM ind AS a
INNER JOIN sys.sysindexes AS asi
    ON asi.id = a.object_id
       AND asi.indid = a.index_id
INNER JOIN ind AS b
    ON a.object_id = b.object_id
       AND LEN (a.list) > LEN (b.list)
       AND LEFT(a.list, LEN (b.list)) = b.list
INNER JOIN sys.sysindexes AS bsi
    ON bsi.id = b.object_id
       AND bsi.indid = b.index_id
LEFT JOIN sys.dm_db_index_usage_stats AS usa
    ON usa.database_id = DB_ID ()
       AND usa.object_id = a.object_id
       AND usa.index_id = a.index_id
LEFT JOIN sys.dm_db_index_usage_stats AS usb
    ON usb.database_id = DB_ID ()
       AND usb.object_id = b.object_id
       AND usb.index_id = b.index_id
WHERE asi.rowcnt = bsi.rowcnt -- verify same row count
ORDER BY 1,
         2;