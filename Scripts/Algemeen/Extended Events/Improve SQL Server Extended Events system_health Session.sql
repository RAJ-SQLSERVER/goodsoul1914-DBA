/* ----------------------------------------------------------------------------
 – Improve SQL Server Extended Events system_health Session
---------------------------------------------------------------------------- */

/*
Problem
I was recently trying to troubleshoot a SQL Server replication-related deadlock 
that our monitoring tool didn't capture, and tried to find information about it 
in the system_health Extended Events session. With the default retention 
settings and the amount of noise contributed by security ring buffer events, 
I quickly discovered that the session only had data going back less than two 
hours. Meaning unless I started investigating an event immediately after it 
happened, all evidence had rolled out forever.

Solution
There are a few things you can do to make your system_health data last longer. 
An elaborate way would be to archive the .xel files themselves (or periodically 
take snapshots into your own storage), but I have two simpler solutions that 
might work for you.
*/

-------------------------------------------------------------------------------
-- Change the retention settings for system_health Extended Events session
-------------------------------------------------------------------------------

/*
By default, the system_health session retains 4 rollover files of a maximum of 
5 MB each, allowing you to retain 20 MB of data.
*/

/*
Luckily, unlike with the default trace, you can change the retention settings. 
For example, if I wanted to keep 40 rollover files of 10 MB each, for 400 MB of 
retention, I could run the following:
*/

USE master;
GO
ALTER EVENT SESSION system_health ON SERVER 
  DROP TARGET package0.event_file;

ALTER EVENT SESSION system_health ON SERVER
  ADD TARGET package0.event_file
 (
    SET filename           = N'system_health.xel',
        max_file_size      = (10), -- MB
        max_rollover_files = (40)
  );
GO

/*
In SQL Server 2016, 2017, and 2019, the defaults – if you haven't altered them 
already – increase to 10 files of 100 MB each, allowing you to retain 1 GB of 
system_health data (see KB #4541132 for more details). You can still increase 
or decrease these settings after applying the relevant cumulative update, but 
what is the right number will be a balancing act between manageability and XML 
query performance.
*/

-------------------------------------------------------------------------------
-- Stop collecting unactionable noise for system_health Extended Events session
-------------------------------------------------------------------------------

/*
Increasing the retention is nice, but what if you're collecting 1 GB (or more) 
of garbage? On every system I looked at, 99% of the events we were collecting 
were security ring buffer errors we can't do anything about (they involve how 
apps connect, authenticate, and validate authentication). I ran the following 
query (I always dump XEvent session data to a #temp table before any further 
processing):
*/

;WITH cte
AS
(
    SELECT CONVERT(XML, event_data) AS ed
    FROM   sys.fn_xe_file_target_read_file(N'system_health*.xel', NULL, NULL, NULL)
)
SELECT      x.ed.query('.') AS event_data
INTO        #t
FROM        cte
CROSS APPLY cte.ed.nodes(N'.') AS x(ed);
SELECT   t.EventName,
         COUNT(*) AS EventCount,
         DATEDIFF(MINUTE, MIN(t.EventTime), SYSUTCDATETIME()) AS EarliestEvent_MinutesAgo
FROM     (
    SELECT event_data.value(N'(event/@timestamp)[1]', N'datetime'),
           event_data.value(N'(event/@name)[1]', N'nvarchar(255)')
    FROM   #t
) AS t(EventTime, EventName)
GROUP BY t.EventName
ORDER BY EventCount DESC;
GO

/*
-- Remove an event from system_health
ALTER EVENT SESSION [system_health] ON SERVER
DROP EVENT sqlserver.security_error_ring_buffer_recorded;

-- Restore the event in system_health
ALTER EVENT SESSION [system_health] ON SERVER
ADD EVENT sqlserver.security_error_ring_buffer_recorded
(SET collect_call_stack=(0)); -- maybe you don't need the call stack!
*/

ALTER EVENT SESSION [system_health] ON SERVER
DROP EVENT sqlos.memory_broker_ring_buffer_recorded;

ALTER EVENT SESSION [system_health] ON SERVER
DROP EVENT sqlos.security_error_ring_buffer_recorded;

ALTER EVENT SESSION [system_health] ON SERVER
DROP EVENT sqlserver.scheduler_monitor_system_health_ring_buffer_recorded;

ALTER EVENT SESSION [system_health] ON SERVER
DROP EVENT sqlserver.connectivity_ring_buffer_recorded;

