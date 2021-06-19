SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vwDatabaseRoleMembersLatest]
AS
SELECT CheckDate,
       SqlInstance,
       [Database],
       Role,
       UserName,
       Login,
       LoginType
FROM DBA.dbo.DatabaseRoleMembers
WHERE CheckDate >= DATEADD (DAY, -1, GETDATE ())
      AND UserName NOT LIKE '##%'
      AND username <> 'MS_DataCollectorInternalUser'
      AND username <> 'AllSchemaOwner';
GO
