USE AdventureWorks2019;
GO

-------------------------------------------------------------------------------
-- Using BETWEEN operator
-------------------------------------------------------------------------------
SELECT   DISTINCT
         CONVERT(CHAR(10), OrderDate, 121) AS [OrderDateYYYY-MM-DD],
         COUNT(*) AS NumOfOrders
FROM     Sales.SalesOrderHeader
WHERE    OrderDate BETWEEN  '2011-06-01' AND '2011-06-30'
GROUP BY OrderDate
ORDER BY [OrderDateYYYY-MM-DD];
GO

-------------------------------------------------------------------------------
-- Searching Last Names that match pattern
-------------------------------------------------------------------------------
SELECT FirstName,
       MiddleName,
       LastName
FROM   Person.Person
WHERE  LastName LIKE '[C,H]%sen';
GO

-------------------------------------------------------------------------------
-- Using multiple queries in the IN operator
-------------------------------------------------------------------------------
SELECT Name,
       ListPrice
FROM   Production.Product
WHERE  Name IN (
    SELECT Name
    FROM   Production.Product
    WHERE  Name LIKE 'Road%Tube'
            OR Name LIKE 'Tour%Pe%'
            OR Name LIKE 'Mi%pump'
);
GO

-------------------------------------------------------------------------------
-- Using Multiple Subqueries with IN operator
-------------------------------------------------------------------------------
SELECT Name,
       ListPrice
FROM   Production.Product
WHERE  Name IN ((
    SELECT Name FROM Production.Product WHERE Name LIKE 'Road%Tube'
), (
    SELECT Name FROM Production.Product WHERE Name LIKE 'Tour%Pe%'
), (
    SELECT Name FROM Production.Product WHERE Name LIKE 'Mi%pump'
));
GO

-------------------------------------------------------------------------------
-- Searching for Nulls
-------------------------------------------------------------------------------
SELECT Name,
       Color
FROM   Production.Product
WHERE  Color IN ( 'White', 'Grey', NULL );
GO

-------------------------------------------------------------------------------
-- Finding NULL Colors
-------------------------------------------------------------------------------
SELECT Name,
       Color
FROM   Production.Product
WHERE  COALESCE(Color, '') IN ( 'White', 'Grey', '' );
GO

-------------------------------------------------------------------------------
-- Code to show case-sensitivity issue
-------------------------------------------------------------------------------
DECLARE @Colors TABLE
(
    Color VARCHAR(15)
);
INSERT INTO @Colors
VALUES ('White'),
       ('white'),
       ('Grey'),
       ('grey');
SELECT Color
FROM   @Colors
WHERE  Color IN ( 'white', 'grey' );
GO

-------------------------------------------------------------------------------
-- Dealing with Case-Sensitive values
-------------------------------------------------------------------------------
DECLARE @Colors TABLE
(
    Color VARCHAR(15)
);
INSERT INTO @Colors
VALUES ('White'),
       ('white'),
       ('Grey'),
       ('grey');
SELECT Color
FROM   @Colors
WHERE  Color COLLATE Latin1_General_CS_AS IN ( 'white', 'grey' );
GO
