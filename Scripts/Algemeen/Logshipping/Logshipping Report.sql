/****************************************
Creat temporary table to hold the values 
****************************************/
IF OBJECT_ID('TEMPDB.dbo.#Logshipping_Monitor') IS NOT NULL
	DROP TABLE #Logshipping_Monitor;

CREATE TABLE #Logshipping_Monitor (
	Primary_Server NVARCHAR(100),
	Primary_Database NVARCHAR(100),
	Secondary_Server NVARCHAR(100),
	Secondary_Database NVARCHAR(100),
	Restore_Latency INT,
	Min_Behind_Primary INT
	);

/******************************
 Insert temp table with values 
******************************/
INSERT INTO #Logshipping_Monitor
SELECT secondary_server,
	secondary_database,
	primary_server,
	primary_database,
	last_restored_latency,
	DATEDIFF(minute, last_restored_date_utc, GETUTCDATE()) + last_restored_latency AS [Minutes Behind Current Time]
FROM msdb.dbo.log_shipping_monitor_secondary
ORDER BY [Minutes Behind Current Time] DESC;

/*************************************************************
Send email alert only if Secondary is behind Primary by 60min 
*************************************************************/
--Set the body of the email 
DECLARE @xml NVARCHAR(max);
DECLARE @body NVARCHAR(max);

SET @xml = CAST((
			SELECT Primary_Server AS 'td',
				'',
				Primary_Database AS 'td',
				'',
				Secondary_Server AS 'td',
				'',
				Secondary_Database AS 'td',
				'',
				Restore_Latency AS 'td',
				'',
				Min_Behind_Primary AS 'td'
			FROM #Logshipping_Monitor
			WHERE Min_Behind_Primary > 60
			ORDER BY Min_Behind_Primary DESC
			FOR XML path('tr'),
				elements
			) AS NVARCHAR(max));
SET @body = '<html><body><H3>Logshipping Report</H3>
			<table border = 1>
			<tr>
			<th>Primary_Server</th>
			<th>Primary_Database</th>
			<th>Secondary_Server</th>
			<th>Secondary_Database</th>
			<th>Latency_Min</th>
			<th>Min_Behind_Primary</th>';
SET @body = @body + @xml + '</table></body></html>';

--Send email
EXEC msdb.dbo.sp_send_dbmail @profile_name = 'lt-rsd-01.boomaars.local',
	@Subject = 'Logshipping Monitoring',
	@recipients = 'mboomaars@gmail.com',
	@body = @body,
	@body_format = 'HTML';

DROP TABLE #Logshipping_Monitor;
