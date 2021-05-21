IF EXISTS --if the session already exists, then delete it. We are assuming you've changed something
(
    SELECT *
    FROM sys.server_event_sessions
    WHERE server_event_sessions.name = 'DeprecatedFeatures'
)
    DROP EVENT SESSION DeprecatedFeatures ON SERVER;
GO
CREATE EVENT SESSION DeprecatedFeatures
ON SERVER
    ADD EVENT sqlserver.deprecation_announcement
    (ACTION
     (
         sqlserver.database_name,
         sqlserver.username,
         sqlserver.session_nt_username,
         sqlserver.sql_text
     )
    ),
    ADD EVENT sqlserver.deprecation_final_support
    (ACTION
     (
         sqlserver.database_name,
         sqlserver.username,
         sqlserver.session_nt_username,
         sqlserver.sql_text
     )
    )
    ADD TARGET package0.ring_buffer
--we don't need a more permanent record or a bucket count
WITH
(
    STARTUP_STATE = OFF
);
GO
ALTER EVENT SESSION DeprecatedFeatures ON SERVER STATE = START;


/*
	Read the data
*/
DECLARE @Target_Data XML =
        (
            SELECT TOP 1
                   CAST(xet.target_data AS XML) AS targetdata
            FROM sys.dm_xe_session_targets AS xet
                INNER JOIN sys.dm_xe_sessions AS xes
                    ON xes.address = xet.event_session_address
            WHERE xes.name = 'DeprecatedFeatures'
                  AND xet.target_name = 'ring_buffer'
        );
SELECT CONVERT(
                  DATETIME2,
                  SWITCHOFFSET(
                                  CONVERT(DATETIMEOFFSET, the.event_data.value('(@timestamp)[1]', 'datetime2')),
                                  DATENAME(TzOffset, SYSDATETIMEOFFSET())
                              )
              ) AS datetime_local,
       the.event_data.value('(@name)[1]', 'nvarchar(40)') AS [Deprecation type],
       the.event_data.value('(data[@name="feature"]/value)[1]', 'nvarchar(100)') AS [Notice],
       --the.event_data.value('(data[@name="feature"]/value)[1]', 'nvarchar(40)') AS [Feature],
       the.event_data.value('(data[@name="message"]/value)[1]', 'nvarchar(max)') AS [message],
       the.event_data.value('(action[@name="database_name"]/value)[1]', 'sysname') AS [Database],
       the.event_data.value('(action[@name="username"]/value)[1]', 'sysname') AS Username,
       the.event_data.value('(action[@name="session_nt_username"]/value)[1]', 'sysname') AS [Session NT Username],
       the.event_data.value('(action[@name="sql_text"]/value)[1]', 'nvarchar(max)') AS [SQL Context]
FROM @Target_Data.nodes('//RingBufferTarget/event') AS the(event_data);


DECLARE @Target_Data XML =
        (
            SELECT TOP 1
                   CAST(xet.target_data AS XML) AS targetdata
            FROM sys.dm_xe_session_targets AS xet
                INNER JOIN sys.dm_xe_sessions AS xes
                    ON xes.address = xet.event_session_address
            WHERE xes.name = 'DeprecatedFeatures'
                  AND xet.target_name = 'ring_buffer'
        );
SELECT COUNT(*),
       [Deprecation type],
       Notice,
       [message],
       [Database],
       [Session NT Username],
       [SQL Context]
FROM
(
    SELECT CONVERT(
                      DATETIME2,
                      SWITCHOFFSET(
                                      CONVERT(DATETIMEOFFSET, the.event_data.value('(@timestamp)[1]', 'datetime2')),
                                      DATENAME(TzOffset, SYSDATETIMEOFFSET())
                                  )
                  ) AS datetime_local,
           the.event_data.value('(@name)[1]', 'nvarchar(40)') AS [Deprecation type],
           the.event_data.value('(data[@name="feature"]/value)[1]', 'nvarchar(100)') AS [Notice],
           --the.event_data.value('(data[@name="feature"]/value)[1]', 'nvarchar(40)') AS [Feature],
           the.event_data.value('(data[@name="message"]/value)[1]', 'nvarchar(max)') AS [message],
           the.event_data.value('(action[@name="database_name"]/value)[1]', 'sysname') AS [Database],
           the.event_data.value('(action[@name="username"]/value)[1]', 'sysname') AS Username,
           the.event_data.value('(action[@name="session_nt_username"]/value)[1]', 'sysname') AS [Session NT Username],
           the.event_data.value('(action[@name="sql_text"]/value)[1]', 'nvarchar(max)') AS [SQL Context]
    FROM @Target_Data.nodes('//RingBufferTarget/event') AS the(event_data)
) SessionData
GROUP BY [Deprecation type],
         Notice,
         [message],
         [Database],
         [Session NT Username],
         [SQL Context];