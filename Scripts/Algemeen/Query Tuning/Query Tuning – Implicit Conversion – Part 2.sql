USE AdventureWorks;
GO

SET STATISTICS TIME ON;

-------------------------------------------------------------------------------
-- With implicit conversion -> 22 sec
-------------------------------------------------------------------------------

SELECT p.FirstName,
       p.LastName,
       p.BusinessEntityID,
       cust.AccountNumber,
       cust.StoreID
FROM Sales.Customer cust
    INNER JOIN Person.Person p
        ON cust.PersonID = p.BusinessEntityID
WHERE cust.AccountNumber = N'AW00029594';
GO 200


-------------------------------------------------------------------------------
-- Without conversion -> 2 sec
-------------------------------------------------------------------------------

SELECT p.FirstName,
       p.LastName,
       p.BusinessEntityID,
       cust.AccountNumber,
       cust.StoreID
FROM Sales.Customer cust
    INNER JOIN Person.Person p
        ON cust.PersonID = p.BusinessEntityID
WHERE cust.AccountNumber = 'AW00029594';
GO 200


-------------------------------------------------------------------------------
-- Explicit Conversion -> 2 sec
-------------------------------------------------------------------------------

SELECT p.FirstName,
       p.LastName,
       p.BusinessEntityID,
       cust.AccountNumber,
       cust.StoreID
FROM Sales.Customer cust
    INNER JOIN Person.Person p
        ON cust.PersonID = p.BusinessEntityID
WHERE cust.AccountNumber = CONVERT(VARCHAR, N'AW00029594');
GO 200


