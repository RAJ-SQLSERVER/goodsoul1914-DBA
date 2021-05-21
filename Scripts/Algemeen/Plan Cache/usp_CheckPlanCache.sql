/*****************************************************************************
============================================================================
  File:     sp_CheckPlanCache

  Summary:  This procedure looks at cache and totals the single-use plans
			to report the percentage of memory consumed (and therefore wasted)
			from single-use plans.
			
  Date:     April 2010

  Version:	2008.
------------------------------------------------------------------------------
  Written by Kimberly L. Tripp, SQLskills.com

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by SQLskills instructors.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================
*****************************************************************************/

use DBA;
go

if OBJECTPROPERTY(OBJECT_ID('usp_CheckPlanCache'), 'IsProcedure') = 1
	drop procedure usp_CheckPlanCache;
go

create procedure usp_CheckPlanCache
(
	@Percent  decimal(6, 3) output, 
	@WastedMB decimal(19, 3) output) 
as
begin
	set nocount on;

	declare @ConfiguredMemory   decimal(19, 3), 
			@PhysicalMemory     decimal(19, 3), 
			@MemoryInUse        decimal(19, 3), 
			@SingleUsePlanCount bigint;

	create table #ConfigurationOptions
	(
		name         nvarchar(35), 
		minimum      int, 
		maximum      int, 
		config_value int, -- in bytes 
		run_value    int -- in bytes
	);

	exec sp_configure 'show advanced options', 1;
	reconfigure;

	insert into #ConfigurationOptions
	exec ('sp_configure ''max server memory''');

	select @ConfiguredMemory = run_value / 1024 / 1024
	from #ConfigurationOptions
	where name = 'max server memory (MB)';

	exec sp_configure 'show advanced options', 0;
	reconfigure;

	select @PhysicalMemory = total_physical_memory_kb / 1024
	from sys.dm_os_sys_memory;

	select @MemoryInUse = physical_memory_in_use_kb / 1024
	from sys.dm_os_process_memory;

	select @WastedMB = SUM(CAST(case
									when usecounts = 1
										 and objtype in('Adhoc', 'Prepared') then size_in_bytes
								else 0
								end as decimal(12, 2))) / 1024 / 1024, 
		   @SingleUsePlanCount = SUM(case
										 when usecounts = 1
											  and objtype in('Adhoc', 'Prepared') then 1
									 else 0
									 end), 
		   @Percent = @WastedMB / @MemoryInUse * 100
	from sys.dm_exec_cached_plans;

	select [TotalPhysicalMemory (MB)] = @PhysicalMemory, 
		   [TotalConfiguredMemory (MB)] = @ConfiguredMemory, 
		   [MaxMemoryAvailableToSQLServer (%)] = @ConfiguredMemory / @PhysicalMemory * 100, 
		   [MemoryInUseBySQLServer (MB)] = @MemoryInUse, 
		   [TotalSingleUsePlanCache (MB)] = @WastedMB, 
		   TotalNumberOfSingleUsePlans = @SingleUsePlanCount, 
		   [PercentOfConfiguredCacheWastedForSingleUsePlans (%)] = @Percent;
end;
go

--exec sys.sp_MS_marksystemobject 'usp_CheckPlanCache';
--go

-----------------------------------------------------------------
-- Logic (in a job?) to decide whether or not to clear - using sproc...
-----------------------------------------------------------------

declare @Percent    decimal(6, 3), 
		@WastedMB   decimal(19, 3), 
		@StrMB      nvarchar(20), 
		@StrPercent nvarchar(20);

exec usp_CheckPlanCache @Percent output, @WastedMB output;

select @StrMB = CONVERT(nvarchar(20), @WastedMB), 
	   @StrPercent = CONVERT(nvarchar(20), @Percent);

if @Percent > 10
   or @WastedMB > 10
begin
	dbcc freesystemcache('SQL Plans');

	raiserror('%s MB (%s percent) was allocated to single-use plan cache. Single-use plans have been cleared.', 10, 1, @StrMB, @StrPercent);
end;
else
begin
	raiserror('Only %s MB (%s percent) is allocated to single-use plan cache - no need to clear cache now.', 10, 1, @StrMB, @StrPercent);
	-- Note: this is only a warning message and not an actual error.
end;
go