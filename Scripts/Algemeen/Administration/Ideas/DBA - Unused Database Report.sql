USE DBA;
GO

CREATE PROCEDURE dbo.usp_ConnectionCount
AS
BEGIN
    IF OBJECT_ID('dbo.ConnectionCount', 'U') IS NULL
        CREATE TABLE dbo.ConnectionCount
        (
            serverName VARCHAR(500),
            DBName VARCHAR(1000),
            TotalConnection INT,
            QueryDate DATETIME
        );

    INSERT INTO dbo.ConnectionCount
    SELECT @@ServerName AS [Server Name],
           databases.name AS [Database Name],
           COUNT(processes.status) AS [Total Number of User connection],
           GETDATE() AS [Query execution time]
    FROM sys.databases AS databases
    LEFT JOIN sys.sysprocesses AS processes
        ON databases.database_id = processes.dbid
    WHERE databases.database_id > 4
    GROUP BY databases.name
    ORDER BY COUNT(processes.status) DESC;
END;
GO


-- Create a job called: [DBA - Unused Database Report]
CREATE PROCEDURE dbo.usp_EmailReport
AS
BEGIN
    DECLARE @UnusedDatabase VARCHAR(MAX);
    SELECT @UnusedDatabase
        = '<table id="AutoNumber1" style="BORDER-COLLAPSE: collapse" borderColor="#111111" height="40" cellSpacing="0" cellPadding="0" width="24%" border="1">
	        <tr>
	        <td width="27%" bgColor="#D3D3D3" height="15"><b>
	        <font face="Verdana" size="1" color="#FFFFFF">Database Name</font></b></td>
	        <td width="59%" bgColor="#D3D3D3" height="15"><b>
	        <font face="Verdana" size="1" color="#FFFFFF"> Total Connection </font></b></td>
	        </tr>
	    <p style="margin-top: 1; margin-bottom: 0">&nbsp;</p>
	    <p><font face="Verdana" size="4">Disk Stats</font></p>';
    SELECT @UnusedDatabase
        = @UnusedDatabase + '<tr><td><font face="Verdana" size="2">' + CONVERT(VARCHAR, DBName) + '</font></td>'
          + '<td><font face="Verdana" size="2">' + CONVERT(VARCHAR, MAX(TotalConnection)) + '</font></td></tr>'
    FROM dbo.ConnectionCount
    WHERE QueryDate < GETDATE()
          AND TotalConnection = 0
    GROUP BY DBName;

    EXEC msdb.dbo.sp_send_dbmail @profile_name = 'KPNMail',
                                 @recipients = 'mboomaars@gmail.com',
                                 @subject = 'List of unused databases',
                                 @body = @UnusedDatabase,
                                 @body_format = 'HTML';
END;
GO



--SELECT DBName,
--       MAX(TotalConnection) AS TotalConnection
--FROM dbo.ConnectionCount
--WHERE QueryDate < GETDATE()
--      --AND TotalConnection = 0
--GROUP BY DBName
--ORDER BY DBName;



--USE msdb;
--GO
--EXEC msdb..sp_start_job [DBA - Unused Database Report];