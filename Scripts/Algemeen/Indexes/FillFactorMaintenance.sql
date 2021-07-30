/* FillFactorMaintenance.sql */


/* 1 find most fragmented indexes */

SELECT DatabaseName,
       ObjectName AS "TableName",
       IndexName,
       COUNT (*) AS "Qty"
FROM master.dbo.CommandLog
WHERE Command LIKE '%REBUILD%'
GROUP BY DatabaseName,
         ObjectName,
         IndexName
ORDER BY Qty DESC;


/* 2 find current fill factor */

USE DBA;
GO
SELECT DB_NAME () AS "DatabaseName",
       o.name AS "TableName",
       i.name AS "IndexName",
       i.fill_factor
FROM sys.indexes AS i
JOIN sys.objects AS o
    ON i.object_id = o.object_id
WHERE o.name = 'WaitStats'
      AND i.name = 'PK_WaitStats';


/* 3 cautiously lower fill factor by just 1 or 2 */

USE DBA;
GO
ALTER INDEX PK_WaitStats
ON dbo.WaitStats
REBUILD
WITH (FILLFACTOR = 100);


/* repeat after 30 days */