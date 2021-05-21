/******************************************************************************
	Orphaned users
******************************************************************************/

-------------------------------------------------------------------------------
-- Get orphaned database users
-------------------------------------------------------------------------------
SELECT DP.type_desc,
       DP.sid,
       DP.name AS "UserName"
FROM sys.database_principals AS DP
LEFT JOIN sys.server_principals AS SP
    ON DP.sid = SP.sid
WHERE SP.sid IS NULL
      AND DP.authentication_type_desc = 'INSTANCE';

USE master;
GO

-------------------------------------------------------------------------------
-- Add SQL logins
--
-- (If you do not know the Login password that was used on the old server, 
-- CREATE a new one)
-------------------------------------------------------------------------------
CREATE LOGIN Mary
WITH PASSWORD = 'SomePassword',
     SID = 0x5D5D087DD06B7649899FB25E1B035D4A;

CREATE LOGIN ReadOnlySupportStaffUser1
WITH PASSWORD = 'SomePassword',
     SID = 0x0C8B39C4D2573140BF8B9B2DB99CA022;
GO

-------------------------------------------------------------------------------
-- Add Windows user logins
-------------------------------------------------------------------------------
CREATE LOGIN [SomeDomain\SomeLogin] FROM WINDOWS
WITH DEFAULT_DATABASE = master;
GO
