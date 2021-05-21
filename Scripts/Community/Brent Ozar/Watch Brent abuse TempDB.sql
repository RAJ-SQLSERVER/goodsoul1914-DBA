/****************************************************
What hammers TempDB:

Done:
* Temp tables
* Version store (query will need to do modifications)

To do:
* Spill to disk (inadequate memory grants)
* Triggers (virtual insert/update/delete)
****************************************************/

ALTER DATABASE StackOverflow2013 SET READ_COMMITTED_SNAPSHOT ON WITH NO_WAIT;
GO

USE StackOverflow2013;
GO

CREATE OR ALTER PROC dbo.usp_GrantRedShirtBadge @StartDate DATETIME = NULL,
                                                @EndDate   DATETIME = NULL
AS
    BEGIN
        BEGIN TRAN;

        -- Get the users we want to modify into a temp table
        DECLARE @UsersWhoEarnedTheBadge TABLE (UserId INT, LastAccessDate DATETIME);

        INSERT INTO @UsersWhoEarnedTheBadge (UserId, LastAccessDate)
        SELECT TOP (10000) Id,
                           LastAccessDate
        FROM dbo.Users AS u
        WHERE u.LastAccessDate >= @StartDate
              AND u.LastAccessDate <= @EndDate
              AND NOT EXISTS (SELECT * FROM dbo.Badges AS b WHERE b.UserId = u.Id)
        ORDER BY u.CreationDate;

        INSERT INTO dbo.Badges (Name, UserId, Date)
        SELECT 'Red Shirt',
               u.UserId,
               u1.CreationDate -- Added to grant them the badge retroactively
        FROM @UsersWhoEarnedTheBadge AS u
        INNER JOIN dbo.Users AS u1
            ON u.UserId = u1.Id
        LEFT OUTER JOIN dbo.Badges AS b
            ON u.UserId = b.UserId
               AND b.Name = 'Red Shirt'
        WHERE b.Name IS NULL; -- User hasn't earned the red shirt badge yet

        -- Give them 10 points for bravery during inactivity
        UPDATE u
        SET Reputation = u.Reputation + 10
        FROM @UsersWhoEarnedTheBadge AS ueb
        INNER JOIN dbo.Users AS u
            ON ueb.UserId = u.Id;

        COMMIT;
    END;
GO




DELETE dbo.Badges
WHERE Name = 'Red Shirt';

DBCC FREEPROCCACHE;


EXEC dbo.usp_GrantRedShirtBadge @StartDate = '2007-01-01',
                                @EndDate = '2007-01-02';

EXEC dbo.usp_GrantRedShirtBadge @StartDate = '2007-01-01',
                                @EndDate = '2020-01-02';