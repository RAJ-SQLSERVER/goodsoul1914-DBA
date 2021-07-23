SELECT d.name,
       (
           SELECT MAX (bb.xx) AS X1
           FROM (
               SELECT MAX (last_user_seek) AS xx
               WHERE MAX (last_user_seek) IS NOT NULL
               UNION ALL
               SELECT MAX (last_user_scan) AS xx
               WHERE MAX (last_user_scan) IS NOT NULL
               UNION ALL
               SELECT MAX (last_user_lookup) AS xx
               WHERE MAX (last_user_lookup) IS NOT NULL
               UNION ALL
               SELECT MAX (last_user_update) AS xx
               WHERE MAX (last_user_update) IS NOT NULL
           ) AS bb
       ) AS x1
FROM master.dbo.sysdatabases AS d
LEFT OUTER JOIN sys.dm_db_index_usage_stats AS s
    ON d.dbid = s.database_id
WHERE d.dbid > 4
GROUP BY d.name;