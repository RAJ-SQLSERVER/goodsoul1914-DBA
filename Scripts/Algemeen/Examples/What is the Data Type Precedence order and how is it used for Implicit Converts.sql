/*
 SQL Server uses the following precedence order for data types:

	1.  user-defined data types (highest)
	2.  sql_variant
	3.  xml
	4.  datetimeoffset
	5.  datetime2
	6.  datetime
	7.  smalldatetime
	8.  date
	9.  time
	10. float
	11. real
	12. decimal
	13. money
	14. smallmoney
	15. bigint
	16. int
	17. smallint
	18. tinyint
	19. bit
	20. ntext
	21. text
	22. image
	23. timestamp
	24. uniqueidentifier
	25. nvarchar (including nvarchar(max))
	26. nchar
	27. varchar (including varchar(max))
	28. char
	29. varbinary (including varbinary(max))
	30. binary (lowest)
 */

USE AdventureWorks
GO

/*
	A way to get the data types for a particular table is 
	to run one of the following queries.
*/
SELECT TABLE_CATALOG,
       TABLE_SCHEMA,
       TABLE_NAME,
       ORDINAL_POSITION,
       DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'salesorderheader';
GO

SELECT name,
       TYPE_NAME(user_type_id) AS DataType,
       max_length,
       precision,
       scale,
       is_nullable
FROM sys.columns
WHERE object_id = OBJECT_ID('production.product');
GO


/*
	You will also see data types used with declaring variables 
	and stored procedure parameters
*/
DECLARE @SorderID VARCHAR(20);
SET @SorderID = '43659';

SELECT *
FROM [Sales].[SalesOrderHeader]
WHERE [SalesOrderID] = @SorderID;
GO


/*
	How Do I know an Auto Type Conversion took place? 

	When looking at an Execution plan you will see a warning sign 
	on the operator if there is an issue. You can see this below 
	on the operator to the far left, it is a yellow triangle.  
	This can be a warning for a few things, implicit convert is 
	just one of them.

	Another approach you can use to find out if an implicit convert 
	happened is to use the sql_variant_property function
*/
DECLARE @one TINYINT;
DECLARE @two VARCHAR(20);

SET @one = 1;
SET @two = '2';

SELECT SQL_VARIANT_PROPERTY(@one + @two, 'basetype') AS 'ResultOfExpression',
       SQL_VARIANT_PROPERTY(@one, 'basetype') AS 'DataTypeOf @one',
       SQL_VARIANT_PROPERTY(@two, 'basetype') AS 'DataTypeOf @two';
GO

-- Because the data types are different, SQL Server will automatically 
-- convert the result to the variable data types that are higher up 
-- the precedent level. 


/*
	One additional tool you can use to capture implicit converts 
	is Extended Events.
*/
