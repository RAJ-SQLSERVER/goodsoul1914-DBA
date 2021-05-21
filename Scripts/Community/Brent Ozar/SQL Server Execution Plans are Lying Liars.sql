USE StackOverflow2010;
GO

SET STATISTICS TIME ON;
GO

-------------------------------------------------------------------------------
-- Create the function
-------------------------------------------------------------------------------

CREATE OR ALTER FUNCTION dbo.fnGetPostType (@PostTypeId INT)
RETURNS NVARCHAR(50)
WITH RETURNS NULL ON NULL INPUT, SCHEMABINDING
AS
    BEGIN
        DECLARE @PostType NVARCHAR(50);
        SELECT @PostType = Type
        FROM dbo.PostTypes
        WHERE Id = @PostTypeId;

        IF @PostType IS NULL SET @PostType = N'Unknown';
        RETURN @PostType;
    END;
GO

-------------------------------------------------------------------------------
-- Query #1
-------------------------------------------------------------------------------

SELECT u.AboutMe,
       c.Text,
       p.Body,
       b.Name,
       v.BountyAmount
FROM dbo.Users AS u
CROSS JOIN dbo.Posts AS p
CROSS JOIN dbo.Comments AS c
CROSS JOIN dbo.Badges AS b
CROSS JOIN dbo.Votes AS v
WHERE u.Reputation + u.UpVotes < 0
ORDER BY u.AboutMe,
         c.Text,
         p.Body,
         b.Name,
         v.BountyAmount;
GO

-------------------------------------------------------------------------------
-- Query #2
--
-- * Arrows show the actual number of rows read
-- * Missing index only shows the first available (there may be more)
-- * Type conversion warning on SELECT statement while going out the door!
-------------------------------------------------------------------------------

SELECT p.Title AS "QuestionTitle",
       dbo.fnGetPostType (p.PostTypeId) AS "PostType", -- Makes query go single-threaded!!!
       c.CreationDate,
       c.Score,
       c.Text,
       CAST(p.CreationDate AS NVARCHAR(50)) AS "QuestionDate"
FROM dbo.Users AS u
LEFT OUTER JOIN dbo.Comments AS c
    ON u.Id = c.UserId
LEFT OUTER JOIN dbo.Posts AS p
    ON c.PostId = p.ParentId
WHERE u.DisplayName = N'Brent Ozar';
GO

-------------------------------------------------------------------------------
-- sp_BlitzCache
-------------------------------------------------------------------------------

EXEC master.dbo.sp_BlitzCache;
GO
