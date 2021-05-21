/*
	https://sqlperformance.com/2014/10/t-sql-queries/performance-tuning-whole-plan
*/

USE Playground
GO

CREATE TABLE dbo.Test
(
    data INTEGER NOT NULL,
);
GO

CREATE CLUSTERED INDEX cx ON dbo.Test (data);
GO


INSERT dbo.Test WITH (TABLOCK)
(
    data
)
SELECT TOP (10000000)
       (ROW_NUMBER() OVER (ORDER BY (SELECT 0)) % 1000) + 1
FROM master.sys.columns AS C1 WITH (READUNCOMMITTED)
    CROSS JOIN master.sys.columns AS C2 WITH (READUNCOMMITTED)
    CROSS JOIN master.sys.columns C3 WITH (READUNCOMMITTED);
GO


-- Avoiding the SORT:
-- TF8795 sets the DML Request Sort property to false, so rows are no longer required 
-- to arrive at the Clustered Index Insert in clustered key order
TRUNCATE TABLE dbo.Test;
GO
INSERT dbo.Test WITH (TABLOCK)
(
    data
)
SELECT TOP (10000000)
       ROW_NUMBER() OVER (ORDER BY (SELECT 0)) % 1000
FROM master.sys.columns AS C1 WITH (READUNCOMMITTED)
    CROSS JOIN master.sys.columns AS C2 WITH (READUNCOMMITTED)
    CROSS JOIN master.sys.columns C3 WITH (READUNCOMMITTED)
OPTION (QUERYTRACEON 8795);
GO


-- Avoiding the Sort II
TRUNCATE TABLE dbo.Test;
GO
INSERT dbo.Test WITH (TABLOCK)
(
    data
)
SELECT N.number
FROM
(
    SELECT SV.number
    FROM master.dbo.spt_values AS SV WITH (READUNCOMMITTED)
    WHERE SV.[type] = N'P'
          AND SV.number >= 1
          AND SV.number <= 1000
) AS N
    CROSS JOIN
    (
        SELECT TOP (10000)
               Dummy = NULL
        FROM master.sys.columns AS C1 WITH (READUNCOMMITTED)
            CROSS JOIN master.sys.columns AS C2 WITH (READUNCOMMITTED)
            CROSS JOIN master.sys.columns C3 WITH (READUNCOMMITTED)
    ) AS C;
GO


-- Avoiding the Sort Finally!
TRUNCATE TABLE dbo.Test;
GO
INSERT dbo.Test WITH (TABLOCK)
(
    data
)
SELECT N.number
FROM
(
    SELECT SV.number
    FROM master.dbo.spt_values AS SV WITH (READUNCOMMITTED)
    WHERE SV.[type] = N'P'
          AND SV.number >= 1
          AND SV.number <= 1000
) AS N
    CROSS JOIN
    (
        SELECT TOP (10000)
               Dummy = NULL
        FROM master.sys.columns AS C1 WITH (READUNCOMMITTED)
            CROSS JOIN master.sys.columns AS C2 WITH (READUNCOMMITTED)
            CROSS JOIN master.sys.columns C3 WITH (READUNCOMMITTED)
    ) AS C
OPTION (FORCE ORDER);
GO


-- Finding the Distinct Values
SELECT DISTINCT
       data
FROM dbo.Test WITH (TABLOCK)
OPTION (MAXDOP 1);
GO


-- A Better Algorithm
WITH RecursiveCTE
AS (
   -- Anchor
   SELECT data = MIN(T.data)
   FROM dbo.Test AS T
   UNION ALL

   -- Recursive
   SELECT MIN(T.data)
   FROM dbo.Test AS T
       JOIN RecursiveCTE AS R
           ON R.data < T.data)
SELECT data
FROM RecursiveCTE
OPTION (MAXRECURSION 0);
GO

-- Attempt 2
WITH RecursiveCTE
AS (
   -- Anchor
   SELECT TOP (1)
          T.data
   FROM dbo.Test AS T
   ORDER BY T.data
   UNION ALL

   -- Recursive
   SELECT TOP (1)
          T.data
   FROM dbo.Test AS T
       JOIN RecursiveCTE AS R
           ON R.data < T.data
   ORDER BY T.data)
SELECT data
FROM RecursiveCTE
OPTION (MAXRECURSION 0);
GO

-- Attempt 3
WITH RecursiveCTE
AS (
   -- Anchor
   SELECT TOP (1)
          data
   FROM dbo.Test AS T
   ORDER BY T.data
   UNION ALL

   -- Recursive
   SELECT R.data
   FROM
   (
       -- Number the rows
       SELECT T.data,
              rn = ROW_NUMBER() OVER (ORDER BY T.data)
       FROM dbo.Test AS T
           JOIN RecursiveCTE AS R
               ON R.data < T.data
   ) AS R
   WHERE
       -- Only the row that sorts lowest
       R.rn = 1)
SELECT data
FROM RecursiveCTE
OPTION (MAXRECURSION 0);
GO

