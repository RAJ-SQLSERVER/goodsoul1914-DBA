/*
Watch Brent Tune Queries: SQLSaturday Oslo 2020
v1.0 - 2020-08-29
https://www.BrentOzar.com/go/tunequeries
 
This demo requires:
* Any supported version of SQL Server
* The 2018-06 Stack Overflow database: https://www.BrentOzar.com/go/querystack
  (The demo will work with other versions, but only if you tweak query
  parameters to reproduce the estimation errors I cover here.)
 
This first RAISERROR is just to make sure you don't accidentally hit F5 and
run the entire script. You don't need to run this:
*/
RAISERROR (N'Oops! No, don''t just hit F5. Run these demos one at a time.', 20, 1) WITH LOG;
GO

/* I'm using the large Stack database: */
USE StackOverflow2010;
GO

/* I'm using 2019 compat level to give SQL Server every possible chance,
but if you have an older server, use the newest compat level you have. */
ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 150;
ALTER DATABASE SCOPED CONFIGURATION SET LAST_QUERY_PLAN_STATS = ON; /* 2019 only */
EXEC DropIndexes;
GO

/* These indexes should help our query: */
CREATE INDEX UserId_Incl ON dbo.Comments (UserId) INCLUDE (CreationDate);

CREATE INDEX OwnerUserId_Incl
ON dbo.Posts (OwnerUserId)
INCLUDE (CreationDate);

CREATE INDEX CreationDate_Incl
ON dbo.Comments (CreationDate)
INCLUDE (UserId);

CREATE INDEX CreationDate_Incl
ON dbo.Posts (CreationDate)
INCLUDE (OwnerUserId);
GO

CREATE OR ALTER PROC dbo.rpt_TopUsers_ByLocation @Location  NVARCHAR(100),
                                                 @StartDate DATE,
                                                 @EndDate   DATE
AS
    BEGIN
        SELECT TOP (1000) u.Reputation,
                          u.DisplayName,
                          u.AboutMe,
                          SUM (p.Score) AS "PostsScore",
                          SUM (c.Score) AS "CommentsScore"
        FROM dbo.Users AS u
        LEFT OUTER JOIN dbo.Posts AS p
            ON u.Id = p.OwnerUserId
               AND p.CreationDate BETWEEN @StartDate AND @EndDate
        LEFT OUTER JOIN dbo.Comments AS c
            ON u.Id = c.UserId
               AND c.CreationDate BETWEEN @StartDate AND @EndDate
        WHERE u.Location = @Location
        GROUP BY u.Reputation,
                 u.DisplayName,
                 u.AboutMe
        ORDER BY SUM (p.Score) DESC;
    END;
GO

/* Turn on actual plans & our query options: */
SET STATISTICS IO, TIME ON;

/* My users have been complaining about this: */
EXEC rpt_TopUsers_ByLocation @Location = N'Reading, United Kingdom',
                             @StartDate = '2011-09-01',
                             @EndDate = '2011-10-01';
GO

/* If a query takes a long time to run, your options include:

* Get the estimated plan

* Look at the live plan with sp_BlitzWho or Activity Monitor
  SQL 2016 SP1 or newer: https://www.brentozar.com/archive/2017/10/get-live-query-plans-sp_blitzwho/

* Run it with Live Query Statistics on

* Get the last actual plan with sp_BlitzCache:
  SQL 2019 or newer: https://www.brentozar.com/archive/2016/08/run-sp_blitzcache-single-query/
*/


CREATE OR ALTER PROC dbo.rpt_TopUsers_ByLocation_MBo @Location  NVARCHAR(100),
                                                     @StartDate DATE,
                                                     @EndDate   DATE
AS
    BEGIN
        /* Get the list of users in this location so we get better estimates */
        CREATE TABLE #Users (
            Id          INT PRIMARY KEY CLUSTERED,
            Reputation  INT,
            DisplayName NVARCHAR(40),
            AboutMe     NVARCHAR(MAX)
        );

        INSERT INTO #Users (Id, Reputation, DisplayName, AboutMe)
        SELECT Id,
               Reputation,
               DisplayName,
               AboutMe
        FROM dbo.Users
        WHERE Location = @Location;

        SELECT TOP (1000) u.Reputation,
                          u.DisplayName,
                          u.AboutMe,
                          SUM (p.Score) AS "PostsScore",
                          SUM (c.Score) AS "CommentsScore"
        FROM #Users AS u
        LEFT OUTER JOIN dbo.Posts AS p
            ON u.Id = p.OwnerUserId
               AND p.CreationDate BETWEEN @StartDate AND @EndDate
        LEFT OUTER JOIN dbo.Comments AS c
            ON u.Id = c.UserId
               AND c.CreationDate BETWEEN @StartDate AND @EndDate
        GROUP BY u.Reputation,
                 u.DisplayName,
                 u.AboutMe
        ORDER BY SUM (p.Score) DESC;
    END;
GO

EXEC dbo.rpt_TopUsers_ByLocation_MBo @Location = N'Reading, United Kingdom',
                                     @StartDate = '2011-09-01',
                                     @EndDate = '2011-10-01';
GO

/* Getting rid of the Key Lookups */

EXEC dbo.sp_BlitzIndex @TableName = 'Posts';
GO

CREATE INDEX OwnerUserId_Incl
ON StackOverflow2010.dbo.Posts (OwnerUserId)
INCLUDE (CreationDate, score)
WITH (ONLINE = ON, DROP_EXISTING = ON);
GO

EXEC sp_BlitzIndex @TableName = 'Comments';
GO

CREATE INDEX UserId_Incl
ON StackOverflow2010.dbo.Comments (UserId)
INCLUDE (CreationDate, score)
WITH (FILLFACTOR = 100, ONLINE = ON, DROP_EXISTING = ON);
GO

-- temp table version
EXEC dbo.rpt_TopUsers_ByLocation_MBo @Location = N'Reading, United Kingdom',
                                     @StartDate = '2011-09-01',
                                     @EndDate = '2011-10-01';
GO

-- "real" version
EXEC dbo.rpt_TopUsers_ByLocation @Location = N'Reading, United Kingdom',
                                 @StartDate = '2011-09-01',
                                 @EndDate = '2011-10-01';
GO

/* How about using a query hint */
CREATE OR ALTER PROC dbo.rpt_TopUsers_ByLocation @Location  NVARCHAR(100),
                                                 @StartDate DATE,
                                                 @EndDate   DATE
AS
    BEGIN
        SELECT TOP (1000) u.Reputation,
                          u.DisplayName,
                          u.AboutMe,
                          SUM (p.Score) AS "PostsScore",
                          SUM (c.Score) AS "CommentsScore"
        FROM dbo.Users AS u
        LEFT OUTER JOIN dbo.Posts AS p
            ON u.Id = p.OwnerUserId
               AND p.CreationDate BETWEEN @StartDate AND @EndDate
        LEFT OUTER JOIN dbo.Comments AS c
            ON u.Id = c.UserId
               AND c.CreationDate BETWEEN @StartDate AND @EndDate
        WHERE u.Location = @Location
        GROUP BY u.Reputation,
                 u.DisplayName,
                 u.AboutMe
        ORDER BY SUM (p.Score) DESC
        OPTION (USE HINT ('ENABLE_PARALLEL_PLAN_PREFERENCE'));
    END;
GO

EXEC dbo.rpt_TopUsers_ByLocation @Location = N'Reading, United Kingdom',
                                 @StartDate = '2011-09-01',
                                 @EndDate = '2011-10-01';
GO

