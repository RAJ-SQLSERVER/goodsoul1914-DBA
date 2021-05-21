/*
 
 How to find out who's queries are using the most CPU

 - Create workload pools as if we wre going to cap/limit people's CPU power
 - Create a classifier function so that when they log in, we can put them into different pools
 - Set limits on each workload pool's CPU
 - Use Resource Governor's reporting DMV's to query who's been burning up our processors

*/

USE [master];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/* Create pools for the groups of users you want to track */

CREATE RESOURCE POOL pool_WebSite;
CREATE RESOURCE POOL pool_Accounting;
CREATE RESOURCE POOL pool_Reporting;
GO

CREATE WORKLOAD GROUP wg_WebSite USING pool_WebSite;
CREATE WORKLOAD GROUP wg_Accounting USING pool_Accounting;
CREATE WORKLOAD GROUP wg_Reporting USING pool_Reporting;
GO

/* 
 For the purposes of this demo we're going to create a few SQL logins 
 that we classify into different groups
*/

CREATE LOGIN [WebSiteApp]
WITH PASSWORD = N'Bl3nd3r70',
     DEFAULT_DATABASE = [StackOverflow2010],
     CHECK_EXPIRATION = OFF,
     CHECK_POLICY = OFF;
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [WebSiteApp];
GO

CREATE LOGIN [AccountingApp]
WITH PASSWORD = N'Bl3nd3r70',
     DEFAULT_DATABASE = [StackOverflow2010],
     CHECK_EXPIRATION = OFF,
     CHECK_POLICY = OFF;
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [AccountingApp];
GO

CREATE LOGIN [IPFreely]
WITH PASSWORD = N'Bl3nd3r70',
     DEFAULT_DATABASE = [StackOverflow2010],
     CHECK_EXPIRATION = OFF,
     CHECK_POLICY = OFF;
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [IPFreely];
GO

/* On login this function will run and put people into different groups */

CREATE FUNCTION dbo.ResourceGovernorClassifier()
RETURNS sysname
WITH SCHEMABINDING
AS
BEGIN
    DECLARE @grp_name AS sysname;

    SELECT @grp_name = CASE SUSER_NAME()
                           WHEN 'WebSiteApp' THEN
                               'wg_WebSite'
                           WHEN 'AccountingApp' THEN
                               'wg_Accounting'
                           WHEN 'IPFreely' THEN
                               'wg_Reporting'
                           ELSE
                               'default'
                       END;

    RETURN @grp_name;
END;
GO

/* Tell Resource Governor which function to use */

ALTER RESOURCE GOVERNOR 
WITH (CLASSIFIER_FUNCTION = dbo.ResourceGovernorClassifier);
GO

/* Make changes effective */

--ALTER RESOURCE GOVERNOR RECONFIGURE;
