/* INDEX USAGE STATS 
The DMO sys.dm_db_index_usage_stats provides information on how indexes are being used and when
the index was last used. This information can be useful when you want to track whether indexes are being
used and which operations are being executed against the index
*/
CREATE TABLE dbo.index_usage_stats_snapshot (
    snapshot_id        INT      IDENTITY(1, 1),
    create_date        DATETIME,
    database_id        SMALLINT NOT NULL,
    object_id          INT      NOT NULL,
    index_id           INT      NOT NULL,
    user_seeks         BIGINT   NOT NULL,
    user_scans         BIGINT   NOT NULL,
    user_lookups       BIGINT   NOT NULL,
    user_updates       BIGINT   NOT NULL,
    last_user_seek     DATETIME,
    last_user_scan     DATETIME,
    last_user_lookup   DATETIME,
    last_user_update   DATETIME,
    system_seeks       BIGINT   NOT NULL,
    system_scans       BIGINT   NOT NULL,
    system_lookups     BIGINT   NOT NULL,
    system_updates     BIGINT   NOT NULL,
    last_system_seek   DATETIME,
    last_system_scan   DATETIME,
    last_system_lookup DATETIME,
    last_system_update DATETIME,
    CONSTRAINT PK_IndexUsageStatsSnapshot
        PRIMARY KEY CLUSTERED (snapshot_id),
    CONSTRAINT UQ_IndexUsageStatsSnapshot
        UNIQUE (create_date, database_id, object_id, index_id)
);

CREATE TABLE dbo.index_usage_stats_history (
    history_id         INT      IDENTITY(1, 1),
    create_date        DATETIME,
    database_id        SMALLINT NOT NULL,
    object_id          INT      NOT NULL,
    index_id           INT      NOT NULL,
    user_seeks         BIGINT   NOT NULL,
    user_scans         BIGINT   NOT NULL,
    user_lookups       BIGINT   NOT NULL,
    user_updates       BIGINT   NOT NULL,
    last_user_seek     DATETIME,
    last_user_scan     DATETIME,
    last_user_lookup   DATETIME,
    last_user_update   DATETIME,
    system_seeks       BIGINT   NOT NULL,
    system_scans       BIGINT   NOT NULL,
    system_lookups     BIGINT   NOT NULL,
    system_updates     BIGINT   NOT NULL,
    last_system_seek   DATETIME,
    last_system_scan   DATETIME,
    last_system_lookup DATETIME,
    last_system_update DATETIME,
    CONSTRAINT PK_IndexUsageStatsHistory
        PRIMARY KEY CLUSTERED (history_id),
    CONSTRAINT UQ_IndexUsageStatsHistory
        UNIQUE (create_date, database_id, object_id, index_id)
);
GO

-- Index Usage Stats Snapshot Population (schedule every 4 hours)
-- Be certain to schedule a snapshot prior to any index defragmentation processes to 
-- capture information that might be lost when indexes are rebuilt.
INSERT INTO dbo.index_usage_stats_snapshot
SELECT GETDATE (),
       database_id,
       object_id,
       index_id,
       user_seeks,
       user_scans,
       user_lookups,
       user_updates,
       last_user_seek,
       last_user_scan,
       last_user_lookup,
       last_user_update,
       system_seeks,
       system_scans,
       system_lookups,
       system_updates,
       last_system_seek,
       last_system_scan,
       last_system_lookup,
       last_system_update
FROM sys.dm_db_index_usage_stats;
GO

WITH IndexUsageCTE AS
(
    SELECT DENSE_RANK () OVER (ORDER BY create_date DESC) AS "HistoryID",
           create_date,
           database_id,
           object_id,
           index_id,
           user_seeks,
           user_scans,
           user_lookups,
           user_updates,
           last_user_seek,
           last_user_scan,
           last_user_lookup,
           last_user_update,
           system_seeks,
           system_scans,
           system_lookups,
           system_updates,
           last_system_seek,
           last_system_scan,
           last_system_lookup,
           last_system_update
    FROM dbo.index_usage_stats_snapshot
)
INSERT INTO dbo.index_usage_stats_history
SELECT i1.create_date,
       i1.database_id,
       i1.object_id,
       i1.index_id,
       i1.user_seeks - COALESCE (i2.user_seeks, 0),
       i1.user_scans - COALESCE (i2.user_scans, 0),
       i1.user_lookups - COALESCE (i2.user_lookups, 0),
       i1.user_updates - COALESCE (i2.user_updates, 0),
       i1.last_user_seek,
       i1.last_user_scan,
       i1.last_user_lookup,
       i1.last_user_update,
       i1.system_seeks - COALESCE (i2.system_seeks, 0),
       i1.system_scans - COALESCE (i2.system_scans, 0),
       i1.system_lookups - COALESCE (i2.system_lookups, 0),
       i1.system_updates - COALESCE (i2.system_updates, 0),
       i1.last_system_seek,
       i1.last_system_scan,
       i1.last_system_lookup,
       i1.last_system_update
FROM IndexUsageCTE AS i1
LEFT OUTER JOIN IndexUsageCTE AS i2
    ON i1.database_id = i2.database_id
       AND i1.object_id = i2.object_id
       AND i1.index_id = i2.index_id
       AND i2.HistoryID = 2
       --Verify no rows are less than 0
       AND NOT (
               i1.system_seeks - COALESCE (i2.system_seeks, 0) < 0
               AND i1.system_scans - COALESCE (i2.system_scans, 0) < 0
               AND i1.system_lookups - COALESCE (i2.system_lookups, 0) < 0
               AND i1.system_updates - COALESCE (i2.system_updates, 0) < 0
               AND i1.user_seeks - COALESCE (i2.user_seeks, 0) < 0
               AND i1.user_scans - COALESCE (i2.user_scans, 0) < 0
               AND i1.user_lookups - COALESCE (i2.user_lookups, 0) < 0
               AND i1.user_updates - COALESCE (i2.user_updates, 0) < 0
           )
WHERE i1.HistoryID = 1
      --Only include rows are greater than 0
      AND (
          i1.system_seeks - COALESCE (i2.system_seeks, 0) > 0
          OR i1.system_scans - COALESCE (i2.system_scans, 0) > 0
          OR i1.system_lookups - COALESCE (i2.system_lookups, 0) > 0
          OR i1.system_updates - COALESCE (i2.system_updates, 0) > 0
          OR i1.user_seeks - COALESCE (i2.user_seeks, 0) > 0
          OR i1.user_scans - COALESCE (i2.user_scans, 0) > 0
          OR i1.user_lookups - COALESCE (i2.user_lookups, 0) > 0
          OR i1.user_updates - COALESCE (i2.user_updates, 0) > 0
      );
GO


/* INDEX OPERATIONAL STATS 
The DMO sys.dm_db_index_operational_stats provides information on the physical operations that
happen on indexes during plan execution. This information can be useful for tracking the physical plan
operations that occur when indexes are used and the rates for those operations. One of the other things this
DMO monitors is the success rate in which compression operates
*/
CREATE TABLE dbo.index_operational_stats_snapshot (
    snapshot_id                        INT      IDENTITY(1, 1),
    create_date                        DATETIME,
    database_id                        SMALLINT NOT NULL,
    object_id                          INT      NOT NULL,
    index_id                           INT      NOT NULL,
    partition_number                   INT      NOT NULL,
    leaf_insert_count                  BIGINT   NOT NULL,
    leaf_delete_count                  BIGINT   NOT NULL,
    leaf_update_count                  BIGINT   NOT NULL,
    leaf_ghost_count                   BIGINT   NOT NULL,
    nonleaf_insert_count               BIGINT   NOT NULL,
    nonleaf_delete_count               BIGINT   NOT NULL,
    nonleaf_update_count               BIGINT   NOT NULL,
    leaf_allocation_count              BIGINT   NOT NULL,
    nonleaf_allocation_count           BIGINT   NOT NULL,
    leaf_page_merge_count              BIGINT   NOT NULL,
    nonleaf_page_merge_count           BIGINT   NOT NULL,
    range_scan_count                   BIGINT   NOT NULL,
    singleton_lookup_count             BIGINT   NOT NULL,
    forwarded_fetch_count              BIGINT   NOT NULL,
    lob_fetch_in_pages                 BIGINT   NOT NULL,
    lob_fetch_in_bytes                 BIGINT   NOT NULL,
    lob_orphan_create_count            BIGINT   NOT NULL,
    lob_orphan_insert_count            BIGINT   NOT NULL,
    row_overflow_fetch_in_pages        BIGINT   NOT NULL,
    row_overflow_fetch_in_bytes        BIGINT   NOT NULL,
    column_value_push_off_row_count    BIGINT   NOT NULL,
    column_value_pull_in_row_count     BIGINT   NOT NULL,
    row_lock_count                     BIGINT   NOT NULL,
    row_lock_wait_count                BIGINT   NOT NULL,
    row_lock_wait_in_ms                BIGINT   NOT NULL,
    page_lock_count                    BIGINT   NOT NULL,
    page_lock_wait_count               BIGINT   NOT NULL,
    page_lock_wait_in_ms               BIGINT   NOT NULL,
    index_lock_promotion_attempt_count BIGINT   NOT NULL,
    index_lock_promotion_count         BIGINT   NOT NULL,
    page_latch_wait_count              BIGINT   NOT NULL,
    page_latch_wait_in_ms              BIGINT   NOT NULL,
    page_io_latch_wait_count           BIGINT   NOT NULL,
    page_io_latch_wait_in_ms           BIGINT   NOT NULL,
    tree_page_latch_wait_count         BIGINT   NOT NULL,
    tree_page_latch_wait_in_ms         BIGINT   NOT NULL,
    tree_page_io_latch_wait_count      BIGINT   NOT NULL,
    tree_page_io_latch_wait_in_ms      BIGINT   NOT NULL,
    page_compression_attempt_count     BIGINT   NOT NULL,
    page_compression_success_count     BIGINT   NOT NULL,
    CONSTRAINT PK_IndexOperationalStatsSnapshot
        PRIMARY KEY CLUSTERED (snapshot_id)--,
    --CONSTRAINT UQ_IndexOperationalStatsSnapshot
        --UNIQUE (create_date, database_id, object_id, index_id, partition_number)
);

CREATE TABLE dbo.index_operational_stats_history (
    history_id                         INT      IDENTITY(1, 1),
    create_date                        DATETIME,
    database_id                        SMALLINT NOT NULL,
    object_id                          INT      NOT NULL,
    index_id                           INT      NOT NULL,
    partition_number                   INT      NOT NULL,
    leaf_insert_count                  BIGINT   NOT NULL,
    leaf_delete_count                  BIGINT   NOT NULL,
    leaf_update_count                  BIGINT   NOT NULL,
    leaf_ghost_count                   BIGINT   NOT NULL,
    nonleaf_insert_count               BIGINT   NOT NULL,
    nonleaf_delete_count               BIGINT   NOT NULL,
    nonleaf_update_count               BIGINT   NOT NULL,
    leaf_allocation_count              BIGINT   NOT NULL,
    nonleaf_allocation_count           BIGINT   NOT NULL,
    leaf_page_merge_count              BIGINT   NOT NULL,
    nonleaf_page_merge_count           BIGINT   NOT NULL,
    range_scan_count                   BIGINT   NOT NULL,
    singleton_lookup_count             BIGINT   NOT NULL,
    forwarded_fetch_count              BIGINT   NOT NULL,
    lob_fetch_in_pages                 BIGINT   NOT NULL,
    lob_fetch_in_bytes                 BIGINT   NOT NULL,
    lob_orphan_create_count            BIGINT   NOT NULL,
    lob_orphan_insert_count            BIGINT   NOT NULL,
    row_overflow_fetch_in_pages        BIGINT   NOT NULL,
    row_overflow_fetch_in_bytes        BIGINT   NOT NULL,
    column_value_push_off_row_count    BIGINT   NOT NULL,
    column_value_pull_in_row_count     BIGINT   NOT NULL,
    row_lock_count                     BIGINT   NOT NULL,
    row_lock_wait_count                BIGINT   NOT NULL,
    row_lock_wait_in_ms                BIGINT   NOT NULL,
    page_lock_count                    BIGINT   NOT NULL,
    page_lock_wait_count               BIGINT   NOT NULL,
    page_lock_wait_in_ms               BIGINT   NOT NULL,
    index_lock_promotion_attempt_count BIGINT   NOT NULL,
    index_lock_promotion_count         BIGINT   NOT NULL,
    page_latch_wait_count              BIGINT   NOT NULL,
    page_latch_wait_in_ms              BIGINT   NOT NULL,
    page_io_latch_wait_count           BIGINT   NOT NULL,
    page_io_latch_wait_in_ms           BIGINT   NOT NULL,
    tree_page_latch_wait_count         BIGINT   NOT NULL,
    tree_page_latch_wait_in_ms         BIGINT   NOT NULL,
    tree_page_io_latch_wait_count      BIGINT   NOT NULL,
    tree_page_io_latch_wait_in_ms      BIGINT   NOT NULL,
    page_compression_attempt_count     BIGINT   NOT NULL,
    page_compression_success_count     BIGINT   NOT NULL,
    CONSTRAINT PK_IndexOperationalStatsHistory
        PRIMARY KEY CLUSTERED (history_id),
    CONSTRAINT UQ_IndexOperationalStatsHistory
        UNIQUE (create_date, database_id, object_id, index_id, partition_number)
);
GO


INSERT INTO dbo.index_operational_stats_snapshot
SELECT GETDATE (),
       database_id,
       object_id,
       index_id,
       partition_number,
       leaf_insert_count,
       leaf_delete_count,
       leaf_update_count,
       leaf_ghost_count,
       nonleaf_insert_count,
       nonleaf_delete_count,
       nonleaf_update_count,
       leaf_allocation_count,
       nonleaf_allocation_count,
       leaf_page_merge_count,
       nonleaf_page_merge_count,
       range_scan_count,
       singleton_lookup_count,
       forwarded_fetch_count,
       lob_fetch_in_pages,
       lob_fetch_in_bytes,
       lob_orphan_create_count,
       lob_orphan_insert_count,
       row_overflow_fetch_in_pages,
       row_overflow_fetch_in_bytes,
       column_value_push_off_row_count,
       column_value_pull_in_row_count,
       row_lock_count,
       row_lock_wait_count,
       row_lock_wait_in_ms,
       page_lock_count,
       page_lock_wait_count,
       page_lock_wait_in_ms,
       index_lock_promotion_attempt_count,
       index_lock_promotion_count,
       page_latch_wait_count,
       page_latch_wait_in_ms,
       page_io_latch_wait_count,
       page_io_latch_wait_in_ms,
       tree_page_latch_wait_count,
       tree_page_latch_wait_in_ms,
       tree_page_io_latch_wait_count,
       tree_page_io_latch_wait_in_ms,
       page_compression_attempt_count,
       page_compression_success_count
FROM sys.dm_db_index_operational_stats (NULL, NULL, NULL, NULL);
GO


WITH IndexOperationalCTE AS
(
    SELECT DENSE_RANK () OVER (ORDER BY create_date DESC) AS "HistoryID",
           create_date,
           database_id,
           object_id,
           index_id,
           partition_number,
           leaf_insert_count,
           leaf_delete_count,
           leaf_update_count,
           leaf_ghost_count,
           nonleaf_insert_count,
           nonleaf_delete_count,
           nonleaf_update_count,
           leaf_allocation_count,
           nonleaf_allocation_count,
           leaf_page_merge_count,
           nonleaf_page_merge_count,
           range_scan_count,
           singleton_lookup_count,
           forwarded_fetch_count,
           lob_fetch_in_pages,
           lob_fetch_in_bytes,
           lob_orphan_create_count,
           lob_orphan_insert_count,
           row_overflow_fetch_in_pages,
           row_overflow_fetch_in_bytes,
           column_value_push_off_row_count,
           column_value_pull_in_row_count,
           row_lock_count,
           row_lock_wait_count,
           row_lock_wait_in_ms,
           page_lock_count,
           page_lock_wait_count,
           page_lock_wait_in_ms,
           index_lock_promotion_attempt_count,
           index_lock_promotion_count,
           page_latch_wait_count,
           page_latch_wait_in_ms,
           page_io_latch_wait_count,
           page_io_latch_wait_in_ms,
           tree_page_latch_wait_count,
           tree_page_latch_wait_in_ms,
           tree_page_io_latch_wait_count,
           tree_page_io_latch_wait_in_ms,
           page_compression_attempt_count,
           page_compression_success_count
    FROM dbo.index_operational_stats_snapshot
)
INSERT INTO dbo.index_operational_stats_history
SELECT i1.create_date,
       i1.database_id,
       i1.object_id,
       i1.index_id,
       i1.partition_number,
       i1.leaf_insert_count - COALESCE (i2.leaf_insert_count, 0),
       i1.leaf_delete_count - COALESCE (i2.leaf_delete_count, 0),
       i1.leaf_update_count - COALESCE (i2.leaf_update_count, 0),
       i1.leaf_ghost_count - COALESCE (i2.leaf_ghost_count, 0),
       i1.nonleaf_insert_count - COALESCE (i2.nonleaf_insert_count, 0),
       i1.nonleaf_delete_count - COALESCE (i2.nonleaf_delete_count, 0),
       i1.nonleaf_update_count - COALESCE (i2.nonleaf_update_count, 0),
       i1.leaf_allocation_count - COALESCE (i2.leaf_allocation_count, 0),
       i1.nonleaf_allocation_count - COALESCE (i2.nonleaf_allocation_count, 0),
       i1.leaf_page_merge_count - COALESCE (i2.leaf_page_merge_count, 0),
       i1.nonleaf_page_merge_count - COALESCE (i2.nonleaf_page_merge_count, 0),
       i1.range_scan_count - COALESCE (i2.range_scan_count, 0),
       i1.singleton_lookup_count - COALESCE (i2.singleton_lookup_count, 0),
       i1.forwarded_fetch_count - COALESCE (i2.forwarded_fetch_count, 0),
       i1.lob_fetch_in_pages - COALESCE (i2.lob_fetch_in_pages, 0),
       i1.lob_fetch_in_bytes - COALESCE (i2.lob_fetch_in_bytes, 0),
       i1.lob_orphan_create_count - COALESCE (i2.lob_orphan_create_count, 0),
       i1.lob_orphan_insert_count - COALESCE (i2.lob_orphan_insert_count, 0),
       i1.row_overflow_fetch_in_pages - COALESCE (i2.row_overflow_fetch_in_pages, 0),
       i1.row_overflow_fetch_in_bytes - COALESCE (i2.row_overflow_fetch_in_bytes, 0),
       i1.column_value_push_off_row_count - COALESCE (i2.column_value_push_off_row_count, 0),
       i1.column_value_pull_in_row_count - COALESCE (i2.column_value_pull_in_row_count, 0),
       i1.row_lock_count - COALESCE (i2.row_lock_count, 0),
       i1.row_lock_wait_count - COALESCE (i2.row_lock_wait_count, 0),
       i1.row_lock_wait_in_ms - COALESCE (i2.row_lock_wait_in_ms, 0),
       i1.page_lock_count - COALESCE (i2.page_lock_count, 0),
       i1.page_lock_wait_count - COALESCE (i2.page_lock_wait_count, 0),
       i1.page_lock_wait_in_ms - COALESCE (i2.page_lock_wait_in_ms, 0),
       i1.index_lock_promotion_attempt_count - COALESCE (i2.index_lock_promotion_attempt_count, 0),
       i1.index_lock_promotion_count - COALESCE (i2.index_lock_promotion_count, 0),
       i1.page_latch_wait_count - COALESCE (i2.page_latch_wait_count, 0),
       i1.page_latch_wait_in_ms - COALESCE (i2.page_latch_wait_in_ms, 0),
       i1.page_io_latch_wait_count - COALESCE (i2.page_io_latch_wait_count, 0),
       i1.page_io_latch_wait_in_ms - COALESCE (i2.page_io_latch_wait_in_ms, 0),
       i1.tree_page_latch_wait_count - COALESCE (i2.tree_page_latch_wait_count, 0),
       i1.tree_page_latch_wait_in_ms - COALESCE (i2.tree_page_latch_wait_in_ms, 0),
       i1.tree_page_io_latch_wait_count - COALESCE (i2.tree_page_io_latch_wait_count, 0),
       i1.tree_page_io_latch_wait_in_ms - COALESCE (i2.tree_page_io_latch_wait_in_ms, 0),
       i1.page_compression_attempt_count - COALESCE (i2.page_compression_attempt_count, 0),
       i1.page_compression_success_count - COALESCE (i2.page_compression_success_count, 0)
FROM IndexOperationalCTE AS i1
LEFT OUTER JOIN IndexOperationalCTE AS i2
    ON i1.database_id = i2.database_id
       AND i1.object_id = i2.object_id
       AND i1.index_id = i2.index_id
       AND i1.partition_number = i2.partition_number
       AND i2.HistoryID = 2
       --Verify no rows are less than 0
       AND NOT (
               i1.leaf_insert_count - COALESCE (i2.leaf_insert_count, 0) < 0
               AND i1.leaf_delete_count - COALESCE (i2.leaf_delete_count, 0) < 0
               AND i1.leaf_update_count - COALESCE (i2.leaf_update_count, 0) < 0
               AND i1.leaf_ghost_count - COALESCE (i2.leaf_ghost_count, 0) < 0
               AND i1.nonleaf_insert_count - COALESCE (i2.nonleaf_insert_count, 0) < 0
               AND i1.nonleaf_delete_count - COALESCE (i2.nonleaf_delete_count, 0) < 0
               AND i1.nonleaf_update_count - COALESCE (i2.nonleaf_update_count, 0) < 0
               AND i1.leaf_allocation_count - COALESCE (i2.leaf_allocation_count, 0) < 0
               AND i1.nonleaf_allocation_count - COALESCE (i2.nonleaf_allocation_count, 0) < 0
               AND i1.leaf_page_merge_count - COALESCE (i2.leaf_page_merge_count, 0) < 0
               AND i1.nonleaf_page_merge_count - COALESCE (i2.nonleaf_page_merge_count, 0) < 0
               AND i1.range_scan_count - COALESCE (i2.range_scan_count, 0) < 0
               AND i1.singleton_lookup_count - COALESCE (i2.singleton_lookup_count, 0) < 0
               AND i1.forwarded_fetch_count - COALESCE (i2.forwarded_fetch_count, 0) < 0
               AND i1.lob_fetch_in_pages - COALESCE (i2.lob_fetch_in_pages, 0) < 0
               AND i1.lob_fetch_in_bytes - COALESCE (i2.lob_fetch_in_bytes, 0) < 0
               AND i1.lob_orphan_create_count - COALESCE (i2.lob_orphan_create_count, 0) < 0
               AND i1.lob_orphan_insert_count - COALESCE (i2.lob_orphan_insert_count, 0) < 0
               AND i1.row_overflow_fetch_in_pages - COALESCE (i2.row_overflow_fetch_in_pages, 0) < 0
               AND i1.row_overflow_fetch_in_bytes - COALESCE (i2.row_overflow_fetch_in_bytes, 0) < 0
               AND i1.column_value_push_off_row_count - COALESCE (i2.column_value_push_off_row_count, 0) < 0
               AND i1.column_value_pull_in_row_count - COALESCE (i2.column_value_pull_in_row_count, 0) < 0
               AND i1.row_lock_count - COALESCE (i2.row_lock_count, 0) < 0
               AND i1.row_lock_wait_count - COALESCE (i2.row_lock_wait_count, 0) < 0
               AND i1.row_lock_wait_in_ms - COALESCE (i2.row_lock_wait_in_ms, 0) < 0
               AND i1.page_lock_count - COALESCE (i2.page_lock_count, 0) < 0
               AND i1.page_lock_wait_count - COALESCE (i2.page_lock_wait_count, 0) < 0
               AND i1.page_lock_wait_in_ms - COALESCE (i2.page_lock_wait_in_ms, 0) < 0
               AND i1.index_lock_promotion_attempt_count - COALESCE (i2.index_lock_promotion_attempt_count, 0) < 0
               AND i1.index_lock_promotion_count - COALESCE (i2.index_lock_promotion_count, 0) < 0
               AND i1.page_latch_wait_count - COALESCE (i2.page_latch_wait_count, 0) < 0
               AND i1.page_latch_wait_in_ms - COALESCE (i2.page_latch_wait_in_ms, 0) < 0
               AND i1.page_io_latch_wait_count - COALESCE (i2.page_io_latch_wait_count, 0) < 0
               AND i1.page_io_latch_wait_in_ms - COALESCE (i2.page_io_latch_wait_in_ms, 0) < 0
               AND i1.tree_page_latch_wait_count - COALESCE (i2.tree_page_latch_wait_count, 0) < 0
               AND i1.tree_page_latch_wait_in_ms - COALESCE (i2.tree_page_latch_wait_in_ms, 0) < 0
               AND i1.tree_page_io_latch_wait_count - COALESCE (i2.tree_page_io_latch_wait_count, 0) < 0
               AND i1.tree_page_io_latch_wait_in_ms - COALESCE (i2.tree_page_io_latch_wait_in_ms, 0) < 0
               AND i1.page_compression_attempt_count - COALESCE (i2.page_compression_attempt_count, 0) < 0
               AND i1.page_compression_success_count - COALESCE (i2.page_compression_success_count, 0) < 0
           )
WHERE i1.HistoryID = 1
      --Only include rows are greater than 0
      AND (
          i1.leaf_insert_count - COALESCE (i2.leaf_insert_count, 0) > 0
          OR i1.leaf_delete_count - COALESCE (i2.leaf_delete_count, 0) > 0
          OR i1.leaf_update_count - COALESCE (i2.leaf_update_count, 0) > 0
          OR i1.leaf_ghost_count - COALESCE (i2.leaf_ghost_count, 0) > 0
          OR i1.nonleaf_insert_count - COALESCE (i2.nonleaf_insert_count, 0) > 0
          OR i1.nonleaf_delete_count - COALESCE (i2.nonleaf_delete_count, 0) > 0
          OR i1.nonleaf_update_count - COALESCE (i2.nonleaf_update_count, 0) > 0
          OR i1.leaf_allocation_count - COALESCE (i2.leaf_allocation_count, 0) > 0
          OR i1.nonleaf_allocation_count - COALESCE (i2.nonleaf_allocation_count, 0) > 0
          OR i1.leaf_page_merge_count - COALESCE (i2.leaf_page_merge_count, 0) > 0
          OR i1.nonleaf_page_merge_count - COALESCE (i2.nonleaf_page_merge_count, 0) > 0
          OR i1.range_scan_count - COALESCE (i2.range_scan_count, 0) > 0
          OR i1.singleton_lookup_count - COALESCE (i2.singleton_lookup_count, 0) > 0
          OR i1.forwarded_fetch_count - COALESCE (i2.forwarded_fetch_count, 0) > 0
          OR i1.lob_fetch_in_pages - COALESCE (i2.lob_fetch_in_pages, 0) > 0
          OR i1.lob_fetch_in_bytes - COALESCE (i2.lob_fetch_in_bytes, 0) > 0
          OR i1.lob_orphan_create_count - COALESCE (i2.lob_orphan_create_count, 0) > 0
          OR i1.lob_orphan_insert_count - COALESCE (i2.lob_orphan_insert_count, 0) > 0
          OR i1.row_overflow_fetch_in_pages - COALESCE (i2.row_overflow_fetch_in_pages, 0) > 0
          OR i1.row_overflow_fetch_in_bytes - COALESCE (i2.row_overflow_fetch_in_bytes, 0) > 0
          OR i1.column_value_push_off_row_count - COALESCE (i2.column_value_push_off_row_count, 0) > 0
          OR i1.column_value_pull_in_row_count - COALESCE (i2.column_value_pull_in_row_count, 0) > 0
          OR i1.row_lock_count - COALESCE (i2.row_lock_count, 0) > 0
          OR i1.row_lock_wait_count - COALESCE (i2.row_lock_wait_count, 0) > 0
          OR i1.row_lock_wait_in_ms - COALESCE (i2.row_lock_wait_in_ms, 0) > 0
          OR i1.page_lock_count - COALESCE (i2.page_lock_count, 0) > 0
          OR i1.page_lock_wait_count - COALESCE (i2.page_lock_wait_count, 0) > 0
          OR i1.page_lock_wait_in_ms - COALESCE (i2.page_lock_wait_in_ms, 0) > 0
          OR i1.index_lock_promotion_attempt_count - COALESCE (i2.index_lock_promotion_attempt_count, 0) > 0
          OR i1.index_lock_promotion_count - COALESCE (i2.index_lock_promotion_count, 0) > 0
          OR i1.page_latch_wait_count - COALESCE (i2.page_latch_wait_count, 0) > 0
          OR i1.page_latch_wait_in_ms - COALESCE (i2.page_latch_wait_in_ms, 0) > 0
          OR i1.page_io_latch_wait_count - COALESCE (i2.page_io_latch_wait_count, 0) > 0
          OR i1.page_io_latch_wait_in_ms - COALESCE (i2.page_io_latch_wait_in_ms, 0) > 0
          OR i1.tree_page_latch_wait_count - COALESCE (i2.tree_page_latch_wait_count, 0) > 0
          OR i1.tree_page_latch_wait_in_ms - COALESCE (i2.tree_page_latch_wait_in_ms, 0) > 0
          OR i1.tree_page_io_latch_wait_count - COALESCE (i2.tree_page_io_latch_wait_count, 0) > 0
          OR i1.tree_page_io_latch_wait_in_ms - COALESCE (i2.tree_page_io_latch_wait_in_ms, 0) > 0
          OR i1.page_compression_attempt_count - COALESCE (i2.page_compression_attempt_count, 0) > 0
          OR i1.page_compression_success_count - COALESCE (i2.page_compression_success_count, 0) > 0
      );
GO

/* INDEX PHYSICAL STATS
The indexing DMO for monitoring indexes is sys.dm_db_index_physical_stats. 
This DMO provides statistics on the current physical structure of the indexes in the databases. 
The value of this information is in determining the fragmentation of the index.
*/
CREATE TABLE dbo.index_physical_stats_history (
    history_id                     INT IDENTITY(1, 1),
    create_date                    DATETIME,
    database_id                    SMALLINT,
    object_id                      INT,
    index_id                       INT,
    partition_number               INT,
    index_type_desc                NVARCHAR(60),
    alloc_unit_type_desc           NVARCHAR(60),
    index_depth                    TINYINT,
    index_level                    TINYINT,
    avg_fragmentation_in_percent   FLOAT,
    fragment_count                 BIGINT,
    avg_fragment_size_in_pages     FLOAT,
    page_count                     BIGINT,
    avg_page_space_used_in_percent FLOAT,
    record_count                   BIGINT,
    ghost_record_count             BIGINT,
    version_ghost_record_count     BIGINT,
    min_record_size_in_bytes       INT,
    max_record_size_in_bytes       INT,
    avg_record_size_in_bytes       FLOAT,
    forwarded_record_count         BIGINT,
    compressed_page_count          BIGINT,
    CONSTRAINT PK_IndexPhysicalStatsHistory
        PRIMARY KEY CLUSTERED (history_id)--,
    --CONSTRAINT UQ_IndexPhysicalStatsHistory
    --    UNIQUE (
    --        create_date,
    --        database_id,
    --        object_id,
    --        index_id,
    --        partition_number,
    --        alloc_unit_type_desc,
    --        index_depth,
    --        index_level
    --    )
);
GO

-- Index Physical Stats History Population
DECLARE @DatabaseID INT;
DECLARE DatabaseList CURSOR FAST_FORWARD FOR
SELECT database_id
FROM sys.databases
WHERE state_desc = 'ONLINE';
OPEN DatabaseList;
FETCH NEXT FROM DatabaseList
INTO @DatabaseID;
WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO dbo.index_physical_stats_history (create_date,
                                                  database_id,
                                                  object_id,
                                                  index_id,
                                                  partition_number,
                                                  index_type_desc,
                                                  alloc_unit_type_desc,
                                                  index_depth,
                                                  index_level,
                                                  avg_fragmentation_in_percent,
                                                  fragment_count,
                                                  avg_fragment_size_in_pages,
                                                  page_count,
                                                  avg_page_space_used_in_percent,
                                                  record_count,
                                                  ghost_record_count,
                                                  version_ghost_record_count,
                                                  min_record_size_in_bytes,
                                                  max_record_size_in_bytes,
                                                  avg_record_size_in_bytes,
                                                  forwarded_record_count,
                                                  compressed_page_count)
    SELECT GETDATE (),
           database_id,
           object_id,
           index_id,
           partition_number,
           index_type_desc,
           alloc_unit_type_desc,
           index_depth,
           index_level,
           avg_fragmentation_in_percent,
           fragment_count,
           avg_fragment_size_in_pages,
           page_count,
           avg_page_space_used_in_percent,
           record_count,
           ghost_record_count,
           version_ghost_record_count,
           min_record_size_in_bytes,
           max_record_size_in_bytes,
           avg_record_size_in_bytes,
           forwarded_record_count,
           compressed_page_count
    FROM sys.dm_db_index_physical_stats (@DatabaseID, NULL, NULL, NULL, 'SAMPLED');
    FETCH NEXT FROM DatabaseList
    INTO @DatabaseID;
END;
CLOSE DatabaseList;
DEALLOCATE DatabaseList;
GO


/* WAIT STATS
This DMO collects information related to resources that SQL Server is waiting for in 
order to start or continue executing a query or other request.
*/
CREATE TABLE dbo.wait_stats_snapshot (
    wait_stats_snapshot_id INT          IDENTITY(1, 1),
    create_date            DATETIME,
    wait_type              NVARCHAR(60) NOT NULL,
    waiting_tasks_count    BIGINT       NOT NULL,
    wait_time_ms           BIGINT       NOT NULL,
    max_wait_time_ms       BIGINT       NOT NULL,
    signal_wait_time_ms    BIGINT       NOT NULL,
    CONSTRAINT PK_wait_stats_snapshot
        PRIMARY KEY CLUSTERED (wait_stats_snapshot_id)
);

CREATE TABLE dbo.wait_stats_history (
    wait_stats_history_id INT          IDENTITY(1, 1),
    create_date           DATETIME,
    wait_type             NVARCHAR(60) NOT NULL,
    waiting_tasks_count   BIGINT       NOT NULL,
    wait_time_ms          BIGINT       NOT NULL,
    max_wait_time_ms      BIGINT       NOT NULL,
    signal_wait_time_ms   BIGINT       NOT NULL,
    CONSTRAINT PK_wait_stats_history
        PRIMARY KEY CLUSTERED (wait_stats_history_id)
);
GO

/* Should be collected every 1 hour */
INSERT INTO dbo.wait_stats_snapshot (create_date,
                                     wait_type,
                                     waiting_tasks_count,
                                     wait_time_ms,
                                     max_wait_time_ms,
                                     signal_wait_time_ms)
SELECT GETDATE (),
       wait_type,
       waiting_tasks_count,
       wait_time_ms,
       max_wait_time_ms,
       signal_wait_time_ms
FROM sys.dm_os_wait_stats;
GO

WITH WaitStatCTE AS
(
    SELECT create_date,
           DENSE_RANK () OVER (ORDER BY create_date DESC) AS "HistoryID",
           wait_type,
           waiting_tasks_count,
           wait_time_ms,
           max_wait_time_ms,
           signal_wait_time_ms
    FROM dbo.wait_stats_snapshot
)
INSERT INTO dbo.wait_stats_history
SELECT w1.create_date,
       w1.wait_type,
       w1.waiting_tasks_count - COALESCE (w2.waiting_tasks_count, 0),
       w1.wait_time_ms - COALESCE (w2.wait_time_ms, 0),
       w1.max_wait_time_ms - COALESCE (w2.max_wait_time_ms, 0),
       w1.signal_wait_time_ms - COALESCE (w2.signal_wait_time_ms, 0)
FROM WaitStatCTE AS w1
LEFT OUTER JOIN WaitStatCTE AS w2
    ON w1.wait_type = w2.wait_type
       AND w1.waiting_tasks_count >= COALESCE (w2.waiting_tasks_count, 0)
       AND w2.HistoryID = 2
WHERE w1.HistoryID = 1
      AND w1.waiting_tasks_count - COALESCE (w2.waiting_tasks_count, 0) > 0;
GO


/* CLEANUP TASKS */
DECLARE @SnapshotDays INT = 3,
        @HistoryDays  INT = 90;

DELETE FROM dbo.index_usage_stats_snapshot
WHERE create_date < DATEADD (d, -@SnapshotDays, GETDATE ());

DELETE FROM dbo.index_usage_stats_history
WHERE create_date < DATEADD (d, -@HistoryDays, GETDATE ());

DELETE FROM dbo.index_operational_stats_snapshot
WHERE create_date < DATEADD (d, -@SnapshotDays, GETDATE ());

DELETE FROM dbo.index_operational_stats_history
WHERE create_date < DATEADD (d, -@HistoryDays, GETDATE ());

DELETE FROM dbo.index_physical_stats_history
WHERE create_date < DATEADD (d, -@HistoryDays, GETDATE ());

DELETE FROM dbo.wait_stats_snapshot
WHERE create_date < DATEADD (d, -@SnapshotDays, GETDATE ());

DELETE FROM dbo.wait_stats_history
WHERE create_date < DATEADD (d, -@HistoryDays, GETDATE ());
GO
