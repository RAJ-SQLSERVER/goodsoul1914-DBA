-- ================================
-- Read Committed Isolation Level
-- ================================
/*****************************************
	READERS:	SHARED LOCK:	S
	WRITERS:	EXCLUSIVE LOCK: X

	ISOLATION LEVEL (Default isolation level)
*****************************************/
-- =========
-- SESSION 1
-- =========
USE AdventureWorks2017;
GO

BEGIN TRANSACTION;

UPDATE Person.Person
SET Title = 'Mr'
WHERE BusinessEntityID = 1;

SELECT *
FROM Person.Person
WHERE BusinessEntityID = 1;

-- Execute the query from session 2
ROLLBACK TRANSACTION;
