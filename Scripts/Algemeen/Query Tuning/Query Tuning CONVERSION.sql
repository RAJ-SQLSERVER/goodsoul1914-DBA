USE AdventureWorks;
GO

SET STATISTICS IO, TIME ON;
GO

-- varchar tot nvarchar
SELECT p.FirstName,
       p.LastName,
       c.AccountNumber
FROM Sales.Customer AS c
    INNER JOIN Person.Person AS p
        ON c.PersonID = p.BusinessEntityID
WHERE c.AccountNumber = N'AW00029594';
GO 50 -- CPU time = 485 ms,  elapsed time = 542 ms

-- remedy
SELECT p.FirstName,
       p.LastName,
       c.AccountNumber
FROM Sales.Customer AS c
    INNER JOIN Person.Person AS p
        ON c.PersonID = p.BusinessEntityID
WHERE c.AccountNumber = 'AW00029594';
GO 50 -- CPU time = 0 ms,  elapsed time = 0 ms

