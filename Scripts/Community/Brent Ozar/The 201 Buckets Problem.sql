/*
 The 201 Buckets Problem
*/

-- There are about 300,000 Users
USE StackOverflow2013;
GO

CREATE INDEX Location ON dbo.Users (location);
GO

SELECT COUNT (*)
FROM dbo.Users;
GO

-- You can see the statistics with DBCC SHOW_STATISTICS
DBCC SHOW_STATISTICS('dbo.Users', 'Location');
GO

-- Because Ahmadabad is an outlier, and it has its own bucket
SELECT *
FROM dbo.Users
WHERE Location = N'Ahmadabad, India'
ORDER BY DisplayName;

-- I�m getting an estimate of just 10 rows when there are actually 99 Floridians.
-- Miami, FL isn�t big enough to be one of the 201 outliers featured in the statistics buckets, 
-- but it�s large enough that it has a relatively unusual number of people
SELECT *
FROM dbo.Users
WHERE Location = N'Miami, FL'
ORDER BY DisplayName
OPTION (RECOMPILE);

-- Will updating statistics fix this?
UPDATE STATISTICS dbo.Users
WITH FULLSCAN;
GO

-- It still produces the same stats
DBCC SHOW_STATISTICS('dbo.Users', 'Location');
GO

-- No matter how many times you update stats, there are still just only 201 buckets max, 
-- and Miami doesn't have enough data to be one of those outliers. To find similar locations, 
-- do a TOP 1000, and the folks in the 200-1000 range are probably going to be your outliers 
-- that get bad estimates:
SELECT TOP 1000 Location,
                COUNT (*) AS "recs"
FROM dbo.Users
GROUP BY Location
ORDER BY COUNT (*) DESC;

-- How Bad Estimates Backfire As Your Data Grows
