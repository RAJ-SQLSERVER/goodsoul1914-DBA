/**********************************************************************************************************
	Check Index Fragmentation based on Page Fullness and Fill Factor
***************************************************************************
Author: Eitan Blumin | https://www.eitanblumin.com
Version History:
	2020-01-07	First version

Description:
This script was inspired by Erik Darling's blog post here:
https://www.erikdarlingdata.com/2019/10/because-your-index-maintenance-script-is-measuring-the-wrong-thing/
	-----------------
	!!!  WARNING  !!!
	-----------------
This script uses "SAMPLED" mode for checking fragmentation,
which can potentially cause significant IO stress on a large production server.
Use at your own risk!
**********************************************************************************************************/

declare @MinPageCount                          int = 1000, 
		@MinUserUpdates                        int = 1000, 
		@MinFragmentationToReduceFillFactor100 int = 50, 
		@MaxFragmentationToSetFillFactor100    int = 20, 
		@MaxSpaceUsedForFillFactor100          int = 90, 
		@MaxSpaceUsedForFillFactorLessThan100  int = 75, 
		@OnlineRebuild                         bit = 0, 
		@SortInTempDB                          bit = 0;

set transaction isolation level read uncommitted;

set nocount, arithabort, xact_abort on;

if @OnlineRebuild = 1
   and CONVERT(nvarchar, SERVERPROPERTY('Edition')) not like N'Enterprise%'
   and CONVERT(nvarchar, SERVERPROPERTY('Edition')) not like N'Developer%'
begin
	raiserror(N'Online Rebuild is not supported in this SQL Server edition.', 16, 1);
	goto Quit;
end;

declare @CommandTemplate nvarchar(max);

set @CommandTemplate = N'RAISERROR(N''{DATABASE}.{TABLE} - {INDEX}'',0,1) WITH NOWAIT;
ALTER INDEX {INDEX} ON {TABLE}
REBUILD WITH(SORT_IN_TEMPDB=' + case
									when @SortInTempDB = 1 then N'ON'
									else N'OFF'
								end + N', ONLINE=' + case
														 when @OnlineRebuild = 1 then N'ON'
														 else N'OFF'
													 end + N'{FILLFACTOR});
GO';

select DatabaseName = DB_NAME(), 
	   SchemaName = OBJECT_SCHEMA_NAME(t.object_id), 
	   TableName = t.name, 
	   IndexName = ix.name, 
	   Remediation = REPLACE(REPLACE(REPLACE(REPLACE(@CommandTemplate, N'{DATABASE}', QUOTENAME(DB_NAME())), N'{TABLE}', QUOTENAME(OBJECT_SCHEMA_NAME(t.object_id)) + N'.' + QUOTENAME(t.name)), N'{INDEX}', QUOTENAME(ix.name)), N'{FILLFACTOR}',
																																																								  case
																																																									  when ix.fill_factor = 0
																																																										   and ps.avg_fragmentation_in_percent >= @MinFragmentationToReduceFillFactor100 then N', FILLFACTOR=90'
																																																									  when ix.fill_factor > 0
																																																										   and ps.avg_fragmentation_in_percent <= @MaxFragmentationToSetFillFactor100 then N', FILLFACTOR=100'
																																																									  else N''
																																																								  end), 
	   ix.fill_factor, 
	   RowsCount =
(
	select SUM(rows)
	from sys.partitions as p
	where p.object_id = t.object_id
		  and p.index_id = ix.index_id
), 
	   us.user_updates, 
	   us.last_user_update, 
	   ps.avg_fragmentation_in_percent, 
	   ps.avg_page_space_used_in_percent, 
	   ps.record_count, 
	   ps.page_count, 
	   ps.compressed_page_count, 
	   t.object_id, 
	   ix.index_id, 
	   ps.partition_number
from sys.dm_db_index_usage_stats as us
	 inner join sys.tables as t on us.object_id = t.object_id
	 inner join sys.indexes as ix on ix.object_id = t.object_id
									 and ix.index_id = us.index_id
	 cross apply sys.dm_db_index_physical_stats (DB_ID(), t.object_id, ix.index_id, null, 'SAMPLED') as ps
where us.database_id = DB_ID()
	  and ps.alloc_unit_type_desc = 'IN_ROW_DATA'
	  and t.is_ms_shipped = 0
	  and us.user_updates >= @MinUserUpdates
	  and ps.page_count >= @MinPageCount
	  and ( ps.avg_page_space_used_in_percent <= @MaxSpaceUsedForFillFactorLessThan100
			or ix.fill_factor = 0
			and ps.avg_page_space_used_in_percent <= @MaxSpaceUsedForFillFactor100
			and ps.avg_fragmentation_in_percent >= @MinFragmentationToReduceFillFactor100
		  );

Quit: