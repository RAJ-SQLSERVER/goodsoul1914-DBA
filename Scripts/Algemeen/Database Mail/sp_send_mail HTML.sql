DECLARE @tableHTML NVARCHAR(MAX);

SET @tableHTML
    = N'<H2>[WINSRV1] SQL logins password audit</H2>' + N'<table border="0">'
      + N'<tr><th>SQL_login</th><th>IsSysAdmin</th><th>IsDisabled</th><th>IsPolicyChecked</th><th>IsExpirationChecked</th><th>IsWeakPassword</th>'
      + N'<th>WeakPassword</th><th>PwdLastUpdated</th><th>PwdDaysOld</th><th>DateAudited</th></tr>'
      + CAST(
        (
            SELECT td = spa.SQL_login,
                   '',
                   td = spa.IsSysAdmin,
                   '',
				   td = spa.IsDisabled,
                   '',
				   td = spa.IsPolicyChecked,
                   '',
				   td = spa.IsExpirationChecked,
                   '',
                   td = spa.IsWeakPassword,
                   '',
                   td = spa.WeakPassword,
                   '',
                   td = FORMAT(spa.PwdLastUpdate, 'dd-MM-yyyy HH:mm:ss'),
                   '',
                   td = spa.PwdDaysOld,
                   '',
                   td = FORMAT(spa.DateAudited, 'dd-MM-yyyy HH:mm:ss'),
                   ''
            FROM DBATools.dbo.SQLPasswordAudit AS spa
            ORDER BY SQL_login
            FOR XML PATH('tr'), TYPE
        ) AS NVARCHAR(MAX)) + N'</table>';

EXEC msdb.dbo.sp_send_dbmail @profile_name = 'WINSRV1',
                             @recipients = 'mboomaars@gmail.com',
                             @subject = '[WINSRV1] SQL login password audit',
                             @body = @tableHTML,
                             @body_format = 'HTML';