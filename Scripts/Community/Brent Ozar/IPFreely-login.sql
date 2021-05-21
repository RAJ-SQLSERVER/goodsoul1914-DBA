-- Execute this code as IPFreely

USE StackOverflow2010
GO

SELECT COUNT_BIG(*)
FROM dbo.Posts p
    CROSS JOIN dbo.Votes v;
GO 10
