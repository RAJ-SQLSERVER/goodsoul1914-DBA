SELECT OBJECT_NAME (st.object_id) AS "TableName",
       sp.stats_id,
       st.name AS "StatisticsName",
       ob.type,
       sc.column_id,
       co.name AS "ColumnName",
       st.filter_definition,
       sp.last_updated,
       sp.rows,
       sp.rows_sampled,
       CONVERT (DECIMAL(32, 2), sp.rows_sampled) / CONVERT (DECIMAL(32, 2), sp.rows) * 100 AS "SampleRate",
       sp.steps,
       sp.unfiltered_rows,
       sp.modification_counter,
       CONVERT (
           DECIMAL(32, 2),
           CASE
               WHEN sp.modification_counter > 0 THEN
                   CONVERT (DECIMAL(32, 2), sp.modification_counter) / CONVERT (DECIMAL(32, 2), sp.rows)
               ELSE 0
           END
       ) * 100 AS "PercentModifications"
FROM sys.stats AS st
INNER JOIN sys.stats_columns AS sc
    ON st.object_id = sc.object_id
       AND st.stats_id = sc.stats_id
INNER JOIN sys.columns AS co
    ON sc.column_id = co.column_id
       AND sc.object_id = co.object_id
INNER JOIN sysobjects AS ob
    ON sc.object_id = ob.id
CROSS APPLY sys.dm_db_stats_properties (st.object_id, st.stats_id) AS sp
WHERE ob.type = 'u'
-- AND CONVERT(DECIMAL(32,2),CASE WHEN sp.modification_counter > 0 
-- THEN CONVERT(DECIMAL(32,2),sp.modification_counter)/CONVERT(DECIMAL(32,2),sp.rows) 
-- ELSE 0 END) > .4
ORDER BY 1;
GO
