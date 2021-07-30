SELECT N'In server ' + @@SERVERNAME + N', owner of job "' + j.name COLLATE DATABASE_DEFAULT + N'"'
       + CASE
             WHEN L.sid IS NULL THEN N' was not found'
             WHEN L.denylogin = 1
                  OR L.hasaccess = 0 THEN N' (' + L.name COLLATE DATABASE_DEFAULT + N') has no server access'
             ELSE N' is ok'
         END,
       1,
       N'EXEC msdb.dbo.sp_update_job @job_name=N' + QUOTENAME (j.name, N'''') + N' , @owner_login_name=N'
       + QUOTENAME (SUSER_NAME (0x01), N'''') AS "RemediationCmd"
FROM msdb.dbo.sysjobs AS j
LEFT JOIN master.sys.syslogins AS L
    ON j.owner_sid = L.sid
WHERE j.enabled = 1
      AND (L.sid IS NULL OR L.denylogin = 1 OR L.hasaccess = 0);
