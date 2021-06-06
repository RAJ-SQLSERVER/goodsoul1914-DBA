USE tempdb;

WITH cte
AS (
    SELECT DB_NAME (database_id) AS name,
           mf.name AS db_filename,
           mf.physical_name,
           CAST(((mf.size * 8) / 1024.0) AS DECIMAL(20, 2)) AS initial_size_MB,
           CAST(((df.size * 8) / 1024.0) AS DECIMAL(20, 2)) AS actual_size_MB,
           CASE mf.is_percent_growth
               WHEN 0 THEN STR (CAST(((mf.growth * 8) / 1024.0) AS DECIMAL(10, 2))) + ' MB'
               WHEN 1 THEN STR (mf.growth) + '%'
           END AS auto_grow_setting
    FROM sys.master_files AS mf
    JOIN sys.database_files AS df
        ON mf.name = df.name
    WHERE mf.database_id = DB_ID ()
)
SELECT *,
       actual_size_MB - initial_size_MB AS change_in_MB_since_restart
FROM cte;