/* ----------------------------------------------------------------------------
 – SQL Server Windows Authentication with Users and Groups
---------------------------------------------------------------------------- */

USE master;
GO

-------------------------------------------------------------------------------
-- Administrating access at the SQL Server Instance Level
-------------------------------------------------------------------------------

-- Creating SQL Server Logins
CREATE LOGIN [MYDOMAIN\SqlDBAGroup] FROM WINDOWS;
CREATE LOGIN [MYDOMAIN\SqlDeveloperGroup] FROM WINDOWS;
CREATE LOGIN [MYDOMAIN\SqlReaderGroup] FROM WINDOWS;
GO

-- Create SQL Server Roles and Add Members
CREATE SERVER ROLE udsr_dba;
GO

GRANT ALTER ANY DATABASE TO udsr_dba;
GRANT ALTER ANY LOGIN TO udsr_dba;
GRANT ALTER ANY SERVER ROLE TO udsr_dba;
GRANT CONNECT ANY DATABASE TO udsr_dba;
GRANT CONNECT SQL TO udsr_dba;
GRANT CREATE ANY DATABASE TO udsr_dba;
GRANT VIEW ANY DATABASE TO udsr_dba;
GRANT VIEW ANY DEFINITION TO udsr_dba;
GRANT VIEW SERVER STATE TO udsr_dba;
GO

-------------------------------------------------------------------------------
-- Database Level Security
-------------------------------------------------------------------------------

USE AdventureWorks2019;
GO

-- Create Database Users
CREATE USER SqlDBA FOR LOGIN [MYDOMAIN\SqlDBAGroup];
CREATE USER SqlDeveloper FOR LOGIN [MYDOMAIN\SqlDeveloperGroup];
CREATE USER SqlReader FOR LOGIN [MYDOMAIN\SqlReaderGroup];
GO

-- Create Database Roles
CREATE ROLE db_sql_reader;
CREATE ROLE db_sql_developer;
CREATE ROLE db_sql_dba;
GO

-- Assign Permissions to Roles
GRANT EXECUTE ON SCHEMA::SalesLT TO db_sql_reader;
GRANT SELECT ON SCHEMA::SalesLT TO db_sql_reader;
GO

GRANT EXECUTE ON SCHEMA::SalesLT TO db_sql_developer;
GRANT SELECT ON SCHEMA::SalesLT TO db_sql_developer;
GRANT INSERT ON SCHEMA::SalesLT TO db_sql_developer;
GRANT UPDATE ON SCHEMA::SalesLT TO db_sql_developer;
GRANT DELETE ON SCHEMA::SalesLT TO db_sql_developer;
GO

GRANT EXECUTE ON SCHEMA::dbo TO db_sql_dba;
GRANT SELECT ON SCHEMA::dbo TO db_sql_dba;
GRANT INSERT ON SCHEMA::dbo TO db_sql_dba;
GRANT UPDATE ON SCHEMA::dbo TO db_sql_dba;
GRANT DELETE ON SCHEMA::dbo TO db_sql_dba;
GO

