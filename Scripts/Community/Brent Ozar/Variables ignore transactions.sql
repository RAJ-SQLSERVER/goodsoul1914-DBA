
/******************************************************************************

A Transact-SQL local variable is an object that can hold a single data value 
of a specific type. Variables in batches and scripts are typically used:

	- As a counter either to count the number of times a loop is performed or 
	  to control how many times the loop is performed.
	- To hold a data value to be tested by a control-of-flow statement.
	- To save a data value to be returned by a stored procedure return code or 
	  function return value.

Variables have local scope and are only visible within the batch or procedure 
where they are defined.

When a variable is first declared, its value is set to NULL. To assign a value 
to a variable, use the SET statement. This is the preferred method of 
assigning a value to a variable. A variable can also have a value assigned by 
being referenced in the select list of a SELECT statement.

******************************************************************************/

DECLARE @MySalary INT = 100000;

BEGIN TRAN;
SET @MySalary = @MySalary * 2;
ROLLBACK;

SELECT @MySalary;
GO


DECLARE @People TABLE (Name VARCHAR(50));
BEGIN TRAN;
INSERT INTO @People
VALUES ('Bill Gates');
INSERT INTO @People
VALUES ('Melinda Gates');
INSERT INTO @People
VALUES ('Satya Nadella');

ROLLBACK;

SELECT *
FROM @People;
GO