-------------------------------------------------------------------------------
-- Find last login date of SQL Server Login
-------------------------------------------------------------------------------
SELECT login_name AS Login,
       MAX(login_time) AS [Last Login Time]
FROM sys.dm_exec_sessions
GROUP BY login_name;

-------------------------------------------------------------------------------
-- Contains one row for each login account
-------------------------------------------------------------------------------
SELECT sid,
       status,
       createdate,
       updatedate,
       accdate,
       totcpu,
       totio,
       spacelimit,
       timelimit,
       resultlimit,
       name,
       dbname,
       password,
       language,
       denylogin,
       hasaccess,
       isntname,
       isntgroup,
       isntuser,
       sysadmin,
       securityadmin,
       serveradmin,
       setupadmin,
       processadmin,
       diskadmin,
       dbcreator,
       bulkadmin,
       loginname
FROM sys.syslogins
ORDER BY 1;

-------------------------------------------------------------------------------
-- Show details for all SQL logins
-------------------------------------------------------------------------------
SELECT name,
       create_date,
       modify_date,
       default_database_name,
       is_policy_checked,
       is_expiration_checked,
       LOGINPROPERTY(name, 'DaysUntilExpiration') AS DaysUntilExpiration,
       LOGINPROPERTY(name, 'PasswordLastSetTime') AS PasswordLastSetTime,
       LOGINPROPERTY(name, 'IsLocked') AS IsLocked,
       LOGINPROPERTY(name, 'IsExpired') AS IsExpired,
       LOGINPROPERTY(name, 'BadPasswordCount') AS BadPasswordCount,
       LOGINPROPERTY(name, 'BadPasswordTime') AS BadPasswordTime,
       LOGINPROPERTY(name, 'HistoryLength') AS HistoryLength,
       LOGINPROPERTY(name, 'IsMustChange') AS IsMustChange,
       LOGINPROPERTY(name, 'LockoutTime') AS LockoutTime,
       LOGINPROPERTY(name, 'PasswordLastSetTime') AS PasswordLastSetTime,
       LOGINPROPERTY(name, 'PasswordHash') AS PasswordHash
FROM sys.sql_logins;