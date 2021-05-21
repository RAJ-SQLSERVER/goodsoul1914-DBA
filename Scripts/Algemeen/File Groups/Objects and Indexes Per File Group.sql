
-- List all Objects and Indexes per Filegroup / Partition and Allocation Type 
-- including the allocated data size 
---------------------------------------------------------------------------------------------------
select DS.name as DataSpaceName, 
	   AU.type_desc as AllocationDesc, 
	   AU.total_pages / 128 as TotalSizeMB, 
	   AU.used_pages / 128 as UsedSizeMB, 
	   AU.data_pages / 128 as DataSizeMB, 
	   SCH.name as SchemaName, 
	   OBJ.type_desc as ObjectType, 
	   OBJ.name as ObjectName, 
	   IDX.type_desc as IndexType, 
	   IDX.name as IndexName
from sys.data_spaces as DS
	 inner join sys.allocation_units as AU on DS.data_space_id = AU.data_space_id
	 inner join sys.partitions as PA on AU.type in(1, 3)
										and AU.container_id = PA.hobt_id
										or AU.type = 2
										   and AU.container_id = PA.partition_id
	 inner join sys.objects as OBJ on PA.object_id = OBJ.object_id
	 inner join sys.schemas as SCH on OBJ.schema_id = SCH.schema_id
	 left join sys.indexes as IDX on PA.object_id = IDX.object_id
									 and PA.index_id = IDX.index_id
order by DS.name, 
		 SCH.name, 
		 OBJ.name, 
		 IDX.name;