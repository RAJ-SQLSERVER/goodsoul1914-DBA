
-------------------------------------------------------------------------------
-- The statement (that caused the error)
-------------------------------------------------------------------------------
USE [StackOverflow2013];
GO
DROP USER [Dom\SomeUser];
GO

/* --------------------------------------------------
 – The Error ...

	Drop failed for user 'Dom\SomeUser'
	The database principal owns a schema in the database
	and cannot be dropped. Error: 15138
-------------------------------------------------- */


-------------------------------------------------------------------------------
-- 1. find the name of the schema
-------------------------------------------------------------------------------
SELECT [name]
FROM sys.schemas s
WHERE s.principal_id = USER_ID('Dom\SomeUser');


-------------------------------------------------------------------------------
-- 2. transfer ownership of the schema to 'dbo'
-------------------------------------------------------------------------------
ALTER AUTHORIZATION ON SCHEMA::[SomeSchemaName] TO dbo;

-- repeat "The Statement"