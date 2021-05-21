USE BobsShoes;
GO

--  Show the active snapshot transactions
SELECT DB_NAME (database_id) AS "DatabaseName",
       t.transaction_id,
       t.transaction_sequence_num,
       t.commit_sequence_num,
       t.session_id,
       t.is_snapshot,
       t.first_snapshot_sequence_num,
       t.max_version_chain_traversed,
       t.average_version_chain_traversed,
       t.elapsed_time_seconds
FROM sys.dm_tran_active_snapshot_database_transactions AS t
JOIN sys.dm_exec_sessions AS s
    ON t.session_id = s.session_id;

-- Show space usage in tempdb
SELECT DB_NAME (vsu.database_id) AS "DatabaseName",
       vsu.reserved_page_count,
       vsu.reserved_space_kb,
       tu.total_page_count AS "tempdb_pages",
       vsu.reserved_page_count * 100. / tu.total_page_count AS "Snapshot %",
       tu.allocated_extent_page_count * 100. / tu.total_page_count AS "tempdb % used"
FROM sys.dm_tran_version_store_space_usage AS vsu
CROSS JOIN tempdb.sys.dm_db_file_space_usage AS tu
WHERE vsu.database_id = DB_ID (DB_NAME ());

-- Show the contents of the current version store (expensive)
SELECT DB_NAME (database_id) AS "DatabaseName",
       transaction_sequence_num,
       version_sequence_num,
       database_id,
       rowset_id,
       status,
       min_length_in_bytes,
       record_length_first_part_in_bytes,
       record_image_first_part,
       record_length_second_part_in_bytes,
       record_image_second_part
FROM sys.dm_tran_version_store;

-- Show objects producing most versions (expensive)
SELECT DB_NAME (database_id) AS "DatabaseName",
       database_id,
       rowset_id,
       aggregated_record_length_in_bytes
FROM sys.dm_tran_top_version_generators;
