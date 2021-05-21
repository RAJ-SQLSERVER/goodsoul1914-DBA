USE AdventureWorks;
GO

SET STATISTICS IO, TIME ON;
GO

-- Bad
SELECT *
FROM Person.Person;

-- Good
SELECT FirstName,
       LastName
FROM Person.Person;


-- Real-world example

SELECT x.*
INTO #x
FROM dbo.bigProduct AS p
    CROSS APPLY
(
    SELECT TOP (1000)
           *
    FROM dbo.bigTransactionHistory AS bth
    WHERE bth.ProductId = p.ProductId
    ORDER BY TransactionDate DESC
) AS x
WHERE p.ProductId
BETWEEN 1000 AND 7500;
GO
-- 4420 ms


ALTER TABLE dbo.bigTransactionHistory ADD CustomerId INT NULL;
GO

DROP TABLE #x;
GO

SELECT x.*
INTO #x
FROM dbo.bigProduct AS p
    CROSS APPLY
(
    SELECT TOP (1000)
           *
    FROM dbo.bigTransactionHistory AS bth
    WHERE bth.ProductId = p.ProductId
    ORDER BY TransactionDate DESC
) AS x
WHERE p.ProductId
BETWEEN 1000 AND 7500;
GO
-- 19666 ms

-- 1 small schema change causes a lot of trouble !!!

-- But you should not have used SELECT x.* in the first place
-- If you would have named each column, CustomerId would not have been there in the first place!

DROP TABLE #x;
GO

DBCC FREEPROCCACHE;
GO
DBCC DROPCLEANBUFFERS;
GO

ALTER TABLE dbo.bigTransactionHistory DROP COLUMN CustomerID;
GO
