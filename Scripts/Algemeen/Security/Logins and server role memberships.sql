-------------------------------------------------------------------------------
-- Show logins and server role memberships 
-------------------------------------------------------------------------------
SELECT a.name,
       CASE
           WHEN IS_SRVROLEMEMBER ('bulkadmin', a.name) = 1 THEN 'YES'
           ELSE 'NO'
       END AS "is_bulkadmin",
       CASE
           WHEN IS_SRVROLEMEMBER ('dbcreator', a.name) = 1 THEN 'YES'
           ELSE 'NO'
       END AS "is_dbcreator",
       CASE
           WHEN IS_SRVROLEMEMBER ('diskadmin', a.name) = 1 THEN 'YES'
           ELSE 'NO'
       END AS "is_diskadmin",
       CASE
           WHEN IS_SRVROLEMEMBER ('processadmin', a.name) = 1 THEN 'YES'
           ELSE 'NO'
       END AS "is_processadmin",
       CASE
           WHEN IS_SRVROLEMEMBER ('securityadmin', a.name) = 1 THEN 'YES'
           ELSE 'NO'
       END AS "is_securityadmin",
       CASE
           WHEN IS_SRVROLEMEMBER ('serveradmin', a.name) = 1 THEN 'YES'
           ELSE 'NO'
       END AS "is_serveradmin",
       CASE
           WHEN IS_SRVROLEMEMBER ('setupadmin', a.name) = 1 THEN 'YES'
           ELSE 'NO'
       END AS "is_setupadmin",
       CASE
           WHEN IS_SRVROLEMEMBER ('sysadmin', a.name) = 1 THEN 'YES'
           ELSE 'NO'
       END AS "is_sysadmin",
       a.type_desc,
       a.is_disabled,
       a.default_database_name,
       b.createdate
FROM master.sys.server_principals AS a
INNER JOIN master.sys.syslogins AS b
    ON a.name = b.name
WHERE a.type NOT IN ( 'R', 'C' )
      AND a.is_disabled = 0
ORDER BY is_sysadmin DESC,
         type_desc,
         name;
GO