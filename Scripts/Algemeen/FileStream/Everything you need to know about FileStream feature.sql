/*
The file stream network path technically is this 
\\SQL Server name\Network Share Name\Database File stream Directory Name\<File Table Name>

SQL Server Name – (starting with \\)
Windows Share Name – It is visible in 
SQL Server Configuration tool -> SQL Server properties -> FileStream tab.

Database File stream Directory Name – It can be seen in 
Database Properties -> Options -> FILESTREAM Directory Name

The last part is the file table name.
*/

-------------------------------------------------------------------------------
-- Exploration queries
-------------------------------------------------------------------------------

SELECT DB_NAME (database_id) AS "DatabaseName",
       non_transacted_access_desc,
       directory_name
FROM sys.database_filestream_options
WHERE directory_name IS NOT NULL;
GO

SELECT directory_name,
       is_enabled,
       filename_collation_name
FROM sys.filetables;
GO

SELECT *
FROM sys.tables
WHERE is_filetable = 1;
GO

SELECT object_id,
       OBJECT_NAME (object_id) AS "Object Names"
FROM sys.filetable_system_defined_objects;
GO

-- To get the root level UNC path of a file table
SELECT FileTableRootPath ();

SELECT FileTableRootPath (N'documents');
GO


-------------------------------------------------------------------------------
-- Enable/disable queries
-------------------------------------------------------------------------------

-- Disable Non-Transactional write access.
ALTER DATABASE MyFileTable
SET FILESTREAM (NON_TRANSACTED_ACCESS = READ_ONLY);
GO

-- Disable non-transactional access.
ALTER DATABASE MyFileTable SET FILESTREAM (NON_TRANSACTED_ACCESS = OFF);
GO

-- Enable full non-transactional Access
ALTER DATABASE MyFileTable SET FILESTREAM (NON_TRANSACTED_ACCESS = FULL);
GO


-------------------------------------------------------------------------------
-- Find locks helt by Filestream queries
-------------------------------------------------------------------------------

SELECT *
FROM sys.dm_filestream_non_transacted_handles;
GO

-- To identify open files and the associated locks
SELECT opened_file_name
FROM sys.dm_filestream_non_transacted_handles
WHERE fcb_id IN ( SELECT request_owner_id FROM sys.dm_tran_locks );
GO

-- Kill all open handles in all the filetables in the database.
EXEC sys.sp_kill_filestream_non_transacted_handles;
GO

-- Kill all open handles in a single filetable.
EXEC sys.sp_kill_filestream_non_transacted_handles @table_name = 'documents';
GO

-- Kill a single handle.
EXEC sys.sp_kill_filestream_non_transacted_handles @handle_id = integer_handle_id;
GO
