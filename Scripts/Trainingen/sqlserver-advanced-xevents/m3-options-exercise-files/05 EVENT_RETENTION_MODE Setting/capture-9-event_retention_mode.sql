-- Alter the event session to specify a MAX_EVENT_SIZE
ALTER EVENT SESSION [DefaultBuffers] 
ON SERVER 
WITH (EVENT_RETENTION_MODE=ALLOW_MULTIPLE_EVENT_LOSS)
GO

-- Start the event session
ALTER EVENT SESSION [DefaultBuffers]
ON SERVER
STATE = START;
GO

-- Show the buffer_policy_desc
SELECT 
	name,
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