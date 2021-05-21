-- Returns the schema information for all the objects
---------------------------------------------------------------------------------------------------

select xoe.name as colName, 
	   xoe.description as colDesc, 
	   xoe.object_name as objName, 
	   xoe.type_name as objType, 
	   xoe.column_type as colType, 
	   xoe.column_value as colValue
from sys.dm_xe_object_columns as xoe
where xoe.object_name like 'sql_statement_completed';
go