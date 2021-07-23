/*************************************************
 Information about all indexes of a specific table
*************************************************/
USE AdventureWorks2019;
GO

SELECT OBJECT_NAME (P.object_id) AS "table",
       I.name AS "index",
       P.index_id,
       P.index_type_desc,
       P.index_level,
       P.page_count,
       avg_page_space_used_in_percent AS "Page:Percent Full",
       min_record_size_in_bytes AS "Row:MinLen",
       max_record_size_in_bytes AS "Row:MaxLen",
       avg_record_size_in_bytes AS "Row:AvgLen"
FROM sys.dm_db_index_physical_stats (DB_ID (), OBJECT_ID ('Sales.SalesOrderDetail'), NULL, NULL, 'DETAILED') AS P
JOIN sys.indexes AS I
    ON I.object_id = P.object_id
       AND I.index_id = P.index_id;

/******************************************
 SELECT 1237 + 455 + 271 + 803 = 2766 PAGES
 SELECT 2766 * 8192 / 1024 = 22128 KB
******************************************/
EXEC sp_spaceused N'Sales.SalesOrderDetail';
GO