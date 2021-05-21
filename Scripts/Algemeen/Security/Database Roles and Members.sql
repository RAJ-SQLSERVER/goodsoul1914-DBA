-- List Database Roles and Members with Server Login
-- ------------------------------------------------------------------------------------------------

select ROL.name as RoleName, 
	   MEM.name as MemberName, 
	   MEM.type_desc as MemberType, 
	   MEM.default_schema_name as DefaultSchema, 
	   SP.name as ServerLogin
from sys.database_role_members as DRM
	 inner join sys.database_principals as ROL on DRM.role_principal_id = ROL.principal_id
	 inner join sys.database_principals as MEM on DRM.member_principal_id = MEM.principal_id
	 inner join sys.server_principals as SP on MEM.sid = SP.sid
order by RoleName, 
		 MemberName;
go