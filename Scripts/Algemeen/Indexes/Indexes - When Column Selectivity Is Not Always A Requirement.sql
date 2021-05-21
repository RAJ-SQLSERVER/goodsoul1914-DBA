--� 2020 | ByrdNest Consulting

/************************************************************

    This script is used to show that there are times where the
	first column of an index does not have to be selective

	Created By Mike Byrd; Aug 19,2020

	The script uses data from the AdventureWorks2017 database;
	lines 15-94 are used to set up a dbo.Customer table.

	Lines 95 on are to show performance effects of a typical query
	with and without covering indexes and different definitions
	of the covering index.

**************************************************************/

USE tempdb;
GO

IF OBJECT_ID(N'Customer') IS NOT NULL
    DROP TABLE dbo.Customer;
GO

CREATE TABLE dbo.Customer
(
    CustomerID INT NOT NULL IDENTITY,
    FirstName VARCHAR(50) NOT NULL,
    MiddleName VARCHAR(50),
    LastName VARCHAR(50) NOT NULL,
    [Address] VARCHAR(60) NOT NULL,
    City VARCHAR(30) NOT NULL,
    [State] VARCHAR(25) NOT NULL,
    ZipCode VARCHAR(15) NOT NULL,
    Phone VARCHAR(20) NOT NULL,
    Gender CHAR(1),
    DateAdded DATE,
    DateLastModified DATE,
    AddedBy INT NOT NULL,
    UpdatedBy INT NOT NULL,
    DelFlag CHAR(1),
    CONSTRAINT PK_Customer
        PRIMARY KEY CLUSTERED (CustomerID ASC)
        WITH (DATA_COMPRESSION = ROW)
);

ALTER TABLE dbo.Customer WITH CHECK
ADD CONSTRAINT CK_Customer_DelFlag CHECK (DelFlag = 'N'
                                          OR DelFlag = 'Y'
                                         );
ALTER TABLE dbo.Customer CHECK CONSTRAINT CK_Customer_DelFlag;

ALTER TABLE dbo.Customer WITH CHECK
ADD CONSTRAINT CK_Customer_Gender CHECK (Gender = 'F'
                                         OR Gender = 'M'
                                        );
ALTER TABLE dbo.Customer CHECK CONSTRAINT CK_Customer_Gender;
GO

INSERT dbo.Customer
(
    FirstName,
    MiddleName,
    LastName,
    [Address],
    City,
    [State],
    ZipCode,
    Phone,
    Gender,
    DateAdded,
    DateLastModified,
    AddedBy,
    UpdatedBy,
    DelFlag
)
SELECT p.FirstName,
       p.MiddleName,
       p.LastName,
       a.AddressLine1,
       a.City,
       sp.[Name],
       a.PostalCode,
       pp.PhoneNumber,
       NULL Gender,
       NULL DateAdded,
       NULL DateLastModified,
       1,
       1,
       NULL DelFlag
FROM AdventureWorks.Sales.Customer c
    JOIN AdventureWorks.Person.Person p
        ON p.BusinessEntityID = c.PersonID
    JOIN AdventureWorks.Person.PersonPhone pp
        ON pp.BusinessEntityID = p.BusinessEntityID
    JOIN AdventureWorks.[Person].[BusinessEntityAddress] bea
        ON bea.[BusinessEntityID] = p.BusinessEntityID
    JOIN AdventureWorks.Person.[Address] a
        ON a.AddressID = bea.AddressID
    JOIN AdventureWorks.[Person].[StateProvince] sp
        ON sp.[StateProvinceID] = a.StateProvinceID
WHERE pp.PhoneNumberTypeID = 2 --Home
      AND bea.AddressTypeID = 2; --Home

SELECT *
FROM dbo.Customer;
GO


DECLARE @I INT = 1;
WHILE @I <= 9140
BEGIN
    UPDATE dbo.Customer
    SET Gender = CASE
                     WHEN RAND() < 0.5 THEN
                         'F'
                     ELSE
                         'M'
                 END,
        DateAdded = DATEADD(DAY, CONVERT(INT, RAND() * 365.0), '1/1/2019'),
        DateLastModified = DATEADD(DAY, CONVERT(INT, RAND() * 365.0), '1/1/2019'),
        DelFlag = CASE
                      WHEN RAND() < 0.2 THEN
                          'Y'
                      ELSE
                          'N'
                  END
    WHERE CustomerID = @I;
    SET @I = @I + 1;
END;

SELECT SUM(   CASE
                  WHEN Gender = 'F' THEN
                      1
                  ELSE
                      0
              END
          ) GenderCount,
       SUM(   CASE
                  WHEN DelFlag = 'N' THEN
                      1
                  ELSE
                      0
              END
          ) DelFlagCount
FROM dbo.Customer;
--Female count = 4562	-- these numbers will vary because of the RAND variability
--DelFlag count = 7286



-- consider the following query, find lastname, firstname and DateAdded
-- for females from the customer table defined above
SET STATISTICS IO, TIME ON;
GO
SELECT LastName,
       FirstName,
       DateAdded
FROM dbo.Customer
WHERE DateAdded >= '6/1/2019'
      AND DateAdded < '7/1/2019'
      AND Gender = 'F';
GO
SET STATISTICS IO, TIME OFF;
GO
--Clustered Index scan, predicate on dateadded, gender
--query plan cost = 0,171855
--217 logical reads
--no index was recommended -- most likely because of the small size of the table

/***********************************************************

Let's discuss Predicate and Seek Predicate for the data operator.

Seek Predicate is used to limit the resultset similar as to a
WHERE clause in a standard query. Predicate then acts as a filter
to the result set, most likely reducing the size of the result set.  

Obviously putting as many conditions in the Seek Predicate helps
to reduce the overall work of the operator.

So, in the query above, the sql engine had to scan every row and 
then filter with dateadded and gender (hence a predicate operator)

*************************************************************/


-- Now add following non-clustered index
-- In this case let's put DateAdded before Gender since DateAdded is more selective.
CREATE INDEX IX_Customer_DateAddedGender
ON dbo.Customer (
                    DateAdded ASC,
                    Gender ASC
                )
INCLUDE (
            LastName,
            FirstName
        );
GO

-- With Nonclustered index based on DateAdded, then Gender
SET STATISTICS IO, TIME ON;
GO

SELECT LastName,
       FirstName,
       DateAdded
FROM dbo.Customer
WHERE DateAdded >= '6/1/2019'
      AND DateAdded < '7/1/2019'
      AND Gender = 'F';
GO

SET STATISTICS IO, TIME OFF;
GO
-- Index Seek on IX_Customer_DateAddedGender; seek predicate on dateadded, predicate on Gender
-- Query cost = 0.005594
-- 6 logical reads

-- So why is the DateAdded restriction in the Seek Predicate and the Gender in 
-- the Predicate? Probable reason is that since DateAdded is in ascending order 
-- then the range is used to limit the result set. But the Gender cannot be 
-- accounted for there and must be used in the Predicate to filter the result set.


DROP INDEX IX_Customer_DateAddedGender ON dbo.Customer;
GO

CREATE INDEX IX_Customer_GenderDateAdded
ON dbo.Customer (
                    Gender ASC,
                    DateAdded ASC
                )
INCLUDE (
            LastName,
            FirstName
        );
GO


SET STATISTICS IO, TIME ON;
GO

SELECT LastName,
       FirstName,
       DateAdded
FROM dbo.Customer
WHERE DateAdded >= '6/1/2019'
      AND DateAdded < '7/1/2019'
      AND Gender = 'F';
GO

SET STATISTICS IO, TIME OFF;
GO
-- Index Seek on IX_Customer_DelFlagDateAdded; Seek Predicate on Gender,DateAdded
-- Query cost = 0.0053502
-- 4 logical reads

-- note here the seek on on Gender (first column) then the Date Range (2nd column)
-- where the Date Range is already sorted.  