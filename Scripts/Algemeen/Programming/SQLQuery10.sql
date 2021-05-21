-------------------------------------------------------------------------------
-- Little Bobby Tables, SQL Injection and EXECUTE AS
-------------------------------------------------------------------------------

/*
EXECUTE AS Caller is the default. This means that the user that executes the 
procedure must have the DIRECT rights associated with the Dynamically Executed 
String. And, so, this is good. This should protect MOST cases altogether. 
However, what if the users have higher privileges? Well, I’d say that there’s 
already something wrong with your database (because this should NEVER be the 
case) but… well… I’ve seen apps (and even RECENTLY) heard of apps that connect 
as SA. Yes, seriously. So… what can they do… Well, much worse than DROP TABLE. 
How about DROP DATABASE? Or, well, let’s just say that if I found 
vulnerabilities in that – I could possible get outside of their SQL Server and 
do even more damage – to files, to the network. So… this is REALLY REALLY 
REALLY REALLY BAD. I would STRONGLY suggest that anyone that connects as SA – 
IMMEDIATELY WORK HARD TO CHANGE THIS.

EXECUTE AS Owner is almost as bad (although nothing’s as bad as connecting 
as SA) – especially when the OWNER has elevated rights. So, I’d try to avoid 
EXECUTE AS Owner unless you SEVERELY restrict who has permissions to the 
procedure in general. But, don’t EXECUTE AS Owner for a stored procedure that’s 
granted EXEC to public. That completely defeats the purpose!

EXECUTE AS Self is a bit strange. But, when a stored procedure is created in a 
schema, the ownership chaining and privileges follow from the OWNER of the 
schema. So, what if the author of the stored procedure has rights that the 
owner doesn’t. No, I don’t really recommend this but that’s where “self” comes 
in. This is where the procedure can execute under the context of the actual 
creator (not the owner). However, often these are the same and often they’re 
DBO. This is even worse… Although still, not as bad as connecting as SA.

EXECUTE AS User (where the User is a low-privileged user with very few rights) 
is good. And, in fact, this will be the answer to this problem!
*/

USE Credit
GO

CREATE USER User_GetMembers
WITHOUT LOGIN;
GO
 
GRANT SELECT ON Member TO User_GetMembers;
GO
 
CREATE OR ALTER PROCEDURE dbo.GetMembers
(@FirstName NVARCHAR(50))
WITH EXECUTE AS N'User_GetMembers'
AS
BEGIN
    DECLARE @ExecStr NVARCHAR(2000);
    SELECT @ExecStr = N'SELECT * FROM dbo.member WHERE FirstName = ''' + REPLACE(@FirstName, '''', '''''') + N'''';
    SELECT @ExecStr;
	--EXEC(@ExecStr);
END;
GO

EXEC dbo.GetMembers @FirstName = 'Simon; DROP DATABASE temp'

