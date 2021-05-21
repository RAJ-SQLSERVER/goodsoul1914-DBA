-- REFERENCES:
-- see //msdn.microsoft.com/en-us/library/ms188246.aspx
-- (MS BOL Analyzing Deadlocks with SQL Server Profiler)
-- see //msdn.microsoft.com/en-us/library/ms175519.aspx
-- (MS BOL Lock Modes)
-- //blogs.msdn.com/bartd/archive/2006/09/09/Deadlock-Troubleshooting_2C00_-Part-1.aspx
-- //blogs.msdn.com/b/bartd/archive/2008/09/24/today-s-annoyingly-unwieldy-term-intra-query-parallel-thread-deadlocks.aspx
-- Shred XML Deadlock Graphs, showing in tabular format as much information as possible.
-- Insert the XML Deadlock Graph into the @deadlock table.
-- Author: Wayne Sheffield
-- Modification History:
-- Version - Date       - Description
-- 2         2010-10-10 - Added individual items in the Execution Stack node.
--                      - Converted from using an XML variable to a table variable with an XML variable
--                      -   to allow seeing multiple deadlocks simultaneously.
-- 3         2010-10-11 - Added KPID to Process CTE and final results.
--                      - Expanded LockMode to varchar(10).
-- 4         2011-05-11 - Added Waits.
-- 5         2011-05-15 - Revamped to minimize calls to the root of the deadlock xml nodes.
--                        Modified InputBuffer to be XML.
--                        Modified Execution Stack to return XML (vs. one row for each item, which
--                          was causing duplication of other data).
-- 6         2012-02-01 - Add loading deadlock info from fn_trace_gettable.
--                      - Get the InputBuffer from .query vs. trying to build XML.
--                      - Add number of processes involved in the deadlock.
--                      - Add the Query Statement being run.
-- 7         2012-09-01 - Corrected typo in ObjNode in both the Locks and Waits CTEs.
--                      - Added DENSE_RANK for each process.
--                      - Added support for exchangeEvent, threadpool, resourceWait events.
--                      -   (threadpool and resourceWait events are not tested - need to find a deadlock with them to test)
--                      - Simplified xpath queries
-- 8         2012-09-04 - Greatly simplified locks and waits CTEs based on feedback from Mark Cowne.
--                      - Added database_id and AssociatedObjectId per feedback from Gianluca Sartori.
--                      - Combined the Locks and Waits CTEs into one.
-- 9         2012-10-26 - Handle deadlock graphs from the system_health xe (has a victim-list node for multi-victim deadlocks).
-- 10        2013-07-29 - Added ability to load in a deadlock file (.xdl).
--                      - Added QueryStatement to output.
--                      - Switched from clause order from "Locks JOIN Process" to "Process LEFT JOIN Locks"
-- 11        2013-12-26 - Read in deadlocks from the system_health XE file target
-- 12        2014-05-06 - Read in deadlocks from the system_health XE ring buffer
-- 13        2014-07-01 - Read in deadlocks from SQL Sentry
DECLARE @deadlock TABLE (
	DeadlockID INT identity PRIMARY KEY CLUSTERED,
	DeadlockGraph XML
	);

-- use below to load a deadlock trace file
/*****************************************************************************************************
DECLARE @file VARCHAR(500);
SELECT  @file = REVERSE(SUBSTRING(REVERSE([PATH]), CHARINDEX('\', REVERSE([path])), 260)) + N'LOG.trc'
FROM    sys.traces 
WHERE   is_default = 1; -- get the system default trace, use different # for other active traces.

-- or just SET @file = 'your trace file to load';

INSERT  INTO @deadlock (DeadlockGraph)
SELECT  TextData
FROM    ::FN_TRACE_GETTABLE(@file, DEFAULT)
WHERE   TextData LIKE '%';
*****************************************************************************************************/
-- or read in a deadlock file - doesn't have to have a "xdl" extension.
/**************************************************************
INSERT INTO @deadlock (DeadlockGraph)
SELECT *
FROM OPENROWSET(BULK 'Deadlock.xdl', SINGLE_BLOB) UselessAlias;
**************************************************************/
-- or read in the deadlock from the system_health XE file target
/***********************************************************************************
WITH cte1 AS
(
SELECT	target_data = convert(XML, target_data)
FROM	sys.dm_xe_session_targets t
		JOIN sys.dm_xe_sessions s 
		  ON t.event_session_address = s.address
WHERE	t.target_name = 'event_file'
AND		s.name = 'system_health'
), cte2 AS
(
SELECT	[FileName] = FileEvent.FileTarget.value('@name', 'varchar(1000)')
FROM	cte1
		CROSS APPLY cte1.target_data.nodes('//EventFileTarget/File') FileEvent(FileTarget)
), cte3 AS
(
SELECT	event_data = CONVERT(XML, t2.event_data)
FROM    cte2
		CROSS APPLY sys.fn_xe_file_target_read_file(cte2.[FileName], NULL, NULL, NULL) t2
WHERE	t2.object_name = 'xml_deadlock_report'
)
INSERT INTO @deadlock(DeadlockGraph)
SELECT  Deadlock = Deadlock.Report.query('.')
FROM	cte3	
		CROSS APPLY cte3.event_data.nodes('//event/data/value/deadlock') Deadlock(Report);
***********************************************************************************/
-- or read in the deadlock from the system_health XE ring buffer
/************************************************************************************************
INSERT INTO @deadlock(DeadlockGraph)
SELECT  --XEventData.XEvent.value('@timestamp', 'datetime') AS DeadlockDateTime,
        CONVERT(XML, XEventData.XEvent.value('(data/value)[1]', 'varchar(max)')) AS DeadlockGraph
FROM    (SELECT CAST(target_data AS XML) AS TargetData
         FROM   sys.dm_xe_session_targets st WITH (NOLOCK)
                JOIN sys.dm_xe_sessions s WITH (NOLOCK)
                  ON s.address = st.event_session_address
         WHERE  name = 'system_health'
        ) AS Data
        CROSS APPLY TargetData.nodes('//RingBufferTarget/event') AS XEventData (XEvent)
WHERE   XEventData.XEvent.value('@name', 'varchar(4000)') = 'xml_deadlock_report';
************************************************************************************************/
/*************************************************************
-- or read in the deadlock from SQL Sentry deadlock collection
INSERT INTO @deadlock(DeadlockGraph)
SELECT  deadlockxml
FROM    dbo.PerformanceAnalysisTraceDeadlock
*************************************************************/
-- use below to load individual deadlocks.
-- INSERT INTO @deadlock VALUES ('Put your deadlock here');
-- Insert the deadlock XML in the above line!
-- Duplicate as necessary for additional graphs.
WITH CTE
AS (
	SELECT DeadlockID,
		DeadlockGraph
	FROM @deadlock
	),
Victims
AS (
	SELECT ID = Victims.List.value('@id', 'varchar(50)')
	FROM CTE
	CROSS APPLY CTE.DeadlockGraph.nodes('//deadlock/victim-list/victimProcess') AS Victims(List)
	),
Locks
AS (
	-- Merge all of the lock information together.
	SELECT CTE.DeadlockID,
		MainLock.Process.value('@id', 'varchar(100)') AS LockID,
		OwnerList.OWNER.value('@id', 'varchar(200)') AS LockProcessId,
		REPLACE(MainLock.Process.value('local-name(.)', 'varchar(100)'), 'lock', '') AS LockEvent,
		MainLock.Process.value('@objectname', 'sysname') AS ObjectName,
		OwnerList.OWNER.value('@mode', 'varchar(10)') AS LockMode,
		MainLock.Process.value('@dbid', 'INTEGER') AS Database_id,
		MainLock.Process.value('@associatedObjectId', 'BIGINT') AS AssociatedObjectId,
		MainLock.Process.value('@WaitType', 'varchar(100)') AS WaitType,
		WaiterList.OWNER.value('@id', 'varchar(200)') AS WaitProcessId,
		WaiterList.OWNER.value('@mode', 'varchar(10)') AS WaitMode
	FROM CTE
	CROSS APPLY CTE.DeadlockGraph.nodes('//deadlock/resource-list') AS Lock(list)
	CROSS APPLY Lock.list.nodes('*') AS MainLock(Process)
	OUTER APPLY MainLock.Process.nodes('owner-list/owner') AS OwnerList(OWNER)
	CROSS APPLY MainLock.Process.nodes('waiter-list/waiter') AS WaiterList(OWNER)
	),
Process
AS (
	-- get the data from the process node
	SELECT CTE.DeadlockID,
		Victim = CONVERT(BIT, CASE 
				WHEN Deadlock.Process.value('@id', 'varchar(50)') = ISNULL(Deadlock.Process.value('../../@victim', 'varchar(50)'), v.ID)
					THEN 1
				ELSE 0
				END),
		LockMode = Deadlock.Process.value('@lockMode', 'varchar(10)'), -- how is this different from in the resource-list section?
		ProcessID = Process.ID, --Deadlock.Process.value('@id', 'varchar(50)'),
		KPID = Deadlock.Process.value('@kpid', 'int'), -- kernel-process id / thread ID number
		SPID = Deadlock.Process.value('@spid', 'int'), -- system process id (connection to sql)
		SBID = Deadlock.Process.value('@sbid', 'int'), -- system batch id / request_id (a query that a SPID is running)
		ECID = Deadlock.Process.value('@ecid', 'int'), -- execution context ID (a worker thread running part of a query)
		IsolationLevel = Deadlock.Process.value('@isolationlevel', 'varchar(200)'),
		WaitResource = Deadlock.Process.value('@waitresource', 'varchar(200)'),
		LogUsed = Deadlock.Process.value('@logused', 'int'),
		ClientApp = Deadlock.Process.value('@clientapp', 'varchar(100)'),
		HostName = Deadlock.Process.value('@hostname', 'varchar(20)'),
		LoginName = Deadlock.Process.value('@loginname', 'varchar(20)'),
		TransactionTime = Deadlock.Process.value('@lasttranstarted', 'datetime'),
		BatchStarted = Deadlock.Process.value('@lastbatchstarted', 'datetime'),
		BatchCompleted = Deadlock.Process.value('@lastbatchcompleted', 'datetime'),
		INPUTBUFFER = Input.Buffer.query('.'),
		CTE.DeadlockGraph,
		es.ExecutionStack,
		SQLHandle = ExecStack.Stack.value('@sqlhandle', 'varchar(64)'),
		QueryStatement = NULLIF(ExecStack.Stack.value('.', 'varchar(max)'), ''),
		--[QueryStatement] = Execution.Frame.value('.', 'varchar(max)'),
		ProcessQty = SUM(1) OVER (PARTITION BY CTE.DeadlockID),
		TranCount = Deadlock.Process.value('@trancount', 'int')
	FROM CTE
	CROSS APPLY CTE.DeadlockGraph.nodes('//deadlock/process-list/process') AS Deadlock(Process)
	CROSS APPLY (
		SELECT Deadlock.Process.value('@id', 'varchar(50)')
		) AS Process(ID)
	LEFT JOIN Victims AS v ON Process.ID = v.ID
	CROSS APPLY Deadlock.Process.nodes('inputbuf') AS Input(Buffer)
	CROSS APPLY Deadlock.Process.nodes('executionStack') AS Execution(Frame)
	-- get the data from the executionStack node as XML
	CROSS APPLY (
		SELECT ExecutionStack = (
				SELECT ProcNumber = ROW_NUMBER() OVER (
						PARTITION BY CTE.DeadlockID,
						Deadlock.Process.value('@id', 'varchar(50)'),
						Execution.Stack.value('@procname', 'sysname'),
						Execution.Stack.value('@code', 'varchar(MAX)') ORDER BY (
								SELECT 1
								)
						),
					ProcName = Execution.Stack.value('@procname', 'sysname'),
					Line = Execution.Stack.value('@line', 'int'),
					SQLHandle = Execution.Stack.value('@sqlhandle', 'varchar(64)'),
					Code = LTRIM(RTRIM(Execution.Stack.value('.', 'varchar(MAX)')))
				FROM Execution.Frame.nodes('frame') AS Execution(Stack)
				ORDER BY ProcNumber
				FOR XML path('frame'),
					root('executionStack'),
					type
				)
		) AS es
	CROSS APPLY Execution.Frame.nodes('frame') AS ExecStack(Stack)
	)
-- get the columns in the desired order
--SELECT * FROM Locks
SELECT p.DeadlockID,
	p.Victim,
	p.ProcessQty,
	ProcessNbr = DENSE_RANK() OVER (
		PARTITION BY p.DeadlockId ORDER BY p.ProcessID
		),
	p.LockMode,
	LockedObject = NULLIF(l.ObjectName, ''),
	l.database_id,
	l.AssociatedObjectId,
	LockProcess = p.ProcessID,
	p.KPID,
	p.SPID,
	p.SBID,
	p.ECID,
	p.TranCount,
	l.LockEvent,
	LockedMode = l.LockMode,
	l.WaitProcessID,
	l.WaitMode,
	p.WaitResource,
	l.WaitType,
	p.IsolationLevel,
	p.LogUsed,
	p.ClientApp,
	p.HostName,
	p.LoginName,
	p.TransactionTime,
	p.BatchStarted,
	p.BatchCompleted,
	p.QueryStatement,
	p.SQLHandle,
	p.INPUTBUFFER,
	p.DeadlockGraph,
	p.ExecutionStack
FROM Process AS p
LEFT JOIN Locks AS l --JOIN Process p
	ON p.DeadlockID = l.DeadlockID
	AND p.ProcessID = l.LockProcessID
ORDER BY p.DeadlockId,
	p.Victim DESC,
	p.ProcessId;
	/*

<deadlock-list>
<deadlock victim="process181735b88">
<process-list>
<process id="process181735b88" taskpriority="0" logused="352" waitresource="KEY: 21:72057594049658880 (010008207756)" waittime="9564" ownerId="181040" transactionname="user_transaction" lasttranstarted="2011-05-15T00:12:52.523" XDES="0x19208ce90" lockMode="X" schedulerid="2" kpid="4380" status="suspended" spid="60" sbid="0" ecid="0" priority="0" trancount="2" lastbatchstarted="2011-05-15T00:12:52.523" lastbatchcompleted="2011-05-15T00:12:28.323" clientapp="Microsoft SQL Server Management Studio - Query" hostname="WS-HPDV7" hostpid="4636" loginname="WS-HPDV7\wgshef" isolationlevel="read committed (2)" xactid="181040" currentdb="21" lockTimeout="4294967295" clientoption1="671090784" clientoption2="390200">
<executionStack>
<frame procname="adhoc" line="5" stmtstart="38" sqlhandle="0x0200000071e4b91c182ff5918af8199d2b19e9fb930172bc">
UPDATE [dbo].[Tally] set [N] = [N]-@1  WHERE [N]=@2     </frame>
<frame procname="adhoc" line="5" stmtstart="136" sqlhandle="0x02000000c2adc438b1f60f3b4049de8c294e3acf4c0113c0">
UPDATE dbo.Tally SET N = N-1 WHERE N = 1

--ROLLBACK TRANSACTION     </frame>
</executionStack>
<inputbuf>
BEGIN TRANSACTION

UPDATE dbo.Tally_sm SET N = N-2 WHERE N = 1

UPDATE dbo.Tally SET N = N-1 WHERE N = 1

--ROLLBACK TRANSACTION    </inputbuf>
</process>
<process id="process181734bc8" taskpriority="0" logused="360" waitresource="KEY: 21:72057594038976512 (010086470766)" waittime="4208" ownerId="181034" transactionname="user_transaction" lasttranstarted="2011-05-15T00:12:46.773" XDES="0x18f0c9970" lockMode="X" schedulerid="2" kpid="4388" status="suspended" spid="56" sbid="0" ecid="0" priority="0" trancount="2" lastbatchstarted="2011-05-15T00:12:57.880" lastbatchcompleted="2011-05-15T00:12:46.773" clientapp="Microsoft SQL Server Management Studio - Query" hostname="WS-HPDV7" hostpid="4636" loginname="WS-HPDV7\wgshef" isolationlevel="read committed (2)" xactid="181034" currentdb="21" lockTimeout="4294967295" clientoption1="671090784" clientoption2="390200">
<executionStack>
<frame procname="adhoc" line="1" stmtstart="38" sqlhandle="0x02000000c556121369885d6117621bc2f0e2091c81bf6e70">
UPDATE [dbo].[Tally_sm] set [N] = [N]-@1  WHERE [N]=@2     </frame>
<frame procname="adhoc" line="1" sqlhandle="0x02000000b8cc250508388dfe00dcef08bfd27496a9da3b34">
UPDATE dbo.Tally_sm SET N = N-2 WHERE N = 1     </frame>
</executionStack>
<inputbuf>
UPDATE dbo.Tally_sm SET N = N-2 WHERE N = 1
</inputbuf>
</process>
</process-list>
<resource-list>
<keylock hobtid="72057594049658880" dbid="21" objectname="Sandbox.dbo.Tally" indexname="PK_Tally" id="lock1852e8700" mode="X" associatedObjectId="72057594049658880">
<owner-list>
<owner id="process181734bc8" mode="X"/>
</owner-list>
<waiter-list>
<waiter id="process181735b88" mode="X" requestType="wait"/>
</waiter-list>
</keylock>
<keylock hobtid="72057594038976512" dbid="21" objectname="Sandbox.dbo.Tally_sm" indexname="PK_Tally_sm" id="lock184e54080" mode="X" associatedObjectId="72057594038976512">
<owner-list>
<owner id="process181735b88" mode="X"/>
</owner-list>
<waiter-list>
<waiter id="process181734bc8" mode="X" requestType="wait"/>
</waiter-list>
</keylock>
</resource-list>
</deadlock>
</deadlock-list>



<deadlock>
 <victim-list>
  <victimProcess id="process3749e50c8" />
  <victimProcess id="process3749e4928" />
  <victimProcess id="process3749e5c38" />
  <victimProcess id="process37797c928" />
  <victimProcess id="process3749e4558" />
  <victimProcess id="process3747e70c8" />
  <victimProcess id="process378639c38" />
  <victimProcess id="process375a72558" />
  <victimProcess id="process3786390c8" />
 </victim-list>
 <process-list>
  <process id="process3749e50c8" taskpriority="0" logused="0" waitresource="OBJECT: 2:264388011:0 " waittime="4486" ownerId="2903582" transactionname="user_transaction" lasttranstarted="2012-10-25T20:49:28.517" XDES="0x377ea23a8" lockMode="IX" schedulerid="1" kpid="38928" status="suspended" spid="55" sbid="0" ecid="0" priority="0" trancount="3" lastbatchstarted="2012-10-25T20:49:56.640" lastbatchcompleted="2012-10-25T20:49:56.633" lastattention="1900-01-01T00:00:00.633" clientapp=".Net SqlClient Data Provider" hostname="WS-HPDV7" hostpid="17052" loginname="WS-HPDV7\wgshef" isolationlevel="read committed (2)" xactid="2903582" currentdb="2" lockTimeout="4294967295" clientoption1="673187936" clientoption2="390200">
   <executionStack>
    <frame procname="adhoc" line="6" stmtstart="16" sqlhandle="0x02000000eeda9d033f24084ed8191c2cee06a6148f7ea6240000000000000000000000000000000000000000">
UPDATE [dbo].[junk] set [i] = @1    </frame>
    <frame procname="adhoc" line="6" stmtstart="142" sqlhandle="0x0200000095ebf5346d60a6b12dbee5fd29e4a7e173e769f80000000000000000000000000000000000000000">
UPDATE dbo.junk SET i=1;

--ROLLBACK    </frame>
   </executionStack>
   <inputbuf>

BEGIN TRANSACTION

SELECT * FROM junk WITH (TABLOCK, HOLDLOCK);

UPDATE dbo.junk SET i=1;

--ROLLBACK   </inputbuf>
  </process>
  <process id="process3749e4928" taskpriority="0" logused="0" waitresource="OBJECT: 2:264388011:0 " waittime="4486" ownerId="2903586" transactionname="user_transaction" lasttranstarted="2012-10-25T20:49:28.517" XDES="0x37e04f078" lockMode="IX" schedulerid="1" kpid="4244" status="suspended" spid="64" sbid="0" ecid="0" priority="0" trancount="3" lastbatchstarted="2012-10-25T20:49:56.640" lastbatchcompleted="2012-10-25T20:49:56.637" lastattention="1900-01-01T00:00:00.637" clientapp=".Net SqlClient Data Provider" hostname="WS-HPDV7" hostpid="17052" loginname="WS-HPDV7\wgshef" isolationlevel="read committed (2)" xactid="2903586" currentdb="2" lockTimeout="4294967295" clientoption1="673187936" clientoption2="390200">
   <executionStack>
    <frame procname="adhoc" line="6" stmtstart="16" sqlhandle="0x02000000eeda9d033f24084ed8191c2cee06a6148f7ea6240000000000000000000000000000000000000000">
UPDATE [dbo].[junk] set [i] = @1    </frame>
    <frame procname="adhoc" line="6" stmtstart="142" sqlhandle="0x0200000095ebf5346d60a6b12dbee5fd29e4a7e173e769f80000000000000000000000000000000000000000">
UPDATE dbo.junk SET i=1;

--ROLLBACK    </frame>
   </executionStack>
   <inputbuf>

BEGIN TRANSACTION

SELECT * FROM junk WITH (TABLOCK, HOLDLOCK);

UPDATE dbo.junk SET i=1;

--ROLLBACK   </inputbuf>
  </process>
  <process id="process3749e5c38" taskpriority="0" logused="0" waitresource="OBJECT: 2:264388011:0 " waittime="4487" ownerId="2903585" transactionname="user_transaction" lasttranstarted="2012-10-25T20:49:28.517" XDES="0x37ab7cd28" lockMode="IX" schedulerid="1" kpid="38892" status="suspended" spid="61" sbid="0" ecid="0" priority="0" trancount="3" lastbatchstarted="2012-10-25T20:49:56.640" lastbatchcompleted="2012-10-25T20:49:56.637" lastattention="1900-01-01T00:00:00.637" clientapp=".Net SqlClient Data Provider" hostname="WS-HPDV7" hostpid="17052" loginname="WS-HPDV7\wgshef" isolationlevel="read committed (2)" xactid="2903585" currentdb="2" lockTimeout="4294967295" clientoption1="673187936" clientoption2="390200">
   <executionStack>
    <frame procname="adhoc" line="6" stmtstart="16" sqlhandle="0x02000000eeda9d033f24084ed8191c2cee06a6148f7ea6240000000000000000000000000000000000000000">
UPDATE [dbo].[junk] set [i] = @1    </frame>
    <frame procname="adhoc" line="6" stmtstart="142" sqlhandle="0x0200000095ebf5346d60a6b12dbee5fd29e4a7e173e769f80000000000000000000000000000000000000000">
UPDATE dbo.junk SET i=1;

--ROLLBACK    </frame>
   </executionStack>
   <inputbuf>

BEGIN TRANSACTION

SELECT * FROM junk WITH (TABLOCK, HOLDLOCK);

UPDATE dbo.junk SET i=1;

--ROLLBACK   </inputbuf>
  </process>
  <process id="process37797c928" taskpriority="0" logused="0" waitresource="OBJECT: 2:264388011:0 " waittime="4487" ownerId="2903584" transactionname="user_transaction" lasttranstarted="2012-10-25T20:49:28.517" XDES="0x3754e8d28" lockMode="IX" schedulerid="1" kpid="32072" status="suspended" spid="59" sbid="0" ecid="0" priority="0" trancount="3" lastbatchstarted="2012-10-25T20:49:56.640" lastbatchcompleted="2012-10-25T20:49:56.637" lastattention="1900-01-01T00:00:00.637" clientapp=".Net SqlClient Data Provider" hostname="WS-HPDV7" hostpid="17052" loginname="WS-HPDV7\wgshef" isolationlevel="read committed (2)" xactid="2903584" currentdb="2" lockTimeout="4294967295" clientoption1="673187936" clientoption2="390200">
   <executionStack>
    <frame procname="adhoc" line="6" stmtstart="16" sqlhandle="0x02000000eeda9d033f24084ed8191c2cee06a6148f7ea6240000000000000000000000000000000000000000">
UPDATE [dbo].[junk] set [i] = @1    </frame>
    <frame procname="adhoc" line="6" stmtstart="142" sqlhandle="0x0200000095ebf5346d60a6b12dbee5fd29e4a7e173e769f80000000000000000000000000000000000000000">
UPDATE dbo.junk SET i=1;

--ROLLBACK    </frame>
   </executionStack>
   <inputbuf>

BEGIN TRANSACTION

SELECT * FROM junk WITH (TABLOCK, HOLDLOCK);

UPDATE dbo.junk SET i=1;

--ROLLBACK   </inputbuf>
  </process>
  <process id="process3749e4558" taskpriority="0" logused="0" waitresource="OBJECT: 2:264388011:0 " waittime="4487" ownerId="2903583" transactionname="user_transaction" lasttranstarted="2012-10-25T20:49:28.517" XDES="0x377ea2d28" lockMode="IX" schedulerid="1" kpid="36388" status="suspended" spid="57" sbid="0" ecid="0" priority="0" trancount="3" lastbatchstarted="2012-10-25T20:49:56.640" lastbatchcompleted="2012-10-25T20:49:56.637" lastattention="1900-01-01T00:00:00.637" clientapp=".Net SqlClient Data Provider" hostname="WS-HPDV7" hostpid="17052" loginname="WS-HPDV7\wgshef" isolationlevel="read committed (2)" xactid="2903583" currentdb="2" lockTimeout="4294967295" clientoption1="673187936" clientoption2="390200">
   <executionStack>
    <frame procname="adhoc" line="6" stmtstart="16" sqlhandle="0x02000000eeda9d033f24084ed8191c2cee06a6148f7ea6240000000000000000000000000000000000000000">
UPDATE [dbo].[junk] set [i] = @1    </frame>
    <frame procname="adhoc" line="6" stmtstart="142" sqlhandle="0x0200000095ebf5346d60a6b12dbee5fd29e4a7e173e769f80000000000000000000000000000000000000000">
UPDATE dbo.junk SET i=1;

--ROLLBACK    </frame>
   </executionStack>
   <inputbuf>

BEGIN TRANSACTION

SELECT * FROM junk WITH (TABLOCK, HOLDLOCK);

UPDATE dbo.junk SET i=1;

--ROLLBACK   </inputbuf>
  </process>
  <process id="process3747e70c8" taskpriority="0" logused="0" waitresource="OBJECT: 2:264388011:0 " waittime="4487" ownerId="2903581" transactionname="user_transaction" lasttranstarted="2012-10-25T20:49:28.517" XDES="0x37ab7c3a8" lockMode="IX" schedulerid="2" kpid="37560" status="suspended" spid="63" sbid="0" ecid="0" priority="0" trancount="3" lastbatchstarted="2012-10-25T20:49:56.640" lastbatchcompleted="2012-10-25T20:49:56.627" lastattention="1900-01-01T00:00:00.627" clientapp=".Net SqlClient Data Provider" hostname="WS-HPDV7" hostpid="17052" loginname="WS-HPDV7\wgshef" isolationlevel="read committed (2)" xactid="2903581" currentdb="2" lockTimeout="4294967295" clientoption1="673187936" clientoption2="390200">
   <executionStack>
    <frame procname="adhoc" line="6" stmtstart="16" sqlhandle="0x02000000eeda9d033f24084ed8191c2cee06a6148f7ea6240000000000000000000000000000000000000000">
UPDATE [dbo].[junk] set [i] = @1    </frame>
    <frame procname="adhoc" line="6" stmtstart="142" sqlhandle="0x0200000095ebf5346d60a6b12dbee5fd29e4a7e173e769f80000000000000000000000000000000000000000">
UPDATE dbo.junk SET i=1;

--ROLLBACK    </frame>
   </executionStack>
   <inputbuf>

BEGIN TRANSACTION

SELECT * FROM junk WITH (TABLOCK, HOLDLOCK);

UPDATE dbo.junk SET i=1;

--ROLLBACK   </inputbuf>
  </process>
  <process id="process378639c38" taskpriority="0" logused="0" waitresource="OBJECT: 2:264388011:0 " waittime="4487" ownerId="2903580" transactionname="user_transaction" lasttranstarted="2012-10-25T20:49:28.517" XDES="0x377b60d28" lockMode="IX" schedulerid="2" kpid="22656" status="suspended" spid="62" sbid="0" ecid="0" priority="0" trancount="3" lastbatchstarted="2012-10-25T20:49:56.640" lastbatchcompleted="2012-10-25T20:49:56.627" lastattention="1900-01-01T00:00:00.627" clientapp=".Net SqlClient Data Provider" hostname="WS-HPDV7" hostpid="17052" loginname="WS-HPDV7\wgshef" isolationlevel="read committed (2)" xactid="2903580" currentdb="2" lockTimeout="4294967295" clientoption1="673187936" clientoption2="390200">
   <executionStack>
    <frame procname="adhoc" line="6" stmtstart="16" sqlhandle="0x02000000eeda9d033f24084ed8191c2cee06a6148f7ea6240000000000000000000000000000000000000000">
UPDATE [dbo].[junk] set [i] = @1    </frame>
    <frame procname="adhoc" line="6" stmtstart="142" sqlhandle="0x0200000095ebf5346d60a6b12dbee5fd29e4a7e173e769f80000000000000000000000000000000000000000">
UPDATE dbo.junk SET i=1;

--ROLLBACK    </frame>
   </executionStack>
   <inputbuf>

BEGIN TRANSACTION

SELECT * FROM junk WITH (TABLOCK, HOLDLOCK);

UPDATE dbo.junk SET i=1;

--ROLLBACK   </inputbuf>
  </process>
  <process id="process375a72558" taskpriority="0" logused="0" waitresource="OBJECT: 2:264388011:0 " waittime="4487" ownerId="2903579" transactionname="user_transaction" lasttranstarted="2012-10-25T20:49:28.517" XDES="0x377b616a8" lockMode="IX" schedulerid="2" kpid="22960" status="suspended" spid="60" sbid="0" ecid="0" priority="0" trancount="3" lastbatchstarted="2012-10-25T20:49:56.640" lastbatchcompleted="2012-10-25T20:49:56.623" lastattention="1900-01-01T00:00:00.623" clientapp=".Net SqlClient Data Provider" hostname="WS-HPDV7" hostpid="17052" loginname="WS-HPDV7\wgshef" isolationlevel="read committed (2)" xactid="2903579" currentdb="2" lockTimeout="4294967295" clientoption1="673187936" clientoption2="390200">
   <executionStack>
    <frame procname="adhoc" line="6" stmtstart="16" sqlhandle="0x02000000eeda9d033f24084ed8191c2cee06a6148f7ea6240000000000000000000000000000000000000000">
UPDATE [dbo].[junk] set [i] = @1    </frame>
    <frame procname="adhoc" line="6" stmtstart="142" sqlhandle="0x0200000095ebf5346d60a6b12dbee5fd29e4a7e173e769f80000000000000000000000000000000000000000">
UPDATE dbo.junk SET i=1;

--ROLLBACK    </frame>
   </executionStack>
   <inputbuf>

BEGIN TRANSACTION

SELECT * FROM junk WITH (TABLOCK, HOLDLOCK);

UPDATE dbo.junk SET i=1;

--ROLLBACK   </inputbuf>
  </process>
  <process id="process3786390c8" taskpriority="0" logused="0" waitresource="OBJECT: 2:264388011:0 " waittime="4487" ownerId="2903578" transactionname="user_transaction" lasttranstarted="2012-10-25T20:49:28.517" XDES="0x377b603a8" lockMode="IX" schedulerid="2" kpid="30268" status="suspended" spid="58" sbid="0" ecid="0" priority="0" trancount="3" lastbatchstarted="2012-10-25T20:49:56.640" lastbatchcompleted="2012-10-25T20:49:56.623" lastattention="1900-01-01T00:00:00.623" clientapp=".Net SqlClient Data Provider" hostname="WS-HPDV7" hostpid="17052" loginname="WS-HPDV7\wgshef" isolationlevel="read committed (2)" xactid="2903578" currentdb="2" lockTimeout="4294967295" clientoption1="673187936" clientoption2="390200">
   <executionStack>
    <frame procname="adhoc" line="6" stmtstart="16" sqlhandle="0x02000000eeda9d033f24084ed8191c2cee06a6148f7ea6240000000000000000000000000000000000000000">
UPDATE [dbo].[junk] set [i] = @1    </frame>
    <frame procname="adhoc" line="6" stmtstart="142" sqlhandle="0x0200000095ebf5346d60a6b12dbee5fd29e4a7e173e769f80000000000000000000000000000000000000000">
UPDATE dbo.junk SET i=1;

--ROLLBACK    </frame>
   </executionStack>
   <inputbuf>

BEGIN TRANSACTION

SELECT * FROM junk WITH (TABLOCK, HOLDLOCK);

UPDATE dbo.junk SET i=1;

--ROLLBACK   </inputbuf>
  </process>
  <process id="process3747e7868" taskpriority="0" logused="0" waitresource="OBJECT: 2:264388011:0 " waittime="4487" ownerId="2903577" transactionname="user_transaction" lasttranstarted="2012-10-25T20:49:28.517" XDES="0x37ab7d6a8" lockMode="IX" schedulerid="2" kpid="37880" status="suspended" spid="56" sbid="0" ecid="0" priority="0" trancount="3" lastbatchstarted="2012-10-25T20:49:56.640" lastbatchcompleted="2012-10-25T20:49:56.623" lastattention="1900-01-01T00:00:00.623" clientapp=".Net SqlClient Data Provider" hostname="WS-HPDV7" hostpid="17052" loginname="WS-HPDV7\wgshef" isolationlevel="read committed (2)" xactid="2903577" currentdb="2" lockTimeout="4294967295" clientoption1="673187936" clientoption2="390200">
   <executionStack>
    <frame procname="adhoc" line="6" stmtstart="16" sqlhandle="0x02000000eeda9d033f24084ed8191c2cee06a6148f7ea6240000000000000000000000000000000000000000">
UPDATE [dbo].[junk] set [i] = @1    </frame>
    <frame procname="adhoc" line="6" stmtstart="142" sqlhandle="0x0200000095ebf5346d60a6b12dbee5fd29e4a7e173e769f80000000000000000000000000000000000000000">
UPDATE dbo.junk SET i=1;

--ROLLBACK    </frame>
   </executionStack>
   <inputbuf>

BEGIN TRANSACTION

SELECT * FROM junk WITH (TABLOCK, HOLDLOCK);

UPDATE dbo.junk SET i=1;

--ROLLBACK   </inputbuf>
  </process>
 </process-list>
 <resource-list>
  <objectlock lockPartition="0" objid="264388011" subresource="FULL" dbid="2" objectname="tempdb.dbo.junk" id="lock37a897b00" mode="S" associatedObjectId="264388011">
   <owner-list>
    <owner id="process37797c928" mode="S" />
    <owner id="process3749e4558" mode="S" />
    <owner id="process3747e70c8" mode="S" />
    <owner id="process3747e70c8" mode="IX" requestType="convert" />
    <owner id="process3749e4558" mode="IX" requestType="convert" />
    <owner id="process37797c928" mode="IX" requestType="convert" />
   </owner-list>
   <waiter-list>
    <waiter id="process3749e50c8" mode="IX" requestType="convert" />
   </waiter-list>
  </objectlock>
  <objectlock lockPartition="0" objid="264388011" subresource="FULL" dbid="2" objectname="tempdb.dbo.junk" id="lock37a897b00" mode="S" associatedObjectId="264388011">
   <owner-list>
    <owner id="process37797c928" mode="S" />
    <owner id="process3749e4558" mode="S" />
    <owner id="process3747e70c8" mode="S" />
    <owner id="process3747e70c8" mode="IX" requestType="convert" />
    <owner id="process3749e4558" mode="IX" requestType="convert" />
    <owner id="process37797c928" mode="IX" requestType="convert" />
   </owner-list>
   <waiter-list>
    <waiter id="process3749e4928" mode="IX" requestType="convert" />
   </waiter-list>
  </objectlock>
  <objectlock lockPartition="0" objid="264388011" subresource="FULL" dbid="2" objectname="tempdb.dbo.junk" id="lock37a897b00" mode="S" associatedObjectId="264388011">
   <owner-list>
    <owner id="process37797c928" mode="S" />
    <owner id="process3749e4558" mode="S" />
    <owner id="process3747e70c8" mode="S" />
    <owner id="process3747e70c8" mode="IX" requestType="convert" />
    <owner id="process3749e4558" mode="IX" requestType="convert" />
    <owner id="process37797c928" mode="IX" requestType="convert" />
   </owner-list>
   <waiter-list>
    <waiter id="process3749e5c38" mode="IX" requestType="convert" />
   </waiter-list>
  </objectlock>
  <objectlock lockPartition="0" objid="264388011" subresource="FULL" dbid="2" objectname="tempdb.dbo.junk" id="lock37a897b00" mode="S" associatedObjectId="264388011">
   <owner-list>
    <owner id="process3749e5c38" mode="S" />
    <owner id="process3749e4558" mode="S" />
    <owner id="process3747e70c8" mode="S" />
    <owner id="process3747e70c8" mode="IX" requestType="convert" />
    <owner id="process3749e4558" mode="IX" requestType="convert" />
    <owner id="process3749e5c38" mode="IX" requestType="convert" />
   </owner-list>
   <waiter-list>
    <waiter id="process37797c928" mode="IX" requestType="convert" />
   </waiter-list>
  </objectlock>
  <objectlock lockPartition="0" objid="264388011" subresource="FULL" dbid="2" objectname="tempdb.dbo.junk" id="lock37a897b00" mode="S" associatedObjectId="264388011">
   <owner-list>
    <owner id="process37797c928" mode="S" />
    <owner id="process3749e50c8" mode="S" />
    <owner id="process3747e70c8" mode="S" />
    <owner id="process3749e50c8" mode="IX" requestType="convert" />
    <owner id="process3747e70c8" mode="IX" requestType="convert" />
    <owner id="process37797c928" mode="IX" requestType="convert" />
   </owner-list>
   <waiter-list>
    <waiter id="process3749e4558" mode="IX" requestType="convert" />
   </waiter-list>
  </objectlock>
  <objectlock lockPartition="0" objid="264388011" subresource="FULL" dbid="2" objectname="tempdb.dbo.junk" id="lock37a897b00" mode="S" associatedObjectId="264388011">
   <owner-list>
    <owner id="process37797c928" mode="S" />
    <owner id="process3749e50c8" mode="S" />
    <owner id="process3747e7868" mode="S" />
    <owner id="process3747e7868" mode="IX" requestType="convert" />
    <owner id="process3749e50c8" mode="IX" requestType="convert" />
    <owner id="process37797c928" mode="IX" requestType="convert" />
   </owner-list>
   <waiter-list>
    <waiter id="process3747e70c8" mode="IX" requestType="convert" />
   </waiter-list>
  </objectlock>
  <objectlock lockPartition="0" objid="264388011" subresource="FULL" dbid="2" objectname="tempdb.dbo.junk" id="lock37a897b00" mode="S" associatedObjectId="264388011">
   <owner-list>
    <owner id="process37797c928" mode="S" />
    <owner id="process3749e50c8" mode="S" />
    <owner id="process3747e7868" mode="S" />
    <owner id="process3747e7868" mode="IX" requestType="convert" />
    <owner id="process3749e50c8" mode="IX" requestType="convert" />
    <owner id="process37797c928" mode="IX" requestType="convert" />
   </owner-list>
   <waiter-list>
    <waiter id="process378639c38" mode="IX" requestType="convert" />
   </waiter-list>
  </objectlock>
  <objectlock lockPartition="0" objid="264388011" subresource="FULL" dbid="2" objectname="tempdb.dbo.junk" id="lock37a897b00" mode="S" associatedObjectId="264388011">
   <owner-list>
    <owner id="process37797c928" mode="S" />
    <owner id="process3749e50c8" mode="S" />
    <owner id="process3747e7868" mode="S" />
    <owner id="process3747e7868" mode="IX" requestType="convert" />
    <owner id="process3749e50c8" mode="IX" requestType="convert" />
    <owner id="process37797c928" mode="IX" requestType="convert" />
   </owner-list>
   <waiter-list>
    <waiter id="process375a72558" mode="IX" requestType="convert" />
   </waiter-list>
  </objectlock>
  <objectlock lockPartition="0" objid="264388011" subresource="FULL" dbid="2" objectname="tempdb.dbo.junk" id="lock37a897b00" mode="S" associatedObjectId="264388011">
   <owner-list>
    <owner id="process37797c928" mode="S" />
    <owner id="process3749e50c8" mode="S" />
    <owner id="process3747e7868" mode="S" />
    <owner id="process3747e7868" mode="IX" requestType="convert" />
    <owner id="process3749e50c8" mode="IX" requestType="convert" />
    <owner id="process37797c928" mode="IX" requestType="convert" />
   </owner-list>
   <waiter-list>
    <waiter id="process3786390c8" mode="IX" requestType="convert" />
   </waiter-list>
  </objectlock>
  <objectlock lockPartition="0" objid="264388011" subresource="FULL" dbid="2" objectname="tempdb.dbo.junk" id="lock37a897b00" mode="S" associatedObjectId="264388011">
   <owner-list>
    <owner id="process37797c928" mode="S" />
    <owner id="process3749e50c8" mode="S" />
    <owner id="process3749e50c8" mode="IX" requestType="convert" />
    <owner id="process37797c928" mode="IX" requestType="convert" />
   </owner-list>
   <waiter-list>
    <waiter id="process3747e7868" mode="IX" requestType="convert" />
   </waiter-list>
  </objectlock>
 </resource-list>
</deadlock>

*/
