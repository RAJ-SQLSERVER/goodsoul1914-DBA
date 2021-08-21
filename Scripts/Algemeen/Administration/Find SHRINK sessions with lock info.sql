-- Find SHRINK sessions with lock info
SELECT DISTINCT req.session_id,
                req.start_time,
                req.command,
                req.status,
                req.wait_type,
                ISNULL (req.database_id, rsc_dbid) AS "dbid",
                rsc_objid AS "ObjId",
                OBJECT_SCHEMA_NAME (rsc_objid, rsc_dbid) AS "SchemaName",
                OBJECT_NAME (rsc_objid, rsc_dbid) AS "TableName",
                rsc_indid AS "IndexId",
                indexes.name AS "IndexName"
FROM sys.dm_exec_requests AS req
LEFT JOIN master.dbo.syslockinfo
    ON req_spid = req.session_id
       AND rsc_objid <> 0
LEFT JOIN sys.indexes
    ON syslockinfo.rsc_objid = indexes.object_id
       AND syslockinfo.rsc_indid = indexes.index_id
WHERE req.command IN ( 'DbccFilesCompact', 'DbccSpaceReclaim' );