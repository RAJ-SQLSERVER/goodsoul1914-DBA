-- Database Filenames and Paths
-- File names and paths for TempDB and all user databases in instance
--
-- Things to look at:
-- Are data files and log files on different drives?
-- Is everything on the C: drive?
-- Is TempDB on dedicated drives?
-- Is there only one TempDB data file?
-- Are all of the TempDB data files the same size?
-- Are there multiple data files for user databases?
-- Is percent growth enabled for any files (which is bad)?
-- ------------------------------------------------------------------------------------------------

select DB_NAME(database_id) as [Database Name], 
	   file_id, 
	   name, 
	   physical_name, 
	   type_desc, 
	   state_desc, 
	   is_percent_growth, 
	   growth, 
	   CONVERT(bigint, growth / 128.0) as [Growth in MB], 
	   CONVERT(bigint, size / 128.0) as [Total Size in MB]
from sys.master_files with(nolock)
where database_id > 4
	  and database_id <> 32767
	  or database_id = 2
order by DB_NAME(database_id) option(recompile);
go