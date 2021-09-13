USE DBA;
GO

/****** Object:  Table [dbo].[index_operational_stats_history]    Script Date: 13-9-2021 11:24:34 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE TABLE dbo.index_operational_stats_history (
    history_id                         INT      IDENTITY(1, 1) NOT NULL,
    create_date                        DATETIME NULL,
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
        PRIMARY KEY CLUSTERED (history_id ASC)
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
              ALLOW_PAGE_LOCKS = ON
        ) ON [PRIMARY],
    CONSTRAINT UQ_IndexOperationalStatsHistory
        UNIQUE NONCLUSTERED (
            create_date ASC,
            database_id ASC,
            object_id ASC,
            index_id ASC,
            partition_number ASC
        )
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
              ALLOW_PAGE_LOCKS = ON
        ) ON [PRIMARY]
) ON [PRIMARY];
GO
/****** Object:  Table [dbo].[index_operational_stats_snapshot]    Script Date: 13-9-2021 11:24:34 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE dbo.index_operational_stats_snapshot (
    snapshot_id                        INT      IDENTITY(1, 1) NOT NULL,
    create_date                        DATETIME NULL,
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
        PRIMARY KEY CLUSTERED (snapshot_id ASC)
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
              ALLOW_PAGE_LOCKS = ON
        ) ON [PRIMARY]
) ON [PRIMARY];
GO
/****** Object:  Table [dbo].[index_physical_stats_history]    Script Date: 13-9-2021 11:24:34 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE dbo.index_physical_stats_history (
    history_id                     INT          IDENTITY(1, 1) NOT NULL,
    create_date                    DATETIME     NULL,
    database_id                    SMALLINT     NULL,
    object_id                      INT          NULL,
    index_id                       INT          NULL,
    partition_number               INT          NULL,
    index_type_desc                NVARCHAR(60) NULL,
    alloc_unit_type_desc           NVARCHAR(60) NULL,
    index_depth                    TINYINT      NULL,
    index_level                    TINYINT      NULL,
    avg_fragmentation_in_percent   FLOAT        NULL,
    fragment_count                 BIGINT       NULL,
    avg_fragment_size_in_pages     FLOAT        NULL,
    page_count                     BIGINT       NULL,
    avg_page_space_used_in_percent FLOAT        NULL,
    record_count                   BIGINT       NULL,
    ghost_record_count             BIGINT       NULL,
    version_ghost_record_count     BIGINT       NULL,
    min_record_size_in_bytes       INT          NULL,
    max_record_size_in_bytes       INT          NULL,
    avg_record_size_in_bytes       FLOAT        NULL,
    forwarded_record_count         BIGINT       NULL,
    compressed_page_count          BIGINT       NULL,
    CONSTRAINT PK_IndexPhysicalStatsHistory
        PRIMARY KEY CLUSTERED (history_id ASC)
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
              ALLOW_PAGE_LOCKS = ON
        ) ON [PRIMARY]
) ON [PRIMARY];
GO
/****** Object:  Table [dbo].[index_usage_stats_history]    Script Date: 13-9-2021 11:24:34 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE dbo.index_usage_stats_history (
    history_id         INT      IDENTITY(1, 1) NOT NULL,
    create_date        DATETIME NULL,
    database_id        SMALLINT NOT NULL,
    object_id          INT      NOT NULL,
    index_id           INT      NOT NULL,
    user_seeks         BIGINT   NOT NULL,
    user_scans         BIGINT   NOT NULL,
    user_lookups       BIGINT   NOT NULL,
    user_updates       BIGINT   NOT NULL,
    last_user_seek     DATETIME NULL,
    last_user_scan     DATETIME NULL,
    last_user_lookup   DATETIME NULL,
    last_user_update   DATETIME NULL,
    system_seeks       BIGINT   NOT NULL,
    system_scans       BIGINT   NOT NULL,
    system_lookups     BIGINT   NOT NULL,
    system_updates     BIGINT   NOT NULL,
    last_system_seek   DATETIME NULL,
    last_system_scan   DATETIME NULL,
    last_system_lookup DATETIME NULL,
    last_system_update DATETIME NULL,
    CONSTRAINT PK_IndexUsageStatsHistory
        PRIMARY KEY CLUSTERED (history_id ASC)
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
              ALLOW_PAGE_LOCKS = ON
        ) ON [PRIMARY],
    CONSTRAINT UQ_IndexUsageStatsHistory
        UNIQUE NONCLUSTERED (create_date ASC, database_id ASC, object_id ASC, index_id ASC)
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
              ALLOW_PAGE_LOCKS = ON
        ) ON [PRIMARY]
) ON [PRIMARY];
GO
/****** Object:  Table [dbo].[index_usage_stats_snapshot]    Script Date: 13-9-2021 11:24:34 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE dbo.index_usage_stats_snapshot (
    snapshot_id        INT      IDENTITY(1, 1) NOT NULL,
    create_date        DATETIME NULL,
    database_id        SMALLINT NOT NULL,
    object_id          INT      NOT NULL,
    index_id           INT      NOT NULL,
    user_seeks         BIGINT   NOT NULL,
    user_scans         BIGINT   NOT NULL,
    user_lookups       BIGINT   NOT NULL,
    user_updates       BIGINT   NOT NULL,
    last_user_seek     DATETIME NULL,
    last_user_scan     DATETIME NULL,
    last_user_lookup   DATETIME NULL,
    last_user_update   DATETIME NULL,
    system_seeks       BIGINT   NOT NULL,
    system_scans       BIGINT   NOT NULL,
    system_lookups     BIGINT   NOT NULL,
    system_updates     BIGINT   NOT NULL,
    last_system_seek   DATETIME NULL,
    last_system_scan   DATETIME NULL,
    last_system_lookup DATETIME NULL,
    last_system_update DATETIME NULL,
    CONSTRAINT PK_IndexUsageStatsSnapshot
        PRIMARY KEY CLUSTERED (snapshot_id ASC)
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
              ALLOW_PAGE_LOCKS = ON
        ) ON [PRIMARY],
    CONSTRAINT UQ_IndexUsageStatsSnapshot
        UNIQUE NONCLUSTERED (create_date ASC, database_id ASC, object_id ASC, index_id ASC)
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
              ALLOW_PAGE_LOCKS = ON
        ) ON [PRIMARY]
) ON [PRIMARY];
GO
/****** Object:  Table [dbo].[IndexingCounters]    Script Date: 13-9-2021 11:24:34 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE dbo.IndexingCounters (
    counter_id               INT          IDENTITY(1, 1) NOT NULL,
    create_date              DATETIME     NULL,
    server_name              VARCHAR(128) NOT NULL,
    object_name              VARCHAR(128) NOT NULL,
    counter_name             VARCHAR(128) NOT NULL,
    instance_name            VARCHAR(128) NULL,
    Calculated_Counter_value FLOAT        NULL,
    CONSTRAINT PK_IndexingCounters
        PRIMARY KEY CLUSTERED (counter_id ASC)
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
              ALLOW_PAGE_LOCKS = ON
        ) ON [PRIMARY]
) ON [PRIMARY];
GO
/****** Object:  Table [dbo].[IndexingCountersBaseline]    Script Date: 13-9-2021 11:24:34 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE dbo.IndexingCountersBaseline (
    counter_baseline_id              INT          IDENTITY(1, 1) NOT NULL,
    start_date                       DATETIME     NULL,
    end_date                         DATETIME     NULL,
    server_name                      VARCHAR(128) NOT NULL,
    object_name                      VARCHAR(128) NOT NULL,
    counter_name                     VARCHAR(128) NOT NULL,
    instance_name                    VARCHAR(128) NULL,
    minimum_counter_value            FLOAT        NULL,
    maximum_counter_value            FLOAT        NULL,
    average_counter_value            FLOAT        NULL,
    standard_deviation_counter_value FLOAT        NULL,
    CONSTRAINT PK_IndexingCountersBaseline
        PRIMARY KEY CLUSTERED (counter_baseline_id ASC)
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
              ALLOW_PAGE_LOCKS = ON
        ) ON [PRIMARY]
) ON [PRIMARY];
GO
/****** Object:  Table [dbo].[wait_stats_history]    Script Date: 13-9-2021 11:24:34 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE dbo.wait_stats_history (
    wait_stats_history_id INT          IDENTITY(1, 1) NOT NULL,
    create_date           DATETIME     NULL,
    wait_type             NVARCHAR(60) NOT NULL,
    waiting_tasks_count   BIGINT       NOT NULL,
    wait_time_ms          BIGINT       NOT NULL,
    max_wait_time_ms      BIGINT       NOT NULL,
    signal_wait_time_ms   BIGINT       NOT NULL,
    CONSTRAINT PK_wait_stats_history
        PRIMARY KEY CLUSTERED (wait_stats_history_id ASC)
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
              ALLOW_PAGE_LOCKS = ON
        ) ON [PRIMARY]
) ON [PRIMARY];
GO
/****** Object:  Table [dbo].[wait_stats_snapshot]    Script Date: 13-9-2021 11:24:34 ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE dbo.wait_stats_snapshot (
    wait_stats_snapshot_id INT          IDENTITY(1, 1) NOT NULL,
    create_date            DATETIME     NULL,
    wait_type              NVARCHAR(60) NOT NULL,
    waiting_tasks_count    BIGINT       NOT NULL,
    wait_time_ms           BIGINT       NOT NULL,
    max_wait_time_ms       BIGINT       NOT NULL,
    signal_wait_time_ms    BIGINT       NOT NULL,
    CONSTRAINT PK_wait_stats_snapshot
        PRIMARY KEY CLUSTERED (wait_stats_snapshot_id ASC)
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
              ALLOW_PAGE_LOCKS = ON
        ) ON [PRIMARY]
) ON [PRIMARY];
GO
