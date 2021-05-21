
/**********************************************************************************
Author: Adrian Buckman
Revision date: 06/09/2017
Version: 1
**********************************************************************************/

select Database_name, 
	   DataFilename, 
	   PhysicalFile_name, 
	   File_id, 
	   DatabaseFileSize_MB, 
	   GrowthRate_MB, 
	   Is_Percent_Growth,
	   case GrowthCheck.is_percent_Growth
		   when 1 then Growth
		   else 0
	   end as [GrowthPercentage%], 
	   NextGrowth
from
(
	select DB_NAME(Masterfiles.Database_id) as Database_name, 
		   Masterfiles.Name as DataFilename, 
		   MasterFiles.physical_name as PhysicalFile_name, 
		   MasterFiles.File_id, 
		   ( CAST(Size as bigint) * 8 ) / 1024 as DatabaseFileSize_MB,
		   case Masterfiles.is_percent_Growth
			   when 0 then( Masterfiles.Growth * 8 ) / 1024
			   when 1 then( ( ( CAST(Size as bigint) * 8 ) / 1024 ) * Growth ) / 100
		   end as GrowthRate_MB, 
		   Masterfiles.is_percent_growth, 
		   Masterfiles.growth,
		   case Masterfiles.is_percent_growth
			   when 0 then( CAST(Size as bigint) * 8 ) / 1024 + ( [Growth] * 8 ) / 1024
			   when 1 then( CAST(Size as bigint) * 8 ) / 1024 + ( ( ( CAST([Size] as bigint) * 8 ) / 1024 ) * [Growth] ) / 100
		   end as NextGrowth
	from SYS.master_files as Masterfiles
		 inner join sys.databases as DatabasesList on Masterfiles.database_id = DatabasesList.database_id
	where Masterfiles.Database_ID > 4       -- Ignore System databases
		  --AND [Type_desc] = 'ROWS'          -- Data Files only
		  and DatabasesList.State = 0       -- Online Databases only
) as GrowthCheck
order by Database_name asc, 
		 File_ID asc;


-- Check individual File Sizes and space available for current database
SELECT name AS [File Name] , physical_name AS [Physical Name], size/128.0 AS [Total Size in MB],
size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128.0 AS [Available Space In MB], [file_id]
FROM sys.database_files;