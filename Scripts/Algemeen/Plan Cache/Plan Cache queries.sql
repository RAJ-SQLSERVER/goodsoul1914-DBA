/* ----------------------------------------------------------------------------
 – Cache stores
---------------------------------------------------------------------------- */
SELECT *
FROM sys.dm_os_memory_cache_counters;
GO


/* ----------------------------------------------------------------------------
 – Retrieve number of buckets for each of the plan cache stores
---------------------------------------------------------------------------- */
SELECT type AS [plan cache store],
       buckets_count
FROM sys.dm_os_memory_cache_hash_tables
WHERE type IN ( 'CACHESTORE_OBJCP', 'CACHESTORE_SQLCP', 'CACHESTORE_PHDR', 'CACHESTORE_XPROC' );
GO


/* ----------------------------------------------------------------------------
 – To view the cached plans use the query sys.dm_exec_cached plans and 
   sys.dm_exec_sql_text. The query below gives the sql text of the query, 
   number of times the query has been executed (or reused), 
   cacheobjtype (Compiled Plan/Extended Stored Procedure/Parse Tree), 
   objtype (View/Proc/Adhoc), bucketid in the hash table these plans are hashed 
   to, and the plan handle.
---------------------------------------------------------------------------- */
SELECT TOP (1000)
       st.text,
       cp.cacheobjtype,
       cp.objtype,
       cp.refcounts,
       cp.usecounts,
       cp.size_in_bytes,
       cp.bucketid,
       cp.plan_handle
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) AS st
WHERE cp.cacheobjtype = 'Compiled Plan'
      AND cp.objtype = 'Prepared'
ORDER BY cp.usecounts DESC;
GO


/* ----------------------------------------------------------------------------
 – Parameterization of queries gives a significant performance benefit. 
   Parameterized queries have objtype 'Prepared'. Prepared queries typically 
   have large usecounts and are greater in size than the corresponding adhoc 
   shell queries (less than 50K for ad hoc shell queries). Plans for stored 
   procedures also have a high degree of reuse. In some workloads, there is 
   reuse of ad hoc queries with the exact same parameter values. In such cases 
   caching of the shell query proves gives better throughput.

   Sorting the data on usecounts gives the information regarding the degree of 
   reuse of queries. The query below sorts the cached plans on the plan size. 
   This query can be used to identify large plans. Caching several 
   un-parameterized adhoc queries with large plan size and with no reuse will 
   lead to plan cache bloating. This causes the plan cache to be under constant 
   memory pressure and gives suboptimal performance results. It is therefore 
   important to try to parameterize queries.
---------------------------------------------------------------------------- */
SELECT TOP (1000)
       st.text,
       cp.cacheobjtype,
       cp.objtype,
       cp.refcounts,
       cp.usecounts,
       cp.size_in_bytes,
       cp.bucketid,
       cp.plan_handle
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) AS st
WHERE cp.cacheobjtype = 'Compiled Plan'
      AND (
          cp.objtype = 'Adhoc'
          OR cp.objtype = 'Prepared'
      )
ORDER BY cp.objtype DESC,
         cp.size_in_bytes DESC;
GO


/* ----------------------------------------------------------------------------
 – The DMV sys.dm_os_memory_cache_entries has the number of 8KB pages allocated 
   for the plan, the number of disk IO's associated with this entry, the number 
   of context switches associated with this query, the original and current 
   cost for the entry. Original cost of the entry is an approximation of the 
   number of I/Os incurred, memory, and the context switch count. The current 
   cost of the entry is the actual cost associated with the query. A query is 
   inserted into the cache with a zero current cost. Its current cost is 
   incremented by one on every re-use. The maximum value of the current cost 
   is the original cost of query. Entries with zero current cost will be 
   removed when the plan cache is under memory pressure. Use either query below 
   to get this information:
---------------------------------------------------------------------------- */
SELECT TOP (1000)
       st.text,
       cp.objtype,
       cp.refcounts,
       cp.usecounts,
       cp.size_in_bytes,
       ce.disk_ios_count,
       ce.context_switches_count,
       ce.pages_kb,
       ce.original_cost,
       ce.current_cost
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) AS st
JOIN sys.dm_os_memory_cache_entries AS ce
    ON cp.memory_object_address = ce.memory_object_address
WHERE cp.cacheobjtype = 'Compiled Plan'
      AND (
          cp.objtype = 'Adhoc'
          OR cp.objtype = 'Prepared'
      )
ORDER BY cp.objtype DESC,
         cp.usecounts DESC;
GO


SELECT st.text,
       cp.objtype,
       cp.refcounts,
       cp.usecounts,
       cp.size_in_bytes,
       ce.disk_ios_count,
       ce.context_switches_count,
       ce.pages_kb,
       ce.original_cost,
       ce.current_cost
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) AS st
JOIN sys.dm_os_memory_cache_entries AS ce
    ON cp.memory_object_address = ce.memory_object_address
WHERE cp.cacheobjtype = 'Compiled Plan'
      AND ce.type IN ( 'CACHESTORE_SQLCP', 'CACHESTORE_OBJCP' )
ORDER BY cp.objtype DESC,
         cp.usecounts DESC;
GO


/* ----------------------------------------------------------------------------
 – To estimate the amount of plan cache memory that is being reused
---------------------------------------------------------------------------- */
SELECT SUM(size_in_bytes) / 1024 AS total_size_in_KB,
       COUNT(size_in_bytes) AS number_of_plans,
       ((SUM(size_in_bytes) / 1024) / (COUNT(size_in_bytes))) AS avg_size_in_KB,
       cacheobjtype,
       usecounts
FROM sys.dm_exec_cached_plans
GROUP BY usecounts,
         cacheobjtype
ORDER BY usecounts ASC;
GO


/* ----------------------------------------------------------------------------
 – Estimate the amount of memory that can be reclaimed after the next round 
   of memory pressure
---------------------------------------------------------------------------- */
SELECT ce.type,
       ce.current_cost,
       SUM(cp.size_in_bytes) AS total_size_in_bytes
FROM sys.dm_exec_cached_plans AS cp
JOIN sys.dm_os_memory_cache_entries AS ce
    ON cp.memory_object_address = ce.memory_object_address
WHERE ce.type IN ( 'CACHESTORE_SQLCP', 'CACHESTORE_OBJCP' )
      AND ce.current_cost = 0
GROUP BY ce.type,
         ce.current_cost;
GO


/* ----------------------------------------------------------------------------
 – The DMV sys.dm_os_memory_cache_clock_hands has information regarding how 
   many clock rounds have been made for each cache store. The query below 
   should return 4 rows, two for each cachestore. Each cachestore has an 
   external and internal clock hand that distinguishes external and internal 
   memory pressure respectively. The column removed_last_round_count indicates 
   the number of entries (plans) removed in the last round, and the 
   removed_all_rounds_count indicates the total number of entries removed.
---------------------------------------------------------------------------- */
SELECT *
FROM sys.dm_os_memory_cache_clock_hands
WHERE type = 'CACHESTORE_SQLCP'
      OR type = 'CACHESTORE_OBJCP';
GO


/* ----------------------------------------------------------------------------
 – Get the memory allocation information
---------------------------------------------------------------------------- */
SELECT *
FROM sys.dm_os_memory_cache_counters
WHERE type = 'CACHESTORE_SQLCP'
      OR type = 'CACHESTORE_OBJCP';
GO


/* ----------------------------------------------------------------------------
 – The DMV sys.dm_os_memory_cache_hash_tables has information on the hash 
   bucket length for SQLCP and OBJCP cachestores. A large value for 
   buckets_average_length and a small value for buckets_in_use_count indicate 
   long chains in each hash bucket. Long hash bucket lengths can lead to 
   performance slowdown.
---------------------------------------------------------------------------- */
SELECT name,
       type,
       buckets_count,
       buckets_in_use_count,
       buckets_min_length,
       buckets_max_length,
       buckets_avg_length
FROM sys.dm_os_memory_cache_hash_tables
WHERE type = 'CACHESTORE_SQLCP'
      OR type = 'CACHESTORE_OBJCP';
GO

-- To get a count of the number of compiled plans use:
SELECT COUNT(*)
FROM sys.dm_exec_cached_plans
WHERE cacheobjtype = 'Compiled Plan';
GO

-- To get a count of the number of adhoc query plans use:
SELECT COUNT(*)
FROM sys.dm_exec_cached_plans
WHERE cacheobjtype = 'Compiled Plan'
      AND objtype = 'Adhoc';
GO

-- To get a count of the number of prepared query plans use:
SELECT COUNT(*)
FROM sys.dm_exec_cached_plans
WHERE cacheobjtype = 'Compiled Plan'
      AND objtype = 'Prepared';
GO

-- For the number of prepared query plans with a given usecount use:
SELECT usecounts,
       COUNT(*) AS no_of_plans
FROM sys.dm_exec_cached_plans
WHERE cacheobjtype = 'Compiled Plan'
      AND objtype = 'Prepared'
GROUP BY usecounts;
GO

-- For the number of adhoc query plans with a given usecount use:
SELECT usecounts,
       COUNT(*) AS no_of_plans
FROM sys.dm_exec_cached_plans
WHERE cacheobjtype = 'Compiled Plan'
      AND objtype = 'Adhoc'
GROUP BY usecounts;
GO

-- For the top 1000 adhoc compiled plans with usecount of 1 use:
SELECT TOP (1000) *
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
WHERE cp.cacheobjtype = 'Compiled Plan'
      AND cp.objtype = 'Adhoc'
      AND cp.usecounts = 1
ORDER BY cp.size_in_bytes DESC, cp.bucketid;
GO


/* ----------------------------------------------------------------------------
 – Get text and size of single-use plans
---------------------------------------------------------------------------- */=
SELECT st.text,
       cp.objtype,
       cp.size_in_bytes
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) AS st
WHERE cp.cacheobjtype = N'Compiled Plan'
      AND cp.objtype IN ( N'Adhoc', N'Prepared' )
      AND cp.usecounts = 1
ORDER BY cp.size_in_bytes DESC
OPTION (RECOMPILE);
GO


/* ----------------------------------------------------------------------------
 – Check for single-use plans in cache
---------------------------------------------------------------------------- */
SELECT objtype AS CacheType,
       COUNT_BIG(*) AS [Total Plans],
       SUM(CAST(size_in_bytes AS DECIMAL(18, 2))) / 1024 / 1024 AS [Total MBs],
       AVG(usecounts) AS [Avg Use Count],
       SUM(CAST((CASE
                     WHEN usecounts = 1 THEN size_in_bytes
                     ELSE 0
                 END
                ) AS DECIMAL(18, 2))
       ) / 1024 / 1024 AS [Total MBs - USE Count 1],
       SUM(CASE
               WHEN usecounts = 1 THEN 1
               ELSE 0
           END
       ) AS [Total Plans - USE Count 1]
FROM sys.dm_exec_cached_plans
GROUP BY objtype
ORDER BY [Total MBs - USE Count 1] DESC;
GO


/* ----------------------------------------------------------------------------
 – Find plans that have missing indexes
---------------------------------------------------------------------------- */
;WITH XMLNAMESPACES (
     DEFAULT N'http://schemas.microsoft.com/sqlserver/2004/07/showplan'
 )
SELECT dec.usecounts,
       dec.refcounts,
       dec.objtype,
       dec.cacheobjtype,
       des.dbid,
       des.text,
       deq.query_plan
FROM sys.dm_exec_cached_plans AS dec
CROSS APPLY sys.dm_exec_sql_text(dec.plan_handle) AS des
CROSS APPLY sys.dm_exec_query_plan(dec.plan_handle) AS deq
WHERE deq.query_plan.exist(
          N'/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple/QueryPlan/MissingIndexes/MissingIndexGroup'
      ) <> 0
ORDER BY dec.usecounts DESC;
GO


/* ----------------------------------------------------------------------------
 – Find plans that have implicit warnings
---------------------------------------------------------------------------- */
;WITH XMLNAMESPACES (
     DEFAULT N'http://schemas.microsoft.com/sqlserver/2004/07/showplan'
 )
SELECT cp.query_hash,
       cp.query_plan_hash,
       operators.value('@ConvertIssue', 'nvarchar(250)') AS ConvertIssue,
       operators.value('@Expression', 'nvarchar(250)') AS Expression,
       qp.query_plan
FROM sys.dm_exec_query_stats AS cp
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) AS qp
CROSS APPLY query_plan.nodes('//Warnings/PlanAffectingConvert') AS rel(operators);
GO


/* ----------------------------------------------------------------------------
 – Return a row for every operator inside of every plan
---------------------------------------------------------------------------- */
;WITH XMLNAMESPACES (
     DEFAULT N'http://schemas.microsoft.com/sqlserver/2004/07/showplan'
 )
SELECT cp.query_hash,
       cp.query_plan_hash,
       operators.value('@PhysicalOp', 'nvarchar(50)') AS PhysicalOperator,
       operators.value('@LogicalOp', 'nvarchar(50)') AS LogicalOp,
       operators.value('@AvgRowSize', 'nvarchar(50)') AS AvgRowSize,
       operators.value('@EstimateCPU', 'nvarchar(50)') AS EstimateCPU,
       operators.value('@EstimateIO', 'nvarchar(50)') AS EstimateIO,
       operators.value('@EstimateRebinds', 'nvarchar(50)') AS EstimateRebinds,
       operators.value('@EstimateRewinds', 'nvarchar(50)') AS EstimateRewinds,
       operators.value('@EstimateRows', 'nvarchar(50)') AS EstimateRows,
       operators.value('@Parallel', 'nvarchar(50)') AS Parallel,
       operators.value('@NodeId', 'nvarchar(50)') AS NodeId,
       operators.value('@EstimatedTotalSubtreeCost', 'nvarchar(50)') AS EstimatedTotalSubtreeCost
FROM sys.dm_exec_query_stats AS cp
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) AS qp
CROSS APPLY query_plan.nodes('//RelOp') AS rel(operators);
GO


/* ----------------------------------------------------------------------------
 – Find query using query_hash
---------------------------------------------------------------------------- */
SELECT COUNT(*) AS [Count], query_stats.query_hash, 
    query_stats.statement_text AS [Text]
FROM 
    (SELECT QS.*, 
    SUBSTRING(ST.text, (QS.statement_start_offset/2) + 1,
    ((CASE QS.statement_end_offset 
        WHEN -1 THEN DATALENGTH(ST.text)
        ELSE QS.statement_end_offset END 
            - QS.statement_start_offset)/2) + 1) AS statement_text
     FROM sys.dm_exec_query_stats AS QS
     CROSS APPLY sys.dm_exec_sql_text(QS.sql_handle) as ST) as query_stats
GROUP BY query_stats.query_hash, query_stats.statement_text
ORDER BY 1 DESC
GO


/* ----------------------------------------------------------------------------
 – If you want to dive into the size of the plan in the cache:
---------------------------------------------------------------------------- */
CREATE PROCEDURE dbo.QuickCheckOnCacheWSize (@StringToFind NVARCHAR(4000))
AS
BEGIN
    SET NOCOUNT ON;

    SELECT cp.objtype,
           cp.cacheobjtype,
           cp.size_in_bytes,
           cp.usecounts,
           st.text
    FROM sys.dm_exec_cached_plans AS cp
    CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) AS st
    WHERE cp.objtype IN ( N'Adhoc', N'Prepared' )
          AND st.text LIKE @StringToFind
          AND (
              st.text NOT LIKE N'%syscacheobjects%'
              OR st.text NOT LIKE N'%SELECT%cp.objecttype%'
          )
    ORDER BY cp.objtype,
             cp.size_in_bytes;
END;
GO


/* ----------------------------------------------------------------------------
 – Simple proc to quickly see a subset of what statements are in cache - 
   with their plans.
---------------------------------------------------------------------------- */
CREATE PROCEDURE dbo.QuickCheckOnCache (@StringToFind NVARCHAR(4000))
AS
    BEGIN
        SET NOCOUNT ON;

        SELECT st.text,
               qs.execution_count,
               qs.*,
               p.*
        FROM sys.dm_exec_query_stats AS qs
        CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
        CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS p
        WHERE st.text LIKE @StringToFind
        ORDER BY 1,
                 qs.execution_count DESC;
    END;
GO


/* ----------------------------------------------------------------------------
 – Essentially the same thing, but add the query plan to the output
---------------------------------------------------------------------------- */
CREATE PROCEDURE dbo.QuickCheckOnCacheWSizeAndPlan (@StringToFind NVARCHAR(4000))
AS
BEGIN
    SET NOCOUNT ON;

    SELECT st.text,
           qs.execution_count,
           qs.plan_handle,
           qs.statement_start_offset,
           qp.query_plan
    FROM sys.dm_exec_query_stats AS qs
    CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
    CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
    WHERE st.text LIKE @StringToFind
          AND (
              st.text NOT LIKE N'%syscacheobjects%'
              OR st.text NOT LIKE N'%SELECT%cp.objecttype%'
          )
    ORDER BY 1,
             qs.execution_count DESC;
END;
GO


/* ----------------------------------------------------------------------------
 – The cumulative effect of queries
---------------------------------------------------------------------------- */
SELECT   qs2.query_hash AS "Query Hash",
         qs2.query_plan_hash AS "Query Plan Hash",
         SUM(qs2.total_worker_time) / SUM(qs2.execution_count) AS "Avg CPU Time",
         MIN(qs2.statement_text) AS "Example Statement Text"
FROM
         (
             SELECT      qs.*,
                         SUBSTRING(   st.text,
                                      (qs.statement_start_offset / 2) + 1,
                                      ((CASE statement_end_offset
                                            WHEN -1 THEN
                                                DATALENGTH(st.text)
                                            ELSE
                                                qs.statement_end_offset
                                        END - qs.statement_start_offset
                                       ) / 2
                                      ) + 1
                                  ) AS "statement_text"
             FROM        sys.dm_exec_query_stats AS qs
             CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
         ) AS qs2
GROUP BY qs2.query_hash,
         qs2.query_plan_hash
ORDER BY [Avg CPU Time] DESC;
GO


/* ----------------------------------------------------------------------------
 – Analyzing the plan cache
---------------------------------------------------------------------------- */
SELECT DB_NAME(CONVERT(INT, pa.value)) AS [Database Name],
       st.text,
       qs.query_hash,
       qs.query_plan_hash,
       qs.execution_count,
       qs.plan_handle,
       qs.statement_start_offset,
       qs.*,
       qp.*
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
CROSS APPLY sys.dm_exec_plan_attributes(qs.plan_handle) AS pa
WHERE st.text LIKE N'%SalesOrderDetail%'
      AND st.text NOT LIKE N'%syscacheobjects%'
      AND pa.attribute = N'dbid'
      AND pa.value = DB_ID()
ORDER BY 2,
         qs.execution_count DESC;
GO


/* ----------------------------------------------------------------------------
 – Get an overall picture of how many plans EACH **query_hash** has
---------------------------------------------------------------------------- */
SELECT qs.query_hash,
       COUNT(DISTINCT qs.query_plan_hash) AS [Distinct Plan Count],
       SUM(qs.execution_count) AS [Execution Total]
FROM sys.dm_exec_query_stats AS qs
GROUP BY qs.query_hash
ORDER BY [Execution Total] DESC;
GO


/* ----------------------------------------------------------------------------
 – Review a sampling of the queries (grouping by the query_hash) and see which 
   have the highest *Avg CPU Time*
---------------------------------------------------------------------------- */
SELECT qs2.query_hash AS [Query Hash],
       qs2.query_plan_hash AS [Query Plan Hash],
       SUM(qs2.total_worker_time) / SUM(qs2.execution_count) AS [Avg CPU Time],
       MIN(qs2.statement_text) AS [Example Statement Text]
FROM (
    SELECT qs.*,
           SUBSTRING(st.text,
                     (qs.statement_start_offset / 2) + 1,
                     ((CASE qs.statement_end_offset
                           WHEN -1 THEN
                               DATALENGTH(st.text)
                           ELSE
                               qs.statement_end_offset
                       END - qs.statement_start_offset
                      ) / 2
                     ) + 1
           ) AS statement_text
    FROM sys.dm_exec_query_stats AS qs
    CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
) AS qs2
GROUP BY qs2.query_hash,
         qs2.query_plan_hash
ORDER BY [Avg CPU Time] DESC;
GO


/* ----------------------------------------------------------------------------
 – Review a sampling of the queries (grouping by the query_hash) and see which 
   have the highest cumulative effect by *CPU Time*:
---------------------------------------------------------------------------- */
SELECT qs2.query_hash AS [Query Hash],
       SUM(qs2.total_worker_time) AS [Total CPU Time - Cumulative Effect],
       COUNT(DISTINCT qs2.query_plan_hash) AS [Number of plans],
       SUM(qs2.execution_count) AS [Number of executions],
       MIN(qs2.statement_text) AS [Example Statement Text]
FROM (
    SELECT qs.*,
           SUBSTRING(st.text,
                     (qs.statement_start_offset / 2) + 1,
                     ((CASE qs.statement_end_offset
                           WHEN -1 THEN
                               DATALENGTH(st.text)
                           ELSE
                               qs.statement_end_offset
                       END - qs.statement_start_offset
                      ) / 2
                     ) + 1
           ) AS statement_text
    FROM sys.dm_exec_query_stats AS qs
    CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
) AS qs2
GROUP BY qs2.query_hash
ORDER BY [Total CPU Time - Cumulative Effect] DESC;
GO


/* ----------------------------------------------------------------------------
 – How much of your cache is allocated to single-use plans?
---------------------------------------------------------------------------- */
SELECT cp.objtype AS [Cache Type],
       COUNT_BIG(*) AS [Total Plans],
       SUM(CAST(cp.size_in_bytes AS DECIMAL(18, 2))) / 1024.0 / 1024.0 AS [Total MBs],
       AVG(cp.usecounts) AS [Avg Use Count],
       SUM(CAST((CASE
                     WHEN cp.usecounts = 1 THEN cp.size_in_bytes
                     ELSE 0
                 END
                ) AS DECIMAL(18, 2))
       ) / 1024.0 / 1024.0 AS [Total MBs - USE Count 1],
       SUM(CASE
               WHEN cp.usecounts = 1 THEN 1
               ELSE 0
           END
       ) AS [Total Plans - USE Count 1],
       (SUM(CAST((CASE
                      WHEN cp.usecounts = 1 THEN cp.size_in_bytes
                      ELSE 0
                  END
                 ) AS DECIMAL(18, 2))
        ) / SUM(cp.size_in_bytes)
       ) * 100 AS [Percent Wasted]
FROM sys.dm_exec_cached_plans AS cp
GROUP BY cp.objtype
ORDER BY [Total MBs - USE Count 1] DESC;
GO


/* ----------------------------------------------------------------------------
 – How much is each query_hash using and how many plans?
---------------------------------------------------------------------------- */
SELECT qs.query_hash,
       COUNT(DISTINCT qs.query_plan_hash) AS DistinctPlanCount,
       SUM(qs.execution_count) AS ExecutionTotal,
       SUM(cp.size_in_bytes) / 1024.0 / 1024.0 AS TotalMB
FROM sys.dm_exec_query_stats AS qs
INNER JOIN sys.dm_exec_cached_plans AS cp
    ON cp.plan_handle = qs.plan_handle
GROUP BY qs.query_hash
ORDER BY ExecutionTotal DESC;
GO


/* ----------------------------------------------------------------------------
 – Plan cache contents
---------------------------------------------------------------------------- */

WITH XMLNAMESPACES (
    DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'
)
SELECT deqp.query_plan.value('(//StmtSimple)[1]/@ParameterizedPlanHandle', 'nvarchar(64)') AS ParameterizedPlanHandle,
       deqp.query_plan.value('(//StmtSimple)[1]/@ParameterizedText', 'nvarchar(max)') AS ParameterizedText,
       deqp.query_plan,
       decp.cacheobjtype,
       decp.objtype,
       decp.plan_handle,
       dest.text,
       decp.refcounts,
       decp.usecounts
FROM sys.dm_exec_cached_plans AS decp
CROSS APPLY sys.dm_exec_sql_text(decp.plan_handle) AS dest
CROSS APPLY sys.dm_exec_query_plan(decp.plan_handle) AS deqp
WHERE dest.text LIKE N'%Address%'
      AND dest.text NOT LIKE N'%sys.dm_exec_cached_plans%';
GO


/* ----------------------------------------------------------------------------
 – Get Compiled Plan with Parameters From Cache
---------------------------------------------------------------------------- */
SELECT cvalue.DBName,
       cvalue.ObjectName,
       SUBSTRING(cvalue.text, cvalue.statement_start_offset, cvalue.statement_end_offset) AS sql_text,
       cvalue.query_plan,
       pc.compiled.value('@Column', 'nvarchar(128)') AS Parameterlist,
       pc.compiled.value('@ParameterCompiledValue', 'nvarchar(128)') AS [compiled Value]
FROM (
    SELECT OBJECT_NAME(est.objectid) AS ObjectName,
           DB_NAME(est.dbid) AS DBName,
           eqs.plan_handle,
           eqs.query_hash,
           est.text,
           eqp.query_plan,
           eqs.statement_start_offset / 2 + 1 AS statement_start_offset,
           (CASE
                WHEN eqs.statement_end_offset = -1 THEN
                    LEN(CONVERT(NVARCHAR(MAX), est.text)) * 2
                ELSE
                    eqs.statement_end_offset
            END - eqs.statement_start_offset
           ) / 2 AS statement_end_offset,
           TRY_CONVERT(XML, SUBSTRING(
                                etqp.query_plan,
                                CHARINDEX('<ParameterList>', etqp.query_plan),
                                CHARINDEX('</ParameterList>', etqp.query_plan) + LEN('</ParameterList>')
                                - CHARINDEX('<ParameterList>', etqp.query_plan)
                            )) AS Parameters
    FROM sys.dm_exec_query_stats AS eqs
    CROSS APPLY sys.dm_exec_sql_text(eqs.sql_handle) AS est
    CROSS APPLY sys.dm_exec_text_query_plan(eqs.plan_handle, eqs.statement_start_offset, eqs.statement_end_offset) AS etqp
    CROSS APPLY sys.dm_exec_query_plan(eqs.plan_handle) AS eqp
    WHERE est.encrypted <> 1
) AS cvalue
OUTER APPLY cvalue.parameters.nodes('//ParameterList/ColumnReference') AS pc(compiled);
GO


/* ----------------------------------------------------------------------------
 – Create a view to show most of the same information as SQL Server 2000's 
   syscacheobjects
---------------------------------------------------------------------------- */
USE DBA;
GO
DROP VIEW IF EXISTS sp_cacheobjects;
GO
CREATE VIEW sp_cacheobjects
(
    bucketid,
    cacheobjtype,
    objtype,
    usecounts,
    pagesused,
    objid,
    dbid,
    dbidexec,
    uid,
    refcounts,
    setopts,
    langid,
    dateformat,
    status,
    lasttime,
    maxexectime,
    avgexectime,
    lastreads,
    lastwrites,
    sqlbytes,
    sql,
    plan_handle
)
AS
SELECT pvt.bucketid,
       CONVERT(NVARCHAR(18), pvt.cacheobjtype) AS cacheobjtype,
       pvt.objtype,
       pvt.usecounts,
       pvt.size_in_bytes / 8192 AS size_in_bytes,
       CONVERT(INT, pvt.objectid) AS object_id,
       CONVERT(SMALLINT, pvt.dbid) AS dbid,
       CONVERT(SMALLINT, pvt.dbid_execute) AS execute_dbid,
       CONVERT(SMALLINT, pvt.user_id) AS user_id,
       pvt.refcounts,
       CONVERT(INT, pvt.set_options) AS setopts,
       CONVERT(SMALLINT, pvt.language_id) AS langid,
       CONVERT(SMALLINT, pvt.date_format) AS date_format,
       CONVERT(INT, pvt.status) AS status,
       CONVERT(BIGINT, 0),
       CONVERT(BIGINT, 0),
       CONVERT(BIGINT, 0),
       CONVERT(BIGINT, 0),
       CONVERT(BIGINT, 0),
       CONVERT(INT, LEN(CONVERT(NVARCHAR(MAX), fgs.text)) * 2),
       CONVERT(NVARCHAR(3900), fgs.text),
       plan_handle
FROM (
    SELECT ecp.*,
           epa.attribute,
           epa.value
    FROM sys.dm_exec_cached_plans AS ecp
    OUTER APPLY sys.dm_exec_plan_attributes(ecp.plan_handle) AS epa
) AS ecpa
PIVOT (
    MAX(value)
    FOR attribute IN ("set_options", "objectid", "dbid", "dbid_execute", "user_id", "language_id", "date_format",
                      "status"
    )
) AS pvt
OUTER APPLY sys.dm_exec_sql_text(pvt.plan_handle) AS fgs
WHERE cacheobjtype LIKE 'Compiled%'
      AND pvt.dbid
      BETWEEN 5 AND 32766
      AND fgs.text NOT LIKE '%msparam%'
      AND fgs.text NOT LIKE '%xtp%'
      AND fgs.text NOT LIKE '%filetable%'
      AND text not like '%fulltext%';
GO


/* ----------------------------------------------------------------------------
 – View statistics for all query optimizations since the server was started
---------------------------------------------------------------------------- */
SELECT *
FROM   sys.dm_exec_query_optimizer_info;
GO


/* ----------------------------------------------------------------------------
 – Display the percentage of optimizations in the instance that include hints
---------------------------------------------------------------------------- */
SELECT (
           SELECT occurrence
           FROM sys.dm_exec_query_optimizer_info
           WHERE counter = 'hints'
       ) * 100.0 / (
           SELECT occurrence
           FROM sys.dm_exec_query_optimizer_info
           WHERE counter = 'optimizations'
       );
GO


/* ----------------------------------------------------------------------------
 –  Display the optimization information for a specific query
---------------------------------------------------------------------------- */

-- optimize these queries now so they do not skew the collected results
SELECT *
INTO after_query_optimizer_info
FROM sys.dm_exec_query_optimizer_info
GO

SELECT *
INTO before_query_optimizer_info
FROM sys.dm_exec_query_optimizer_info
GO

DROP TABLE dbo.before_query_optimizer_info
DROP TABLE dbo.after_query_optimizer_info
GO

-- real execution starts
SELECT *
INTO before_query_optimizer_info
FROM sys.dm_exec_query_optimizer_info
GO

-- insert your query here
SELECT *
FROM Person.Address
-- keep this to force a new optimization
OPTION (RECOMPILE)
GO

SELECT *
INTO after_query_optimizer_info
FROM sys.dm_exec_query_optimizer_info
GO

SELECT a.counter,
       (a.occurrence - b.occurrence) AS "occurrence",
       (a.occurrence * a.value - b.occurrence * b.value) AS "value"
FROM   dbo.before_query_optimizer_info AS b
JOIN   dbo.after_query_optimizer_info AS a
    ON b.counter = a.counter
WHERE  b.occurrence <> a.occurrence;
DROP TABLE dbo.before_query_optimizer_info
DROP TABLE dbo.after_query_optimizer_info
GO


/* ----------------------------------------------------------------------------
 – Logical trees
---------------------------------------------------------------------------- */
DBCC TRACEON(3604)
GO

SELECT ProductID,
       Name
FROM   Production.Product
WHERE  ProductID = 877
OPTION (RECOMPILE, QUERYTRACEON 8605);
GO


