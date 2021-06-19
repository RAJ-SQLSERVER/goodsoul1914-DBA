SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW vwServerRoleMembersLatest
as
SELECT CheckDate,
       SqlInstance,
       Role,
       Name
FROM dbo.ServerRoleMembers
WHERE (CheckDate >= DATEADD (DAY, -1, GETDATE ()))
GO
