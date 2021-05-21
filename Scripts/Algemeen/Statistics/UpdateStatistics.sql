/****************************************************************************
Author: David Fowler
Revision date: 04/09/2019
Version: 1.4

www.sqlundercover.com 
****************************************************************************/

create proc UpdateStatistics
(
	@Threshold int = 5000) -- number of row changes before stats update      
as
begin

	if OBJECT_ID('tempdb.dbo.##StatsUpdate') is not null
		drop table ##StatsUpdate;

	create table ##StatsUpdate
	(
		UpdateCmd varchar(8000));

	declare @DBName sysname;
	declare @SQL varchar(max);
	declare @UpdateCmd varchar(8000);

	-- get databases that are primary on the current node into cursor  
	declare DatabasesCur cursor static forward_only
	for select databases.name as DBName
		from sys.databases
		where database_id > 4
			  and state = 0;

	open DatabasesCur;

	fetch next from DatabasesCur into @DBName;

	while @@FETCH_STATUS = 0
	begin

		set @SQL = 'USE ' + QUOTENAME(@DBName) + ';  
 INSERT INTO ##StatsUpdate  
 SELECT  ''USE '' + QUOTENAME(DB_NAME()) + ''; UPDATE STATISTICS '' + QUOTENAME(SCHEMA_NAME(tables.schema_id)) + ''.'' + QUOTENAME(objects.name) + '' '' + QUOTENAME(stats.name) + '';''  
 FROM sys.stats stats  
 CROSS APPLY sys.dm_db_stats_properties(stats.object_id, stats.stats_id) properties  
 JOIN sys.tables tables ON stats.object_id = tables.object_id  
 JOIN sys.objects objects ON objects.object_id = stats.object_id  
 WHERE properties.modification_counter >= ' + CAST(@Threshold as varchar(10)) + '  
 AND objects.type = ''U''';

		exec (@SQL);

		fetch next from DatabasesCur into @DBName;
	end;

	close DatabasesCur;
	deallocate DatabasesCur;

	-- cursor through and run all stats updates  

	raiserror('Starting Stats Update', 0, 1) with nowait;

	declare UpdateStatsCmds cursor static forward_only
	for select distinct 
			   UpdateCmd
		from ##StatsUpdate;

	open UpdateStatsCmds;

	fetch next from UpdateStatsCmds into @UpdateCmd;

	while @@FETCH_STATUS = 0
	begin
		raiserror(@UpdateCmd, 0, 1) with nowait;
		exec (@UpdateCmd);
		fetch next from UpdateStatsCmds into @UpdateCmd;
	end;

	close UpdateStatsCmds;
	deallocate UpdateStatsCmds;
end;