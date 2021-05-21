-- Returns space usage information for each file in the database
------------------------------------------------------------------------------------------------------
SELECT file_id,
	filegroup_id,
	total_page_count,
	allocated_extent_page_count,
	unallocated_extent_page_count,
	mixed_extent_page_count,
	version_store_reserved_page_count,
	user_object_reserved_page_count,
	internal_object_reserved_page_count
FROM sys.dm_db_file_space_usage;
GO


