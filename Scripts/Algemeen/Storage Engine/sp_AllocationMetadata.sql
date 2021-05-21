/*****************************************************************************
  File:     sp_AllocationMetadata.sql
 
  Summary:  This script cracks the system tables to provide top-level
            metadata about a table or index
 
  SQL Server Versions: 2005 onwards
------------------------------------------------------------------------------
  Written by Paul S. Randal, SQLskills.com
 
  (c) 2014, SQLskills.com. All rights reserved.
 
  For more scripts and sample code, check out http://www.SQLskills.com
*****************************************************************************/

use [master];
go

if OBJECT_ID(N'sp_AllocationMetadata') is not null
	drop procedure sp_AllocationMetadata;
go

create procedure sp_AllocationMetadata
(
	@object sysname = null) 
as
begin
	select OBJECT_NAME(sp.object_id) as [Object Name], 
		   sp.index_id as [Index ID], 
		   sp.partition_id as [Partition ID], 
		   sa.allocation_unit_id as [Alloc Unit ID], 
		   sa.type_desc as [Alloc Unit Type], 
		   '(' + CONVERT(varchar(6), CONVERT(int, SUBSTRING(sa.first_page, 6, 1) + SUBSTRING(sa.first_page, 5, 1))) + ':' + CONVERT(varchar(20), CONVERT(int, SUBSTRING(sa.first_page, 4, 1) + SUBSTRING(sa.first_page, 3, 1) + SUBSTRING(sa.first_page, 2, 1) + SUBSTRING(sa.first_page, 1, 1))) + ')' as [First Page], 
		   '(' + CONVERT(varchar(6), CONVERT(int, SUBSTRING(sa.root_page, 6, 1) + SUBSTRING(sa.root_page, 5, 1))) + ':' + CONVERT(varchar(20), CONVERT(int, SUBSTRING(sa.root_page, 4, 1) + SUBSTRING(sa.root_page, 3, 1) + SUBSTRING(sa.root_page, 2, 1) + SUBSTRING(sa.root_page, 1, 1))) + ')' as [Root Page], 
		   '(' + CONVERT(varchar(6), CONVERT(int, SUBSTRING(sa.first_iam_page, 6, 1) + SUBSTRING(sa.first_iam_page, 5, 1))) + ':' + CONVERT(varchar(20), CONVERT(int, SUBSTRING(sa.first_iam_page, 4, 1) + SUBSTRING(sa.first_iam_page, 3, 1) + SUBSTRING(sa.first_iam_page, 2, 1) + SUBSTRING(sa.first_iam_page, 1, 1))) + ')' as [First IAM Page]
	from sys.system_internals_allocation_units as sa, sys.partitions as sp
	where sa.container_id = sp.partition_id
		  and sp.object_id = case
								 when @object is null then sp.object_id
							 else OBJECT_ID(@object)
							 end;
end;
go

exec sys.sp_MS_marksystemobject sp_AllocationMetadata;
go

/*******************************************************
USE [AdventureWorks];
GO
EXEC [sp_AllocationMetadata] N'HumanResources.Employee';
GO
*******************************************************/