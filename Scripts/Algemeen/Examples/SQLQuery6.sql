
-- 
SELECT sid
  FROM sys.database_principals dp
 WHERE type = 'S'
   AND name = 'Mary';

-- Orphaned users
-- Execute the script below under the context of the database in question.
SELECT [name],
       SUSER_SNAME(sid) AS Resolved_SID
  FROM sys.database_principals
 WHERE type_desc = 'SQL_USER'
   AND NOT EXISTS (SELECT sid FROM sys.server_principals)
   AND [name]    <> 'guest';
GO