-- Returns information about the cursors that are open in various databases
-- 
-- Fetch_buffer_size	1 for TSQL cursors. Higher value can be set for API cursors.
-- Fetch_buffer_start	For FAST_FORWARD and DYNAMIC cursors it is -1 when open and 0 when closed 
--						or before the first row. For STATIC and KEYSET it returns -1 if positioned 
--						beyond last row, 0 when not open and positioned row number in other cases.
--
---------------------------------------------------------------------------------------------------
SELECT session_id,
	cursor_id,
	name,
	properties,
	creation_time,
	is_open,
	is_async_population,
	is_close_on_commit,
	fetch_status,
	fetch_buffer_size,
	fetch_buffer_start,
	ansi_position,
	worker_time / 1000 AS worker_ms,
	reads,
	writes
FROM sys.dm_exec_cursors(0);
GO
