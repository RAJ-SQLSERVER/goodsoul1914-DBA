DECLARE @DatabaseName  				varchar(50)		='HIX_ACCEPTATIE'
DECLARE @TableName     				varchar(50)		='zkh_blocklog'

DECLARE @ProcedureName				varchar(50)		='zkh_blockdetection'

DECLARE @AgentCategoryName     		varchar(50)		='Ziekenhuis'
DECLARE @AgentJobName     			varchar(50)		='ZKH: Block Detection'
DECLARE @AgentJobDescription		varchar(200)	='Automatic Block-Detection by zkh'
DECLARE @AgentJobMode				varchar(50)		='once'
DECLARE @AgentJobThreshold			varchar(50)		=1
DECLARE @AgentJobFrequency			varchar(50)		=1
DECLARE @AgentJobSave				varchar(50)		=1

DECLARE @AlertName					varchar(50)		='ZKH: Block Detection'

EXEC('USE ['+@DatabaseName+']')

/*
	Step 1 – Block Log Table
*/

-- check if table exists
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].'+@TableName) AND type in (N'U'))
BEGIN
	PRINT 'Deleting table: ['+@DatabaseName+'].[dbo].['+@TableName+']'
	EXEC('DROP TABLE ['+@DatabaseName+'].[dbo].['+@TableName+']')
END


/*
	Step 2 – Stored Procedure to save the data 
*/

-- If procedure exists drop it
IF (OBJECT_ID(@ProcedureName) IS NOT NULL)
BEGIN
	PRINT 'Deleting procedure: [dbo].['+@ProcedureName+']'
	EXEC('DROP PROCEDURE [dbo].['+@ProcedureName+']')
END


/*
	Step 3 – SQL Server Agent Job that will then execute the procedure 
*/

-- If agent job exists, then drop
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = @AgentJobName)
BEGIN
	PRINT 'Deleting agent job: '+@AgentJobName
	EXEC msdb.dbo.sp_delete_job @job_name=@AgentJobName, @delete_unused_schedule=1
END


/*
	Step 4 – Alert to monitor "Processes Blocked"
*/

-- If alert exists then drop
IF  EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = @AlertName) 
BEGIN 
	PRINT 'Deleting Alert: '+@AlertName 
	EXEC msdb.dbo.sp_delete_alert @name=@AlertName 
END 