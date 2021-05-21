-- Setup code
CREATE LOGIN WriteOnlyUser
WITH PASSWORD = 'WriteOnlyUser',
     CHECK_POLICY = OFF;
GO

USE AdventureWorks2014;
GO

CREATE USER WriteOnlyUser FROM LOGIN WriteOnlyUser;
GO

ALTER ROLE db_datawriter ADD MEMBER WriteOnlyUser;
GO

-- 
EXECUTE AS USER = 'WriteOnlyUser';
GO

INSERT INTO Person.PersonPhone (BusinessEntityID,
                                PhoneNumber,
                                PhoneNumberTypeID)
VALUES (1, '999-999-9999', 1);
GO

REVERT;
GO

-- 
EXECUTE AS USER = 'WriteOnlyUser';
GO
UPDATE Person.PersonPhone
   SET PhoneNumberTypeID = 3
 WHERE BusinessEntityID = 1
   AND PhoneNumber      = '999-999-9999';
GO

DELETE Person.PersonPhone
 WHERE BusinessEntityID = 1
   AND PhoneNumber      = '999-999-9999';
GO

REVERT;
GO

-- 
EXECUTE AS USER = 'WriteOnlyUser';
GO

UPDATE TOP (1) Person.PersonPhone
   SET         PhoneNumberTypeID = 3;
GO

DELETE TOP (1) Person.PersonPhone;
GO

REVERT;
GO