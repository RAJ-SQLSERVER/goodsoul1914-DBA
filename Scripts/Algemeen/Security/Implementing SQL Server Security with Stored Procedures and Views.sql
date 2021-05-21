/*
 ██████╗ ██╗    ██╗███╗   ██╗███████╗██████╗ ███████╗██╗  ██╗██╗██████╗ 
██╔═══██╗██║    ██║████╗  ██║██╔════╝██╔══██╗██╔════╝██║  ██║██║██╔══██╗
██║   ██║██║ █╗ ██║██╔██╗ ██║█████╗  ██████╔╝███████╗███████║██║██████╔╝
██║   ██║██║███╗██║██║╚██╗██║██╔══╝  ██╔══██╗╚════██║██╔══██║██║██╔═══╝ 
╚██████╔╝╚███╔███╔╝██║ ╚████║███████╗██║  ██║███████║██║  ██║██║██║     
 ╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝╚═╝     
                                                                        
 ██████╗██╗  ██╗ █████╗ ██╗███╗   ██╗██╗███╗   ██╗ ██████╗              
██╔════╝██║  ██║██╔══██╗██║████╗  ██║██║████╗  ██║██╔════╝              
██║     ███████║███████║██║██╔██╗ ██║██║██╔██╗ ██║██║  ███╗             
██║     ██╔══██║██╔══██║██║██║╚██╗██║██║██║╚██╗██║██║   ██║             
╚██████╗██║  ██║██║  ██║██║██║ ╚████║██║██║ ╚████║╚██████╔╝             
 ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═══╝ ╚═════╝                                                                                    
*/

/******************************************************************************
Ownership chaining is a security feature in SQL Server which occurs when all 
of the following conditions are true:

	- A user (which could be an app through a login/service account) tries to 
	  access an object that makes a reference to another object. For instance, 
	  the user tries to execute a stored procedure that accesses other objects 
	  or a SELECT from a view that accesses other tables.
	- The user has access to the first object, such as EXECUTE rights on the 
	  stored procedure or SELECT rights on the view.
	- Both objects have the same owner.

In this case, SQL Server will see the chain between the object the user called 
and the object being referenced. SQL Server will also determine that the owner 
for both objects is the same. When those conditions are met, SQL Server will 
create the ownership chain.

Ownership chaining is a great way to prevent direct access to the base tables. 
******************************************************************************/


-------------------------------------------------------------------------------
-- Setup
-------------------------------------------------------------------------------

CREATE DATABASE TestDB;
GO

USE TestDB;
GO

CREATE SCHEMA HR;
GO

CREATE TABLE HR.Employee
(
    EmployeeID INT,
    GivenName VARCHAR(50),
    Surname VARCHAR(50),
    SSN CHAR(9)
);
GO

CREATE VIEW HR.LookupEmployee
AS
SELECT EmployeeID,
       GivenName,
       Surname
FROM HR.Employee;
GO


-------------------------------------------------------------------------------
-- Reading from a view
-------------------------------------------------------------------------------

CREATE ROLE HumanResourcesAnalyst;
GO

GRANT SELECT ON HR.LookupEmployee TO HumanResourcesAnalyst;
GO

CREATE USER JaneDoe WITHOUT LOGIN;
GO

ALTER ROLE HumanResourcesAnalyst ADD MEMBER JaneDoe;
GO

-- This will work
-- JaneDoe has SELECT against the view
-- She does not have SELECT against the table
-- Ownership chaining makes this happen
EXECUTE AS USER = 'JaneDoe';
GO

SELECT *
FROM HR.LookupEmployee;
GO

REVERT;
GO

-- This will not work
-- Since JaneDoe doesn't have SELECT permission
-- She cannot query the table in this way
EXECUTE AS USER = 'JaneDoe';
GO

SELECT *
FROM HR.Employee;
GO

REVERT;
GO


-------------------------------------------------------------------------------
-- Executing a Stored Procedure
-------------------------------------------------------------------------------

CREATE PROC HR.InsertNewEmployee
    @EmployeeID INT,
    @GivenName VARCHAR(50),
    @Surname VARCHAR(50),
    @SSN CHAR(9)
AS
BEGIN
    INSERT INTO HR.Employee
    (
        EmployeeID,
        GivenName,
        Surname,
        SSN
    )
    VALUES
    (@EmployeeID, @GivenName, @Surname, @SSN);
END;
GO


CREATE ROLE HumanResourcesRecruiter;
GO

GRANT EXECUTE ON SCHEMA::[HR] TO HumanResourcesRecruiter;
GO

CREATE USER JohnSmith WITHOUT LOGIN;
GO

ALTER ROLE HumanResourcesRecruiter ADD MEMBER JohnSmith;
GO

-- This will fail as JohnSmith doesn't have the ability to
-- insert directly into the table.
EXECUTE AS USER = 'JohnSmith';
GO

INSERT INTO HR.Employee
(
    EmployeeID,
    GivenName,
    Surname,
    SSN
)
VALUES
(557, 'Michael', 'Cooper', '3343343344');
GO

REVERT;
GO

-- This will succeed because JohnSmith can execute any 
-- stored procedure in the HR schema. An ownership chain forms,
-- allowing the insert to happen.
EXECUTE AS USER = 'JohnSmith';
GO
EXEC HR.InsertNewEmployee @EmployeeID = 557,
                          @GivenName = 'Michael',
                          @Surname = 'Cooper',
                          @SSN = '3343343344';
GO
REVERT;
GO

-- Verifying the insert
SELECT EmployeeID,
       GivenName,
       Surname,
       SSN
FROM HR.Employee;
GO


-------------------------------------------------------------------------------
-- Cleanup
-------------------------------------------------------------------------------

--ALTER DATABASE TestDB SET SINGLE_USER WITH NO_WAIT
--GO
USE master
GO
DROP DATABASE TestDB
GO
