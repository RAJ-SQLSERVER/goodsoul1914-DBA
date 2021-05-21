-- =========
-- SESSION 2
-- =========
USE AdventureWorks2017;
GO

-- We do not have to specify the READ COMMITTED isolation level, 
-- because it is the default
SELECT *
FROM Person.Person
WHERE BusinessEntityID = 1;
GO

-- Shared Locks are only acquired during the resource reading when working
-- with the READ COMMITTED isolation level
BEGIN TRANSACTION;

WAITFOR DELAY '00:00:15.000';
