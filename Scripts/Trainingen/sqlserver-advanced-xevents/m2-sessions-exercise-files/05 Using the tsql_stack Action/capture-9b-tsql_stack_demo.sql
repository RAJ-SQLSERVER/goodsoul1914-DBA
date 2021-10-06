USE [tsql_stackDemo];
GO

-- First get the object_id of the function
SELECT OBJECT_ID(N'ReturnsTrue');
GO

-- If the event session exists drop it
IF EXISTS (SELECT 1 
			FROM sys.server_event_sessions 
			WHERE name = 'tsql_stack')
	DROP EVENT SESSION [tsql_stack] ON SERVER;
GO

-- Create the Event Session 
CREATE EVENT SESSION [tsql_stack] 
ON SERVER 
ADD EVENT sqlserver.module_start(
    ACTION(sqlserver.tsql_stack)
    WHERE ([object_id]=245575913)) 
ADD TARGET package0.ring_buffer;
GO

-- Start the event session
ALTER EVENT SESSION [tsql_stack]
ON SERVER
STATE=START;
GO

-- Execute the test procedures
EXECUTE dbo.CalledFirst;
EXECUTE dbo.OtherProcedure;


-- Extract the Event information from the Event Session
SELECT 
	ROW_NUMBER() OVER (ORDER BY XEvent.value('(event/@timestamp)[1]', 'datetime2')) AS event_id,
	XEvent.query('(action[@name="tsql_stack"]/value/frames)[1]') AS [tsql_stack]
FROM 
(    -- Cast the target_data to XML 
    SELECT CAST(target_data AS XML) AS TargetData 
    FROM sys.dm_xe_session_targets st 
    JOIN sys.dm_xe_sessions s 
        ON s.address = st.event_session_address 
    WHERE name = N'tsql_stack' 
        AND target_name = N'ring_buffer'
) AS Data 
-- Split out the Event Nodes 
CROSS APPLY TargetData.nodes ('RingBufferTarget/event') AS XEventData (XEvent);

-- Lets break down the tsql_stack
SELECT 
	event_id,
	frame.value('(@level)[1]', 'int') AS [level],
	frame.value('xs:hexBinary(substring((@handle)[1], 3))', 'varbinary(max)') AS [handle],
	frame.value('(@line)[1]', 'int') AS [line],
	frame.value('(@offsetStart)[1]', 'int') AS [offset_start],
	frame.value('(@offsetEnd)[1]', 'int') AS [offset_end]
FROM
(
	SELECT 
		ROW_NUMBER() OVER (ORDER BY XEvent.value('(event/@timestamp)[1]', 'datetime2')) AS event_id,
		XEvent.query('(action[@name="tsql_stack"]/value/frames)[1]') AS [tsql_stack]
	FROM 
	(    -- Cast the target_data to XML 
		SELECT CAST(target_data AS XML) AS TargetData 
		FROM sys.dm_xe_session_targets st 
		JOIN sys.dm_xe_sessions s 
			ON s.address = st.event_session_address 
		WHERE name = N'tsql_stack' 
			AND target_name = N'ring_buffer'
	) AS Data 
	-- Split out the Event Nodes 
	CROSS APPLY TargetData.nodes ('RingBufferTarget/event') AS XEventData (XEvent)
) AS tab (event_id, tsql_stack)
CROSS APPLY tsql_stack.nodes ('(frames/frame)') AS stack(frame);


-- What's executing the function
SELECT
	event_id,
	level,
	handle,
	line,
	offset_start,
	offset_end,
	st.dbid,
	st.objectid,
	OBJECT_NAME(st.objectid, st.dbid) AS ObjectName,
    SUBSTRING(st.text, (offset_start/2)+1, 
        ((CASE offset_end
          WHEN -1 THEN DATALENGTH(st.text)
         ELSE offset_end
         END - offset_start)/2) + 1) AS stmt

FROM
(
	SELECT 
		event_id,
		frame.value('(@level)[1]', 'int') AS [level],
		frame.value('xs:hexBinary(substring((@handle)[1], 3))', 'varbinary(max)') AS [handle],
		frame.value('(@line)[1]', 'int') AS [line],
		frame.value('(@offsetStart)[1]', 'int') AS [offset_start],
		frame.value('(@offsetEnd)[1]', 'int') AS [offset_end]
	FROM
	(
		SELECT 
			ROW_NUMBER() OVER (ORDER BY XEvent.value('(event/@timestamp)[1]', 'datetime2')) AS event_id,
			XEvent.query('(action[@name="tsql_stack"]/value/frames)[1]') AS [tsql_stack]
		FROM 
		(    -- Cast the target_data to XML 
			SELECT CAST(target_data AS XML) AS TargetData 
			FROM sys.dm_xe_session_targets st 
			JOIN sys.dm_xe_sessions s 
				ON s.address = st.event_session_address 
			WHERE name = N'tsql_stack' 
				AND target_name = N'ring_buffer'
		) AS Data 
		-- Split out the Event Nodes 
		CROSS APPLY TargetData.nodes ('RingBufferTarget/event') AS XEventData (XEvent)
	) AS tab 
	CROSS APPLY tsql_stack.nodes ('(frames/frame)') AS stack(frame)
) AS tab2
CROSS APPLY sys.dm_exec_sql_text(handle) AS st;



