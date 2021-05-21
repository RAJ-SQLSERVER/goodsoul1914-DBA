/******************************************************************************

	Looking for security vulnerabilities in database code

******************************************************************************/

SELECT   OBJECT_NAME(sm.object_id) AS [ProcedureName],
         CASE
             WHEN sm.definition LIKE '%EXEC%(%' THEN
                 'WARNING: code contains EXEC'
             WHEN sm.definition LIKE '%EXECUTE%(%' THEN
                 'WARNING: code contains EXECUTE'
             WHEN sm.definition LIKE '%sp_executesql%' THEN
                 'WARNING: code contains sp_executesql'
         END AS [DynamicStrings],
         CASE
             WHEN sm.execute_as_principal_id IS NOT NULL THEN
                 N'WARNING: EXECUTE AS ' + USER_NAME(sm.execute_as_principal_id)
             ELSE
                 'Code to run as caller – check connection context'
         END AS [ExecutionContextStatus]
FROM     sys.sql_modules AS sm
ORDER BY [ProcedureName];
GO
