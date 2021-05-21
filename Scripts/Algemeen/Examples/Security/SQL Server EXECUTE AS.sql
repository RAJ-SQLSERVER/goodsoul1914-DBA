/*
 The EXECUTE AS clause can be added to stored procedures, functions, DML triggers, 
 DDL triggers, queues as well as a stand alone clause to change the users context

 There are basically five types of impersonation that can be used:

	SELF - the specified user is the person creating or altering the module
	CALLER - this will take on the permissions of the current user
	OWNER - this will take on the permissions of the owner of the module being called
	'user_name' - a specific user
	'login_name' - a specific login
 */

USE Playground;
GO

CREATE TABLE dbo.table_1
(
    id INT,
    data NCHAR(10)
);
GO


CREATE PROCEDURE dbo.usp_Demo2
AS
BEGIN
    IF NOT EXISTS
    (
        SELECT *
        FROM   sys.objects
        WHERE  object_id = OBJECT_ID(N'[dbo].table_2')
               AND type IN ( N'U' )
    )
        CREATE TABLE table_2
        (
            id INT,
            data NCHAR(10)
        );

    INSERT INTO table_2
    SELECT TOP (5)
           *
    FROM   dbo.table_1;
END;
GO

GRANT EXEC ON dbo.usp_Demo2 TO test;
GO

EXEC dbo.usp_Demo2;
GO

--Msg 262, Level 14, State 1, Procedure dbo.usp_Demo2, Line 12 [Batch Start Line 49]
--CREATE TABLE permission denied in database 'Playground'.

CREATE OR ALTER PROCEDURE dbo.usp_Demo2
WITH EXECUTE AS OWNER
AS
BEGIN
    IF NOT EXISTS
    (
        SELECT *
        FROM   sys.objects
        WHERE  object_id = OBJECT_ID(N'[dbo].table_2')
               AND type IN ( N'U' )
    )
        CREATE TABLE table_2
        (
            id INT,
            data NCHAR(10)
        );

    INSERT INTO table_2
    SELECT TOP (5)
           *
    FROM   dbo.table_1;
END;
GO

GRANT EXEC ON dbo.usp_Demo2 TO test;
GO

EXEC dbo.usp_Demo2;