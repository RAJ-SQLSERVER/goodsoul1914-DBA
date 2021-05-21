USE StackOverflow2010;
GO

RAISERROR (N'Oops! No do''t just hit F5. Run these demos one at a time.', 20, 1) WITH LOG;

-------------------------------------------------------------------------------
-- The problem with Multi-Parameter Stored Procedures
--
-- Say we want to search the dbo.Users table - we might want a proc that lets
-- us pass in different search parameters:
--
--    * @SearchDisplayName
--	  * @SearchLocation
--	  * @SearchReputation
--
-- Like this:
-- EXEC usp_SearchUsers @SearchDisplayName = 'Brent%', @SearchLocation = 'NY%';
-- EXEC usp_SearchUsers @SearchLocation = 'NY', @SearchReputation = 2;
-------------------------------------------------------------------------------

ALTER DATABASE StackOverflow2010 SET COMPATIBILITY_LEVEL = 140;
GO
EXEC dbo.DropIndexes @TableName = N'Users';
GO

SET STATISTICS IO ON;
GO

SELECT COUNT (*)
FROM dbo.Users; -- Worst case scenario: logical reads 7761
GO

-- We want our searches to be fast - if we're searching for Displayname, then 
-- we want an index seek on DisplayName. Let's create a few supporting indexes
CREATE INDEX IX_DisplayName ON dbo.Users (DisplayName);
CREATE INDEX IX_Location ON dbo.Users (location);
CREATE INDEX IX_Reputation ON dbo.Users (Reputation);
GO

-- Here's one way to do it. It's a bad way - it doesn't really work - but let's
-- look at how it performs:
CREATE OR ALTER PROC dbo.usp_SearchUsers @SearchDisplayName NVARCHAR(100) = NULL,
                                         @SearchLocation    NVARCHAR(100) = NULL,
                                         @SearchReputation  INT           = NULL
AS
    BEGIN
        IF @SearchDisplayName IS NOT NULL
            SELECT *
            FROM dbo.Users
            WHERE DisplayName LIKE @SearchDisplayName;
        ELSE IF @SearchLocation IS NOT NULL
            SELECT *
            FROM dbo.Users
            WHERE Location LIKE @SearchLocation;
        ELSE IF @SearchReputation IS NOT NULL
            SELECT *
            FROM dbo.Users
            WHERE Reputation = @SearchReputation;
    END;
GO

EXEC dbo.usp_SearchUsers @SearchDisplayName = 'Brent%',
                         @SearchLocation = 'San Diego%'; -- logical reads 7398
EXEC dbo.usp_SearchUsers @SearchLocation = 'Seattle', @SearchReputation = 2; -- logical reads 7398
GO

-- So let's try again using the "kitchen sink" design pattern
CREATE OR ALTER PROC dbo.usp_SearchUsers @SearchDisplayName NVARCHAR(100) = NULL,
                                         @SearchLocation    NVARCHAR(100) = NULL,
                                         @SearchReputation  INT           = NULL
AS
    BEGIN
        SELECT *
        FROM dbo.Users
        WHERE (DisplayName LIKE @SearchDisplayName OR @SearchDisplayName IS NULL)
              AND (Location LIKE @SearchLocation OR @SearchLocation IS NULL)
              AND (Reputation LIKE @SearchReputation OR @SearchReputation IS NULL)
        OPTION (RECOMPILE);
    END;
GO

EXEC dbo.usp_SearchUsers @SearchDisplayName = 'Brent%',
                         @SearchLocation = 'San Diego%'; -- logical reads 22
EXEC dbo.usp_SearchUsers @SearchLocation = 'Seattle', @SearchReputation = 2; -- logical reads 102
GO

/*
Good news! This will give the right results most of the time (Handling NULL
parameters that are specifically looking for nulls only is another story)

Let's try to run it and see what indexes it chooses to use:
*/
DBCC FREEPROCCACHE;
GO
EXEC dbo.usp_SearchUsers @SearchDisplayName = 'Brent%';
GO
EXEC dbo.usp_SearchUsers @SearchLocation = 'Seattle%';
GO

/*
How about using COALESCE ?
*/

CREATE OR ALTER PROC dbo.usp_SearchUsers @SearchDisplayName NVARCHAR(100) = NULL,
                                         @SearchLocation    NVARCHAR(100) = NULL,
                                         @SearchReputation  INT           = NULL
AS
    BEGIN
        SELECT *
        FROM dbo.Users
        WHERE DisplayName LIKE COALESCE (@SearchDisplayName, DisplayName)
              AND Location LIKE COALESCE (@SearchLocation, Location)
              AND Reputation LIKE COALESCE (@SearchReputation, Reputation);
    END;
GO

DBCC FREEPROCCACHE;
GO
EXEC dbo.usp_SearchUsers @SearchDisplayName = 'Brent%'; -- Scan count 15, logical reads 2885
GO
EXEC dbo.usp_SearchUsers @SearchLocation = 'Seattle%'; -- Scan count 15, logical reads 7648
GO

/*
When SQL Server builds a plan for a proc
it has to be able to reuse that plan,
NO MATTER WHAT PARAMETERS ARE USED.

So you often end up with clustered index scans when you think you're filtering,
and even if you do get an index hit, it can end up being a scan, not a seek.
(Not that seeks are always amazing.)

What about ISNULL ?
*/

CREATE OR ALTER PROC dbo.usp_SearchUsers @SearchDisplayName NVARCHAR(100) = NULL,
                                         @SearchLocation    NVARCHAR(100) = NULL,
                                         @SearchReputation  INT           = NULL
AS
    BEGIN
        SELECT *
        FROM dbo.Users
        WHERE DisplayName LIKE ISNULL (@SearchDisplayName, DisplayName)
              AND Location LIKE ISNULL (@SearchLocation, Location)
              AND Reputation LIKE ISNULL (@SearchReputation, Reputation);
    END;
GO

DBCC FREEPROCCACHE;
GO
EXEC dbo.usp_SearchUsers @SearchDisplayName = 'Brent%'; -- Scan count 15, logical reads 2885
GO
EXEC dbo.usp_SearchUsers @SearchLocation = 'Seattle%'; -- Scan count 15, logical reads 7648
GO


-------------------------------------------------------------------------------
-- Indexed Views
-------------------------------------------------------------------------------

USE StackOverflow2010;
GO
dbo.DropIndexes;
SET STATISTICS IO, TIME ON;
GO

/*
Say we constantly need to count the number of votes per post
*/
SELECT TOP (100) p.Id,
                 p.Title,
                 COUNT (*) AS "VoteCount"
FROM dbo.Posts AS p
INNER JOIN dbo.Votes AS v
    ON v.PostId = p.Id
GROUP BY p.Id,
         p.Title
ORDER BY COUNT (*) DESC;
GO

-- Takes over 10 seconds!

/* To make this faster, we can index votes */
CREATE INDEX IX_VoteTypeId_PostId ON dbo.Votes (PostId);
GO

-- Still takes 7 seconds!

/* Or create a columnstore index */
CREATE NONCLUSTERED COLUMNSTORE INDEX NCCI_PostId ON dbo.Votes (PostId);
GO

-- Takes 1.2 seconds now
-- Still not good enough

/* Welcome to indexed views */
CREATE OR ALTER VIEW dbo.vwVotesByPost
WITH SCHEMABINDING
AS
SELECT PostId,
       COUNT_BIG (*) AS "VoteCount"
FROM dbo.Votes
GROUP BY PostId;
GO
CREATE UNIQUE CLUSTERED INDEX CL_PostId ON dbo.vwVotesByPost (PostId);
GO

-- Takes CPU time = 1156 ms without changing the query
-- But after changing the code ...

SELECT TOP (100) p.Id,
                 p.Title,
                 COUNT_BIG (*) AS "VoteCount"
FROM dbo.Posts AS p
INNER JOIN dbo.Votes AS v
    ON v.PostId = p.Id
GROUP BY p.Id,
         p.Title
ORDER BY COUNT_BIG (*) DESC;
GO


/* It is still sorting though. If you wanted to get rid of that */
CREATE INDEX IX_VoteCount ON dbo.vwVotesByPost (VoteCount);
GO

-- After changing the query to use COUNT_BIG
-- it takes CPU time = 15 ms

