-------------------------------------------------------------------------------
-- Shows the owner at the login level
-------------------------------------------------------------------------------

SELECT so.[name] AS [Object],
       sch.[name] AS [Schema],
       USER_NAME(COALESCE(so.[principal_id], sch.[principal_id])) AS [OwnerUserName],
       sp.name AS [OwnerLoginName],
       so.type_desc AS [ObjectType]
FROM sys.objects so
    JOIN sys.schemas sch
        ON so.[schema_id] = sch.[schema_id]
    JOIN [sys].database_principals dp
        ON dp.[principal_id] = COALESCE(so.[principal_id], sch.[principal_id])
    LEFT JOIN [master].[sys].[server_principals] sp
        ON dp.sid = sp.sid
WHERE so.[type] IN ( 'U', 'P', 'V' );
GO


