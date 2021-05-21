/********************************************************************************
Author: David Fowler
Revision date: 22/04/2020
Version: 1.1
 
� www.sqlundercover.com 
********************************************************************************/

-- Config variables

declare @logpath nvarchar(260) = 'D:\MSSQL\Log';

declare @datapath nvarchar(260) = 'D:\MSSQL\Data';

declare @movelogs bit = 1;

declare @movedata bit = 0;

-- Runtime variables

declare @STMT nvarchar(4000);

-- Uncomment predicates to include and exclude databases as required

declare Files cursor static forward_only
for select DB_NAME(database_id), 
		   type, 
		   name, 
		   REVERSE(SUBSTRING(REVERSE(physical_name), 0, CHARINDEX('\', REVERSE(physical_name))))
	from sys.master_files
	where type in (0, 1);
--AND DB_NAME(database_id) IN ('sqlundercover')                         -- Uncomment to include databases
--AND DB_NAME(database_id) NOT IN ('master','tempdb','msdb','model')    -- Uncomment to exclude databases

declare @DBName sysname;

declare @type tinyint;

declare @logicalname sysname;

declare @physicalname nvarchar(260);

-- Check filepaths finish with a \ and add if they don't

if SUBSTRING(@datapath, LEN(@datapath), 1) != '\'
	set @datapath+=N'\';

if SUBSTRING(@logpath, LEN(@logpath), 1) != '\'
	set @logpath+=N'\';

open Files;

fetch next from Files into @DBName, 
						   @type, 
						   @logicalname, 
						   @physicalname;

while @@FETCH_STATUS = 0
begin
	set @STMT = N'ALTER DATABASE ' + QUOTENAME(@DBName) + N' MODIFY FILE (NAME = ' + QUOTENAME(@logicalname) + N', FILENAME = ''';
	set @STMT+=case
				   when @type = 0
						and @movedata = 1 then @datapath + @physicalname + ''')'
				   when @type = 1
						and @movelogs = 1 then @logpath + @physicalname + ''')'
			   end;

	print @STMT;

	fetch next from Files into @DBName, 
							   @type, 
							   @logicalname, 
							   @physicalname;
end;

close Files;

deallocate Files;