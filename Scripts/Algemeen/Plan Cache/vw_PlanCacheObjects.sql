USE master;
GO
CREATE OR ALTER VIEW dbo.vw_PlanCacheObjects
(
    bucketid,
    cacheobjtype,
    objtype,
    objid,
    dbid,
    dbidexec,
    uid,
    refcounts,
    usecounts,
    pagesused,
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
    sql
)
AS
SELECT      pvt.bucketid,
            CONVERT(NVARCHAR(20), pvt.cacheobjtype) AS "cacheobjtype",
            pvt.objtype,
            CONVERT(INT, pvt.objectid) AS "object_id",
            CONVERT(SMALLINT, pvt.dbid) AS "dbid",
            CONVERT(SMALLINT, pvt.dbid_execute) AS "execute_dbid",
            CONVERT(SMALLINT, pvt.user_id) AS "user_id",
            pvt.refcounts,
            pvt.usecounts,
            pvt.size_in_bytes / 8192 AS "size_in_bytes",
            CONVERT(INT, pvt.set_options) AS "setopts",
            CONVERT(SMALLINT, pvt.language_id) AS "langid",
            CONVERT(SMALLINT, pvt.date_format) AS "date_format",
            CONVERT(INT, pvt.status) AS "status",
            CONVERT(BIGINT, 0),
            CONVERT(BIGINT, 0),
            CONVERT(BIGINT, 0),
            CONVERT(BIGINT, 0),
            CONVERT(BIGINT, 0),
            CONVERT(INT, LEN(CONVERT(NVARCHAR(MAX), fgs.text)) * 2),
            CONVERT(NVARCHAR(3900), fgs.text)
FROM
            (
                SELECT      ecp.*,
                            epa.attribute,
                            epa.value
                FROM        sys.dm_exec_cached_plans AS ecp
                OUTER APPLY sys.dm_exec_plan_attributes(ecp.plan_handle) AS epa
            ) AS ecpa
PIVOT
(
    MAX(ecpa.value)
    FOR ecpa.attribute IN ("set_options", "objectid", "dbid", "dbid_execute", "user_id", "language_id", "date_format",
                           "status"
                          )
) AS pvt
OUTER APPLY sys.dm_exec_sql_text(pvt.plan_handle) AS fgs;