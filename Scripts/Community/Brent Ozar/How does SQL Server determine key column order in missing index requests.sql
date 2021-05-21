
/* --------------------------------------------------
 When SQL Server creates a missing index recommendation 
 for a particular query plan, it separates possible key 
 columns into 2 groups. The first set contains all of 
 the recommended columns that are part of an EQUALITY 
 predicate. 
 
 The second set contains all of the recommended columns 
 that are part of an INEQUALITY predicate.

 Within each set, the columns are ordered by the 
 ordinal position of the columns, based on the table 
 definition.
-------------------------------------------------- */

USE StackOverflow2013;
GO
dbo.DropIndexes;
GO


-------------------------------------------------------------------------------
-- Create 3 identical tables, but put their columns in different order. 
-- (The reason here is to use a variety of column names and datatypes to show 
-- that that doesn't impact the column order in the missing index 
-- recommendation.)
-------------------------------------------------------------------------------
CREATE TABLE dbo.NumberLetterDate (
    ID        INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED,
    fINT      INT,
    fNVARCHAR NVARCHAR(40),
    fDATE     DATETIME,
    AboutMe   NVARCHAR(MAX)
);
GO

CREATE TABLE dbo.LetterDateNumber (
    ID        INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED,
    fNVARCHAR NVARCHAR(40),
    fDATE     DATETIME,
    fINT      INT,
    AboutMe   NVARCHAR(MAX)
);
GO

CREATE TABLE dbo.DateNumberLetter (
    ID        INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED,
    fDATE     DATETIME,
    fINT      INT,
    fNVARCHAR NVARCHAR(40),
    AboutMe   NVARCHAR(MAX)
);
GO


-------------------------------------------------------------------------------
-- Populate the tables with the same data. Get 100,000 rows from the Users 
-- table with real-world data distribution
-------------------------------------------------------------------------------
INSERT INTO dbo.NumberLetterDate (fINT, fNVARCHAR, fDATE, AboutMe)
SELECT TOP 100000 Age,
                  DisplayName,
                  LastAccessDate,
                  AboutMe
FROM dbo.Users WITH (NOLOCK)
ORDER BY Id;
GO

INSERT INTO dbo.LetterDateNumber (fINT, fNVARCHAR, fDATE, AboutMe)
SELECT TOP 100000 Age,
                  DisplayName,
                  LastAccessDate,
                  AboutMe
FROM dbo.Users WITH (NOLOCK)
ORDER BY Id;
GO

INSERT INTO dbo.DateNumberLetter (fINT, fNVARCHAR, fDATE, AboutMe)
SELECT TOP 100000 Age,
                  DisplayName,
                  LastAccessDate,
                  AboutMe
FROM dbo.Users WITH (NOLOCK)
ORDER BY Id;
GO


-------------------------------------------------------------------------------
-- Write a query that needs an index. Start with 3 equality filters, 
-- filtering for an exact value in all 3 fields. Note that all 3 queries have 
-- the same fields in the same order:
-------------------------------------------------------------------------------
SELECT ID
FROM dbo.NumberLetterDate
WHERE fINT = 100
      AND fNVARCHAR = 'Brent Ozar'
      AND fDATE = '2018/01/01'
      AND 1 = (SELECT 1);

SELECT ID
FROM dbo.LetterDateNumber
WHERE fINT = 100
      AND fNVARCHAR = 'Brent Ozar'
      AND fDATE = '2018/01/01'
      AND 1 = (SELECT 1);

SELECT ID
FROM dbo.DateNumberLetter
WHERE fINT = 100
      AND fNVARCHAR = 'Brent Ozar'
      AND fDATE = '2018/01/01'
      AND 1 = (SELECT 1);
GO

/******************************************************************************
In the execution plans, the column order in the missing index request exactly 
matches the column order in the table. For example, in dbo.NumberLetterDate, 
the number column is first, so it's first in the missing index request, too:

On dbo.NumberLetterDate, the missing index is on fINT (number), 
fLetter (nvarchar), fDate, the same order of the fields in the table
On dbo.LetterDateNumber, the index order switches to fNVARCHAR, fDATE, fINT
On dbo.DateNumberLetter, the index order switches to fDATE, fINT, fNVARCHAR
For a single-table operation like this, the index field order doesn't appear 
to depend on selectivity, datatype, or position in the query. 
(I leave it to other folks to prove this with more complex queries & joins.)
******************************************************************************/


-------------------------------------------------------------------------------
-- Mix in an inequality filter
-------------------------------------------------------------------------------
SELECT ID
FROM dbo.NumberLetterDate
WHERE fINT <> 100
      AND fNVARCHAR = 'Brent Ozar'
      AND fDATE = '2018/01/01'
      AND 1 = (SELECT 1);

SELECT ID
FROM dbo.LetterDateNumber
WHERE fINT <> 100
      AND fNVARCHAR = 'Brent Ozar'
      AND fDATE = '2018/01/01'
      AND 1 = (SELECT 1);

SELECT ID
FROM dbo.DateNumberLetter
WHERE fINT <> 100
      AND fNVARCHAR = 'Brent Ozar'
      AND fDATE = '2018/01/01'
      AND 1 = (SELECT 1);
GO


-------------------------------------------------------------------------------
-- Use 3 inequality filters
-------------------------------------------------------------------------------
SELECT ID
FROM dbo.NumberLetterDate
WHERE fINT <> 100
      AND fNVARCHAR <> 'Brent Ozar'
      AND fDATE <> '2018/01/01'
      AND 1 = (SELECT 1);

SELECT ID
FROM dbo.LetterDateNumber
WHERE fINT <> 100
      AND fNVARCHAR <> 'Brent Ozar'
      AND fDATE <> '2018/01/01'
      AND 1 = (SELECT 1);

SELECT ID
FROM dbo.DateNumberLetter
WHERE fINT <> 100
      AND fNVARCHAR <> 'Brent Ozar'
      AND fDATE <> '2018/01/01'
      AND 1 = (SELECT 1);
GO


-------------------------------------------------------------------------------
-- Cleanup
-------------------------------------------------------------------------------
DROP TABLE dbo.NumberLetterDate;
DROP TABLE dbo.LetterDateNumber;
DROP TABLE dbo.DateNumberLetter;
GO

dbo.DropIndexes;
GO
