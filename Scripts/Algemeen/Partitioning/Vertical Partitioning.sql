/*
 Vertical Partitioning

 Vertical table partitioning is mostly used to increase SQL Server performance 
 especially in cases where a query retrieves all columns from a table that contains 
 a number of very wide text or BLOB columns. In this case to reduce access times the 
 BLOB columns can be split to its own table. Another example is to restrict access 
 to sensitive data e.g. passwords, salary information etc. 
*/
/*
 Create a sample table
*/
CREATE TABLE EmployeeReports (
	ReportID INT IDENTITY(1, 1) NOT NULL,
	ReportName VARCHAR(100),
	ReportNumber VARCHAR(20),
	ReportDescription VARCHAR(MAX) CONSTRAINT EReport_PK PRIMARY KEY CLUSTERED (ReportID)
	);

DECLARE @i INT;
SET @i = 1;

BEGIN TRAN;

WHILE @i < 100000
BEGIN
	INSERT INTO EmployeeReports (
		ReportName,
		ReportNumber,
		ReportDescription
		)
	VALUES (
		'ReportName',
		CONVERT(VARCHAR(20), @i),
		REPLICATE('Report', 1000)
		);

	SET @i = @i + 1;
END;

COMMIT TRAN;
GO

/*
 Select some data
*/
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT er.ReportID,
	er.ReportName,
	er.ReportNumber
FROM dbo.EmployeeReports er
WHERE er.ReportNumber LIKE '%33%';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

--Table 'EmployeeReports'. Scan count 5, logical reads 107016, physical reads 0
--
--SQL Server Execution Times:
--   CPU time = 201 ms,  elapsed time = 879 ms.
/*
 To reduce the cost of the query we will change the SQL Server database schema and 
 split the EmployeeReports table vertically.
 Next we'll create the ReportsDesc table and move the large ReportDescription column, 
 and the ReportsData table and move all data from the EmployeeReports table except 
 the ReportDescription column:
*/
CREATE TABLE ReportsDesc (
	ReportID INT FOREIGN KEY REFERENCES EmployeeReports(ReportID),
	ReportDescription VARCHAR(MAX) CONSTRAINT PK_ReportDesc PRIMARY KEY CLUSTERED (ReportID)
	);

CREATE TABLE ReportsData (
	ReportID INT NOT NULL,
	ReportName VARCHAR(100),
	ReportNumber VARCHAR(20),
	CONSTRAINT DReport_PK PRIMARY KEY CLUSTERED (ReportID)
	);

INSERT INTO dbo.ReportsData (
	ReportID,
	ReportName,
	ReportNumber
	)
SELECT er.ReportID,
	er.ReportName,
	er.ReportNumber
FROM dbo.EmployeeReports er;

/*
 Select same data
*/
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT er.ReportID,
	er.ReportName,
	er.ReportNumber
FROM ReportsData er
WHERE er.ReportNumber LIKE '%33%';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
	--Table 'ReportsData'. Scan count 1, logical reads 421, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
	--
	--SQL Server Execution Times:
	--   CPU time = 15 ms,  elapsed time = 461 ms.
