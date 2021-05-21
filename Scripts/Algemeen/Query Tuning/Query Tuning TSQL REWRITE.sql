-- OVER Clause

SET NOCOUNT ON;
USE pubs;
GO

-- remembering subqueries....
-- the original problem: calculate two aggregates for each sales row:
--	- the percentage the row contributed to the total sales quantity
--	- the difference between the row's sales quantity and the average quantity over all sales
SELECT stor_id,
       ord_num,
       title_id,
       CONVERT(VARCHAR(10), ord_date, 120) AS ord_date,
       qty,
       CAST(1. * qty / (SELECT SUM(qty) FROM dbo.sales) * 100 AS DECIMAL(5, 2)) AS per,
       CAST(qty - (SELECT AVG(qty) FROM dbo.sales) AS DECIMAL(9, 2)) AS diff
FROM dbo.sales;
GO

-- obtaining aggregates with CROSS JOIN
SELECT s.stor_id,
       s.ord_num,
       s.title_id,
       CONVERT(VARCHAR(10), ord_date, 120) AS ord_date,
       s.qty,
       CAST(1.0 * s.qty / AGG.sumqty * 100 AS DECIMAL(5, 2)) AS per,
       CAST(s.qty - AGG.avgqty AS DECIMAL(9, 2)) AS diff
FROM dbo.sales s ,
(
    SELECT SUM(qty) AS sumqty,
           AVG(1.0 * qty) AS avgqty
    FROM dbo.sales
) AS AGG;

-- obtaining aggregates with OVER clause
-- calculate multiple aggregates using the same OVER clause
-- SQL Server will scan the required source data only once for all
SELECT stor_id,
       ord_num,
       title_id,
       CONVERT(VARCHAR(10), ord_date, 120) AS ord_date,
       qty,
       CAST(1. * qty / SUM(qty) OVER() * 100 AS DECIMAL(5, 2)) AS per,
       CAST(qty - AVG(qty) OVER() AS DECIMAL(9, 2)) AS diff
FROM dbo.sales;
GO


-- comparing single and multiple aggregates using subqueries
SELECT stor_id,
       ord_num,
       title_id,
       (SELECT SUM(qty) FROM dbo.sales) AS sumqty
FROM dbo.sales;
GO

-- comparing single and multiple aggregates using OVER clause
SELECT stor_id,
       ord_num,
       title_id,
       SUM(qty) OVER() AS sumqty
FROM dbo.sales;
GO


-- this query rescans our source data for each aggregate
SELECT stor_id,
       ord_num,
       title_id,
       (SELECT SUM(qty) FROM dbo.sales) AS sumqty,
       (SELECT COUNT(qty) FROM dbo.sales) AS cntqty,
       (SELECT AVG(qty) FROM dbo.sales) AS avgqty,
       (SELECT MIN(qty) FROM dbo.sales) AS minqty,
       (SELECT MAX(qty) FROM dbo.sales) AS maxqty
FROM dbo.sales;
GO

-- this one does the scan once!
SELECT stor_id,
       ord_num,
       title_id,
       SUM(qty) OVER() AS sumqty,
       COUNT(qty) OVER() AS cntqty,
       AVG(qty) OVER() AS avgqty,
       MIN(qty) OVER() AS minqty,
       MAX(qty) OVER() AS maxqty
FROM dbo.sales;
GO

