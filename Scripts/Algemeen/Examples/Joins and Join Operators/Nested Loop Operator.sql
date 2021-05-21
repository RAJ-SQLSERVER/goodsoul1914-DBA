USE AdventureWorks2017;
GO

-- ===================================================
-- Demonstrates the semantics of Nested Loop Operator
-- ===================================================
/*********************
	A:	3, 4, 2, 1, 5, 2
		>
	B:	5, 7, 6, 2, 1, 3
		--------------->	3

	A:	3, 4, 2, 1, 5, 2
		--->
	B:	5, 7, 6, 2, 1, 3
		--------------->	

	A:	3, 4, 2, 1, 5, 2
		------>
	B:	5, 7, 6, 2, 1, 3
		--------->----->	2

	A:	3, 4, 2, 1, 5, 2
		--------->
	B:	5, 7, 6, 2, 1, 3
		------------>-->	1

	A:	3, 4, 2, 1, 5, 2
		------------>
	B:	5, 7, 6, 2, 1, 3
		>-------------->	5

	A:	3, 4, 2, 1, 5, 2
		--------------->
	B:	5, 7, 6, 2, 1, 3
		--------->------>	2

	Result: 3, 2, 1, 5, 2
*********************/
-- Demonstrate the Nested Loop Operator when joining 2 tables
SELECT soh.*,
	d.*
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS d ON d.SalesOrderID = soh.SalesOrderID
WHERE soh.SalesOrderID = 71832;
GO

-- Demonstrate the Nested Loop Operator when performing a Bookmark Lookup (Key Lookup)
SELECT EmailAddressID,
	EmailAddress,
	ModifiedDate
FROM Person.EmailAddress
WHERE EmailAddress LIKE 'sab%';
GO

-- When performing a join against a Table Variable, the Table Variable
-- is always chosen as the outer table
DECLARE @tempTable TABLE (
	ID INT identity(1, 1) PRIMARY KEY,
	FirstName CHAR(4000),
	LastName CHAR(4000)
	);

INSERT INTO @tempTable (
	FirstName,
	LastName
	)
SELECT TOP 20000 name,
	name
FROM master.dbo.syscolumns;

-- The physical join operator will be a Nested Loop,
-- because a Nested Loop is optimized for 1 row in the outer loop
SELECT *
FROM Person.Person AS p
INNER JOIN @tempTable AS t ON t.ID = p.BusinessEntityID;
GO

-- We can fix that bahavior by using the query hint OPTION (RECOMPILE).
-- Therefore the Query Optimizer knows how many records
-- are stored in the Table Variable and can choose
-- the correct physical join operator - Merge Join - in our case
DECLARE @tempTable TABLE (
	ID INT identity(1, 1) PRIMARY KEY,
	FirstName CHAR(4000),
	LastName CHAR(4000)
	);

INSERT INTO @tempTable (
	FirstName,
	LastName
	)
SELECT TOP 20000 name,
	name
FROM master.dbo.syscolumns;

SELECT *
FROM Person.Person AS p
INNER JOIN @tempTable AS t ON t.ID = p.BusinessEntityID
OPTION (RECOMPILE);
GO


