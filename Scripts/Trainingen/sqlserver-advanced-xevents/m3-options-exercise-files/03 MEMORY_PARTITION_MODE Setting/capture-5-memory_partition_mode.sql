-- If the event session exists drop it
IF EXISTS (SELECT 1 
			FROM sys.server_event_sessions 
			WHERE name = N'PartitionedBuffers')
	DROP EVENT SESSION [PartitionedBuffers] 
	ON SERVER;
GO

-- Create the event session
CREATE EVENT SESSION [PartitionedBuffers]
ON SERVER
ADD EVENT sqlserver.error_reported
WITH (MAX_MEMORY = 4MB, 
	  MEMORY_PARTITION_MODE = PER_CPU); --2.5 buffers per CPU
GO

-- Start the event session
ALTER EVENT SESSION [PartitionedBuffers]
ON SERVER
STATE=START;
Go

-- Show the impact of PER_CPU partitioning
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
WHERE name = N'PartitionedBuffers';
GO

-- Add -P24 startup parameter to the instance and restart

-- Start the event session
ALTER EVENT SESSION [PartitionedBuffers]
ON SERVER
STATE=START;
GO

-- Show the impact of PER_CPU partitioning now
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
WHERE name = N'PartitionedBuffers';
GO

-- Do not drop the event session it will be used in a later demo