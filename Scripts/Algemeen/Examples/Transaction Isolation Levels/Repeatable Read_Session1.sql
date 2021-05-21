-- ================================
-- Repeatable Read Isolation Level
-- ================================
-- =========
-- SESSION 1
-- =========
USE AdventureWorks2017;
GO

BEGIN TRANSACTION;

UPDATE Person.Person
SET Title = 'Mr'
WHERE BusinessEntityID = 1;

-- Execute the query from session 2
ROLLBACK TRANSACTION;
