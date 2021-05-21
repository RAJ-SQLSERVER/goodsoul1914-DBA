USE DBA
GO

-- prevent set or regional settings from interfering with 
-- interpretation of dates / literals
SET DATEFIRST 7, -- 1 = Monday, 7 = Sunday
DATEFORMAT MDY, LANGUAGE US_ENGLISH;
-- assume the above is here in all subsequent code blocks.

DECLARE @StartDate DATE = '20100101';

DECLARE @CutoffDate DATE = DATEADD (DAY, -1, DATEADD (YEAR, 30, @StartDate));

;WITH seq (n) AS
(
    SELECT 0
    UNION ALL
    SELECT n + 1
    FROM seq
    WHERE n < DATEDIFF (DAY, @StartDate, @CutoffDate)
),
      d (d) AS (SELECT DATEADD (DAY, n, @StartDate) FROM seq),
      src AS
(
    SELECT CONVERT (DATE, d) AS "TheDate",
           DATEPART (DAY, d) AS "TheDay",
           DATENAME (WEEKDAY, d) AS "TheDayName",
           DATEPART (WEEK, d) AS "TheWeek",
           DATEPART (ISO_WEEK, d) AS "TheISOWeek",
           DATEPART (WEEKDAY, d) AS "TheDayOfWeek",
           DATEPART (MONTH, d) AS "TheMonth",
           DATENAME (MONTH, d) AS "TheMonthName",
           DATEPART (QUARTER, d) AS "TheQuarter",
           DATEPART (YEAR, d) AS "TheYear",
           DATEFROMPARTS (YEAR (d), MONTH (d), 1) AS "TheFirstOfMonth",
           DATEFROMPARTS (YEAR (d), 12, 31) AS "TheLastOfYear",
           DATEPART (DAYOFYEAR, d) AS "TheDayOfYear"
    FROM d
),
      dim AS
(
    SELECT TheDate,
           TheDay,
           CONVERT (CHAR(2),
                    CASE
                        WHEN TheDay / 10 = 1 THEN 'th'
                        ELSE CASE RIGHT(TheDay, 1)
                                 WHEN '1' THEN 'st'
                                 WHEN '2' THEN 'nd'
                                 WHEN '3' THEN 'rd'
                                 ELSE 'th'
                             END
                    END
           ) AS "TheDaySuffix",
           TheDayName,
           TheDayOfWeek,
           CONVERT (TINYINT,
                    ROW_NUMBER () OVER (PARTITION BY TheFirstOfMonth, TheDayOfWeek
ORDER BY TheDate
                                  )
           ) AS "TheDayOfWeekInMonth",
           TheDayOfYear,
           CASE
               WHEN TheDayOfWeek IN ( CASE @@DATEFIRST WHEN 1 THEN 6 WHEN 7 THEN 1 END, 7 ) THEN 1
               ELSE 0
           END AS "IsWeekend",
           TheWeek,
           TheISOWeek,
           DATEADD (DAY, 1 - TheDayOfWeek, TheDate) AS "TheFirstOfWeek",
           DATEADD (DAY, 6, DATEADD (DAY, 1 - TheDayOfWeek, TheDate)) AS "TheLastOfWeek",
           CONVERT (TINYINT,
                    DENSE_RANK () OVER (PARTITION BY TheYear, TheMonth
ORDER BY TheWeek
                                  )
           ) AS "TheWeekOfMonth",
           TheMonth,
           TheMonthName,
           TheFirstOfMonth,
           MAX (TheDate) OVER (PARTITION BY TheYear, TheMonth) AS "TheLastOfMonth",
           DATEADD (MONTH, 1, TheFirstOfMonth) AS "TheFirstOfNextMonth",
           DATEADD (DAY, -1, DATEADD (MONTH, 2, TheFirstOfMonth)) AS "TheLastOfNextMonth",
           TheQuarter,
           MIN (TheDate) OVER (PARTITION BY TheYear, TheQuarter) AS "TheFirstOfQuarter",
           MAX (TheDate) OVER (PARTITION BY TheYear, TheQuarter) AS "TheLastOfQuarter",
           TheYear,
           TheYear - CASE
                         WHEN TheMonth = 1
                              AND TheISOWeek > 51 THEN 1
                         WHEN TheMonth = 12
                              AND TheISOWeek = 1 THEN -1
                         ELSE 0
                     END AS "TheISOYear",
           DATEFROMPARTS (TheYear, 1, 1) AS "TheFirstOfYear",
           TheLastOfYear,
           CONVERT (BIT,
                    CASE
                        WHEN (TheYear % 400 = 0)
                             OR (TheYear % 4 = 0 AND TheYear % 100 <> 0) THEN 1
                        ELSE 0
                    END
           ) AS "IsLeapYear",
           CASE
               WHEN DATEPART (ISO_WEEK, TheLastOfYear) = 53 THEN 1
               ELSE 0
           END AS "Has53Weeks",
           CASE
               WHEN DATEPART (WEEK, TheLastOfYear) = 53 THEN 1
               ELSE 0
           END AS "Has53ISOWeeks",
           CONVERT (CHAR(2), CONVERT (CHAR(8), TheDate, 101)) + CONVERT (CHAR(4), TheYear) AS "MMYYYY",
           CONVERT (CHAR(10), TheDate, 101) AS "Style101",
           CONVERT (CHAR(10), TheDate, 103) AS "Style103",
           CONVERT (CHAR(8), TheDate, 112) AS "Style112",
           CONVERT (CHAR(10), TheDate, 120) AS "Style120"
    FROM src
)
--SELECT *
--FROM dim
--ORDER BY TheDate
--OPTION (MAXRECURSION 0);
SELECT *
INTO dbo.DateDimension
FROM dim 
OPTION (MAXRECURSION 0);

CREATE UNIQUE CLUSTERED INDEX PK_DateDimension ON dbo.DateDimension(TheDate);

