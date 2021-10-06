-- If the event session exists drop it
IF EXISTS (SELECT 1 
			FROM sys.server_event_sessions 
			WHERE name = N'DefaultBuffers')
	DROP EVENT SESSION [DefaultBuffers] 
	ON SERVER;
GO

-- Create the Event Session
CREATE EVENT SESSION [DefaultBuffers]
ON SERVER
ADD EVENT sqlserver.error_reported
GO

-- Start the event session
ALTER EVENT SESSION [DefaultBuffers]
ON SERVER
STATE = START;
GO

-- Show the buffer size and distribution
SELECT 
	name,
	total_regular_buffers,
	regular_buffer_Size,
	total_large_buffers,
	large_buffer_size,
	total_buffer_size,
	buffer_policy_desc,
	flag_desc
FROM sys.dm_xe_sessions
WHERE name = N'DefaultBuffers';

-- Stop event session in UI and show memory configuration options

-- Stop the event session
ALTER EVENT SESSION [DefaultBuffers]
ON SERVER
STATE = STOP;
GO

-- Alter the event session to change MAX_MEMORY
ALTER EVENT SESSION [DefaultBuffers]
ON SERVER
WITH (MAX_MEMORY=8MB);
GO

-- Start the event session
ALTER EVENT SESSION [DefaultBuffers]
ON SERVER
STATE = START;
GO

-- Show the buffer size and distribution
SELECT 
	name,
	total_regular_buffers,
	regular_buffer_Size,
	total_large_buffers,
	large_buffer_size,
	total_buffer_size,
	buffer_policy_desc,
	flag_desc
FROM sys.dm_xe_sessions
WHERE name = N'DefaultBuffers';

-- Do not drop the event session it will be used in a later demo