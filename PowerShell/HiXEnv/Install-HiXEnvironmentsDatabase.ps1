<#
.SYNOPSIS
    Installs the HiX Environments Database.
.DESCRIPTION
	Installs the HiX Environments Database needed to store the HiX Environments with the
	credentials of the current user.
.PARAMETER SqlServer
    Microsoft Sql Server Database Server name
.PARAMETER Database
    Name of the database
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$SqlServer,
    [Parameter(Mandatory=$true)][string]$Database
)

Set-StrictMode -Version Latest

function Open-SqlConnection {
    param([string]$SqlServer, [string]$Db)

    $conn_options = ("Data Source=$SqlServer; Initial Catalog=$Db;" + "Integrated Security=SSPI")
    $conn = New-Object System.Data.SqlClient.SqlConnection($conn_options)
    $conn.Open()
    return $conn
}

function Run-SqlNonQuery {
    param([System.Data.SqlClient.SqlConnection]$Connection, [System.Data.SqlClient.SqlTransaction]$Transaction, [string]$Statement)

    $cmd = $Connection.CreateCommand()
	$cmd.Transaction = $Transaction
    $cmd.CommandText = $Statement
    $result = $cmd.ExecuteNonQuery()
    return $result
}

function Run-SqlQuery {
    param([System.Data.SqlClient.SqlConnection]$Connection, [System.Data.SqlClient.SqlTransaction]$Transaction, [string]$Statement)

    $cmd = $Connection.CreateCommand()
	$cmd.Transaction = $Transaction
    $cmd.CommandText = $Statement
	$reader = $cmd.ExecuteReader()

	$results = @()
	$columns = New-Object object[] $reader.FieldCount
	while($reader.Read()) {
		$reader.GetValues($columns) > $null
		$results += , $columns
	}

	return $results
}


function Run-SqlScalarQuery {
    param([System.Data.SqlClient.SqlConnection]$Connection, [System.Data.SqlClient.SqlTransaction]$Transaction, [string]$Statement)

    $cmd = $Connection.CreateCommand()
	$cmd.Transaction = $Transaction
    $cmd.CommandText = $Statement
	return $cmd.ExecuteScalar()
}

function Get-CreateQueriesv1{
	"
	CREATE TABLE [dbo].[ENV_SecurityGroups](
		[ID] [int] IDENTITY(1,1) NOT NULL,
		[Name] [nvarchar](10) NOT NULL,
	 CONSTRAINT [PK_ENV_SecurityGroups] PRIMARY KEY CLUSTERED 
	(
		[ID] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
	"
	
	"
	CREATE TABLE [dbo].[ENV_SecurityRoles](
		[SecurityGroupID] [int] NOT NULL,
		[SecurityRole] [nvarchar](100) NOT NULL,
	 CONSTRAINT [PK_ENV_SecurityRoles] PRIMARY KEY CLUSTERED 
	(
		[SecurityGroupID] ASC,
		[SecurityRole] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
	"
	
	"
	ALTER TABLE [dbo].[ENV_SecurityRoles]  WITH CHECK ADD  CONSTRAINT [FK_ENV_SecurityRoles_ENV_SecurityGroups] FOREIGN KEY([SecurityGroupID])
	REFERENCES [dbo].[ENV_SecurityGroups] ([ID])
	"
	
	"
	ALTER TABLE [dbo].[ENV_SecurityRoles] CHECK CONSTRAINT [FK_ENV_SecurityRoles_ENV_SecurityGroups]
	"
	
	"
	CREATE TABLE [dbo].[ENV_PersonalEnvironments](
		[ID] [uniqueidentifier] NOT NULL,
		[Name] [nvarchar](100) NOT NULL,
		[Type] [nvarchar](10) NOT NULL,
		[Version] [nvarchar](10) NOT NULL,
		[ConnectionString] [nvarchar](max) NOT NULL,
		[EnvironmentSettingsConnectionString] [nvarchar](max) NOT NULL,
		[SecurityRole] [nvarchar](100) NOT NULL,
	 CONSTRAINT [PK_ENV_PersonalEnvironments] PRIMARY KEY CLUSTERED 
	(
		[ID] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
	"
	
	"
	ALTER TABLE [dbo].[ENV_PersonalEnvironments] ADD  CONSTRAINT [DF_ENV_PersonalEnvironments_ID]  DEFAULT (newsequentialid()) FOR [ID]
	"
	
	"
	CREATE TABLE [dbo].[ENV_Environments](
		[ID] [nvarchar](50) NOT NULL,
		[Name] [nvarchar](100) NOT NULL,
		[Type] [nvarchar](10) NOT NULL,
		[Version] [nvarchar](10) NOT NULL,
		[ConnectionString] [nvarchar](max) NOT NULL,
		[Disabled] [bit] NOT NULL,
		[ReadOnly] [bit] NOT NULL,
		[Category] [nvarchar](10) NOT NULL,
		[EnvironmentSettingsConnectionString] [nvarchar](max) NOT NULL,
		[SecurityGroupID] [int] NOT NULL,
	 CONSTRAINT [PK_ENV_Environments] PRIMARY KEY CLUSTERED 
	(
		[ID] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
	"
	
	"
	ALTER TABLE [dbo].[ENV_Environments]  WITH CHECK ADD  CONSTRAINT [FK_ENV_Environments_ENV_SecurityGroups] FOREIGN KEY([SecurityGroupID])
	REFERENCES [dbo].[ENV_SecurityGroups] ([ID])
	"
	
	"
	ALTER TABLE [dbo].[ENV_Environments] CHECK CONSTRAINT [FK_ENV_Environments_ENV_SecurityGroups]
	"
	
	"
	CREATE TABLE [dbo].[ENV_DatabaseMigrations](
		[Version] [int] NOT NULL,
		[Timestamp] [datetime] NOT NULL,
	 CONSTRAINT [PK_dbo.ENV_DatabaseMigrations] PRIMARY KEY CLUSTERED 
	(
		[Version] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
	"
	
	"
	INSERT INTO [dbo].[ENV_DatabaseMigrations]
	           ([Version]
	           ,[Timestamp])
	     VALUES
	           (1
	           ,GETDATE())
	"
}

function Get-CreateQueriesv2{
	"
	CREATE TABLE [dbo].[ENV_SecurityGroups](
		[ID] [int] IDENTITY(1,1) NOT NULL,
		[Name] [nvarchar](10) NOT NULL,
	 CONSTRAINT [PK_ENV_SecurityGroups] PRIMARY KEY CLUSTERED 
	(
		[ID] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
	"
	
	"
	CREATE TABLE [dbo].[ENV_SecurityRoles](
		[SecurityGroupID] [int] NOT NULL,
		[SecurityRole] [nvarchar](100) NOT NULL,
	 CONSTRAINT [PK_ENV_SecurityRoles] PRIMARY KEY CLUSTERED 
	(
		[SecurityGroupID] ASC,
		[SecurityRole] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
	"
	
	"
	ALTER TABLE [dbo].[ENV_SecurityRoles]  WITH CHECK ADD  CONSTRAINT [FK_ENV_SecurityRoles_ENV_SecurityGroups] FOREIGN KEY([SecurityGroupID])
	REFERENCES [dbo].[ENV_SecurityGroups] ([ID])
	"
	
	"
	ALTER TABLE [dbo].[ENV_SecurityRoles] CHECK CONSTRAINT [FK_ENV_SecurityRoles_ENV_SecurityGroups]
	"
	
	"
	CREATE TABLE [dbo].[ENV_PersonalEnvironments](
		[ID] [uniqueidentifier] NOT NULL,
		[Name] [nvarchar](100) NOT NULL,
		[Type] [nvarchar](10) NOT NULL,
		[Version] [nvarchar](10) NOT NULL,
		[ConnectionString] [nvarchar](max) NOT NULL,
		[SecurityRole] [nvarchar](100) NOT NULL,
	 CONSTRAINT [PK_ENV_PersonalEnvironments] PRIMARY KEY CLUSTERED 
	(
		[ID] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
	"
	
	"
	ALTER TABLE [dbo].[ENV_PersonalEnvironments] ADD  CONSTRAINT [DF_ENV_PersonalEnvironments_ID]  DEFAULT (newsequentialid()) FOR [ID]
	"
	
	"
	CREATE TABLE [dbo].[ENV_Environments](
		[ID] [nvarchar](50) NOT NULL,
		[Name] [nvarchar](100) NOT NULL,
		[Type] [nvarchar](10) NOT NULL,
		[Version] [nvarchar](10) NOT NULL,
		[ConnectionString] [nvarchar](max) NOT NULL,
		[Disabled] [bit] NOT NULL,
		[ReadOnly] [bit] NOT NULL,
		[Category] [nvarchar](10) NOT NULL,
		[SecurityGroupID] [int] NOT NULL,
	 CONSTRAINT [PK_ENV_Environments] PRIMARY KEY CLUSTERED 
	(
		[ID] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
	"
	
	"
	ALTER TABLE [dbo].[ENV_Environments]  WITH CHECK ADD  CONSTRAINT [FK_ENV_Environments_ENV_SecurityGroups] FOREIGN KEY([SecurityGroupID])
	REFERENCES [dbo].[ENV_SecurityGroups] ([ID])
	"
	
	"
	ALTER TABLE [dbo].[ENV_Environments] CHECK CONSTRAINT [FK_ENV_Environments_ENV_SecurityGroups]
	"

	"
	CREATE TABLE [dbo].[ENV_AdditionalDatabases](
		[EnvironmentID] [nvarchar](50) NOT NULL,
		[Type] [nvarchar](10) NOT NULL,
		[ConnectionString] [nvarchar](max) NOT NULL,
	 CONSTRAINT [PK_ENV_AdditionalDatabases] PRIMARY KEY CLUSTERED 
	(
		[EnvironmentID] ASC,
		[Type] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
	"

	"
	ALTER TABLE [dbo].[ENV_AdditionalDatabases]  WITH CHECK ADD  CONSTRAINT [FK_ENV_AdditionalDatabases_ENV_Environments] FOREIGN KEY([EnvironmentID])
	REFERENCES [dbo].[ENV_Environments] ([ID])
	"

	"
	ALTER TABLE [dbo].[ENV_AdditionalDatabases] CHECK CONSTRAINT [FK_ENV_AdditionalDatabases_ENV_Environments]
	"
	
	"
	CREATE TABLE [dbo].[ENV_PersonalAdditionalDatabases](
		[PersonalEnvironmentID] [uniqueidentifier] NOT NULL,
		[Type] [nvarchar](10) NOT NULL,
		[ConnectionString] [nvarchar](max) NOT NULL,
	 CONSTRAINT [PK_ENV_PersonalAdditionalDatabases] PRIMARY KEY CLUSTERED 
	(
		[PersonalEnvironmentID] ASC,
		[Type] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
	"

	"
	ALTER TABLE [dbo].[ENV_PersonalAdditionalDatabases]  WITH CHECK ADD  CONSTRAINT [FK_ENV_PersonalAdditionalDatabases_ENV_PersonalEnvironments] FOREIGN KEY([PersonalEnvironmentID])
	REFERENCES [dbo].[ENV_PersonalEnvironments] ([ID])
	"

	"
	ALTER TABLE [dbo].[ENV_PersonalAdditionalDatabases] CHECK CONSTRAINT [FK_ENV_PersonalAdditionalDatabases_ENV_PersonalEnvironments]
	"

	"
	CREATE TABLE [dbo].[ENV_DefaultAdditionalDatabases](
		[Type] [nvarchar](10) NOT NULL,
		[ConnectionString] [nvarchar](max) NOT NULL,
	 CONSTRAINT [PK_ENV_DefaultAdditionalDatabases] PRIMARY KEY CLUSTERED 
	(
		[Type] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
	"

	"
	CREATE TABLE [dbo].[ENV_DatabaseMigrations](
		[Version] [int] NOT NULL,
		[Timestamp] [datetime] NOT NULL,
	 CONSTRAINT [PK_dbo.ENV_DatabaseMigrations] PRIMARY KEY CLUSTERED 
	(
		[Version] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
	"
	
	"
	INSERT INTO [dbo].[ENV_DatabaseMigrations]
	           ([Version]
	           ,[Timestamp])
	     VALUES
	           (2
	           ,GETDATE())
	"
}

function Get-Upgradev1Tov2{
	"
	CREATE TABLE [dbo].[ENV_DefaultAdditionalDatabases](
		[Type] [nvarchar](10) NOT NULL,
		[ConnectionString] [nvarchar](max) NOT NULL,
	 CONSTRAINT [PK_ENV_DefaultAdditionalDatabases] PRIMARY KEY CLUSTERED 
	(
		[Type] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
	"

	"
	CREATE TABLE [dbo].[ENV_AdditionalDatabases](
		[EnvironmentID] [nvarchar](50) NOT NULL,
		[Type] [nvarchar](10) NOT NULL,
		[ConnectionString] [nvarchar](max) NOT NULL,
	 CONSTRAINT [PK_ENV_AdditionalDatabases] PRIMARY KEY CLUSTERED 
	(
		[EnvironmentID] ASC,
		[Type] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
	"

	"
	ALTER TABLE [dbo].[ENV_AdditionalDatabases]  WITH CHECK ADD  CONSTRAINT [FK_ENV_AdditionalDatabases_ENV_Environments] FOREIGN KEY([EnvironmentID])
	REFERENCES [dbo].[ENV_Environments] ([ID])
	"

	"
	ALTER TABLE [dbo].[ENV_AdditionalDatabases] CHECK CONSTRAINT [FK_ENV_AdditionalDatabases_ENV_Environments]
	"

	"
	INSERT INTO [dbo].[ENV_AdditionalDatabases] ([EnvironmentID], [Type], [ConnectionString])
	SELECT [ID], 'CONF', [EnvironmentSettingsConnectionString]
	FROM [dbo].[ENV_Environments]
	WHERE [EnvironmentSettingsConnectionString] IS NOT NULL
	"

	"
	CREATE TABLE [dbo].[ENV_PersonalAdditionalDatabases](
		[PersonalEnvironmentID] [uniqueidentifier] NOT NULL,
		[Type] [nvarchar](10) NOT NULL,
		[ConnectionString] [nvarchar](max) NOT NULL,
	 CONSTRAINT [PK_ENV_PersonalAdditionalDatabases] PRIMARY KEY CLUSTERED 
	(
		[PersonalEnvironmentID] ASC,
		[Type] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
	"

	"
	ALTER TABLE [dbo].[ENV_PersonalAdditionalDatabases]  WITH CHECK ADD  CONSTRAINT [FK_ENV_PersonalAdditionalDatabases_ENV_PersonalEnvironments] FOREIGN KEY([PersonalEnvironmentID])
	REFERENCES [dbo].[ENV_PersonalEnvironments] ([ID])
	"

	"
	ALTER TABLE [dbo].[ENV_PersonalAdditionalDatabases] CHECK CONSTRAINT [FK_ENV_PersonalAdditionalDatabases_ENV_PersonalEnvironments]
	"

	"
	INSERT INTO [dbo].[ENV_PersonalAdditionalDatabases] ([PersonalEnvironmentID], [Type], [ConnectionString])
	SELECT [ID], 'CONF', [EnvironmentSettingsConnectionString]
	FROM [dbo].[ENV_PersonalEnvironments]
	WHERE [EnvironmentSettingsConnectionString] IS NOT NULL
	"

	"
	ALTER TABLE [dbo].[ENV_PersonalEnvironments] ALTER COLUMN [EnvironmentSettingsConnectionString] [nvarchar](max) NULL
	"
	
	"
	ALTER TABLE [dbo].[ENV_Environments] ALTER COLUMN [EnvironmentSettingsConnectionString] [nvarchar](max) NULL
	"

	#"
	#ALTER TABLE [dbo].[ENV_Environments] DROP COLUMN [EnvironmentSettingsConnectionString]
	#"

	#"
	#ALTER TABLE [dbo].[ENV_PersonalEnvironments] DROP COLUMN [EnvironmentSettingsConnectionString]
	#"

	"
	INSERT INTO [dbo].[ENV_DatabaseMigrations]
	           ([Version]
	           ,[Timestamp])
	     VALUES
	           (2
	           ,GETDATE())
	"
}

$connection = Open-SqlConnection $SqlServer $Database

$query = "select object_id('dbo.ENV_DatabaseMigrations')"
$tableExists = Run-SqlScalarQuery $connection $null $query 
if ($tableExists -isnot [DBNull])
{
	$query = 'SELECT MAX([Version]) FROM [dbo].[ENV_DatabaseMigrations]'
	$dbVersion = Run-SqlScalarQuery $connection $null $query 
}
else
{
	$dbVersion = 0
}

if ($dbVersion -eq 0)
{
	$queries = Get-CreateQueriesv2
}
elseif ($dbVersion -eq 1)
{
	$queries = Get-Upgradev1Tov2
}
elseif ($dbVersion -eq 2)
{
	Write-Output "Database is already installed"
	return
}
else
{
	Write-Error "Installed database is of a higher version: $dbVersion"
	return
}

$transaction = $connection.BeginTransaction()
try
{
	foreach ($query in $queries)
	{
		Run-SqlNonQuery $connection $transaction $query | Out-Null
	}
	$transaction.Commit()
	Write-Output "Database is installed"
}
catch
{
	$transaction.Rollback()
	throw
}
finally
{
	$connection.Close()
}