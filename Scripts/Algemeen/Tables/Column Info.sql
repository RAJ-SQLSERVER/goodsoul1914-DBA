-- Deleting columns does not reduce the width of a record (including new ones). 
-- Tables have to be rebuilt in order to reclaim space
---------------------------------------------------------------------------------------------------
select c.column_id, 
	   c.Name, 
	   ipc.leaf_offset as [Offset in Row], 
	   ipc.max_inrow_length as [Max Length], 
	   ipc.system_type_id as [Column Type]
from sys.system_internals_partition_columns as ipc
	 join sys.partitions as p on ipc.partition_id = p.partition_id
	 join sys.columns as c on c.column_id = ipc.partition_column_id
							  and c.object_id = p.object_id
where p.object_id = OBJECT_ID(N'dbo.AlterDemo')
order by c.column_id;
go