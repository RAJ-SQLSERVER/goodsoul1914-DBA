/*

* How many times am I going to run it
* What time of day/week will it run
* Is it going to hold locksw while it runs
* Is the server doing mostly transactional work, or reporting

Duration:
* SET STATISTICS TIME ON
* CPU time
* Locks behind held, and for how long of the query

Reads:
* SET STATISTICS IO ON
* Do a count(*) to show that reads alone are okay

Memory grant:
* In dev environments look at Desired, can go up to 25% of production box
* Spills
* TempDB requirements (purposely creating temp tables)

*/

USE StackOverflow2013;
GO


EXEC dbo.DropIndexes;
GO


SET STATISTICS TIME, IO ON;
GO


SELECT TOP (100) p.Score,
                 p.Title,
                 p.Id AS "Questionid",
                 u.DisplayName
FROM dbo.Posts AS p
INNER JOIN dbo.PostTypes AS pt
    ON p.PostTypeId = pt.Id
INNER JOIN dbo.Users AS u
    ON p.OwnerUserId = u.Id
WHERE p.CreationDate >= '2010-01-01'
      AND p.CreationDate < '2010-02-01'
      AND pt.Type = 'Question'
ORDER BY p.Score DESC;
GO


SELECT TOP (100) p.Score,
                 p.Title,
                 p.Tags,
                 p.Id AS "Questionid",
                 u.DisplayName
FROM dbo.Posts AS p
INNER JOIN dbo.PostTypes AS pt
    ON p.PostTypeId = pt.Id
INNER JOIN dbo.Users AS u
    ON p.OwnerUserId = u.Id
WHERE p.Tags LIKE '%<sql-server>%'
      AND pt.Type = 'Question'
ORDER BY p.Score DESC;
GO


SELECT COUNT (*)
FROM dbo.Posts AS p;
GO


