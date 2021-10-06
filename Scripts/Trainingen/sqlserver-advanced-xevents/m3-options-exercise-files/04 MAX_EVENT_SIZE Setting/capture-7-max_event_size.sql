-- Alter the event session to specify a MAX_EVENT_SIZE
ALTER EVENT SESSION [DefaultBuffers] 
ON SERVER 
WITH (MAX_EVENT_SIZE=4096 KB)
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

-- Stop the event session
ALTER EVENT SESSION [DefaultBuffers]
ON SERVER
STATE = STOP;
GO

-- Do not drop the event session it will be used in a later demo