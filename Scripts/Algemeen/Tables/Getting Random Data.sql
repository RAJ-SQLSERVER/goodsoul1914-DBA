-------------------------------------------------------------------------------
-- Retrieving random data from a table
-------------------------------------------------------------------------------

USE AdventureWorks
GO

SELECT TOP (10)
       ProductID,
       Name
FROM Production.Product
ORDER BY NEWID();