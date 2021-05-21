-- SQL Server 2012 Security Stairway - Level 6
-- Execution Context
-- Don Kiely, donkiely@computer.org

-- Create the logins and database for this demo
USE master;
GO

IF SUSER_SID('UserProc') IS NOT NULL
    DROP LOGIN UserProc;
IF SUSER_SID('UserTable') IS NOT NULL
    DROP LOGIN UserTable;
IF SUSER_SID('RealUser') IS NOT NULL
    DROP LOGIN RealUser;
GO
CREATE LOGIN UserProc WITH PASSWORD = 'Y&2!@37z#F!l1zB';
CREATE LOGIN UserTable WITH PASSWORD = 'Y&2!@37z#F!l1zB';
CREATE LOGIN RealUser WITH PASSWORD = 'Y&2!@37z#F!l1zB';
GO

IF DB_ID('ExecuteContextDB') IS NOT NULL
    DROP DATABASE ExecuteContextDB;
CREATE DATABASE ExecuteContextDB;
GO
USE ExecuteContextDB;
GO

-- Create the users 
CREATE USER UserProc;
CREATE USER UserTable;
CREATE USER RealUser;
GO

-- Create the schemas 
CREATE SCHEMA SchemaUserProc AUTHORIZATION UserProc;
GO
CREATE SCHEMA SchemaUserTable AUTHORIZATION UserTable;
GO

-- Create a table and a proc in different schemas to ensure that 
-- there is no ownerhship chaining.
CREATE TABLE SchemaUserTable.Vendor
(
    ID INT,
    name VARCHAR(50),
    state CHAR(2),
    phno CHAR(12)
);
GO

SET NOCOUNT ON;
GO

INSERT INTO SchemaUserTable.Vendor
VALUES (1, 'Vendor1', 'AK', '123-345-1232');
INSERT INTO SchemaUserTable.Vendor
VALUES (2, 'Vendor2', 'WA', '454-765-3233');
INSERT INTO SchemaUserTable.Vendor
VALUES (3, 'Vendor3', 'OR', '345-776-3433');
INSERT INTO SchemaUserTable.Vendor
VALUES (4, 'Vendor4', 'AK', '232-454-5654');
INSERT INTO SchemaUserTable.Vendor
VALUES (5, 'Vendor5', 'OR', '454-545-5654');
INSERT INTO SchemaUserTable.Vendor
VALUES (6, 'Vendor6', 'HI', '232-655-1232');
INSERT INTO SchemaUserTable.Vendor
VALUES (7, 'Vendor7', 'HI', '453-454-1232');
INSERT INTO SchemaUserTable.Vendor
VALUES (8, 'Vendor8', 'WA', '555-654-1232');
INSERT INTO SchemaUserTable.Vendor
VALUES (9, 'Vendor9', 'AK', '555-345-1232');
GO

-- Create the stored procedure in SchemaUserProc
CREATE PROC SchemaUserProc.VendorAccessProc @state CHAR(2)
AS
SELECT *
FROM   SchemaUserTable.Vendor
WHERE  state = @state;
GO

-- Grant permissions on the stored procedure
GRANT EXECUTE ON SchemaUserProc.VendorAccessProc TO RealUser;
GO

-- Now try and access the proc as RealUser
EXECUTE AS USER = 'RealUser';
EXEC SchemaUserProc.VendorAccessProc 'AK';

-- The permission is denied on the underlying table. 
-- But do not want to have to grant permissions to all callers on the underlying table.
-- Instead have the proc run as UserTable, which has SELECT permissions on the table,
-- since that user owns the schema it is in.
REVERT;
GO

-- Alter the procedure with UserTable as the execution context
-- ALTER preserves the permissions on the object!
ALTER PROC SchemaUserProc.VendorAccessProc @state CHAR(2)
WITH EXECUTE AS 'UserTable'
AS
SELECT *
FROM   SchemaUserTable.Vendor
WHERE  state = @state;
GO

-- Now try and execute the proc as RealUser
EXECUTE AS USER = 'RealUser';

EXEC SchemaUserProc.VendorAccessProc 'AK';
REVERT;
GO

-- Clean up
USE master;
GO

IF SUSER_SID('UserProc') IS NOT NULL
    DROP LOGIN UserProc;
IF SUSER_SID('UserTable') IS NOT NULL
    DROP LOGIN UserTable;
IF SUSER_SID('RealUser') IS NOT NULL
    DROP LOGIN RealUser;
