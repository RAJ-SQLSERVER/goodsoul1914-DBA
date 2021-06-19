CREATE TABLE [dbo].[DatabaseRoleMembers]
(
[CheckDate] [datetime2] (7) NULL,
[ComputerName] [nvarchar] (max) NULL,
[InstanceName] [nvarchar] (max) NULL,
[SqlInstance] [nvarchar] (max) NULL,
[Database] [nvarchar] (max) NULL,
[Role] [nvarchar] (max) NULL,
[UserName] [nvarchar] (max) NULL,
[Login] [nvarchar] (max) NULL,
[IsSystemObject] [bit] NULL,
[LoginType] [nvarchar] (max) NULL
) TEXTIMAGE_
GO
ALTER TABLE [dbo].[DatabaseRoleMembers] ADD CONSTRAINT [DF_DatabaseRoleMembers_CheckDate] DEFAULT (getdate ()) FOR [CheckDate]
GO
