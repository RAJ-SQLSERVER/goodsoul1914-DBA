/**************************************
 Get Column Names From a Specific Table
**************************************/



-- Method 1 - INFORMATION_SCHEMA.COLUMNS
select *
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = N'Address';
go



-- Method 2 - Using Sys Schema
select OBJECT_SCHEMA_NAME(c.object_id) as SchemaName, 
	   o.Name as Table_Name, 
	   c.Name as Field_Name, 
	   t.Name as Data_Type, 
	   t.max_length as Length_Size, 
	   t.precision as Precision
from sys.columns as c
inner join sys.objects as o on o.object_id = c.object_id
left join sys.types as t on t.user_type_id = c.user_type_id
where o.type = 'U' 
-- and o.Name = 'YourTableName'
order by o.Name, 
		 c.Name;
go



-- Method 3 - ALT + F1
Person.Address;




-- Method 4 - sp_columns
exec sp_columns 'Address';
go