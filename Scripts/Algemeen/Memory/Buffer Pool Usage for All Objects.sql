-- Buffer usage for all objects in detail
-- ------------------------------------------------------------------------------------------------
SELECT SCHEMA_NAME (o.schema_id) AS "Schema Name",
       OBJECT_NAME (p.object_id) AS "Object Name",
       p.index_id,
       CAST(COUNT (*) / 128.0 AS DECIMAL(10, 2)) AS "Buffer size(MB)",
       COUNT (*) AS "BufferCount",
       p.rows AS "Row Count",
       p.data_compression_desc AS "Compression Type"
FROM sys.allocation_units AS a WITH (NOLOCK)
INNER JOIN sys.dm_os_buffer_descriptors AS b WITH (NOLOCK)
    ON a.allocation_unit_id = b.allocation_unit_id
INNER JOIN sys.partitions AS p WITH (NOLOCK)
    ON a.container_id = p.hobt_id
INNER JOIN sys.objects AS o WITH (NOLOCK)
    ON p.object_id = o.object_id
WHERE b.database_id = CONVERT (INT, DB_ID ())
      AND p.object_id > 100
      AND OBJECT_NAME (p.object_id) NOT LIKE N'plan_%'
      AND OBJECT_NAME (p.object_id) NOT LIKE N'sys%'
      AND OBJECT_NAME (p.object_id) NOT LIKE N'xml_index_nodes%'
GROUP BY o.schema_id,
         p.object_id,
         p.index_id,
         p.data_compression_desc,
         p.rows
ORDER BY BufferCount DESC
OPTION (RECOMPILE);
GO
