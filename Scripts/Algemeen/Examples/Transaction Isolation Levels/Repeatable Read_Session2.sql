-- =========
-- SESSION 2
-- =========
USE AdventureWorks2017;
GO

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
GO

-- Shared locks are acquired as soon as we first access a resource
BEGIN TRANSACTION;

SELECT *
FROM Person.Person
WHERE ModifiedDate = '20140503';

COMMIT TRANSACTION;
