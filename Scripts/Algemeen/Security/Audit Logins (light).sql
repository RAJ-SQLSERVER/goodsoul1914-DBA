/* initial setup */

/* create table */
CREATE TABLE [DBATools].[dbo].[LoginAudit]
(
    LoginName VARCHAR(200),
    LastLoginDate DATETIME
);

/* populate with all logins */
INSERT INTO [DBATools].[dbo].[LoginAudit]
(
    LoginName,
    LastLoginDate
)
SELECT [name],
       NULL
FROM [master].[sys].[server_principals]
WHERE type <> 'R' /* is not a Role */
      AND is_disabled <> 1; /* is not Disabled */


/* update logins */
SELECT MAX(login_time) LoginTime,
       login_name LoginName
INTO #LoginTempTable
FROM [sys].[dm_exec_sessions]
WHERE login_name <> '' /* exclude ef */
GROUP BY login_name;

UPDATE [DBATools].[dbo].[LoginAudit]
SET LastLoginDate = tmp.LoginTime
FROM #LoginTempTable tmp
WHERE LoginAudit.LoginName = tmp.LoginName;