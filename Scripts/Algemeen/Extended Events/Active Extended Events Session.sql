-- Returns information about an active extended events session. 
-- This session is a collection of events, actions, and targets.
-- 
-- Pending_buffers				The number of buffers pending on the processing.
-- Total_regular_buffers		Regular buffers are used by most events. This gives the total number of regular buffers. This is controlled based on regular_buffer_size and MEMORY_PARTITION_MODE.
-- Regular_buffer_size			The size of the regular buffer in bytes. This can be controlled by MAX_MEMORY option in CREATE EVENT SESSION. Default is 4 MB.
-- Total_large_buffers			Few events use large buffers which is allocated at event session start. This is based on large_buffer_size
-- Large_buffer_size			The size of large buffer. This can be controlled by MAX_EVENT_SIZE option.
-- Total_buffer_size			The total buffer size used to store event data for the session.
-- Buffer_policy_desc			Specifies how the buffer is handled when it is full.
-- Flag_desc					Description of flags set on the session.
-- Dropped_event_count			Events dropped when buffers are full. Value is 0 if the policy is ?do not drop events? or ?drop full buffer?.
-- Dropped_buffer_count			Buffers dropped when buffers are full. Value is 0 if the policy is ?do not drop events? or ?drop event?.
-- Blocked_event_fire_count		This is the time the event firing is blocked when the buffer is full. Value is 0 if the policy is ?drop event? or ?drop buffer?.
-- Largest_event_dropped_size	This is the largest event that did not fit in the buffer. This will help you in deciding the MAX_EVENT_SIZE.
--
---------------------------------------------------------------------------------------------------

select name, 
	   pending_buffers as PendingBuf, 
	   total_regular_buffers as regBufCnt, 
	   regular_buffer_size as regBufSize, 
	   total_large_buffers as largeBufCnt, 
	   total_buffer_size as largeBufSize, 
	   buffer_policy_desc as bufPolicy, 
	   flag_desc as flag, 
	   dropped_event_count as dropEventCnt, 
	   dropped_buffer_count as dropBufCnt, 
	   blocked_event_fire_time as blockedTime, 
	   largest_event_dropped_size as largeEventDropSize
from sys.dm_xe_sessions;
go

--

select xs.name, 
	   xsoc.column_name, 
	   xsoc.column_value, 
	   xsoc.object_type, 
	   xsoc.object_name
from sys.dm_xe_session_object_columns as xsoc
	 inner join sys.dm_xe_sessions as xs on xsoc.event_session_address = xs.address;
go

--

select xs.name, 
	   xst.target_name, 
	   xst.execution_count, 
	   xst.execution_duration_ms, 
	   xst.target_data
from sys.dm_xe_session_targets as xst
	 inner join sys.dm_xe_sessions as xs on xst.event_session_address = xs.address;
go

--

select xs.name, 
	   xse.event_name, 
	   xse.event_predicate
from sys.dm_xe_session_events as xse
	 inner join sys.dm_xe_sessions as xs on xse.event_session_address = xs.address;
go

--

select xs.name, 
	   xsea.action_name, 
	   xsea.event_name
from sys.dm_xe_session_event_actions as xsea
	 inner join sys.dm_xe_sessions as xs on xsea.event_session_address = xs.address;
go