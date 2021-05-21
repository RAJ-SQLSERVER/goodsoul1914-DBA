-- SQL Scripts , sp_spaceused2 , sp_helpindex2 , sp_partitions , sp_updatestats2 , sp_vas , sp_plancache_flush

/* --
-- updates 2018-04-10
An alternative to the SQL Server sp_updatestats.
The internal statistics update is based on all rows from a random sample of pages.
There can be adverse effects for indexes in which the lead key is not unique
and may be especially severe if compounded.
See Statistics that need special attention.

sp_updatestats2 does fullscan on indexes excluding identity or single key column unique.
Note: consider PERSIST_SAMPLE_PERCENT = ON
per Persisting statistics sampling rate by Pedro Lopes, Aug 17, 2017
for SQL Server 2016 SP1 CU4 and SQL Server 2017 CU1.

TBD: implement incremental statistics: sp_updatestats2 (test version)
*/

USE [master];
GO

IF EXISTS
(
    SELECT *
    FROM sys.objects
    WHERE object_id = OBJECT_ID('dbo.sp_updatestats2')
)
    DROP PROCEDURE dbo.sp_updatestats2;
GO

CREATE PROCEDURE sp_updatestats2
    @resample CHAR(8) = 'NO',
    @modratio BIGINT = 20
AS
DECLARE @dbsid VARBINARY(85),
        @modratio2 INT = 25 * @modratio * @modratio,
        @incr1 BIT;
SELECT @dbsid = owner_sid -- , @incr1 = is_auto_create_stats_incremental_on
FROM sys.databases
WHERE name = DB_NAME();

-- Check the user sysadmin
IF NOT IS_SRVROLEMEMBER('sysadmin') = 1
   AND SUSER_SID() <> @dbsid
BEGIN
    RAISERROR(15247, -1, -1);
    RETURN (1);
END;

-- cannot execute against R/O databases
IF DATABASEPROPERTYEX(DB_NAME(), 'Updateability') = N'READ_ONLY'
BEGIN
    RAISERROR(15635, -1, -1, N'sp_updatestats');
    RETURN (1);
END;

IF UPPER(@resample) <> 'RESAMPLE'
   AND UPPER(@resample) <> 'NO'
BEGIN
    RAISERROR(14138, -1, -1, @resample);
    RETURN (1);
END;

-- required so it can update stats on ICC/IVs
SET ANSI_WARNINGS ON;
SET ANSI_PADDING ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;



IF NOT EXISTS
(
    SELECT *
    FROM sys.objects
    WHERE object_id = OBJECT_ID('dbo.zstats')
) -- DROP TABLE zstats
BEGIN

    CREATE TABLE dbo.zstats
    (
        dd SMALLINT,
        rn INT,
        [object] VARCHAR(255),
        [index] VARCHAR(255),
        row_count BIGINT,
        user_updates BIGINT,
        has_filter BIT,
        leadcol VARCHAR(255),
        system_type_id SMALLINT,
        is_identity BIT,
        is_rowguidcol BIT,
        is_unique BIT,
        kct TINYINT,
        rw_delta BIGINT,
        rows_sampled BIGINT,
        unfiltered_rows BIGINT,
        mod_ctr BIGINT,
        steps INT,
        updated DATETIME,
        otype CHAR(2),
        no_recompute BIT,
        is_incremental BIT -- , partition_number int
    );

    --ALTER TABLE dbo.zstats ADD  no_recompute bit
    --UPDATE dbo.zstats SET no_recompute = 0 WHERE no_recompute IS NULL

    IF NOT EXISTS
    (
        SELECT *
        FROM sys.indexes
        WHERE object_id = OBJECT_ID('dbo.zstats')
              AND index_id = 1
    )
        CREATE UNIQUE CLUSTERED INDEX CX
        ON dbo.zstats (
                          dd,
                          rn
                      )
        WITH (IGNORE_DUP_KEY = ON); -- , DROP_EXISTING = ON)
END;



DECLARE @dd INT;
SELECT @dd = ISNULL(MAX(dd), 0) + 1
FROM dbo.zstats;
WITH b
AS (SELECT d.object_id,
           d.index_id,
           row_count = SUM(d.row_count)
    FROM sys.dm_db_partition_stats d WITH (NOLOCK)
    GROUP BY d.object_id,
             d.index_id),
     k
AS (SELECT object_id,
           index_id,
           COUNT(*) kct
    FROM sys.index_columns WITH (NOLOCK)
    WHERE key_ordinal > 0
    GROUP BY object_id,
             index_id)
INSERT dbo.zstats
SELECT @dd dd,
       ROW_NUMBER() OVER (ORDER BY s.name, o.name, i.index_id) rn,
       QUOTENAME(s.name) + '.' + QUOTENAME(o.name) [object],
       i.name [index],
       b.row_count,
       y.user_updates,
       i.has_filter,
       c.name [leadcol],
       c.system_type_id,
       c.is_identity,
       c.is_rowguidcol,
       i.is_unique,
       k.kct,
       rw_delta = b.row_count - t.rows,
       t.rows_sampled,
       t.unfiltered_rows,
       t.modification_counter mod_ctr,
       t.steps,
       CONVERT(DATETIME, CONVERT(VARCHAR, t.last_updated, 120)) updated,
       o.type,
       d.no_recompute,
       d.is_incremental -- , 0 partition_number

FROM sys.objects o WITH (NOLOCK)
    JOIN sys.schemas s WITH (NOLOCK)
        ON s.schema_id = o.schema_id
    JOIN sys.indexes i WITH (NOLOCK)
        ON i.object_id = o.object_id
    LEFT JOIN sys.stats d WITH (NOLOCK)
        ON d.object_id = i.object_id
           AND d.stats_id = i.index_id
    JOIN sys.index_columns j WITH (NOLOCK)
        ON j.object_id = i.object_id
           AND j.index_id = i.index_id
           AND j.key_ordinal = 1
    JOIN sys.columns c WITH (NOLOCK)
        ON c.object_id = i.object_id
           AND c.column_id = j.column_id
           AND j.key_ordinal = 1
    JOIN b
        ON b.object_id = i.object_id
           AND b.index_id = i.index_id
    JOIN k
        ON k.object_id = i.object_id
           AND k.index_id = i.index_id
    LEFT JOIN sys.dm_db_index_usage_stats y
        ON y.object_id = i.object_id
           AND y.index_id = i.index_id
           AND y.database_id = DB_ID()
    OUTER APPLY sys.dm_db_stats_properties(i.object_id, i.index_id) t
WHERE o.type IN ( 'U', 'V' )
      AND i.index_id > 0
      AND i.type <= 2
      AND i.is_disabled = 0
      AND b.row_count > 0
      AND s.name <> 'cdc'
      AND
      (
          @modratio * t.modification_counter > t.rows
          OR (t.modification_counter * t.modification_counter > @modratio2 * t.rows)
          OR
          (
              2 * t.rows_sampled < b.row_count
              AND
              (
                  k.kct > 1
                  OR is_unique = 0
              )
              AND is_identity = 0
          )
          OR
          (
              is_unique = 1
              AND k.kct = 1
              AND t.modification_counter > 0
          )
          OR t.rows_sampled IS NULL
      );


SELECT dd,
       rn,
       [object],
       [index],
       row_count,
       user_updates,
       has_filter filt,
       leadcol,
       system_type_id,
       is_identity ident,
       is_rowguidcol rgc,
       is_unique uni,
       kct,
       rw_delta,
       rows_sampled, /*, unfiltered_rows uf_rows,*/
       mod_ctr,
       updated,
       steps,
       otype,
       no_recompute nr,
       is_incremental incr
FROM dbo.zstats
WHERE dd = @dd;



DECLARE @object VARCHAR(255),
        @index VARCHAR(255),
        @SQL VARCHAR(1000),
        @ident BIT,
        @uni BIT,
        @kct TINYINT,
        @nr BIT,
        @icr BIT,
        @Inc VARCHAR(50),
        @FS VARCHAR(50),
        @Re VARCHAR(50);

DECLARE s CURSOR FOR
SELECT [object],
       [index],
       is_identity,
       is_unique,
       kct,
       no_recompute,
       is_incremental
FROM dbo.zstats
WHERE dd = @dd;
OPEN s;
FETCH NEXT FROM s
INTO @object,
     @index,
     @ident,
     @uni,
     @kct,
     @nr,
     @icr;
WHILE @@FETCH_STATUS = 0
BEGIN
    IF (@ident = 1 OR (@uni = 1 AND @kct = 1))
    BEGIN
        SET @FS = '';
        IF (@nr = 1)
            SET @Re = 'WITH NORECOMPUTE';
        ELSE
            SET @Re = '';
    END;
    ELSE
    BEGIN
        SET @FS = ' WITH FULLSCAN';
        --IF (@nr = 1)
        SET @Re = ', NORECOMPUTE'; --ELSE SET @Re = ''
        -- note: consider PERSIST_SAMPLE_PERCENT = ON
        -- for SQL Server 2016 SP1 CU4 and SQL Server 2017 CU1
        IF (@icr = 0)
            SET @Inc = ' ';
        ELSE
            SET @Inc = ', INCREMENTAL=ON';
    END;
    SELECT @SQL = CONCAT('UPDATE STATISTICS ', @object, '(', QUOTENAME(@index), ') ', @FS, @Re);
    PRINT CONVERT(VARCHAR(50), GETDATE(), 120) + ',' + @SQL;
    EXEC (@SQL);
    FETCH NEXT FROM s
    INTO @object,
         @index,
         @ident,
         @uni,
         @kct,
         @nr,
         @icr;
END;
CLOSE s;
DEALLOCATE s;



PRINT '';
PRINT 'start column stats';
DECLARE s CURSOR FOR
SELECT QUOTENAME(s.name) + '.' + QUOTENAME(o.name) [object],
       i.name [index]
FROM sys.objects o WITH (NOLOCK)
    JOIN sys.schemas s WITH (NOLOCK)
        ON s.schema_id = o.schema_id
    JOIN sys.stats i WITH (NOLOCK)
        ON i.object_id = o.object_id
    LEFT JOIN sys.indexes x WITH (NOLOCK)
        ON x.object_id = o.object_id
           AND x.index_id = i.stats_id
    OUTER APPLY sys.dm_db_stats_properties(i.object_id, i.stats_id) t
WHERE o.type IN ( 'U', 'V' )
      AND i.stats_id > 0
      AND i.auto_created = 1
      AND i.no_recompute = 0 -- AND i.is_incremental = 0
      AND x.index_id IS NULL
      AND
      (
          20 * t.modification_counter > t.rows
          OR
          (
              t.modification_counter * t.modification_counter > 1000 * t.rows
              AND s.name <> 'dbo'
          )
      )
ORDER BY s.name,
         o.name,
         i.stats_id;

OPEN s;
FETCH NEXT FROM s
INTO @object,
     @index;
WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @SQL = CONCAT('UPDATE STATISTICS ', @object, '(', QUOTENAME(@index), ') ');
    PRINT CONVERT(VARCHAR(50), GETDATE(), 120) + ',' + @SQL;

    EXEC (@SQL);

    FETCH NEXT FROM s
    INTO @object,
         @index;
END;
CLOSE s;
DEALLOCATE s;

RETURN 0;
GO

EXEC sp_MS_marksystemobject 'sp_updatestats2';
GO

SELECT name,
       is_ms_shipped
FROM sys.objects
WHERE name LIKE 'sp_updatestats%';
GO

/*
USE yourdb
GO

exec dbo.sp_updatestats2 @modratio = 20

SELECT * FROM zstats
WHERE dd >= (SELECT dd1 = ISNULL(MAX(dd),0) - 1 FROM dbo.zstats )

SELECT t.name, QUOTENAME(i.name), i.*
FROM sys.tables t JOIN  sys.indexes i ON i.object_id = t.object_id
WHERE t.object_id > 1000
AND CHARINDEX('-', i.name) > 0

SELECT QUOTENAME([object]),  QUOTENAME([index])
FROM zstats

 

*/

