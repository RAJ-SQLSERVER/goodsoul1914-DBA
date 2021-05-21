USE WideWorldImporters;
GO

-- create a copy of sales.customers
SELECT *
INTO Sales.Customers2
FROM Sales.Customers;
GO

-- create a clustered index on customer_id
CREATE CLUSTERED INDEX ix_CustomerID ON Sales.Customers2 (CustomerID);
GO

-- create a nonclustered index on customername
CREATE NONCLUSTERED INDEX ix_CustomerName
ON Sales.Customers2 (CustomerName);
GO

-- simulate user 1
-- runs a select operation in an endless loop
WHILE 1 = 1
SELECT WebsiteURL
FROM Sales.Customers2
WHERE CustomerName = 'Tailspin Toys (Head Office)';

-- simulate user 2 (another window)
-- runs an update operation in an endless loop
-- dirty code!
USE WideWorldImporters
GO
BEGIN
    DECLARE @varname VARCHAR(100);
    WHILE 1 = 1
    BEGIN
        SET @varname =
        (
            SELECT CustomerName FROM Sales.Customers2 WHERE CustomerID = 1
        );
        IF @varname = 'Tailspin Toys (Head Office)'
        BEGIN
            UPDATE Sales.Customers2
            SET CustomerName = 'Tailspin Toys (Head Office) 2'
            WHERE CustomerID = 1;
        END
		ELSE
        BEGIN
			UPDATE Sales.Customers2
            SET CustomerName = 'Tailspin Toys (Head Office)'
            WHERE CustomerID = 1;
		END
    END;
END;

