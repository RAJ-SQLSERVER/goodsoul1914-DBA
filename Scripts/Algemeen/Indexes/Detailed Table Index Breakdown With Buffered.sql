-- Detailed Table Index Breakdown With Buffered
-- http://jongurgul.com/blog/detailed-table-index-breakdown-buffered/
-------------------------------------------------------------------------------

select DB_NAME() as DatabaseName, 
	   ao.object_id as ObjectID, 
	   SCHEMA_NAME(ao.schema_id) as SchemaName, 
	   ao.name as ObjectName, 
	   ao.is_ms_shipped as IsSystemObject, 
	   i.index_id as IndexID, 
	   i.name as IndexName, 
	   i.type_desc as IndexType, 
	   au.type_desc as AllocationUnitType, 
	   p.partition_number as PartitionNumber, 
	   ds.type as IsPartition, 
	   p.data_compression_desc as Compression, 
	   ds.name as PartitionName, 
	   fg.name as FileGroupName, 
	   p.rows as NumberOfRows,
	   case
		   when pf.boundary_value_on_right = 1
				and ds.type = 'PS' then 'RIGHT'
		   when pf.boundary_value_on_right is null
				and ds.type = 'PS' then 'LEFT'
				 else null
	   end as Range, 
	   prv.[value] as LowerBoundaryValue, 
	   prv2.[value] as UpperBoundaryValue, 
	   CONVERT(decimal(15, 3),
							case
								when au.type_desc = 'IN_ROW_DATA'
									 and p.rows > 0 then p.rows / NULLIF(au.data_pages, 0)
							else 0
							end) as RowsPerPage,
	   case
		   when au.type_desc = 'IN_ROW_DATA'
				and i.type_desc = 'CLUSTERED' then au.used_pages * 0.20
									else null
	   end as TippingPointLower_Rows,
	   case
		   when au.type_desc = 'IN_ROW_DATA'
				and i.type_desc = 'CLUSTERED' then au.used_pages * 0.30
			  else null
	   end as TippingPointUpper_Rows, 
	   au.used_pages as UsedPages, 
	   CONVERT(decimal(15, 3),
							case
								when au.type <> 1 then au.used_pages
								when p.index_id < 2 then au.data_pages
							else 0
							end * 0.0078125) as DataUsedSpace_MiB, 
	   CONVERT(decimal(15, 3), ( au.used_pages - case
													 when au.type <> 1 then au.used_pages
													 when p.index_id < 2 then au.data_pages
												 else 0
												 end ) * 0.0078125) as IndexUsedSpace_MiB, 
	   au.data_pages as DataPages, --maybe better called leaf pages? page level 0 could be data pages or in nc index pages. it counts In-row data,LOB data and Row-overflow data.
	   b.DataPagesBuffered, 
	   CONVERT(decimal(15, 3), b.DataPagesBuffered * 0.0078125) as DataBuffered_MiB, 
	   b.IndexPagesBuffered, 
	   CONVERT(decimal(15, 3), b.IndexPagesBuffered * 0.0078125) as IndexBuffered_MiB, 
	   b.PagesBuffered
from sys.partition_functions as pf
	 inner join sys.partition_schemes as ps on pf.function_id = ps.function_id
	 right outer join sys.partitions as p
	 inner join sys.indexes as i on p.object_id = i.object_id
									and p.index_id = i.index_id
	 inner join sys.allocation_units as au on au.container_id = p.partition_id
	 inner join sys.filegroups as fg on au.data_space_id = fg.data_space_id
	 inner join sys.data_spaces as ds on i.data_space_id = ds.data_space_id
	 inner join sys.all_objects as ao on i.object_id = ao.object_id on ps.data_space_id = ds.data_space_id
	 left outer join sys.partition_range_values as prv on ps.function_id = prv.function_id
														  and p.partition_number - 1 = prv.boundary_id
	 left outer join sys.partition_range_values as prv2 on ps.function_id = prv2.function_id
														   and prv2.boundary_id = p.partition_number
	 inner join
(
	select allocation_unit_id, 
		   SUM(case
				   when page_type = 'INDEX_PAGE' then 1
			   else 0
			   end) as IndexPagesBuffered, 
		   SUM(case
				   when page_type = 'DATA_PAGE' then 1
			   else 0
			   end) as DataPagesBuffered, 
		   COUNT_BIG(*) as PagesBuffered
	from sys.dm_os_buffer_descriptors
	where database_id = DB_ID()
	group by allocation_unit_id
) as b on au.allocation_unit_id = b.allocation_unit_id
where ao.is_ms_shipped = 0
	  and au.type_desc = 'IN_ROW_DATA'
--AND SCHEMA_NAME(ao.[schema_id]) ='dbo'
--AND ao.[name] LIKE '%%'
order by SCHEMA_NAME(ao.schema_id), 
		 ao.name;
go