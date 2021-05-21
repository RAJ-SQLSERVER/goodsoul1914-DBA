-- SQL Scripts , sp_spaceused2 , sp_helpindex2 , sp_partitions , sp_updatestats2 , sp_vas

-- update 2018-02-25
USE master;
GO

IF EXISTS
(
    SELECT *
    FROM sys.procedures
    WHERE object_id = OBJECT_ID('sp_partitions')
)
    DROP PROCEDURE [dbo].sp_partitions;
GO

CREATE PROCEDURE [dbo].sp_partitions @objname NVARCHAR(776)
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

-- Check to see the the table exists and initialize @objid.
SELECT @objid = OBJECT_ID(@objname);
IF @objid IS NULL
BEGIN
    RAISERROR(15009, -1, -1, @objname, @dbname);
    RETURN (1);
END;

SELECT i.object_id,
       i.index_id,
       u.name sch,
       o.name tabl,
       i.name [indx],
       s.function_id,
       s.name psn,
       i.data_space_id psi,
       d.partition_number pn,
       r.value,
       d.in_row_data_page_count page_cnt,
       d.reserved_page_count res_cnt,
       d.row_count row_cnt,
       CASE d.row_count
           WHEN 0 THEN
               0
           ELSE
               CONVERT(DECIMAL(18, 1), (8192. * d.in_row_data_page_count) / d.row_count)
       END RwSz,
       e.data_space_id dsid,
       p.data_compression cmp,
       i.fill_factor ff
FROM sys.indexes i WITH (NOLOCK)
    INNER JOIN sys.objects o WITH (NOLOCK)
        ON o.object_id = i.object_id
    JOIN sys.schemas u
        ON u.schema_id = o.schema_id
    INNER JOIN sys.dm_db_partition_stats d WITH (NOLOCK)
        ON d.object_id = i.object_id
           AND d.index_id = i.index_id
    LEFT JOIN sys.partition_schemes s WITH (NOLOCK)
        ON s.data_space_id = i.data_space_id
    LEFT JOIN sys.destination_data_spaces e WITH (NOLOCK)
        ON e.partition_scheme_id = i.data_space_id
           AND e.destination_id = d.partition_number
    LEFT JOIN sys.partition_range_values r WITH (NOLOCK)
        ON r.function_id = s.function_id
           AND r.boundary_id = e.destination_id
    LEFT JOIN sys.partitions p WITH (NOLOCK)
        ON p.object_id = d.object_id
           AND p.index_id = d.index_id
           AND p.partition_number = d.partition_number
WHERE i.object_id = @objid; -- i.type <= 2 AND i.is_disabled = 0 AND i.is_hypothetical = 0
GO

EXEC sys.sp_MS_marksystemobject 'sp_partitions';
GO
SELECT name,
       is_ms_shipped
FROM sys.objects
WHERE name LIKE 'sp_partitions%';
GO