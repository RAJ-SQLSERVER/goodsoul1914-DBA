USE [DBA]
GO

/****** Object:  StoredProcedure [dbo].[usp_GITCDatabaseRoleMembers]    Script Date: 8-10-2020 08:31:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_GITCDatabaseRoleMembers]
AS
BEGIN

	IF NOT EXISTS
	(
		SELECT name
		FROM tempdb.sys.objects
		WHERE name LIKE '##tblDBOwner%'
	)
		CREATE TABLE ##tblDBOwner
		(
			DBName VARCHAR(1024),
			DBRole VARCHAR(1024),
			RoleMember VARCHAR(1024),
			TypeDesc VARCHAR(1024)
		);
    
	EXEC sp_MSforeachdb 'USE [?]; 
		INSERT INTO ##tblDBOwner
		(
			DBname,
			DBRole,
			RoleMember,
			TypeDesc
		)
		SELECT DB_NAME() AS DBNAME,
			   c.name AS DB_ROLE,
			   a.name AS Role_Member,
			   a.type_desc
		FROM [?].sys.database_principals a (NOLOCK)
		INNER JOIN [?].sys.database_role_members b (NOLOCK) ON a.principal_id = b.member_principal_id
		INNER JOIN [?].sys.database_principals c (NOLOCK) ON c.principal_id = b.role_principal_id
		WHERE a.name <> ''dbo'' AND c.is_fixed_role = 1
		ORDER BY c.name,
				 a.name,
				 a.type_desc;';

	SELECT DBName,
           DBRole,
           RoleMember,
           TypeDesc
	FROM ##tblDBOwner;

	DROP TABLE ##tblDBOwner;
END
GO


