IF (OBJECT_ID ('dbo.sp_FindPrimaryKey') IS NULL) EXEC ('CREATE PROCEDURE dbo.sp_FindPrimaryKey AS --');
GO
/*

This stored procedure is used to identify primary key candidates.

Copyright Daniel Hutmacher under Creative Commons 4.0 license with attribution.
http://creativecommons.org/licenses/by/4.0/

Source:  http://sqlsunday.com/downloads/
Version: 2017-10-13

DISCLAIMER: This script does not make any modifications to the server, except
            for installing a stored procedure. However, the script may not be
        suitable to run in a production environment. I cannot assume any
        responsibility regarding the accuracy of the output information,
        performance impacts on your server, or any other consequence. If
        your juristiction does not allow for this kind of waiver/disclaimer,
        or if you do not accept these terms, you are NOT allowed to store,
        distribute or use this code in any way.

*/

ALTER PROCEDURE dbo.sp_FindPrimaryKey @table            sysname,
                                      @column_wildcard  sysname       = N'%', --- Optional: limit your search to just specific columns (for instance '%id')
                                      @where            NVARCHAR(MAX) = NULL, --- Optional: specify a WHERE clause on the table to limit rows.
                                      @initial_sample   BIGINT        = 1000, --- Optional: initial sample size in rows.
                                      @max_column_count TINYINT       = 16    --- Optional: maximum number of columns to try.
AS

--- Anything to declare?
DECLARE @sql             NVARCHAR(MAX),         --- The source table we're analyzing.
        @qualified_table sysname      = @table, --- Database-qualified table name (if we're using tempdb)
        @count           BIGINT,                --- Total row count of the source table.
        @id              INT;

SET NOCOUNT ON;

--- If we're talking temp tables, say so.
IF (@qualified_table LIKE N'#%')
    SET @qualified_table = N'tempdb.dbo.' + @qualified_table;

--- This table keeps track of how many unique
--- members there are in each column of the table.
CREATE TABLE #counts (
    col    sysname NOT NULL,
    _dist  BIGINT  NOT NULL,
    _count BIGINT  NOT NULL,
    PRIMARY KEY CLUSTERED (col)
);

--- These are all the candidates we're going to test:
CREATE TABLE #candidates (
    id         INT     NOT NULL,
    index_name sysname NULL,
    cols       XML     NOT NULL,
    _dist      BIGINT  NOT NULL,
    is_unique  BIT     NULL,
    PRIMARY KEY CLUSTERED (id)
);

CREATE TABLE #columns (name sysname NOT NULL, PRIMARY KEY CLUSTERED (name));

INSERT INTO #columns (name)
SELECT name
FROM sys.columns
WHERE object_id = OBJECT_ID (@qualified_table)
      AND name LIKE @column_wildcard
      AND system_type_id NOT IN (
              SELECT system_type_id
              FROM sys.types
              WHERE name IN ( 'text', 'ntext', 'xml', 'image', 'sql_variant', 'bit' )
          );

IF (@@ROWCOUNT = 0)
    INSERT INTO #columns (name)
    SELECT name
    FROM tempdb.sys.columns
    WHERE object_id = OBJECT_ID (@qualified_table)
          AND name LIKE @column_wildcard
          AND system_type_id NOT IN (
                  SELECT system_type_id
                  FROM tempdb.sys.types
                  WHERE name IN ( 'text', 'ntext', 'xml', 'image', 'sql_variant', 'bit' )
              );



--- Here be dynamic SQL.
SET @sql = N'
    INSERT INTO #counts (col, _dist, _count)
    SELECT x.col, x._dist, src._count
    FROM (
        SELECT COUNT(*) AS _count'
           + CAST((
                 SELECT N', COUNT(DISTINCT ' + QUOTENAME (name) + N') AS ' + QUOTENAME (N'_dist_' + name)
                 FROM #columns AS cols
                 FOR XML PATH (''), TYPE
             ) AS VARCHAR(MAX)) + N'
        FROM ' + @table + ISNULL (N'
        WHERE ' + @where, N'') + N') AS src
    CROSS APPLY (
        VALUES ' + SUBSTRING (CAST((
                                  SELECT N', (src.' + QUOTENAME ('_dist_' + name) + N', ''' + name + N''')'
                                  FROM #columns AS cols
                                  FOR XML PATH (''), TYPE
                              ) AS VARCHAR(MAX)),
                              3,
                              10000
                   ) + N'
        ) AS x(_dist, col);';

EXECUTE sys.sp_executesql @sql;

--- We've stored the row count of the table in one of the columns.
SELECT TOP (1) @count = _count
FROM #counts;


IF (EXISTS (SELECT NULL FROM #counts WHERE _dist = _count))
BEGIN;
    SELECT col AS "Columns",
           'UNIQUE' AS "Uniqueness"
    FROM #counts
    WHERE _dist = _count;

    RETURN;
END;



--- These are all the candidates we're going to test:
WITH cte AS
(
    SELECT 1 AS "colcount",
           col,
           CAST('<col>' + col + '</col>' AS VARCHAR(MAX)) AS "cols",
           _dist,
           1 AS "_colcount"
    FROM #counts
    WHERE _dist < _count
    UNION ALL
    SELECT cte.colcount + 1,
           c.col,
           CAST(cte.cols + '<col>' + c.col + '</col>' AS VARCHAR(MAX)),
           cte._dist * c._dist,
           _colcount + 1
    FROM cte
    INNER JOIN #counts AS c
        ON cte.col < c.col
           AND cte._dist < @count
    WHERE _colcount < @max_column_count
),
     ix AS
(
    SELECT i.name AS "index_name",
           CAST((
               SELECT c.name AS "col"
               FROM sys.index_columns AS ic
               INNER JOIN sys.columns AS c
                   ON ic.object_id = c.object_id
                      AND ic.column_id = c.column_id
               WHERE i.object_id = ic.object_id
                     AND i.index_id = ic.index_id --AND
               -- c.[name] LIKE @column_wildcard AND
               -- c.system_type_id NOT IN (SELECT system_type_id
               --                          FROM sys.types
               --                          WHERE [name] IN ('text', 'ntext', 'xml', 'image', 'sql_variant', 'bit'))
               ORDER BY c.name
               FOR XML PATH (''), TYPE
           ) AS VARCHAR(MAX)) AS "cols"
    FROM sys.indexes AS i
    WHERE i.object_id = OBJECT_ID (@qualified_table)
          AND i.is_unique = 0
          AND i.index_id > 0
    UNION
    SELECT i.name AS "index_name",
           CAST((
               SELECT c.name AS "col"
               FROM tempdb.sys.index_columns AS ic
               INNER JOIN tempdb.sys.columns AS c
                   ON ic.object_id = c.object_id
                      AND ic.column_id = c.column_id
               WHERE i.object_id = ic.object_id
                     AND i.index_id = ic.index_id --AND
               -- c.[name] LIKE @column_wildcard AND
               -- c.system_type_id NOT IN (SELECT system_type_id
               --                          FROM tempdb.sys.types
               --                          WHERE [name] IN ('text', 'ntext', 'xml', 'image', 'sql_variant', 'bit'))
               ORDER BY c.name
               FOR XML PATH (''), TYPE
           ) AS VARCHAR(MAX)) AS "cols"
    FROM tempdb.sys.indexes AS i
    WHERE i.object_id = OBJECT_ID (@qualified_table)
          AND i.is_unique = 0
          AND i.index_id > 0
)
INSERT INTO #candidates (id, index_name, cols, _dist, is_unique)
SELECT ROW_NUMBER () OVER (ORDER BY cte.colcount, cte._dist),
       ix.index_name,
       CAST('<cols>' + cte.cols + '</cols>' AS XML) AS "cols",
       cte._dist,
       NULL
FROM cte
LEFT JOIN (
    SELECT *,
           ROW_NUMBER () OVER (PARTITION BY cols
ORDER BY index_name
                         ) AS "_duplicate"
    FROM ix
) AS ix
    ON cte.cols = ix.cols
       AND ix._duplicate = 1
WHERE _dist >= @count;




--- Loop through them, iterate through increasing sample sizes:
WHILE (EXISTS (SELECT NULL FROM #candidates WHERE is_unique IS NULL))
BEGIN;

    SELECT TOP (1) @id = c.id,
                   @sql = N'
        DECLARE @sample         bigint=' + CAST(@initial_sample AS NVARCHAR(10))
                          + N'/5,
                @duplicates     bit=0,
                @rowcount       bigint=' + CAST(@count AS NVARCHAR(10))
                          + N';

        WHILE (@duplicates=0 AND @sample<@rowcount) BEGIN;
            SET @sample=@sample*5;

            IF (@sample=' + CAST(@initial_sample AS VARCHAR(10)) + N')
                PRINT ''Testing ('
                          + REPLACE (
                                REPLACE (REPLACE (CAST(cols AS NVARCHAR(MAX)), '</col><col>', ', '), '<cols><col>', ''),
                                '</col></cols>',
                                ''
                            ) + N'), sample size=''+STR(@sample, 12, 0)+'' rows.'';
            IF (@sample>' + CAST(@initial_sample AS VARCHAR(10)) + N')
                PRINT ''         '
                          + REPLICATE (
                                ' ',
                                LEN (
                                    REPLACE (
                                        REPLACE (
                                            REPLACE (CAST(cols AS NVARCHAR(MAX)), '</col><col>', ', '),
                                            '<cols><col>',
                                            ''
                                        ),
                                        '</col></cols>',
                                        ''
                                    )
                                )
                            )
                          + N'   sample size=''+STR(@sample, 12, 0)+'' rows.'';

            SELECT TOP (1) @duplicates=1
            FROM (
                SELECT TOP (@sample) *
                FROM ' + @table + ISNULL (N'
                WHERE ' + @where, N'') + N') AS t
            GROUP BY ' + REPLACE (
                             REPLACE (REPLACE (CAST(cols AS NVARCHAR(MAX)), '</col><col>', '], ['), '<cols><col>', '['),
                             '</col></cols>',
                             ']'
                         )
                          + N'
            HAVING COUNT(*)>1;
        END;

        UPDATE #candidates
        SET is_unique=1-@duplicates
        WHERE id=' + CAST(id AS NVARCHAR(10)) + N';'
    FROM #candidates AS c
    WHERE is_unique IS NULL
    ORDER BY id;

    EXECUTE sys.sp_executesql @sql;

    --- Delete candidates that are implicitly unique as a consequence of the unique keys
    --- we just discovered. For instance, if (a, c, e) is unique, (a, b, c, d, e) is implicitly
    --- also unique and can be removed from #candidates.
    DELETE sub
    FROM #candidates AS uq
    INNER JOIN #candidates AS sub
        ON uq.is_unique = 1
           AND uq.id = @id
           AND sub.id != @id
    CROSS APPLY (
        VALUES (
            REPLACE (
                REPLACE (REPLACE (CAST(uq.cols AS NVARCHAR(MAX)), '</col><col>', ']%,%['), '<cols><col>', '%['),
                '</col></cols>',
                ']%'
            ),
            REPLACE (
                REPLACE (REPLACE (CAST(sub.cols AS NVARCHAR(MAX)), '</col><col>', '],['), '<cols><col>', '['),
                '</col></cols>',
                ']'
            )
        )
    ) AS x (uq_cols, sub_cols)
    WHERE x.sub_cols LIKE x.uq_cols
          AND
        --- ... except if the implicit candidate is indexed, in which case we'll just
        --- keep it for the sake of information:
        sub.index_name IS NULL;
END;



--- Output the results.
SELECT ISNULL (index_name, '') AS "Index name",
       REPLACE (
           REPLACE (REPLACE (CAST(cols AS NVARCHAR(MAX)), '</col><col>', ', '), '<cols><col>', ''), '</col></cols>', ''
       ) AS "Columns",
       (CASE
            WHEN is_unique = 1 THEN 'UNIQUE'
            WHEN is_unique = 0 THEN 'Not unique'
        END
       ) AS "Uniqueness"
FROM #candidates
WHERE is_unique = 1
      OR index_name IS NOT NULL
ORDER BY is_unique DESC,
         1;



--- Clean-up.
DROP TABLE #candidates;
DROP TABLE #counts;


GO

--EXECUTE dbo.sp_FindPrimaryKey '#table'

