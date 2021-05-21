USE StackOverflow2010;
GO

dbo.DropIndexes;
GO

CREATE NONCLUSTERED INDEX IX_Location ON dbo.Users (location);
GO

SELECT TOP (100) Location,
                 COUNT (*) AS "recs"
FROM dbo.Users
GROUP BY Location
ORDER BY COUNT (*) DESC;
GO

SELECT AboutMe,
       Age,
       CreationDate,
       DisplayName,
       DownVotes,
       LastAccessDate,
       Location,
       Reputation,
       UpVotes,
       Views
FROM dbo.Users
WHERE Location LIKE '%Argentina%';
GO

/* This is something we can't really fix in post */

/*
	Comparison between two columns in a table
*/

CREATE NONCLUSTERED INDEX CreationDate_LastAccessDate
ON dbo.Users (CreationDate, LastAccessDate)
INCLUDE (Reputation);
CREATE NONCLUSTERED INDEX LastAccessDate_CreationDate
ON dbo.Users (LastAccessDate, CreationDate)
INCLUDE (Reputation);
GO

SET STATISTICS IO ON;

-- A
SELECT TOP (100) *
FROM dbo.Users
WHERE DATEDIFF (HH, CreationDate, LastAccessDate) < 4 /* Seek is not possible ! */
ORDER BY Reputation DESC;
GO

-- B
SELECT TOP (100) *
FROM dbo.Users WITH (INDEX = CreationDate_LastAccessDate)
WHERE DATEDIFF (HH, CreationDate, LastAccessDate) < 4 /* Seek is not possible ! */
ORDER BY Reputation DESC;
GO

-- SQL Server made the right choice
-- Query B performs the KEY LOOKUP first and then the SORT
-- Can we place that SORT operator before the KEY LOOKUP?

WITH Top100Users -- CTE can only use columns that are on the index !!!
AS
(
    SELECT TOP (100) Id,
                     Reputation
    FROM dbo.Users
    WHERE DATEDIFF (HH, CreationDate, LastAccessDate) < 4
    ORDER BY Reputation DESC
)
SELECT u.AboutMe,
       u.Age,
       u.CreationDate,
       u.DisplayName,
       u.DownVotes,
       u.LastAccessDate,
       u.Location,
       u.Reputation,
       u.UpVotes,
       u.Views
FROM Top100Users AS t
INNER JOIN dbo.Users AS u
    ON t.Id = u.Id
ORDER BY t.Reputation DESC;
GO

-- Can we also achieve this without modifying the query?

SELECT TOP (100) Id,
                 AboutMe,
                 Age,
                 CreationDate,
                 DisplayName,
                 DownVotes,
                 EmailHash,
                 LastAccessDate,
                 Location,
                 Reputation,
                 UpVotes,
                 Views,
                 WebsiteUrl,
                 AccountId,
                 HoursBetween_LastAccessDate_and_CreationDate
FROM dbo.Users
WHERE DATEDIFF (HH, CreationDate, LastAccessDate) < 4 /* Seek is not possible ! */
ORDER BY Reputation DESC;
GO

-- Yes, use computed columns

ALTER TABLE dbo.Users
ADD HoursBetween_LastAccessDate_and_CreationDate AS DATEDIFF (HH, CreationDate, LastAccessDate);

CREATE NONCLUSTERED INDEX HoursBetween_LastAccessDate_and_CreationDate
ON dbo.Users (HoursBetween_LastAccessDate_and_CreationDate);
GO

SELECT TOP (100) Id,
                 AboutMe,
                 Age,
                 CreationDate,
                 DisplayName,
                 DownVotes,
                 EmailHash,
                 LastAccessDate,
                 Location,
                 Reputation,
                 UpVotes,
                 Views,
                 WebsiteUrl,
                 AccountId,
                 HoursBetween_LastAccessDate_and_CreationDate
FROM dbo.Users
WHERE DATEDIFF (HH, CreationDate, LastAccessDate) < 4 /* Seek is not possible ! */
ORDER BY Reputation DESC;
GO

-- Or:

SELECT TOP (100) *
FROM dbo.Users WITH (INDEX = HoursBetween_LastAccessDate_and_CreationDate)
WHERE DATEDIFF (HH, CreationDate, LastAccessDate) < 4 /* Seek is not possible ! */
ORDER BY Reputation DESC;
GO

-- Still too many results
-- Create more indexes

CREATE NONCLUSTERED INDEX Reputation_HoursBetween_LastAccessDate_and_CreationDate
ON dbo.Users (Reputation, HoursBetween_LastAccessDate_and_CreationDate);
CREATE NONCLUSTERED INDEX HoursBetween_LastAccessDate_and_CreationDate_Reputation
ON dbo.Users (HoursBetween_LastAccessDate_and_CreationDate, Reputation);
GO

SELECT TOP (100) CreationDate,
                 DisplayName,
                 DownVotes,
                 LastAccessDate,
                 Location,
                 Reputation,
                 UpVotes,
                 Views,
                 HoursBetween_LastAccessDate_and_CreationDate
FROM dbo.Users
WHERE DATEDIFF (HH, CreationDate, LastAccessDate) < 4 /* Seek is not possible ! */
ORDER BY Reputation DESC;
GO

-- Just 436 logical reads! Wowww!

/*
	How about a function inside a WHERE clause
*/

-- System functions ?

SELECT CreationDate,
       DisplayName,
       DownVotes,
       LastAccessDate,
       Location,
       Reputation,
       UpVotes,
       Views,
       HoursBetween_LastAccessDate_and_CreationDate
FROM dbo.Users
WHERE UPPER (DisplayName) = N'Brent Ozar'; -- Collation is case-insenstive
GO

-- How about User defined functions?

CREATE OR ALTER FUNCTION dbo.UpperCase (@StringToUpper NVARCHAR(4000))
RETURNS NVARCHAR(4000)
WITH EXECUTE AS CALLER
AS
    BEGIN
        RETURN UPPER (@StringToUpper);
    END;
GO

SELECT CreationDate,
       DisplayName,
       DownVotes,
       LastAccessDate,
       Location,
       Reputation,
       UpVotes,
       Views
FROM dbo.Users
WHERE dbo.UpperCase (DisplayName) = N'Brent Ozar'; -- Collation is case-insenstive
GO

CREATE OR ALTER FUNCTION dbo.UpperCase (@StringToUpper NVARCHAR(40))
RETURNS NVARCHAR(40)
WITH EXECUTE AS CALLER
AS
    BEGIN
        RETURN @StringToUpper;
    END;
GO

SELECT CreationDate,
       DisplayName,
       DownVotes,
       LastAccessDate,
       Location,
       Reputation,
       UpVotes,
       Views
FROM dbo.Users
WHERE dbo.UpperCase (DisplayName) = N'Brent Ozar'; -- Collation is case-insenstive
GO
