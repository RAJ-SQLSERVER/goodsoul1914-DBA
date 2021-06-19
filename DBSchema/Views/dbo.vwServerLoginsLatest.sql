SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vwServerLoginsLatest]
AS
SELECT SqlInstance,
       Name,
       LoginType,
       LastLogin,
       CreateDate,
       DateLastModified,
       DefaultDatabase,
       DenyWindowsLogin,
       HasAccess,
       IsDisabled,
       IsLocked,
       IsPasswordExpired,
       IsSystemObject,
       MustChangePassword,
       PasswordExpirationEnabled,
       PasswordPolicyEnforced,
       WindowsLoginAccessType
FROM DBA.dbo.ServerLogins
WHERE Name NOT LIKE 'NT %'
      AND Name NOT LIKE '##%'
      AND CheckDate >= DATEADD (DAY, -1, GETDATE ());
GO
