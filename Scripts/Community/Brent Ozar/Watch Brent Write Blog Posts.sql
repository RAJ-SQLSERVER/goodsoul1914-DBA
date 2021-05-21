-- 
CREATE NONCLUSTERED INDEX index1 ON dbo.Users (CreationDate);
GO

-- 
SET STATISTICS IO, TIME ON;

/* With date table: */
SELECT d.day_name,
       COUNT (*) AS "recs"
FROM dbo.Users AS u
JOIN dbo.date_calendar AS d
    ON CAST(u.CreationDate AS DATE) = d.calendar_date
GROUP BY d.day_name
ORDER BY COUNT (*) DESC;


/* Old-school: */
SELECT DATENAME (WEEKDAY, u.CreationDate) AS "WeekDay",
       COUNT (*) AS "recs"
FROM dbo.Users AS u
GROUP BY DATENAME (WEEKDAY, u.CreationDate)
ORDER BY COUNT (*) DESC;

