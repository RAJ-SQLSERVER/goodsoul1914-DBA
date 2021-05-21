USE AdventureWorks2014;
GO


CREATE PROC usp_GetCustomerShipDates
(
    @ShipDateStart DATETIME,
    @ShipDateEnd DATETIME
)
AS
BEGIN
    SELECT CustomerID,
           SalesOrderNumber
    FROM Sales.SalesOrderHeader
    WHERE ShipDate
    BETWEEN @ShipDateStart AND @ShipDateEnd;
END;
GO


CREATE NONCLUSTERED INDEX IX_ShipDate_ASC
ON Sales.SalesOrderHeader (ShipDate);
GO


SET STATISTICS IO ON 
SET STATISTICS TIME ON
GO


DBCC FREEPROCCACHE
EXEC dbo.usp_GetCustomerShipDates '2011-07-08', '2014-01-01';
EXEC dbo.usp_GetCustomerShipDates '2011-07-10', '2011-07-20';

DBCC FREEPROCCACHE
EXEC dbo.usp_GetCustomerShipDates '2011-07-10', '2011-07-20';
EXEC dbo.usp_GetCustomerShipDates '2011-07-08', '2014-01-01';


-- option 1
-- RECOMPILE

DROP PROC dbo.usp_GetCustomerShipDates
GO

CREATE PROC usp_GetCustomerShipDates
(
    @ShipDateStart DATETIME,
    @ShipDateEnd DATETIME
)
WITH RECOMPILE
AS
BEGIN
    SELECT CustomerID,
           SalesOrderNumber
    FROM Sales.SalesOrderHeader
    WHERE ShipDate
    BETWEEN @ShipDateStart AND @ShipDateEnd;
END;
GO


-- option 2
-- Statement-level RECOMPILE

DROP PROC dbo.usp_GetCustomerShipDates
GO

CREATE PROC usp_GetCustomerShipDates
(
    @ShipDateStart DATETIME,
    @ShipDateEnd DATETIME
)
AS
BEGIN
    SELECT CustomerID,
           SalesOrderNumber
    FROM Sales.SalesOrderHeader
    WHERE ShipDate
    BETWEEN @ShipDateStart AND @ShipDateEnd
	OPTION (RECOMPILE)
END;
GO


-- option 3
-- Optimize for hint

DROP PROC dbo.usp_GetCustomerShipDates
GO

