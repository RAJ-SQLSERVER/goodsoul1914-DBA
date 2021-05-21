
-------------------------------------------------------------------------------
-- Setup
-------------------------------------------------------------------------------

CREATE DATABASE TestDB;
GO

USE TestDB;
GO 

CREATE SCHEMA Inventory;
GO 
 
CREATE TABLE Inventory.ItemQuantity 
(
    ItemID int NOT NULL,
    ItemsInStock int NOT NULL,
    CONSTRAINT PK_ItemQuantity PRIMARY KEY CLUSTERED (ItemID)
);
GO 
 
INSERT INTO Inventory.ItemQuantity (ItemID, ItemsInStock) VALUES (1, 5);
INSERT INTO Inventory.ItemQuantity (ItemID, ItemsInStock) VALUES (2, 15);
INSERT INTO Inventory.ItemQuantity (ItemID, ItemsInStock) VALUES (3, 25);
INSERT INTO Inventory.ItemQuantity (ItemID, ItemsInStock) VALUES (4, 10);
GO 
 
CREATE PROC Inventory.RestockItem
    @ItemID int,
    @QuantityToAdd int
AS
BEGIN
    UPDATE Inventory.ItemQuantity
    SET ItemsInStock = ItemsInStock + @QuantityToAdd
   WHERE ItemID = @ItemID;
END;
GO 

CREATE USER JohnDoe WITHOUT LOGIN;
GO 
 
CREATE ROLE RestockClerk;
GO 
 
ALTER ROLE RestockClerk
ADD MEMBER JohnDoe;
GO 
 
GRANT EXEC ON SCHEMA::Inventory TO RestockClerk;
GO 


-------------------------------------------------------------------------------
-- SQL Server Ownership Chaining Example
-------------------------------------------------------------------------------

/* Reset inventory back to 15 if needed
 
UPDATE Inventory.ItemQuantity
SET ItemsInStock = 15
WHERE ItemID = 2;
GO 

*/
 
EXECUTE AS USER = 'JohnDoe';
GO 
 
EXEC Inventory.RestockItem @ItemID = 2, @QuantityToAdd = 10; /* WORKS */
GO 
 
UPDATE Inventory.ItemQuantity
SET ItemsInStock = ItemsInStock + 10
WHERE ItemID = 2;	/* FAILS */
GO 
 
REVERT;
GO 
--Msg 229, Level 14, State 5, Line 72
--The SELECT permission was denied on the object 'ItemQuantity', database 'TestDB', schema 'Inventory'.
--Msg 229, Level 14, State 5, Line 72
--The UPDATE permission was denied on the object 'ItemQuantity', database 'TestDB', schema 'Inventory'.

/*
	UPDATE permissions are required on the target table. 

	SELECT permissions are also required for the table being updated if the UPDATE 
	statement contains a WHERE clause, or if expression in the SET clause uses a 
	column in the table.

	When we specified the creation of both the table and the stored procedure, 
	we put them in the same schema. By default, these objects are created without an owner. 
	That means SQL Server will look at the ownership at the schema level. 
	Since they are both in the same schema, they have the same owner. 
	We can verify like so:
*/

-- Show owners for objects
-- NULL means no owners have been specified and will default to schema owner
SELECT O.name,
       O.principal_id
FROM sys.objects AS O
    JOIN sys.schemas AS S
        ON O.schema_id = S.schema_id
WHERE S.name = 'Inventory';
GO

-- Let's example the schema's owner
SELECT s.name AS "Schema",
       p.name AS "Owner"
FROM sys.schemas s
    JOIN sys.database_principals p
        ON p.principal_id = s.principal_id
WHERE s.name = 'Inventory';
GO


-------------------------------------------------------------------------------
-- Breaking SQL Server Ownership Chaining
-------------------------------------------------------------------------------

CREATE USER BrokenChain WITHOUT LOGIN;
GO 
 
ALTER AUTHORIZATION ON Inventory.RestockItem TO BrokenChain;
GO
 
-- Verify ownership change
SELECT O.name AS "Object",
       O.principal_id AS "Owner Id",
       p.name AS "Owner"
FROM sys.objects AS O
    JOIN sys.schemas AS S
        ON O.schema_id = S.schema_id
    LEFT JOIN sys.database_principals p
        ON p.principal_id = O.principal_id
WHERE S.name = 'Inventory';
GO


EXECUTE AS USER = 'JohnDoe';
GO 
EXEC Inventory.RestockItem @ItemID = 2, @QuantityToAdd = 10;
GO 
REVERT;
GO 
--Msg 229, Level 14, State 5, Procedure Inventory.RestockItem, Line 7 [Batch Start Line 137]
--The SELECT permission was denied on the object 'ItemQuantity', database 'TestDB', schema 'Inventory'.
--Msg 229, Level 14, State 5, Procedure Inventory.RestockItem, Line 7 [Batch Start Line 137]
--The UPDATE permission was denied on the object 'ItemQuantity', database 'TestDB', schema 'Inventory'.


-------------------------------------------------------------------------------
-- SQL Server Ownership Chaining Across Schemas
-------------------------------------------------------------------------------

-- Reset ownership because we're going to call the stored procedure
-- From another schema
ALTER AUTHORIZATION ON Inventory.RestockItem TO SCHEMA OWNER;
GO

-- New schema
CREATE SCHEMA Accounts;
GO

-- New table to track when we've back-ordered something
CREATE TABLE Accounts.BackStockItems
(
    ItemID INT,
    QuantityOrdered INT,
    CONSTRAINT PK_Accounts_OrderedItems
        PRIMARY KEY CLUSTERED (ItemID)
);
GO
 
INSERT INTO Accounts.BackStockItems (ItemID, QuantityOrdered) VALUES (1, 25);
INSERT INTO Accounts.BackStockItems (ItemID, QuantityOrdered) VALUES (2, 15);
GO 
 
CREATE PROC Accounts.ItemReceived @ItemID INT
AS
BEGIN
    BEGIN TRAN;
    DECLARE @Quantity INT;
    SET @Quantity =
    (
        SELECT QuantityOrdered FROM Accounts.BackStockItems WHERE ItemID = @ItemID
    );

    EXEC Inventory.RestockItem @ItemID = @ItemID, @QuantityToAdd = @Quantity;
    DELETE FROM Accounts.BackStockItems
    WHERE ItemID = @ItemID;
    COMMIT TRAN;
END;
GO

CREATE USER JaneDoe WITHOUT LOGIN;
GO 
 
CREATE ROLE Accountant;
GO 
 
GRANT EXECUTE ON SCHEMA::Accounts TO Accountant;
GO 
 
ALTER ROLE Accountant
ADD MEMBER JaneDoe;
GO 

-- Test
EXECUTE AS USER = 'JaneDoe';
GO 
EXEC Accounts.ItemReceived @ItemID = 2;
GO 
REVERT;
GO 


-------------------------------------------------------------------------------
-- Cleanup
-------------------------------------------------------------------------------

USE master
GO
DROP DATABASE TestDB
GO
