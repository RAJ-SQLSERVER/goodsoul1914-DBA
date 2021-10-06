-- Stop the event session
ALTER EVENT SESSION [DefaultBuffers]
ON SERVER
STATE = STOP;
GO

ALTER EVENT SESSION [DefaultBuffers]
ON SERVER
WITH (STARTUP_STATE = ON);
GO

-- Remove the -P24 startup parameter and restart the instance

-- Show the DefaultBuffers session started automatically with the instance
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
WHERE name IN (N'DefaultBuffers', N'PartitionedBuffers');
GO

-- Drop the event sessions
DROP EVENT SESSION [DefaultBuffers]
ON SERVER;
GO

DROP EVENT SESSION [PartitionedBuffers]
ON SERVER;
GO