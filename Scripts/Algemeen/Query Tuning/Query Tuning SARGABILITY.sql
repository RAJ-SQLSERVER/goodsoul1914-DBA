USE AdventureWorks2014;
GO

SET STATISTICS IO, TIME ON
GO


SELECT EmailAddress
FROM Person.EmailAddress
WHERE EmailAddress LIKE 'aaron%';	-- sargable

SELECT EmailAddress
FROM Person.EmailAddress
WHERE EmailAddress LIKE '%aron%';	-- non-sargable


SELECT EmailAddress
FROM Person.EmailAddress
WHERE EmailAddress LIKE 'a%';		-- sargable

SELECT EmailAddress
FROM Person.EmailAddress
WHERE LEFT(EmailAddress, 1) = 'a';	-- non-sargable


-- Using functions

-- good
SELECT FirstName
FROM Person.Person 
WHERE FirstName LIKE 'Rob%'			-- SCAN, because first column in index is 'LastName'
GO

-- bad
SELECT FirstName
FROM Person.Person
WHERE SUBSTRING(FirstName, 1, 3) = 'Rob'	-- non-sargable
GO


-- Keep calculations on the right side of the expression!
