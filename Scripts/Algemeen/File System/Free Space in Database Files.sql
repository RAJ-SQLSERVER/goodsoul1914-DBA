
/*
 Free Space in Database Files
*/

select SUBSTRING(a.FILENAME, 1, 1) as Drive, 
	   FILE_SIZE_MB = CONVERT(decimal(12, 2), ROUND(a.size / 128.000, 2)), 
	   SPACE_USED_MB = CONVERT(decimal(12, 2), ROUND(FILEPROPERTY(a.name, 'SpaceUsed') / 128.000, 2)), 
	   FREE_SPACE_MB = CONVERT(decimal(12, 2), ROUND(( a.size - FILEPROPERTY(a.name, 'SpaceUsed') ) / 128.000, 2)), 
	   [FREE_SPACE_%] = CONVERT(decimal(12, 2), CONVERT(decimal(12, 2), ROUND(( a.size - FILEPROPERTY(a.name, 'SpaceUsed') ) / 128.000, 2)) / CONVERT(decimal(12, 2), ROUND(a.size / 128.000, 2)) * 100), 
	   a.NAME, 
	   a.FILENAME
from dbo.sysfiles as a
order by Drive, 
		 Name;
go
