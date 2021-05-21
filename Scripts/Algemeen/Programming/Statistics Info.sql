-- Statistics Info.sql
SELECT      o.name AS "object_name",
            ss.stats_id,
            ss.name AS "stat_name",
            ss.filter_definition,
            shr.last_updated,
            shr.persisted_sample_percent,
            (shr.rows_sampled * 100) / shr.rows AS "sample_percent",
            shr.rows,
            shr.rows_sampled,
            shr.steps,
            shr.unfiltered_rows,
            shr.modification_counter
FROM        sys.stats AS ss
INNER JOIN  sys.objects AS o
    ON o.object_id = ss.object_id
CROSS APPLY sys.dm_db_stats_properties(ss.object_id, ss.stats_id) AS shr
WHERE       o.is_ms_shipped = 0
ORDER BY    o.name,
            ss.stats_id;