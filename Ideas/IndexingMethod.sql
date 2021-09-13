USE [IndexingMethod]
GO
/****** Object:  Table [dbo].[index_operational_stats_history]    Script Date: 13-9-2021 11:24:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[index_operational_stats_history](
	[history_id] [int] IDENTITY(1,1) NOT NULL,
	[create_date] [datetime] NULL,
	[database_id] [smallint] NOT NULL,
	[object_id] [int] NOT NULL,
	[index_id] [int] NOT NULL,
	[partition_number] [int] NOT NULL,
	[leaf_insert_count] [bigint] NOT NULL,
	[leaf_delete_count] [bigint] NOT NULL,
	[leaf_update_count] [bigint] NOT NULL,
	[leaf_ghost_count] [bigint] NOT NULL,
	[nonleaf_insert_count] [bigint] NOT NULL,
	[nonleaf_delete_count] [bigint] NOT NULL,
	[nonleaf_update_count] [bigint] NOT NULL,
	[leaf_allocation_count] [bigint] NOT NULL,
	[nonleaf_allocation_count] [bigint] NOT NULL,
	[leaf_page_merge_count] [bigint] NOT NULL,
	[nonleaf_page_merge_count] [bigint] NOT NULL,
	[range_scan_count] [bigint] NOT NULL,
	[singleton_lookup_count] [bigint] NOT NULL,
	[forwarded_fetch_count] [bigint] NOT NULL,
	[lob_fetch_in_pages] [bigint] NOT NULL,
	[lob_fetch_in_bytes] [bigint] NOT NULL,
	[lob_orphan_create_count] [bigint] NOT NULL,
	[lob_orphan_insert_count] [bigint] NOT NULL,
	[row_overflow_fetch_in_pages] [bigint] NOT NULL,
	[row_overflow_fetch_in_bytes] [bigint] NOT NULL,
	[column_value_push_off_row_count] [bigint] NOT NULL,
	[column_value_pull_in_row_count] [bigint] NOT NULL,
	[row_lock_count] [bigint] NOT NULL,
	[row_lock_wait_count] [bigint] NOT NULL,
	[row_lock_wait_in_ms] [bigint] NOT NULL,
	[page_lock_count] [bigint] NOT NULL,
	[page_lock_wait_count] [bigint] NOT NULL,
	[page_lock_wait_in_ms] [bigint] NOT NULL,
	[index_lock_promotion_attempt_count] [bigint] NOT NULL,
	[index_lock_promotion_count] [bigint] NOT NULL,
	[page_latch_wait_count] [bigint] NOT NULL,
	[page_latch_wait_in_ms] [bigint] NOT NULL,
	[page_io_latch_wait_count] [bigint] NOT NULL,
	[page_io_latch_wait_in_ms] [bigint] NOT NULL,
	[tree_page_latch_wait_count] [bigint] NOT NULL,
	[tree_page_latch_wait_in_ms] [bigint] NOT NULL,
	[tree_page_io_latch_wait_count] [bigint] NOT NULL,
	[tree_page_io_latch_wait_in_ms] [bigint] NOT NULL,
	[page_compression_attempt_count] [bigint] NOT NULL,
	[page_compression_success_count] [bigint] NOT NULL,
 CONSTRAINT [PK_IndexOperationalStatsHistory] PRIMARY KEY CLUSTERED 
(
	[history_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_IndexOperationalStatsHistory] UNIQUE NONCLUSTERED 
(
	[create_date] ASC,
	[database_id] ASC,
	[object_id] ASC,
	[index_id] ASC,
	[partition_number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[index_operational_stats_snapshot]    Script Date: 13-9-2021 11:24:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[index_operational_stats_snapshot](
	[snapshot_id] [int] IDENTITY(1,1) NOT NULL,
	[create_date] [datetime] NULL,
	[database_id] [smallint] NOT NULL,
	[object_id] [int] NOT NULL,
	[index_id] [int] NOT NULL,
	[partition_number] [int] NOT NULL,
	[leaf_insert_count] [bigint] NOT NULL,
	[leaf_delete_count] [bigint] NOT NULL,
	[leaf_update_count] [bigint] NOT NULL,
	[leaf_ghost_count] [bigint] NOT NULL,
	[nonleaf_insert_count] [bigint] NOT NULL,
	[nonleaf_delete_count] [bigint] NOT NULL,
	[nonleaf_update_count] [bigint] NOT NULL,
	[leaf_allocation_count] [bigint] NOT NULL,
	[nonleaf_allocation_count] [bigint] NOT NULL,
	[leaf_page_merge_count] [bigint] NOT NULL,
	[nonleaf_page_merge_count] [bigint] NOT NULL,
	[range_scan_count] [bigint] NOT NULL,
	[singleton_lookup_count] [bigint] NOT NULL,
	[forwarded_fetch_count] [bigint] NOT NULL,
	[lob_fetch_in_pages] [bigint] NOT NULL,
	[lob_fetch_in_bytes] [bigint] NOT NULL,
	[lob_orphan_create_count] [bigint] NOT NULL,
	[lob_orphan_insert_count] [bigint] NOT NULL,
	[row_overflow_fetch_in_pages] [bigint] NOT NULL,
	[row_overflow_fetch_in_bytes] [bigint] NOT NULL,
	[column_value_push_off_row_count] [bigint] NOT NULL,
	[column_value_pull_in_row_count] [bigint] NOT NULL,
	[row_lock_count] [bigint] NOT NULL,
	[row_lock_wait_count] [bigint] NOT NULL,
	[row_lock_wait_in_ms] [bigint] NOT NULL,
	[page_lock_count] [bigint] NOT NULL,
	[page_lock_wait_count] [bigint] NOT NULL,
	[page_lock_wait_in_ms] [bigint] NOT NULL,
	[index_lock_promotion_attempt_count] [bigint] NOT NULL,
	[index_lock_promotion_count] [bigint] NOT NULL,
	[page_latch_wait_count] [bigint] NOT NULL,
	[page_latch_wait_in_ms] [bigint] NOT NULL,
	[page_io_latch_wait_count] [bigint] NOT NULL,
	[page_io_latch_wait_in_ms] [bigint] NOT NULL,
	[tree_page_latch_wait_count] [bigint] NOT NULL,
	[tree_page_latch_wait_in_ms] [bigint] NOT NULL,
	[tree_page_io_latch_wait_count] [bigint] NOT NULL,
	[tree_page_io_latch_wait_in_ms] [bigint] NOT NULL,
	[page_compression_attempt_count] [bigint] NOT NULL,
	[page_compression_success_count] [bigint] NOT NULL,
 CONSTRAINT [PK_IndexOperationalStatsSnapshot] PRIMARY KEY CLUSTERED 
(
	[snapshot_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[index_physical_stats_history]    Script Date: 13-9-2021 11:24:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[index_physical_stats_history](
	[history_id] [int] IDENTITY(1,1) NOT NULL,
	[create_date] [datetime] NULL,
	[database_id] [smallint] NULL,
	[object_id] [int] NULL,
	[index_id] [int] NULL,
	[partition_number] [int] NULL,
	[index_type_desc] [nvarchar](60) NULL,
	[alloc_unit_type_desc] [nvarchar](60) NULL,
	[index_depth] [tinyint] NULL,
	[index_level] [tinyint] NULL,
	[avg_fragmentation_in_percent] [float] NULL,
	[fragment_count] [bigint] NULL,
	[avg_fragment_size_in_pages] [float] NULL,
	[page_count] [bigint] NULL,
	[avg_page_space_used_in_percent] [float] NULL,
	[record_count] [bigint] NULL,
	[ghost_record_count] [bigint] NULL,
	[version_ghost_record_count] [bigint] NULL,
	[min_record_size_in_bytes] [int] NULL,
	[max_record_size_in_bytes] [int] NULL,
	[avg_record_size_in_bytes] [float] NULL,
	[forwarded_record_count] [bigint] NULL,
	[compressed_page_count] [bigint] NULL,
 CONSTRAINT [PK_IndexPhysicalStatsHistory] PRIMARY KEY CLUSTERED 
(
	[history_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[index_usage_stats_history]    Script Date: 13-9-2021 11:24:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[index_usage_stats_history](
	[history_id] [int] IDENTITY(1,1) NOT NULL,
	[create_date] [datetime] NULL,
	[database_id] [smallint] NOT NULL,
	[object_id] [int] NOT NULL,
	[index_id] [int] NOT NULL,
	[user_seeks] [bigint] NOT NULL,
	[user_scans] [bigint] NOT NULL,
	[user_lookups] [bigint] NOT NULL,
	[user_updates] [bigint] NOT NULL,
	[last_user_seek] [datetime] NULL,
	[last_user_scan] [datetime] NULL,
	[last_user_lookup] [datetime] NULL,
	[last_user_update] [datetime] NULL,
	[system_seeks] [bigint] NOT NULL,
	[system_scans] [bigint] NOT NULL,
	[system_lookups] [bigint] NOT NULL,
	[system_updates] [bigint] NOT NULL,
	[last_system_seek] [datetime] NULL,
	[last_system_scan] [datetime] NULL,
	[last_system_lookup] [datetime] NULL,
	[last_system_update] [datetime] NULL,
 CONSTRAINT [PK_IndexUsageStatsHistory] PRIMARY KEY CLUSTERED 
(
	[history_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_IndexUsageStatsHistory] UNIQUE NONCLUSTERED 
(
	[create_date] ASC,
	[database_id] ASC,
	[object_id] ASC,
	[index_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[index_usage_stats_snapshot]    Script Date: 13-9-2021 11:24:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[index_usage_stats_snapshot](
	[snapshot_id] [int] IDENTITY(1,1) NOT NULL,
	[create_date] [datetime] NULL,
	[database_id] [smallint] NOT NULL,
	[object_id] [int] NOT NULL,
	[index_id] [int] NOT NULL,
	[user_seeks] [bigint] NOT NULL,
	[user_scans] [bigint] NOT NULL,
	[user_lookups] [bigint] NOT NULL,
	[user_updates] [bigint] NOT NULL,
	[last_user_seek] [datetime] NULL,
	[last_user_scan] [datetime] NULL,
	[last_user_lookup] [datetime] NULL,
	[last_user_update] [datetime] NULL,
	[system_seeks] [bigint] NOT NULL,
	[system_scans] [bigint] NOT NULL,
	[system_lookups] [bigint] NOT NULL,
	[system_updates] [bigint] NOT NULL,
	[last_system_seek] [datetime] NULL,
	[last_system_scan] [datetime] NULL,
	[last_system_lookup] [datetime] NULL,
	[last_system_update] [datetime] NULL,
 CONSTRAINT [PK_IndexUsageStatsSnapshot] PRIMARY KEY CLUSTERED 
(
	[snapshot_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_IndexUsageStatsSnapshot] UNIQUE NONCLUSTERED 
(
	[create_date] ASC,
	[database_id] ASC,
	[object_id] ASC,
	[index_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[IndexingCounters]    Script Date: 13-9-2021 11:24:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IndexingCounters](
	[counter_id] [int] IDENTITY(1,1) NOT NULL,
	[create_date] [datetime] NULL,
	[server_name] [varchar](128) NOT NULL,
	[object_name] [varchar](128) NOT NULL,
	[counter_name] [varchar](128) NOT NULL,
	[instance_name] [varchar](128) NULL,
	[Calculated_Counter_value] [float] NULL,
 CONSTRAINT [PK_IndexingCounters] PRIMARY KEY CLUSTERED 
(
	[counter_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[IndexingCountersBaseline]    Script Date: 13-9-2021 11:24:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IndexingCountersBaseline](
	[counter_baseline_id] [int] IDENTITY(1,1) NOT NULL,
	[start_date] [datetime] NULL,
	[end_date] [datetime] NULL,
	[server_name] [varchar](128) NOT NULL,
	[object_name] [varchar](128) NOT NULL,
	[counter_name] [varchar](128) NOT NULL,
	[instance_name] [varchar](128) NULL,
	[minimum_counter_value] [float] NULL,
	[maximum_counter_value] [float] NULL,
	[average_counter_value] [float] NULL,
	[standard_deviation_counter_value] [float] NULL,
 CONSTRAINT [PK_IndexingCountersBaseline] PRIMARY KEY CLUSTERED 
(
	[counter_baseline_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[wait_stats_history]    Script Date: 13-9-2021 11:24:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[wait_stats_history](
	[wait_stats_history_id] [int] IDENTITY(1,1) NOT NULL,
	[create_date] [datetime] NULL,
	[wait_type] [nvarchar](60) NOT NULL,
	[waiting_tasks_count] [bigint] NOT NULL,
	[wait_time_ms] [bigint] NOT NULL,
	[max_wait_time_ms] [bigint] NOT NULL,
	[signal_wait_time_ms] [bigint] NOT NULL,
 CONSTRAINT [PK_wait_stats_history] PRIMARY KEY CLUSTERED 
(
	[wait_stats_history_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[wait_stats_snapshot]    Script Date: 13-9-2021 11:24:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[wait_stats_snapshot](
	[wait_stats_snapshot_id] [int] IDENTITY(1,1) NOT NULL,
	[create_date] [datetime] NULL,
	[wait_type] [nvarchar](60) NOT NULL,
	[waiting_tasks_count] [bigint] NOT NULL,
	[wait_time_ms] [bigint] NOT NULL,
	[max_wait_time_ms] [bigint] NOT NULL,
	[signal_wait_time_ms] [bigint] NOT NULL,
 CONSTRAINT [PK_wait_stats_snapshot] PRIMARY KEY CLUSTERED 
(
	[wait_stats_snapshot_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
