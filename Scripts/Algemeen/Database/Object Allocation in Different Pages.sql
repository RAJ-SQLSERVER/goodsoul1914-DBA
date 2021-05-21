-- It provides information as to how objects keep data in different pages and its allocation 
-- in the databases
--------------------------------------------------------------------------------------------------
SELECT DDDPA.database_id,
	DDDPA.object_id,
	DDDPA.index_id,
	DDDPA.partition_id,
	DDDPA.rowset_id,
	DDDPA.allocation_unit_id,
	DDDPA.allocation_unit_type,
	DDDPA.allocation_unit_type_desc,
	DDDPA.data_clone_id,
	DDDPA.clone_state,
	DDDPA.clone_state_desc,
	DDDPA.extent_file_id,
	DDDPA.extent_page_id,
	DDDPA.allocated_page_iam_file_id,
	DDDPA.allocated_page_iam_page_id,
	DDDPA.allocated_page_file_id,
	DDDPA.allocated_page_page_id,
	DDDPA.is_allocated,
	DDDPA.is_iam_page,
	DDDPA.is_mixed_page_allocation,
	DDDPA.page_free_space_percent,
	DDDPA.page_type,
	DDDPA.page_type_desc,
	DDDPA.page_level,
	DDDPA.next_page_file_id,
	DDDPA.next_page_page_id,
	DDDPA.previous_page_file_id,
	DDDPA.previous_page_page_id,
	DDDPA.is_page_compressed,
	DDDPA.has_ghost_records
FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('dbo.Employee'), NULL, NULL, 'DETAILED') AS DDDPA
WHERE page_type = 1;-- Just data pages
GO


