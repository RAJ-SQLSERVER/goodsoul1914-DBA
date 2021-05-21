-- SQL Scripts , sp_spaceused2 , sp_helpindex2 , sp_partitions , sp_updatestats2 , sp_vas , sp_plancache_flush

-- updates 2018-03-06
-- 2018-04-08 sys.stats is_incremental
-- 2018-10-25 list of tables as input

USE master; -- skip this for Azure
GO

IF EXISTS
(
    SELECT *
    FROM sys.procedures
    WHERE object_id = OBJECT_ID('sp_helpindex2')
)
    DROP PROCEDURE dbo.sp_helpindex2;
GO

CREATE PROCEDURE dbo.sp_helpindex2 @objname NVARCHAR(4000)
AS
DECLARE @objid INT,
        @dbname sysname;

-- Check to see that the object names are local to the current database.
SELECT @dbname = PARSENAME(@objname, 3);
IF @dbname IS NULL
    SELECT @dbname = DB_NAME();
ELSE IF @dbname <> DB_NAME()
BEGIN
    RAISERROR(15250, -1, -1);
    RETURN (1);
END;


-- table/view list -- for use with SQL Server 2016 and later, or substitute STRING_SPLIT function
DECLARE @objs INT;
DECLARE @obj TABLE
(
    object_id INT PRIMARY KEY
);
INSERT @obj
SELECT OBJECT_ID(value)
FROM STRING_SPLIT(@objname, ',')
WHERE OBJECT_ID(value) IS NOT NULL;
SELECT @objs = @@ROWCOUNT;
IF @objs < 1
BEGIN
    RAISERROR(15009, -1, -1, @objname, @dbname);
    RETURN (1);
END;
WITH b
AS (SELECT d.object_id,
           d.index_id,
           part = COUNT(*),
           pop = SUM(   CASE row_count
                            WHEN 0 THEN
                                0
                            ELSE
                                1
                        END
                    ),
           reserved = 8 * SUM(d.reserved_page_count),
           used = 8 * SUM(d.used_page_count),
           in_row_data = 8 * SUM(d.in_row_data_page_count),
           lob_used = 8 * SUM(d.lob_used_page_count),
           overflow = 8 * SUM(d.row_overflow_used_page_count),
           row_count = SUM(row_count),
           notcompressed = SUM(   CASE data_compression
                                      WHEN 0 THEN
                                          1
                                      ELSE
                                          0
                                  END
                              ),
           compressed = SUM(   CASE data_compression
                                   WHEN 0 THEN
                                       0
                                   ELSE
                                       1
                               END
                           ) -- change to 0 for SQL Server 2005

    FROM sys.dm_db_partition_stats d WITH (NOLOCK)
        INNER JOIN sys.partitions r WITH (NOLOCK)
            ON r.partition_id = d.partition_id
    GROUP BY d.object_id,
             d.index_id),
     j
AS (SELECT j.object_id,
           j.index_id,
           j.key_ordinal,
           c.column_id,
           c.name,
           j.is_descending_key,
           j.is_included_column,
           j.partition_ordinal
    FROM sys.index_columns j
        INNER JOIN sys.columns c
            ON c.object_id = j.object_id
               AND c.column_id = j.column_id)
SELECT ISNULL(i.name, '') [index],
       ISNULL(STUFF(
                       (
                           SELECT ', ' + name + CASE is_descending_key
                                                    WHEN 1 THEN
                                                        '-'
                                                    ELSE
                                                        ''
                                                END + CASE partition_ordinal
                                                          WHEN 1 THEN
                                                              '*'
                                                          ELSE
                                                              ''
                                                      END
                           FROM j
                           WHERE j.object_id = i.object_id
                                 AND j.index_id = i.index_id
                                 AND j.key_ordinal > 0
                           ORDER BY j.key_ordinal
                           FOR XML PATH(''), TYPE, ROOT
                       ).value('root[1]', 'nvarchar(max)'),
                       1,
                       1,
                       ''
                   ),
              ''
             ) AS Keys,
       ISNULL(STUFF(
                       (
                           SELECT ', ' + name + CASE partition_ordinal
                                                    WHEN 1 THEN
                                                        '*'
                                                    ELSE
                                                        ''
                                                END
                           FROM j
                           WHERE j.object_id = i.object_id
                                 AND j.index_id = i.index_id
                                 AND
                                 (
                                     j.is_included_column = 1
                                     OR
                                     (
                                         j.key_ordinal = 0
                                         AND partition_ordinal = 1
                                     )
                                 )
                           ORDER BY j.column_id
                           FOR XML PATH(''), TYPE, ROOT
                       ).value('root[1]', 'nvarchar(max)'),
                       1,
                       1,
                       ''
                   ),
              ''
             ) AS Incl,
                       -- for SQL Server 2016, can use STR_AGGR function in place of FOR XML --, j.name AS ptky
       i.index_id,
       CASE
           WHEN i.is_primary_key = 1 THEN
               'PK'
           WHEN i.is_unique_constraint = 1 THEN
               'UC'
           WHEN i.is_unique = 1 THEN
               'U'
           WHEN i.type = 0 THEN
               'heap'
           WHEN i.type = 3 THEN
               'X'
           WHEN i.type = 4 THEN
               'S'
           ELSE
               CONVERT(CHAR, i.type)
       END typ,
       i.data_space_id dsi,
       b.row_count,
       b.in_row_data in_row,
       b.overflow ovf,
       b.lob_used lob,
       b.reserved - b.in_row_data - b.overflow - b.lob_used unu,
       'ABR' = CASE row_count
                   WHEN 0 THEN
                       0
                   ELSE
                       1024 * used / row_count
               END,
       y.user_seeks,
       y.user_scans u_scan,
       y.user_lookups u_look,
       y.user_updates u_upd,
       b.notcompressed ncm,
       b.compressed cmp,
       b.pop,
       b.part,
       rw_delta = b.row_count - s.rows,
       s.rows_sampled, --, s.unfiltered_rows
       s.modification_counter mod_ctr,
       s.steps,
       CONVERT(VARCHAR, s.last_updated, 120) updated,
       i.is_disabled dis,
       i.is_hypothetical hyp,
       ISNULL(i.filter_definition, '') filt,
       t.no_recompute no_rcp,
       t.is_incremental incr,
       INDEXPROPERTY(i.object_id, i.name, 'IndexDepth') depth
FROM sys.objects o
    JOIN sys.indexes i
        ON i.object_id = o.object_id
    LEFT JOIN sys.stats t
        ON t.object_id = o.object_id
           AND t.stats_id = i.index_id
    LEFT JOIN b
        ON b.object_id = i.object_id
           AND b.index_id = i.index_id
    LEFT JOIN sys.dm_db_index_usage_stats y
        ON y.object_id = i.object_id
           AND y.index_id = i.index_id
           AND y.database_id = DB_ID()
    OUTER APPLY sys.dm_db_stats_properties(i.object_id, i.index_id) s
--LEFT JOIN j ON j.object_id = i.object_id AND j.index_id = i.index_id AND j.partition_ordinal = 1

WHERE i.object_id IN
      (
          SELECT object_id FROM @obj
      );
GO

-- Then mark the procedure as a system procedure.
EXEC sys.sp_MS_marksystemobject 'sp_helpindex2'; -- skip this for Azure
GO
SELECT name,
       is_ms_shipped
FROM sys.objects
WHERE name LIKE 'sp_helpindex%';
GO

--DROP PROCEDURE dbo.sp_helpindex2

