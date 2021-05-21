USE AdventureWorks2017;
GO

IF EXISTS
(
    SELECT *
    FROM sys.stats
    WHERE object_id = OBJECT_ID('Sales.SalesOrderHeader')
          AND name = 'TotalDue'
)
    DROP STATISTICS Sales.SalesOrderHeader.TotalDue;
GO

-- first observe the rows
SELECT *
FROM Sales.SalesOrderHeader
GO

-- create a statistic
CREATE STATISTICS TotalDue ON Sales.SalesOrderHeader(TotalDue)
GO

DBCC SHOW_STATISTICS(N'Sales.SalesOrderHeader', TotalDue)
GO
/*
RANGE_HI_KEY	RANGE_ROWS	EQ_ROWS	DISTINCT_RANGE_ROWS	AVG_RANGE_ROWS
1.5183			0			1		0					1
2.5305			0			139		0					1
4.409			2			95		1					2
5.514			0			576		0					1
6.9394			1			137		1					1
8.0444			0			359		0					1
8.7848			0			87		0					1
9.934			0			186		0					1
11.039			0			77		0					1
14.2987			38			58		5					7.6
15.4479			21			201		1					21
...
*/

-- verification queries

-- RANGE_ROWS
SELECT COUNT(*) FROM Sales.SalesOrderHeader
WHERE TotalDue > 11.039 AND TotalDue < 14.2987
GO -- 38

-- EQ_ROWS
SELECT COUNT (*) FROM Sales.SalesOrderHeader
WHERE TotalDue = 2.5305
GO -- 139

-- DISTINCT_RANGE_ROWS
SELECT DISTINCT TotalDue FROM Sales.SalesOrderHeader
WHERE TotalDue > 11.039 AND TotalDue < 14.2987
GO -- 5
/*
TotalDue
11,3152
12,0152
12,6968
13,1937
13,7166
*/

-- AVG_RANGE_ROWS (Use CTRL + M)
SELECT COUNT (*) FROM Sales.SalesOrderHeader
WHERE TotalDue = 12.04
GO
/*
Estimated number of rows per execution = 7.6 
*/

