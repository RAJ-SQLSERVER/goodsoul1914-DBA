/****************************
 Background type noise queries
****************************/
USE StackOverflow2013;
GO

CREATE OR ALTER PROC dbo.sp_GetTagsForUser @UserId INT
AS
    BEGIN
        SELECT TOP 10 COALESCE (p.Tags, pQ.Tags) AS "Tag",
                      SUM (p.Score) AS "TotalScore",
                      COUNT (*) AS "TotalPosts"
        FROM dbo.Users AS u
        INNER JOIN dbo.Posts AS p
            ON u.Id = p.OwnerUserId
        LEFT OUTER JOIN dbo.Posts AS pQ
            ON p.ParentId = pQ.Id
        WHERE u.Id = @UserId
        GROUP BY COALESCE (p.Tags, pQ.Tags)
        ORDER BY SUM (p.Score) DESC;
    END;
GO

/*************************************************************************
 Top Tags

 exec sp_ReportTopTags @StartDate = '2010-11-10', @EndDate = '2010-11-11';
*************************************************************************/
CREATE OR ALTER PROC dbo.sp_ReportTopTags @StartDate DATETIME,
                                          @EndDate   DATETIME,
                                          @SortOrder NVARCHAR(20) = 'Quantity'
AS
    BEGIN
        SELECT TOP 250 pQ.Tags,
                       COUNT (*) AS "TotalPosts",
                       SUM (pQ.Score + COALESCE (pA.Score, 0)) AS "TotalScore",
                       SUM (pQ.ViewCount) AS "TotalViewCount"
        FROM dbo.Posts AS pQ
        LEFT OUTER JOIN dbo.Posts AS pA
            ON pQ.Id = pA.ParentId -- Answers join up to questions on this 
        WHERE pQ.CreationDate >= @StartDate
              AND pQ.CreationDate < @EndDate
              AND pQ.PostTypeId = 1
        GROUP BY pQ.Tags
        ORDER BY CASE
                     WHEN @SortOrder = 'Quantity' THEN COUNT (*)
                     WHEN @SortOrder = 'Score' THEN SUM (pQ.Score + pA.Score)
                     WHEN @SortOrder = 'ViewCount' THEN SUM (pQ.ViewCount)
                     ELSE COUNT (*)
                 END DESC;
    END;
GO

/**************************************
 Questions w/most answers

 exec dbo.sp_ReportQuestionLeaderboard 
	@StartDate = '2010-05-01', 
	@EndDate = '2011-05-02', 
	@PostTypeName = 'Question'
**************************************/
CREATE OR ALTER PROC dbo.sp_ReportQuestionLeaderboard @StartDate    DATETIME,
                                                      @EndDate      DATETIME,
                                                      @PostTypeName VARCHAR(50)
AS
    BEGIN
        SELECT TOP 250 p.*
        FROM dbo.PostTypes AS pT
        INNER JOIN dbo.Posts AS p
            ON pT.Id = p.PostTypeId
        WHERE p.CreationDate >= @StartDate
              AND p.CreationDate < @EndDate
              AND pT.Type = @PostTypeName
        ORDER BY p.AnswerCount DESC;
    END;
GO

/************************************************
 How many of my questions have been answered

 exec sp_ReportQuestionsAnswered @UserId = 26837;
 exec sp_ReportQuestionsAnswered @UserId = 1256;
************************************************/
CREATE OR ALTER PROC dbo.sp_ReportQuestionsAnswered @UserId INT
AS
    BEGIN;
        WITH MyQuestions AS
        (
            SELECT pQ.Id AS "QuestionId",
                   pQ.AnswerCount
            FROM dbo.Users AS u
            INNER JOIN dbo.posts AS pQ
                ON u.Id = pQ.OwnerUserId -- My questions
            WHERE u.Id = @UserId
                  AND pQ.PostTypeId = 1 -- Questions only
        ),
             MyAggregates AS
        (
            SELECT COUNT (*) AS "MyQuestions",
                   SUM (CASE WHEN AnswerCount > 0 THEN 1 ELSE 0 END) AS "Answered"
            FROM MyQuestions
        )
        SELECT MyQuestions,
               Answered,
               100.0 * Answered / MyQuestions AS "AnsweredPercent"
        FROM MyAggregates;
    END;
GO

/***********************************************
 Top 10 people who have posted in the last week 

 exec sp_DashboardTop10Users;
***********************************************/
CREATE OR ALTER PROC dbo.sp_DashboardTop10Users @AsOf DATETIME = '2010-09-02'
AS
    BEGIN
        CREATE TABLE #RecentlyActiveUsers (Id INT, DisplayName NVARCHAR(40), Location NVARCHAR(100));

        INSERT INTO #RecentlyActiveUsers
        SELECT TOP 10 u.Id,
                      u.DisplayName,
                      u.Location
        FROM dbo.Users AS u
        WHERE EXISTS (
            SELECT *
            FROM dbo.Posts
            WHERE OwnerUserId = u.Id
                  AND CreationDate >= DATEADD (DAY, -7, @AsOf)
        )
        ORDER BY Reputation DESC;

        SELECT TOP 100 u.DisplayName,
                       u.Location,
                       pAnswer.Body,
                       pAnswer.Score,
                       pAnswer.CreationDate
        FROM #RecentlyActiveUsers AS u
        INNER JOIN dbo.Posts AS pAnswer
            ON u.Id = pAnswer.OwnerUserId
        WHERE pAnswer.CreationDate >= DATEADD (DAY, -7, @AsOf)
        ORDER BY pAnswer.CreationDate DESC;
    END;
GO

/********************************************************************************************************
 average answer response time

 exec sp_AverageAnswerTimeByTag @StartDate = '2009-01-01', @EndDate = '2011-01-01', @Tag = '<sql-server>'
********************************************************************************************************/
CREATE OR ALTER VIEW dbo.AverageAnswerResponseTime
AS
SELECT pQ.Id,
       pQ.Tags,
       pQ.CreationDate AS "QuestionDate",
       DATEDIFF (SECOND, pQ.CreationDate, pA.CreationDate) AS "ResponseTimeSeconds"
FROM dbo.Posts AS pQ
INNER JOIN dbo.Posts AS pA
    ON pQ.AcceptedAnswerId = pA.Id
WHERE pQ.PostTypeId = 1;
GO

CREATE OR ALTER PROC dbo.sp_AverageAnswerTimeByTag @StartDate DATETIME,
                                                   @EndDate   DATETIME,
                                                   @Tag       NVARCHAR(50)
AS
    BEGIN
        SELECT TOP 100 YEAR (QuestionDate) AS "QuestionYear",
                       MONTH (QuestionDate) AS "QuestionMonth",
                       AVG (ResponseTimeSeconds * 1.0) AS "AverageResponseTimeSeconds"
        FROM AverageAnswerResponseTime AS r
        WHERE r.QuestionDate >= @StartDate
              AND r.QuestionDate < @EndDate
              AND r.Tags = @Tag
        GROUP BY YEAR (QuestionDate),
                 MONTH (QuestionDate)
        ORDER BY YEAR (QuestionDate),
                 MONTH (QuestionDate);
    END;
GO

/**********************************************************************************************************
 Fastest answer 

 exec dbo.sp_ReportFastestAnswers @StartDate = '2008-01-01', @EndDate = '2011-01-01', @Tag = '<sql-server>'
**********************************************************************************************************/
CREATE OR ALTER PROC dbo.sp_ReportFastestAnswers @StartDate DATETIME,
                                                 @EndDate   DATETIME,
                                                 @Tag       NVARCHAR(50)
AS
    BEGIN
        SELECT TOP 10 r.QuestionDate,
                      r.ResponseTimeSeconds,
                      pQ.Title,
                      pQ.CreationDate,
                      pQ.Body,
                      uQ.DisplayName AS "QuestionerDisplayName",
                      uQ.Reputation AS "QuestionerReputation",
                      pA.Body AS "AnswerBody",
                      pA.Score AS "AnswerScore",
                      uA.DisplayName AS "Answerer_DisplayName",
                      uA.Reputation AS "Answerer_Reputation"
        FROM AverageAnswerResponseTime AS r
        INNER JOIN dbo.Posts AS pQ
            ON r.Id = pQ.Id
        INNER JOIN dbo.Users AS uQ
            ON pQ.OwnerUserId = uQ.Id
        INNER JOIN dbo.Posts AS pA
            ON pQ.AcceptedAnswerId = pA.Id
        INNER JOIN dbo.Users AS uA
            ON pA.OwnerUserId = uA.Id
        WHERE r.QuestionDate >= @StartDate
              AND r.QuestionDate < @EndDate
              AND r.Tags = @Tag
        ORDER BY r.ResponseTimeSeconds ASC;
    END;
GO


