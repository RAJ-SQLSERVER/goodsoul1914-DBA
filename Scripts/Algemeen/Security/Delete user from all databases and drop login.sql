/*
	Delete a user from all databases and drop the login
*/

EXECUTE master.sys.sp_MSforeachdb 'USE [?]; 
    DECLARE @Tsql NVARCHAR(MAX)
    SET @Tsql = ''''

    SELECT @Tsql = ''DROP USER '' + d.name
    FROM sys.database_principals d
    JOIN master.sys.server_principals s
        ON s.sid = d.sid
    WHERE s.name = ''[ZKH\lduerin1]''

    EXEC (@Tsql)';
GO

DROP LOGIN [ZKH\lduerin1];
GO
