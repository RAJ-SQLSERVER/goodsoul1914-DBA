-- Get XML deadlock reports

SELECT deadlock.reports.query ('deadlock')
FROM sys.dm_xe_session_targets AS st
JOIN sys.dm_xe_sessions AS s
    ON s.address = st.event_session_address
CROSS APPLY (SELECT CAST(st.target_data AS XML)) AS t(d)
CROSS APPLY t.d.nodes ('RingBufferTarget/event[@name="xml_deadlock_report"]/data/value') AS deadlock(reports)
WHERE s.name = 'system_health'
      AND st.target_name = 'ring_buffer';
