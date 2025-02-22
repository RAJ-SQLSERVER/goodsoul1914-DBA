USE [Master];

CREATE DATABASE [tsql2012];
GO

USE [tsql2012];

-- Table to be used by Over Clause Rows/Range
CREATE TABLE REVENUE (
	[DepartmentID] INT
	,[Revenue] INT
	,[Year] INT
	);

INSERT INTO REVENUE
VALUES (
	1
	,10030
	,1998
	)
	,(
	2
	,20000
	,1998
	)
	,(
	3
	,40000
	,1998
	)
	,(
	1
	,20000
	,1999
	)
	,(
	2
	,60000
	,1999
	)
	,(
	3
	,50000
	,1999
	)
	,(
	1
	,40000
	,2000
	)
	,(
	2
	,40000
	,2000
	)
	,(
	3
	,60000
	,2000
	)
	,(
	1
	,30000
	,2001
	)
	,(
	2
	,30000
	,2001
	)
	,(
	3
	,70000
	,2001
	)
	,(
	1
	,90000
	,2002
	)
	,(
	2
	,20000
	,2002
	)
	,(
	3
	,80000
	,2002
	)
	,(
	1
	,10300
	,2003
	)
	,(
	2
	,1000
	,2003
	)
	,(
	3
	,90000
	,2003
	)
	,(
	1
	,10000
	,2004
	)
	,(
	2
	,10000
	,2004
	)
	,(
	3
	,10000
	,2004
	)
	,(
	1
	,20000
	,2005
	)
	,(
	2
	,20000
	,2005
	)
	,(
	3
	,20000
	,2005
	)
	,(
	1
	,40000
	,2006
	)
	,(
	2
	,30000
	,2006
	)
	,(
	3
	,30000
	,2006
	)
	,(
	1
	,70000
	,2007
	)
	,(
	2
	,40000
	,2007
	)
	,(
	3
	,40000
	,2007
	)
	,(
	1
	,50000
	,2008
	)
	,(
	2
	,50000
	,2008
	)
	,(
	3
	,50000
	,2008
	)
	,(
	1
	,20000
	,2009
	)
	,(
	2
	,60000
	,2009
	)
	,(
	3
	,60000
	,2009
	)
	,(
	1
	,30000
	,2010
	)
	,(
	2
	,70000
	,2010
	)
	,(
	3
	,70000
	,2010
	)
	,(
	1
	,80000
	,2011
	)
	,(
	2
	,80000
	,2011
	)
	,(
	3
	,80000
	,2011
	)
	,(
	1
	,10000
	,2012
	)
	,(
	2
	,90000
	,2012
	)
	,(
	3
	,90000
	,2012
	);

--First OVER Clause pre SQL 2012
-- http://stevestedman.com/?p=1454
SELECT *
	,avg(Revenue) OVER (PARTITION BY DepartmentID) AS AverageRevenue
	,sum(Revenue) OVER (PARTITION BY DepartmentID) AS TotalRevenue
FROM REVENUE
ORDER BY departmentID
	,year;

--ROWS PRECEDING
SELECT Year
	,DepartmentID
	,Revenue
	,sum(Revenue) OVER (
		PARTITION BY DepartmentID ORDER BY [YEAR] ROWS BETWEEN 3 PRECEDING
				AND CURRENT ROW
		) AS Prev3
FROM REVENUE
ORDER BY departmentID
	,year;

-- ROWS FOLLOWING
SELECT Year
	,DepartmentID
	,Revenue
	,sum(Revenue) OVER (
		PARTITION BY DepartmentID ORDER BY [YEAR] ROWS BETWEEN CURRENT ROW
				AND 3 FOLLOWING
		) AS Next3
FROM REVENUE
ORDER BY departmentID
	,year;

