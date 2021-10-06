-- Setup the demo by creating a stored procedure designed to recompile frequently
USE [AdventureWorks2012]
GO
IF OBJECT_ID('AnnualTop5SalesPersonByMonthlyPercent') IS NOT NULL
	DROP PROCEDURE [dbo].[AnnualTop5SalesPersonByMonthlyPercent];
GO
CREATE PROCEDURE [dbo].[AnnualTop5SalesPersonByMonthlyPercent] (@Year INT)
AS
BEGIN
	CREATE TABLE [tempdb].[dbo].[MonthlyTotals] 
	(MonthNumber INT PRIMARY KEY, 
	 TotalSales DECIMAL(18,2));
	
	INSERT INTO [tempdb].[dbo].[MonthlyTotals] 
	(MonthNumber, TotalSales)
	SELECT 
		(DATEPART(YEAR, OrderDate)*100)+DATEPART(MONTH, OrderDate), 
		SUM(TotalDue)
	FROM [Sales].[SalesOrderHeader]
	WHERE SalesPersonID IS NOT NULL
		AND DATEPART(YEAR, OrderDate) = @Year
	GROUP BY (DATEPART(YEAR, OrderDate)*100)+DATEPART(MONTH, OrderDate);
	
	CREATE TABLE [tempdb].[dbo].[EmpSalesPercentByMonth]
	(SalesPersonID INT, 
	 MonthNumber INT, 
	 TotalSales DECIMAL(18,2), 
	 PercentMonthTotal DECIMAL(18,2));
	
	INSERT INTO [tempdb].[dbo].[EmpSalesPercentByMonth] 
	(SalesPersonID, 
	 MonthNumber, 
	 TotalSales)
	SELECT 
		SalesPersonID, 
		(DATEPART(YEAR, OrderDate)*100)+DATEPART(MONTH, OrderDate), 
		SUM(TotalDue)
	FROM [Sales].[SalesOrderHeader]
	WHERE SalesPersonID IS NOT NULL
		AND DATEPART(YEAR, OrderDate) = @Year	
	GROUP BY 
		SalesPersonID, 
		(DATEPART(YEAR, OrderDate)*100)+DATEPART(MONTH, OrderDate);

	CREATE CLUSTERED INDEX [IX_EmpSalesPercentByMonth_MonthNumber]
	ON [tempdb].[dbo].[EmpSalesPercentByMonth] (MonthNumber)

	UPDATE [tempdb].[dbo].[EmpSalesPercentByMonth]
	SET PercentMonthTotal = espbm.TotalSales/mt.TotalSales
	FROM [tempdb].[dbo].[EmpSalesPercentByMonth] AS espbm
	JOIN [tempdb].[dbo].[MonthlyTotals] AS mt
		ON espbm.MonthNumber = mt.MonthNumber;
	
	DROP TABLE [tempdb].[dbo].[MonthlyTotals];
	
	SELECT TOP 5 * 
	FROM [tempdb].[dbo].[EmpSalesPercentByMonth]
	ORDER BY PercentMonthTotal DESC;
	
	DROP TABLE [tempdb].[dbo].[EmpSalesPercentByMonth];
END;

GO

