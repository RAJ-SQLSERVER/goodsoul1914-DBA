CREATE TABLE [dbo].[ServerRoleMembers]
(
[CheckDate] [datetime2] (7) NULL,
[ComputerName] [nvarchar] (max) NULL,
[InstanceName] [nvarchar] (max) NULL,
[SqlInstance] [nvarchar] (max) NULL,
[Role] [nvarchar] (max) NULL,
[Name] [nvarchar] (max) NULL
) TEXTIMAGE_
GO
ALTER TABLE [dbo].[ServerRoleMembers] ADD CONSTRAINT [DF_ServerRoleMembers_CheckDate] DEFAULT (getdate ()) FOR [CheckDate]
GO
