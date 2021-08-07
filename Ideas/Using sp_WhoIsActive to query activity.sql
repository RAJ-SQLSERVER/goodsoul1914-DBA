--which logins were most used in the last 7 days (counting unique login times)
SELECT TOP 10 [login_name], [count of distinct login time] = COUNT(DISTINCT [login_time])
FROM    [Scratch].dbo.[WhoIsActive] (READPAST)
GROUP BY [login_name]
ORDER BY 2 DESC

--were there any SHRINKFILEs (should not be, DBA-type task)
--will not catch all occurences of SHRINKFILE, only those running while data was collected
SELECT  *
FROM    [Scratch].dbo.[WhoIsActive] (READPAST)
WHERE   [sql_text] LIKE N'%SHRINKFILE%'

--tempdb allocations by query
--top queries are typically those that use temporary table variables
--sp_Blitz might show up here (as it is frequently run, and tempdb-heavy)
SELECT TOP 10 [sql_text], [database_name], [Sum of tempdb_allocations] = SUM([tempdb_allocations])
FROM    [Scratch].dbo.[WhoIsActive] (READPAST)
WHERE   [database_name] != N'tempdb'
GROUP BY [sql_text], [database_name]
ORDER BY 3 DESC

--blocked sessions, with blocking session details
;WITH BLOCKING AS (
 --blocking sessions
 SELECT DISTINCT [blocking_session_id], [collection_time]
 FROM    [Scratch].dbo.[WhoIsActive] (READPAST)
 WHERE   [blocking_session_id] IS NOT NULL
), BLOCKING_DETAILS AS (
 --get SQL text from blocking sessions at the same collection time
 SELECT DISTINCT BLOCKING.[blocking_session_id], W.[sql_text]
 FROM    [Scratch].dbo.[WhoIsActive] W (READPAST) INNER JOIN
             BLOCKING ON
                 W.[session_id] = BLOCKING.[blocking_session_id] AND
                 W.[collection_time] = BLOCKING.[collection_time]
 WHERE   W.[sql_text] IS NOT NULL
), BLOCKED AS (
 --blocked sessions
 --note may not have transaction start time, so use either transaction start time or collection time
 SELECT DISTINCT [session_id], [timing] = COALESCE([tran_start_time], [collection_time])
 FROM    [Scratch].dbo.[WhoIsActive] (READPAST)
 WHERE   [blocking_session_id] IS NOT NULL
 GROUP BY [session_id], COALESCE([tran_start_time], [collection_time])
)
SELECT  --blocked session
        W.[session_id], W.[sql_text], W.[login_name],
        --blocking session
        W.[blocking_session_id], [blocking_sql_text] = BLOCKING_DETAILS.[sql_text],
        W.[tran_start_time], W.[database_name], W.[collection_time]
FROM    [Scratch].dbo.[WhoIsActive] W (READPAST) INNER JOIN
            BLOCKED ON
                W.[session_id] = BLOCKED.[session_id] AND
                COALESCE(W.[tran_start_time], W.[collection_time]) = BLOCKED.[timing] LEFT OUTER JOIN
            BLOCKING_DETAILS ON
                W.[blocking_session_id] = BLOCKING_DETAILS.[blocking_session_id]
ORDER BY W.[session_id], COALESCE(W.[tran_start_time], W.[collection_time])