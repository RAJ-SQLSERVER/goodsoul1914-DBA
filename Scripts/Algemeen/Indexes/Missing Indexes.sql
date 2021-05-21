-- Missing indexes for current database by Index Advantage
--
-- Look at index advantage, last user seek time, number of user seeks to help 
--     determine source and importance
-- SQL Server is overly eager to add included columns, so beware
-- Do not just blindly add indexes that show up from this query!!!
-------------------------------------------------------------------------------
select distinct 
	   CONVERT(decimal(18, 2), user_seeks * avg_total_user_cost * avg_user_impact * 0.01) as index_advantage, 
	   migs.last_user_seek, 
	   mid.[statement] as [Database.Schema.Table], 
	   mid.equality_columns, 
	   mid.inequality_columns, 
	   mid.included_columns, 
	   migs.unique_compiles, 
	   migs.user_seeks, 
	   migs.avg_total_user_cost, 
	   migs.avg_user_impact, 
	   OBJECT_NAME(mid.object_id) as [Table Name], 
	   p.rows as [Table Rows]
from sys.dm_db_missing_index_group_stats as migs with(nolock)
	 inner join sys.dm_db_missing_index_groups as mig with(nolock) on migs.group_handle = mig.index_group_handle
	 inner join sys.dm_db_missing_index_details as mid with(nolock) on mig.index_handle = mid.index_handle
	 inner join sys.partitions as p with(nolock) on p.object_id = mid.object_id
where mid.database_id = DB_ID()
	  and p.index_id < 2
order by index_advantage desc option(recompile);
go


-- Missing indexes
------------------------------------------------------------------------------
select DB_NAME(mid.database_id) as DatabaseName, 
	   OBJECT_SCHEMA_NAME(mid.object_id, mid.database_id) as SchemaName, 
	   OBJECT_NAME(mid.object_id, mid.database_id) as ObjectName, 
	   migs.avg_user_impact, 
	   mid.equality_columns, 
	   mid.inequality_columns, 
	   mid.included_columns
from sys.dm_db_missing_index_groups as mig
	 inner join sys.dm_db_missing_index_group_stats as migs on migs.group_handle = mig.index_group_handle
	 inner join sys.dm_db_missing_index_details as mid on mig.index_handle = mid.index_handle;


-- Missing indexes
------------------------------------------------------------------------------
select dm_mid.database_id as DatabaseID, 
	   dm_migs.avg_user_impact * ( dm_migs.user_seeks + dm_migs.user_scans ) as Avg_Estimated_Impact, 
	   dm_migs.last_user_seek as Last_User_Seek, 
	   OBJECT_NAME(dm_mid.object_id, dm_mid.database_id) as TableName, 
	   'CREATE INDEX [IX_' + OBJECT_NAME(dm_mid.object_id, dm_mid.database_id) + '_' + REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.equality_columns, ''), ', ', '_'), '[', ''), ']', '') + case
																																														 when dm_mid.equality_columns is not null
-- Missing index info
------------------------------------------------------------------------------																																															  and dm_mid.inequality_columns is not null then '_'
SELECT mig.index_group_handle,
       mig.index_handle,
       mid.statement AS table_name,
       col.column_id,
       col.column_name,
       col.column_usage
FROM sys.dm_db_missing_index_details AS mid
    CROSS APPLY sys.dm_db_missing_index_columns(mid.index_handle) col
    INNER JOIN sys.dm_db_missing_index_groups AS mig
        ON mig.index_handle = mid.index_handle
ORDER BY mig.index_group_handle,
         mig.index_handle,
         col.column_id;																																													 else ''
																																													 end + REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.inequality_columns, ''), ', ', '_'), '[', ''), ']', '') + ']' + ' ON ' + dm_mid.statement + ' (' + ISNULL(dm_mid.equality_columns, '') + case
																																																																																											  when dm_mid.equality_columns is not null
																																																																																												   and dm_mid.inequality_columns is not null then ','
																																																																																									  else ''
																																																																																										  end + ISNULL(dm_mid.inequality_columns, '') + ')' + ISNULL(' INCLUDE (' + dm_mid.included_columns + ')', '') as Create_Statement
from sys.dm_db_missing_index_groups as dm_mig
	 inner join sys.dm_db_missing_index_group_stats as dm_migs on dm_migs.group_handle = dm_mig.index_group_handle
	 inner join sys.dm_db_missing_index_details as dm_mid on dm_mig.index_handle = dm_mid.index_handle
where dm_mid.database_ID = DB_ID()
order by Avg_Estimated_Impact desc;
go


-- Missing Indexes
-- ----------------------------------------------------------------------------
select TableName = d.statement, 
	   d.equality_columns, 
	   d.inequality_columns, 
	   d.included_columns, 
	   s.user_scans, 
	   s.user_seeks, 
	   s.avg_total_user_cost, 
	   s.avg_user_impact, 
	   AverageCostSavings = ROUND(s.avg_total_user_cost * s.avg_user_impact / 100.0, 3), 
	   TotalCostSavings = ROUND(s.avg_total_user_cost * s.avg_user_impact / 100.0 * ( s.user_seeks + s.user_scans ), 3)
from sys.dm_db_missing_index_groups as g
	 inner join sys.dm_db_missing_index_group_stats as s on s.group_handle = g.index_group_handle
	 inner join sys.dm_db_missing_index_details as d on d.index_handle = g.index_handle
where d.database_id = DB_ID()
order by TableName, 
		 TotalCostSavings desc;


-- Missing indexes
------------------------------------------------------------------------------
select distinct 
	   CONVERT(decimal(18, 2), user_seeks * avg_total_user_cost * avg_user_impact * 0.01) as index_advantage, 
	   migs.last_user_seek, 
	   mid.[statement] as [Database.Schema.Table], 
	   mid.equality_columns, 
	   mid.inequality_columns, 
	   mid.included_columns, 
	   migs.unique_compiles, 
	   migs.user_seeks, 
	   migs.avg_total_user_cost, 
	   migs.avg_user_impact, 
	   OBJECT_NAME(mid.object_id) as [Table Name], 
	   p.rows as [Table Rows]
from sys.dm_db_missing_index_group_stats as migs with(nolock)
	 inner join sys.dm_db_missing_index_groups as mig with(nolock) on migs.group_handle = mig.index_group_handle
	 inner join sys.dm_db_missing_index_details as mid with(nolock) on mig.index_handle = mid.index_handle
	 inner join sys.partitions as p with(nolock) on p.object_id = mid.object_id
where mid.database_id = DB_ID()
	  and p.index_id < 2
order by index_advantage desc option(recompile);
go


-- 
-------------------------------------------------------------------------------
select d.[statement] as table_name, 
	   d.equality_columns, 
	   d.inequality_columns, 
	   d.included_columns, 
	   s.avg_total_user_cost as avg_est_plan_cost, 
	   s.avg_user_impact as avg_est_cost_reduction, 
	   s.user_scans + s.user_seeks as times_requested
from sys.dm_db_missing_index_groups as g
join sys.dm_db_missing_index_group_stats as s on g.index_group_handle = s.group_handle
join sys.dm_db_missing_index_details as d on g.index_handle = d.index_handle
join sys.databases as db on d.database_id = db.database_id
where db.database_id = DB_ID();
go


-- Missing indexes for all databases
-- ----------------------------------------------------------------------------
select CONVERT(decimal(18, 2), user_seeks * avg_total_user_cost * avg_user_impact * 0.01) as index_advantage, 
	   FORMAT(migs.last_user_seek, 'yyyy-MM-dd HH:mm:ss') as last_user_seek, 
	   mid.[statement] as [Database.Schema.Table], 
	   COUNT(1) over(partition by mid.[statement]) as missing_indexes_for_table, 
	   COUNT(1) over(partition by mid.[statement], 
								  equality_columns) as similar_missing_indexes_for_table, 
	   mid.equality_columns, 
	   mid.inequality_columns, 
	   mid.included_columns, 
	   migs.unique_compiles, 
	   migs.user_seeks, 
	   CONVERT(decimal(18, 2), migs.avg_total_user_cost) as avg_total_user_cost, 
	   migs.avg_user_impact
from sys.dm_db_missing_index_group_stats as migs with(nolock)
	 inner join sys.dm_db_missing_index_groups as mig with(nolock) on migs.group_handle = mig.index_group_handle
	 inner join sys.dm_db_missing_index_details as mid with(nolock) on mig.index_handle = mid.index_handle
order by index_advantage desc option(recompile);
go

-- Missing index warnings for cached plans in the current database
--
-- Note: This query could take some time on a busy instance
-- Helps you connect missing indexes to specific stored procedures or queries
-- This can help you decide whether to add them or not
--
-------------------------------------------------------------------------------
select top (50) OBJECT_NAME(objectid) as ObjectName, 
				cp.objtype, 
				cp.usecounts, 
				cp.size_in_bytes, 
				query_plan
from sys.dm_exec_cached_plans as cp with(nolock)
	 cross apply sys.dm_exec_query_plan(cp.plan_handle) as qp
where CAST(query_plan as nvarchar(max)) like N'%MissingIndex%'
	  and dbid = DB_ID()
order by cp.usecounts desc option(recompile);
go


-- Finding Missing Indexes inside the Plan Cache
-------------------------------------------------------------------------------
with xmlnamespaces(default 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
	 select query_plan, 
			n.value('(@StatementText)[1]', 'VARCHAR(4000)') as sql_text, 
			n.value('(//MissingIndexGroup/@Impact)[1]', 'FLOAT') as impact, 
			DB_ID(REPLACE(REPLACE(n.value('(//MissingIndex/@Database)[1]', 'VARCHAR(128)'), '[', ''), ']', '')) as database_id, 
			OBJECT_ID(n.value('(//MissingIndex/@Database)[1]', 'VARCHAR(128)') + '.' + n.value('(//MissingIndex/@Schema)[1]', 'VARCHAR(128)') + '.' + n.value('(//MissingIndex/@Table)[1]', 'VARCHAR(128)')) as OBJECT_ID, 
			n.value('(//MissingIndex/@Database)[1]', 'VARCHAR(128)') + '.' + n.value('(//MissingIndex/@Schema)[1]', 'VARCHAR(128)') + '.' + n.value('(//MissingIndex/@Table)[1]', 'VARCHAR(128)') as statement, 
			(select distinct 
					c.value('(@Name)[1]', 'VARCHAR(128)') + ', '
			 from n.nodes('//ColumnGroup') as t(cg)
				  cross apply cg.nodes('Column') as r(c)
			 where cg.value('(@Usage)[1]', 'VARCHAR(128)') = 'EQUALITY' for xml path('')) as equality_columns, 
			(select distinct 
					c.value('(@Name)[1]', 'VARCHAR(128)') + ', '
			 from n.nodes('//ColumnGroup') as t(cg)
				  cross apply cg.nodes('Column') as r(c)
			 where cg.value('(@Usage)[1]', 'VARCHAR(128)') = 'INEQUALITY' for xml path('')) as inequality_columns, 
			(select distinct 
					c.value('(@Name)[1]', 'VARCHAR(128)') + ', '
			 from n.nodes('//ColumnGroup') as t(cg)
				  cross apply cg.nodes('Column') as r(c)
			 where cg.value('(@Usage)[1]', 'VARCHAR(128)') = 'INCLUDE' for xml path('')) as include_columns
			into #MissingIndexInfo
	 from (select query_plan
		   from (select distinct 
						plan_handle
				 from sys.dm_exec_query_stats with(nolock)) as qs
				outer apply sys.dm_exec_query_plan(qs.plan_handle) as tp
		   where tp.query_plan.exist('//MissingIndex') = 1) as tab(query_plan)
		  cross apply query_plan.nodes('//StmtSimple') as q(n)
	 where n.exist('QueryPlan/MissingIndexes') = 1;
 
-- Trim trailing comma from lists
update #MissingIndexInfo
set equality_columns = LEFT(equality_columns, LEN(equality_columns) - 1), inequality_columns = LEFT(inequality_columns, LEN(inequality_columns) - 1), include_columns = LEFT(include_columns, LEN(include_columns) - 1);
 
select *
from #MissingIndexInfo;

drop table #MissingIndexInfo;


-- Missing Index Script
-- Original Author: David Waller 
-- Date: 4/2020
select db.name as DatabaseName, 
	   OBJECT_NAME(id.object_id, db.database_id) as ObjectName, 
	   id.[statement] as FullyQualifiedObjectName, 
	   id.equality_columns as EqualityColumns, 
	   id.inequality_columns as InEqualityColumns, 
	   id.included_columns as IncludedColumns, 
	   gs.unique_compiles as UniqueCompiles, 
	   gs.user_seeks as UserSeeks, 
	   gs.user_scans as UserScans, 
	   gs.last_user_seek as LastUserSeekTime, 
	   gs.last_user_scan as LastUserScanTime, 
	   gs.avg_total_user_cost as AvgTotalUserCost, -- Average cost of the user queries that could be reduced by the index in the group. 
	   gs.avg_user_impact as AvgUserImpact, -- The value means that the query cost would on average drop by this percentage if this missing index group was implemented. 
	   gs.user_seeks * gs.avg_total_user_cost * gs.avg_user_impact * 0.01 as IndexAdvantage, 
	   'CREATE INDEX [IX_' + OBJECT_NAME(id.object_id, db.database_id) + '_' + REPLACE(REPLACE(REPLACE(ISNULL(id.equality_columns, ''), ', ', '_'), '[', ''), ']', '') + case
																																											 when id.equality_columns is not null
																																												  and id.inequality_columns is not null then '_'
																																										 else ''
																																										 end + REPLACE(REPLACE(REPLACE(ISNULL(id.inequality_columns, ''), ', ', '_'), '[', ''), ']', '') + '_' + LEFT(CAST(NEWID() as nvarchar(64)), 5) + ']' + ' ON ' + id.[statement] + ' (' + ISNULL(id.equality_columns, '') + case
																																																																																																	   when id.equality_columns is not null
																																																																																																			and id.inequality_columns is not null then ','
																																																																																																   else ''
																																																																																																   end + ISNULL(id.inequality_columns, '') + ')' + ISNULL(' INCLUDE (' + id.included_columns + ')', '') as ProposedIndex, 
	   CAST(CURRENT_TIMESTAMP as smalldatetime) as CollectionDate
from sys.dm_db_missing_index_group_stats as gs with(nolock)
	 inner join sys.dm_db_missing_index_groups as ig with(nolock) on gs.group_handle = ig.index_group_handle
	 inner join sys.dm_db_missing_index_details as id with(nolock) on ig.index_handle = id.index_handle
	 inner join sys.databases as db with(nolock) on db.database_id = id.database_id
where db.database_id = DB_ID()
order by ObjectName, 
		 IndexAdvantage desc option(recompile);
go
