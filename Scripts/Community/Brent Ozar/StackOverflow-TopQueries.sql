USE StackOverflow2010;
GO

IF OBJECT_ID ('dbo.usp_Q7521') IS NULL
    EXEC ('CREATE PROCEDURE dbo.usp_Q7521 AS RETURN 0;');
GO

ALTER PROC dbo.usp_Q7521 @UserId INT
AS
    BEGIN

        /*******************************************************************************
 Source: http://data.stackexchange.com/stackoverflow/query/7521/how-unsung-am-i 
*******************************************************************************/

        -- How Unsung am I?
        -- Zero and non-zero accepted count. Self-accepted answers do not count.

        SELECT COUNT (a.Id) AS "Accepted Answers",
               SUM (CASE WHEN a.Score = 0 THEN 0 ELSE 1 END) AS "Scored Answers",
               SUM (CASE WHEN a.Score = 0 THEN 1 ELSE 0 END) AS "Unscored Answers",
               SUM (CASE WHEN a.Score = 0 THEN 1 ELSE 0 END) * 1000 / COUNT (a.Id) / 10.0 AS "Percentage Unscored"
        FROM Posts AS q
        INNER JOIN Posts AS a
            ON a.Id = q.AcceptedAnswerId
        WHERE a.CommunityOwnedDate IS NULL
              AND a.OwnerUserId = @UserId
              AND q.OwnerUserId != @UserId
              AND a.PostTypeId = 2;
    END;
GO


IF OBJECT_ID ('dbo.usp_Q36660') IS NULL
    EXEC ('CREATE PROCEDURE dbo.usp_Q36660 AS RETURN 0;');
GO

ALTER PROC dbo.usp_Q36660 @Useless INT
AS
    BEGIN

        /******************************************************************************************
 Source: http://data.stackexchange.com/stackoverflow/query/36660/most-down-voted-questions 
******************************************************************************************/

        SELECT TOP 20 COUNT (v.PostId) AS "Vote count",
                      v.PostId AS "Post Link",
                      p.Body
        FROM Votes AS v
        INNER JOIN Posts AS p
            ON p.Id = v.PostId
        WHERE PostTypeId = 1
              AND v.VoteTypeId = 3
        GROUP BY v.PostId,
                 p.Body
        ORDER BY 'Vote count' DESC;

    END;
GO


IF OBJECT_ID ('dbo.usp_Q949') IS NULL
    EXEC ('CREATE PROCEDURE dbo.usp_Q949 AS RETURN 0;');
GO

ALTER PROC dbo.usp_Q949 @UserId INT
AS
    BEGIN

        /*********************************************************************************************************
 Source: http://data.stackexchange.com/stackoverflow/query/949/what-is-my-accepted-answer-percentage-rate 
*********************************************************************************************************/

        SELECT CAST(COUNT (a.Id) AS FLOAT)
               / (SELECT COUNT (*) FROM Posts WHERE OwnerUserId = @UserId AND PostTypeId = 2) * 100 AS "AcceptedPercentage"
        FROM Posts AS q
        INNER JOIN Posts AS a
            ON q.AcceptedAnswerId = a.Id
        WHERE a.OwnerUserId = @UserId
              AND a.PostTypeId = 2;

    END;
GO

IF OBJECT_ID ('dbo.usp_Q466') IS NULL
    EXEC ('CREATE PROCEDURE dbo.usp_Q466 AS RETURN 0;');
GO

ALTER PROC dbo.usp_Q466 @Useless INT
AS
    BEGIN

        /***************************************************************************************************
 Source: http://data.stackexchange.com/stackoverflow/query/466/most-controversial-posts-on-the-site 
***************************************************************************************************/

        SET NOCOUNT ON;

        DECLARE @VoteStats TABLE (PostId INT, up INT, down INT);

        INSERT INTO @VoteStats
        SELECT PostId,
               SUM (CASE WHEN VoteTypeId = 2 THEN 1 ELSE 0 END) AS "up",
               SUM (CASE WHEN VoteTypeId = 3 THEN 1 ELSE 0 END) AS "down"
        FROM Votes
        WHERE VoteTypeId IN ( 2, 3 )
        GROUP BY PostId;

        SET NOCOUNT OFF;


        SELECT TOP 100 p.Id AS "Post Link",
                       up,
                       down
        FROM @VoteStats
        JOIN Posts AS p
            ON PostId = p.Id
        WHERE down > up * 0.5
              AND p.CommunityOwnedDate IS NULL
              AND p.ClosedDate IS NULL
        ORDER BY up DESC;
    END;
GO

IF OBJECT_ID ('dbo.usp_Q947') IS NULL
    EXEC ('CREATE PROCEDURE dbo.usp_Q947 AS RETURN 0;');
GO

ALTER PROC dbo.usp_Q947 @UserId INT
AS
    BEGIN

        /********************************************************************************************
 Source: http://data.stackexchange.com/stackoverflow/query/947/my-comment-score-distribution 
********************************************************************************************/

        SELECT COUNT (*) AS "CommentCount",
               Score
        FROM Comments
        WHERE UserId = @UserId
        GROUP BY Score
        ORDER BY Score DESC;
    END;
GO

IF OBJECT_ID ('dbo.usp_Q3160') IS NULL
    EXEC ('CREATE PROCEDURE dbo.usp_Q3160 AS RETURN 0;');
GO

ALTER PROC dbo.usp_Q3160 @UserId INT
AS
    BEGIN;

        /************************************************************************************
 Source: http://data.stackexchange.com/stackoverflow/query/3160/jon-skeet-comparison 
************************************************************************************/

        WITH fights AS
        (
            SELECT myAnswer.ParentId AS "Question",
                   myAnswer.Score AS "MyScore",
                   jonsAnswer.Score AS "JonsScore"
            FROM Posts AS myAnswer
            INNER JOIN Posts AS jonsAnswer
                ON jonsAnswer.OwnerUserId = 22656
                   AND myAnswer.ParentId = jonsAnswer.ParentId
            WHERE myAnswer.OwnerUserId = @UserId
                  AND myAnswer.PostTypeId = 2
        )
        SELECT CASE
                   WHEN MyScore > JonsScore THEN 'You win'
                   WHEN MyScore < JonsScore THEN 'Jon wins'
                   ELSE 'Tie'
               END AS "Winner",
               Question AS "Post Link",
               MyScore AS "My score",
               JonsScore AS "Jon's score"
        FROM fights;
    END;
GO

IF OBJECT_ID ('dbo.usp_Q6627') IS NULL
    EXEC ('CREATE PROCEDURE dbo.usp_Q6627 AS RETURN 0;');
GO

ALTER PROC dbo.usp_Q6627 @Useless INT
AS
    BEGIN

        /********************************************************************************************
 Source: http://data.stackexchange.com/stackoverflow/query/6627/top-50-most-prolific-editors 
********************************************************************************************/

        -- Top 50 Most Prolific Editors
        -- Shows the top 50 post editors, where the user was the most recent editor
        -- (meaning the results are conservative compared to the actual number of edits).

        SELECT TOP 50 Id AS "User Link",
                      (
                          SELECT COUNT (*)
                          FROM Posts
                          WHERE PostTypeId = 1
                                AND LastEditorUserId = Users.Id
                                AND OwnerUserId != Users.Id
                      ) AS "QuestionEdits",
                      (
                          SELECT COUNT (*)
                          FROM Posts
                          WHERE PostTypeId = 2
                                AND LastEditorUserId = Users.Id
                                AND OwnerUserId != Users.Id
                      ) AS "AnswerEdits",
                      (
                          SELECT COUNT (*)
                          FROM Posts
                          WHERE LastEditorUserId = Users.Id
                                AND OwnerUserId != Users.Id
                      ) AS "TotalEdits"
        FROM Users
        ORDER BY TotalEdits DESC;

    END;
GO

IF OBJECT_ID ('dbo.usp_Q6772') IS NULL
    EXEC ('CREATE PROCEDURE dbo.usp_Q6772 AS RETURN 0;');
GO

ALTER PROC dbo.usp_Q6772 @UserId INT
AS
    BEGIN;

        /*************************************************************************************************
 Source: http://data.stackexchange.com/stackoverflow/query/6772/stackoverflow-rank-and-percentile 
*************************************************************************************************/

        WITH Rankings AS
        (
            SELECT Id,
                   ROW_NUMBER () OVER (ORDER BY Reputation DESC) AS "Ranking"
            FROM Users
        ),
             Counts AS (SELECT COUNT (*) AS "Count" FROM Users WHERE Reputation > 100)
        SELECT Id,
               Ranking,
               CAST(Ranking AS DECIMAL(20, 5)) / (SELECT Count FROM Counts) AS "Percentile"
        FROM Rankings
        WHERE Id = @UserId;

    END;
GO

IF OBJECT_ID ('dbo.usp_Q6856') IS NULL
    EXEC ('CREATE PROCEDURE dbo.usp_Q6856 AS RETURN 0;');
GO

ALTER PROC dbo.usp_Q6856 @MinReputation INT,
                         @Upvotes       INT = 100
AS
    BEGIN

        /***************************************************************************************************************
 Source: http://data.stackexchange.com/stackoverflow/query/6856/high-standards-top-100-users-that-rarely-upvote 
***************************************************************************************************************/

        SELECT TOP 100 Id AS "User Link",
                       ROUND ((100.0 * Reputation / 10) / (UpVotes + 1), 2) AS "Ratio %",
                       Reputation AS "Rep",
                       UpVotes AS "+ Votes",
                       DownVotes AS "- Votes"
        FROM Users
        WHERE Reputation > @MinReputation
              AND UpVotes > @Upvotes
        ORDER BY [Ratio %] DESC;

    END;
GO

IF OBJECT_ID ('dbo.usp_Q952') IS NULL
    EXEC ('CREATE PROCEDURE dbo.usp_Q952 AS RETURN 0;');
GO

ALTER PROC dbo.usp_Q952 @Useless INT
AS
    BEGIN

        /********************************************************************************************
 Source: http://data.stackexchange.com/stackoverflow/query/952/top-500-answerers-on-the-site 
********************************************************************************************/

        SELECT TOP 500 Users.Id AS "User Link",
                       COUNT (Posts.Id) AS "Answers",
                       CAST(AVG (CAST(Score AS FLOAT)) AS NUMERIC(6, 2)) AS "Average Answer Score"
        FROM Posts
        INNER JOIN Users
            ON Users.Id = OwnerUserId
        WHERE PostTypeId = 2
              AND CommunityOwnedDate IS NULL
              AND ClosedDate IS NULL
        GROUP BY Users.Id,
                 DisplayName
        HAVING COUNT (Posts.Id) > 10
        ORDER BY [Average Answer Score] DESC;

    END;
GO


IF OBJECT_ID ('dbo.usp_Q975') IS NULL
    EXEC ('CREATE PROCEDURE dbo.usp_Q975 AS RETURN 0;');
GO

ALTER PROC dbo.usp_Q975 @Useless INT
AS
    BEGIN

        /************************************************************************************************************************************************
 Source: http://data.stackexchange.com/stackoverflow/query/975/users-with-more-than-one-duplicate-account-and-a-more-than-1000-reputation-in-agg 
************************************************************************************************************************************************/

        -- Users with more than one duplicate account and a more that 1000 reputation in aggregate
        -- A list of users that have duplicate accounts on site, based on the EmailHash and lots of reputation is riding on it

        SELECT u1.EmailHash,
               COUNT (u1.Id) AS "Accounts",
               (
                   SELECT CAST(u2.Id AS VARCHAR) + ' (' + u2.DisplayName + ' ' + CAST(u2.Reputation AS VARCHAR) + '), '
                   FROM Users AS u2
                   WHERE u2.EmailHash = u1.EmailHash
                   ORDER BY u2.Reputation DESC
                   FOR XML PATH ('')
               ) AS "IdsAndNames"
        FROM Users AS u1
        WHERE u1.EmailHash IS NOT NULL
              AND (
                  SELECT SUM (u3.Reputation)
                  FROM Users AS u3
                  WHERE u3.EmailHash = u1.EmailHash
              ) > 1000
              AND (
                  SELECT COUNT (*)
                  FROM Users AS u3
                  WHERE u3.EmailHash = u1.EmailHash
                        AND Reputation > 10
              ) > 1
        GROUP BY u1.EmailHash
        HAVING COUNT (u1.Id) > 1
        ORDER BY Accounts DESC;

    END;
GO


IF OBJECT_ID ('dbo.usp_Q8116') IS NULL
    EXEC ('CREATE PROCEDURE dbo.usp_Q8116 AS RETURN 0;');
GO

ALTER PROC dbo.usp_Q8116 @UserId INT
AS
    BEGIN

        /********************************************************************************
 Source: http://data.stackexchange.com/stackoverflow/query/8116/my-money-for-jam 
********************************************************************************/

        -- My Money for Jam
        -- My Non Community Wiki Posts that earn the most Passive Reputation.
        -- Reputation gained in the first 15 days of post is ignored,
        -- all reputation after that is considered passive reputation.
        -- Post must be at least 60 Days old.

        SET NOCOUNT ON;

        DECLARE @latestDate DATETIME;
        SELECT @latestDate = MAX (CreationDate)
        FROM Posts;
        DECLARE @ignoreDays NUMERIC = 15;
        DECLARE @minAgeDays NUMERIC = @ignoreDays * 4;

        -- temp table moded from http://odata.stackexchange.com/stackoverflow/s/87
        DECLARE @VoteStats TABLE (PostId INT, up INT, down INT, CreationDate DATETIME);
        INSERT INTO @VoteStats
        SELECT p.Id,
               SUM (CASE
                        WHEN VoteTypeId = 2 THEN CASE
                                                     WHEN p.ParentId IS NULL THEN 5
                                                     ELSE 10
                                                 END
                        ELSE 0
                    END
               ) AS "up",
               SUM (CASE WHEN VoteTypeId = 3 THEN 2 ELSE 0 END) AS "down",
               p.CreationDate
        FROM Votes AS v
        JOIN Posts AS p
            ON v.PostId = p.Id
        WHERE v.VoteTypeId IN ( 2, 3 )
              AND OwnerUserId = @UserId
              AND p.CommunityOwnedDate IS NULL
              AND DATEDIFF (DAY, p.CreationDate, v.CreationDate) > @ignoreDays
              AND DATEDIFF (DAY, p.CreationDate, @latestDate) > @minAgeDays
        GROUP BY p.Id,
                 p.CreationDate,
                 p.ParentId;

        SET NOCOUNT OFF;

        SELECT TOP 100 PostId AS "Post Link",
                       CONVERT (DECIMAL(10, 2), up - down)
                       / (DATEDIFF (DAY, vs.CreationDate, @latestDate) - @ignoreDays) AS "Passive Rep Per Day",
                       up - down AS "Passive Rep",
                       up AS "Passive Up Reputation",
                       down AS "Passive Down Reputation",
                       DATEDIFF (DAY, vs.CreationDate, @latestDate) - @ignoreDays AS "Days Counted"
        FROM @VoteStats AS vs
        ORDER BY [Passive Rep Per Day] DESC;


    END;
GO


IF OBJECT_ID ('dbo.usp_RandomQ') IS NULL
    EXEC ('CREATE PROCEDURE dbo.usp_RandomQ AS RETURN 0;');
GO

ALTER PROCEDURE dbo.usp_RandomQ
WITH RECOMPILE
AS
    BEGIN
        SET NOCOUNT ON;

        DECLARE @Id INT = CAST(RAND () * 10000000 AS INT);

        IF @Id % 12 = 0 EXEC dbo.usp_Q3160 @Id;
        ELSE IF @Id % 11 = 0 EXEC dbo.usp_Q36660 @Id;
        ELSE IF @Id % 10 = 0 EXEC dbo.usp_Q466 @Id;
        --ELSE IF @Id % 9 = 0
        --    EXEC dbo.usp_Q6627 @Id;
        ELSE IF @Id % 8 = 0 EXEC dbo.usp_Q6772 @Id;
        ELSE IF @Id % 7 = 0 EXEC dbo.usp_Q6856 @Id;
        ELSE IF @Id % 6 = 0 EXEC dbo.usp_Q7521 @Id;
        ELSE IF @Id % 5 = 0 EXEC dbo.usp_Q8116 @Id;
        ELSE IF @Id % 4 = 0 EXEC dbo.usp_Q947 @Id;
        ELSE IF @Id % 3 = 0 EXEC dbo.usp_Q949 @Id;
        ELSE IF @Id % 2 = 0 EXEC dbo.usp_Q952 @Id;
        ELSE EXEC dbo.usp_Q975 @Id;
    END;
GO

--EXEC dbo.usp_RandomQ;