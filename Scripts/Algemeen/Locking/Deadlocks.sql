SELECT *
FROM sys.sysprocesses
WHERE blocked > 0

SELECT Blocker.*,
	*
FROM sys.dm_exec_connections AS Conns
INNER JOIN sys.dm_exec_requests AS BlockedReqs ON Conns.session_id = BlockedReqs.blocking_session_id
INNER JOIN sys.dm_os_waiting_tasks AS w ON BlockedReqs.session_id = w.session_id
CROSS APPLY sys.dm_exec_sql_text(Conns.most_recent_sql_handle) AS Blocker

/*********************************************
	Querying Deadlocks From System_Health XEvent	
*********************************************/
SET NOCOUNT ON;

DECLARE @SessionName SYSNAME;

SELECT @SessionName = 'system_health';

IF OBJECT_ID('tempdb..#Events') IS NOT NULL
BEGIN
	DROP TABLE #Events;
END;

DECLARE @Target_File NVARCHAR(1000),
	@Target_Dir NVARCHAR(1000),
	@Target_File_WildCard NVARCHAR(1000);

SELECT @Target_File = CAST(t.target_data AS XML).value('EventFileTarget[1]/File[1]/@name', 'NVARCHAR(256)')
FROM sys.dm_xe_session_targets AS t
INNER JOIN sys.dm_xe_sessions AS s ON s.address = t.event_session_address
WHERE s.name = @SessionName
	AND t.target_name = 'event_file';

SELECT @Target_Dir = LEFT(@Target_File, LEN(@Target_File) - CHARINDEX('\', REVERSE(@Target_File)));

SELECT @Target_File_WildCard = @Target_Dir + '\' + @SessionName + '_*.xel';

--Keep this as a separate table because it's called twice in the next query.  You don't want this running twice.
SELECT DeadlockGraph = CAST(event_data AS XML),
	DeadlockID = ROW_NUMBER() OVER (
		ORDER BY file_name,
			file_offset
		)
INTO #Events
FROM sys.fn_xe_file_target_read_file(@Target_File_WildCard, NULL, NULL, NULL) AS F
WHERE event_data LIKE '<event name="xml_deadlock_report%';

WITH Victims
AS (
	SELECT VictimID = Deadlock.Victims.value('@id', 'varchar(50)'),
		e.DeadlockID
	FROM #Events AS e
	CROSS APPLY e.DeadlockGraph.nodes('/event/data/value/deadlock/victim-list/victimProcess') AS Deadlock(Victims)
	),
DeadlockObjects
AS (
	SELECT DISTINCT e.DeadlockID,
		ObjectName = Deadlock.Resources.value('@objectname', 'nvarchar(256)')
	FROM #Events AS e
	CROSS APPLY e.DeadlockGraph.nodes('/event/data/value/deadlock/resource-list/*') AS Deadlock(Resources)
	)
SELECT *
FROM (
	SELECT e.DeadlockID,
		TransactionTime = Deadlock.Process.value('@lasttranstarted', 'datetime'),
		DeadlockGraph,
		DeadlockObjects = SUBSTRING((
				SELECT ', ' + o.ObjectName
				FROM DeadlockObjects AS o
				WHERE o.DeadlockID = e.DeadlockID
				ORDER BY o.ObjectName
				FOR XML path('')
				), 3, 4000),
		Victim = CASE 
			WHEN v.VictimID IS NOT NULL
				THEN 1
			ELSE 0
			END,
		SPID = Deadlock.Process.value('@spid', 'int'),
		ProcedureName = Deadlock.Process.value('executionStack[1]/frame[1]/@procname[1]', 'varchar(200)'),
		LockMode = Deadlock.Process.value('@lockMode', 'char(1)'),
		Code = Deadlock.Process.value('executionStack[1]/frame[1]', 'varchar(1000)'),
		ClientApp = CASE LEFT(Deadlock.Process.value('@clientapp', 'varchar(100)'), 29)
			WHEN 'SQLAgent - TSQL JobStep (Job '
				THEN 'SQLAgent Job: ' + (
						SELECT name
						FROM msdb..sysjobs AS sj
						WHERE SUBSTRING(Deadlock.Process.value('@clientapp', 'varchar(100)'), 32, 32) = SUBSTRING(sys.fn_varbintohexstr(sj.job_id), 3, 100)
						) + ' - ' + SUBSTRING(Deadlock.Process.value('@clientapp', 'varchar(100)'), 67, LEN(Deadlock.Process.value('@clientapp', 'varchar(100)')) - 67)
			ELSE Deadlock.Process.value('@clientapp', 'varchar(100)')
			END,
		HostName = Deadlock.Process.value('@hostname', 'varchar(20)'),
		LoginName = Deadlock.Process.value('@loginname', 'varchar(20)'),
		INPUTBUFFER = Deadlock.Process.value('inputbuf[1]', 'varchar(1000)')
	FROM #Events AS e
	CROSS APPLY e.DeadlockGraph.nodes('/event/data/value/deadlock/process-list/process') AS Deadlock(Process)
	LEFT JOIN Victims AS v ON v.DeadlockID = e.DeadlockID
		AND v.VictimID = Deadlock.Process.value('@id', 'varchar(50)')
	) AS X --In a subquery to make filtering easier (use column names, not XML parsing), no other reason
ORDER BY DeadlockID DESC;
