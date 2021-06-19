CREATE TABLE [dbo].[ServerLogins]
(
[CheckDate] [datetime2] (7) NULL,
[ComputerName] [nvarchar] (max) NULL,
[InstanceName] [nvarchar] (max) NULL,
[SqlInstance] [nvarchar] (max) NULL,
[LastLogin] [nvarchar] (max) NULL,
[AsymmetricKey] [nvarchar] (max) NULL,
[Certificate] [nvarchar] (max) NULL,
[CreateDate] [datetime2] (7) NULL,
[Credential] [nvarchar] (max) NULL,
[DateLastModified] [datetime2] (7) NULL,
[DefaultDatabase] [nvarchar] (max) NULL,
[DenyWindowsLogin] [bit] NULL,
[HasAccess] [bit] NULL,
[ID] [int] NULL,
[IsDisabled] [bit] NULL,
[IsLocked] [bit] NULL,
[IsPasswordExpired] [bit] NULL,
[IsSystemObject] [bit] NULL,
[LoginType] [nvarchar] (max) NULL,
[MustChangePassword] [bit] NULL,
[PasswordExpirationEnabled] [bit] NULL,
[PasswordHashAlgorithm] [nvarchar] (max) NULL,
[PasswordPolicyEnforced] [bit] NULL,
[Sid] [varbinary] (max) NULL,
[WindowsLoginAccessType] [nvarchar] (max) NULL,
[Name] [nvarchar] (max) NULL
) TEXTIMAGE_
GO
ALTER TABLE [dbo].[ServerLogins] ADD CONSTRAINT [DF_ServerLogins_CheckDate] DEFAULT (getdate ()) FOR [CheckDate]
GO
