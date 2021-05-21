/*
	In order to connect a database user to a login we will need to use the SID, 
	Security Identifier.  When you create a login on a SQL Server, SQL Server 
	creates a SID, sometimes.  So what do I mean sometimes?  Well, if the login 
	is a SQL login, SQL Server will create the SID, however if the login is an 
	Active Directory user or group, the SID will the be same as the SID in 
	Active Directory.
*/

-- In order to find the SID we will need to use Syslogins.
SELECT sid,
       name
FROM sys.syslogins;
GO

-- In order to get the SID for a user account we would run the following query 
-- in the database with the user account.
SELECT sid,
       name
FROM sys.sysusers;
GO

-- If you run this query in the database you are looking for the mapped logins
SELECT u.sid AS DatabaseUserSID,
       u.name AS DatabaseUserName,
       l.name AS LoginName,
       l.sid AS LoginSID
FROM sys.sysusers u
    INNER JOIN master..syslogins l
        ON u.sid = l.sid;
GO

-- If you want to only find the user accounts that have different names from the login, 
-- you will need to add a WHERE clause
USE master
GO

SELECT u.sid AS DatabaseUserSID,
       u.name AS DatabaseUserName,
       l.name AS LoginName,
       l.sid AS LoginSID
FROM sys.sysusers u
    INNER JOIN master..syslogins l
        ON u.sid = l.sid
WHERE u.name <> l.name;
GO

