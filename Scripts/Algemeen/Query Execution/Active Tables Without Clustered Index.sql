/**************************************
Active Tables Without Clustered Index	 
**************************************/

set nocount on;

declare @MinTableRowsThreshold int;
set @MinTableRowsThreshold = 5000;

with [TablesWithoutClusteredIndexes] --( [db_name], [table_name], [table_schema], [row_count] )
	 as (select DB_NAME() as db_name, 
				t.name as table_name, 
				SCHEMA_NAME(t.schema_id) as table_schema, 
				SUM(ps.row_count) as row_count, 
				SUM(us.user_seeks) as user_seeks, 
				SUM(us.user_scans) as user_scans, 
				SUM(us.user_lookups) as user_lookups, 
				SUM(us.user_updates) as user_updates
		 from sys.tables as t
			  inner join sys.dm_db_partition_stats as ps on ps.object_id = t.object_id
			  inner join sys.dm_db_index_usage_stats as us on ps.object_id = us.object_id
		 where OBJECTPROPERTY(t.object_id, N'TableHasClustIndex') = 0
			   and ps.index_id < 2
			   and COALESCE(us.user_seeks, us.user_scans, us.user_lookups, us.user_updates) is not null
		 group by t.name, 
				  t.schema_id)
	 select *
	 from TablesWithoutClusteredIndexes
	 where row_count > 5000;