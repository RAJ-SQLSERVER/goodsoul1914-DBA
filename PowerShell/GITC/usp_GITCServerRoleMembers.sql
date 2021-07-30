USE [DBA]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_GITCServerRoleMembers]
AS
BEGIN

    SELECT c.name AS Fixed_roleName,
           a.name AS logins,
           a.type_desc
    FROM master.sys.server_principals a (NOLOCK)
    INNER JOIN master.sys.server_role_members b (NOLOCK) ON a.principal_id = b.member_principal_id
    INNER JOIN master.sys.server_principals c (NOLOCK) ON c.principal_id = b.role_principal_id
    ORDER BY c.name,
             a.type_desc,
             a.name;
END;
GO


