/*********************************************************************
Why is the Same Query Sometimes Slow?

v1.8 - 2019-08-27

I'm going to teach you 4 things:

1. What parameter sniffing is
2. How to react to parameter sniffing emergencies
3. How to test a query with sniffing problems
4. Options to fix the query long term

Learn more later at:
https://www.BrentOzar.com/go/sniff


This demo requires:

* Any supported version of SQL Server or Azure SQL DB
* Any Stack Overflow database: https://www.BrentOzar.com/go/querystack
* DropIndexes proc: https://www.BrentOzar.com/go/dropindexes
* sp_BlitzCache: https://www.BrentOzar.com/blitzcache
*********************************************************************/

use StackOverflow2010;
go

alter database current set compatibility_level = 140;
go

exec sys.sp_configure @configname = N'cost threshold for parallelism', @configvalue = N'50';
go

exec sys.sp_configure @configname = N'max degree of parallelism', @configvalue = N'4';
go

reconfigure;
go

DropIndexes;
go

/************************************
 Turn on actual execution plans and: 
************************************/

set statistics io, time on;
go

create index IX_Reputation on dbo.Users (Reputation);
go

select TOP (10000) CreationDate,
                   DisplayName,
                   DownVotes,
                   EmailHash,
                   LastAccessDate,
                   Location,
                   Reputation,
                   UpVotes,
                   Views,
                   HoursBetween_LastAccessDate_and_CreationDate
from dbo.Users
where Reputation = 2
order by DisplayName;
go

select TOP (10000) CreationDate,
                 DisplayName,
                 DownVotes,
                 EmailHash,
                 LastAccessDate,
                 Location,
                 Reputation,
                 UpVotes,
                 Views,
                 HoursBetween_LastAccessDate_and_CreationDate
from dbo.Users
where Reputation = 1
order by DisplayName;
go

create or alter procedure dbo.usp_UsersByReputation 
	@Reputation int
as
	select TOP (10000) CreationDate,
                       DisplayName,
                       DownVotes,
                       EmailHash,
                       LastAccessDate,
                       Location,
                       Reputation,
                       UpVotes,
                       Views,
                       HoursBetween_LastAccessDate_and_CreationDate
	from dbo.Users
	where Reputation = @Reputation
	order by DisplayName;
go

exec dbo.usp_UsersByReputation @Reputation = 1;
go

exec dbo.usp_UsersByReputation @Reputation = 2;
go

dbcc freeproccache;
go

exec dbo.usp_UsersByReputation @Reputation = 2;
go

exec dbo.usp_UsersByReputation @Reputation = 1;
go

sp_BlitzCache;

declare @Reputation int = 2;

--CREATE PROCEDURE dbo.usp_UsersByReputation
--  @Reputation int
--AS

select top 10000 *
from dbo.Users
where Reputation = @Reputation
order by DisplayName;
go

dbcc show_statistics('dbo.Users', 'IX_Reputation');
go

create procedure #usp_UsersByReputation 
	@Reputation int
as
begin
	select *
	from dbo.Users
	where Reputation = @Reputation;
end;
go

exec #usp_UsersByReputation 2;
go

/**********************
 "Normal" dynamic SQL: 
**********************/

create or alter procedure dbo.usp_UsersByReputation 
	@Reputation int
as
begin
	declare @StringToExecute nvarchar(4000);
	set @StringToExecute = N'SELECT TOP 10000 * FROM dbo.Users WHERE Reputation=@Reputation ORDER BY DisplayName;';

	exec sp_executesql @StringToExecute, N'@Reputation INT', @Reputation;
end;
go

dbcc freeproccache;
go

exec usp_UsersByReputation @Reputation = 1;
go

exec usp_UsersByReputation @Reputation = 2;
go

sp_BlitzCache;
go

/****************************************************
 "Bad" dynamic SQL building unparameterized strings: 
****************************************************/

create or alter procedure dbo.usp_UsersByReputation 
	@Reputation int
as
begin
	declare @StringToExecute nvarchar(4000);
	set @StringToExecute = N'SELECT TOP 10000 * FROM dbo.Users WHERE Reputation= ' + CAST(@Reputation as nvarchar(10)) + N' ORDER BY DisplayName;';

	exec sp_executesql @StringToExecute;
end;
go

dbcc freeproccache;
go

exec usp_UsersByReputation @Reputation = 1;
go

exec usp_UsersByReputation @Reputation = 2;
go

sp_BlitzCache;
go

/*******************************************
 Parameterized, but with comment injection: 
*******************************************/

create or alter procedure dbo.usp_UsersByReputation 
	@Reputation int
as
begin
	declare @StringToExecute nvarchar(4000);
	set @StringToExecute = N'SELECT TOP 10000 * FROM dbo.Users WHERE Reputation=@Reputation ORDER BY DisplayName;';

	if @Reputation = 1
		set @StringToExecute = @StringToExecute + N' /* Big data */';

	exec sp_executesql @StringToExecute, N'@Reputation INT', @Reputation;
end;
go

dbcc freeproccache;
go

exec usp_UsersByReputation @Reputation = 1;
go

exec usp_UsersByReputation @Reputation = 2;
go

sp_BlitzCache;
go

/***************************************************************
 And for bonus points, this is how real-life complex IF branches
can be way worse than single-query procs: 
***************************************************************/

create or alter proc dbo.usp_QueryStuff 
	@TableToQuery   nvarchar(50) = null, 
	@UserReputation int          = null, 
	@BadgeName      nvarchar(40) = null
as
begin
	if @TableToQuery = 'Users'
		select top 10000 *
		from dbo.Users
		where Reputation = @UserReputation
		order by DisplayName;
		else
		if @TableToQuery = 'Badges'
			select top 200 *
			from dbo.Badges
			where Name = @BadgeName
			order by Date;
end;
go

dbcc freeproccache;

/**********************************************************************
 And here's a few sets of parameters that cause wildly different plans 
**********************************************************************/

exec dbo.usp_QueryStuff @TableToQuery = 'Users', @UserReputation = 1;
go

exec dbo.usp_QueryStuff @TableToQuery = 'Users', @UserReputation = 2;
go

exec dbo.usp_QueryStuff @TableToQuery = 'Badges', @BadgeName = 'Student';
go

exec dbo.usp_QueryStuff @TableToQuery = 'Badges', @BadgeName = 'dynamic-sql';
go

exec dbo.usp_QueryStuff;
go

/**************************************************************************************************************
Learn more later at:
/*
Why is the Same Query Sometimes Slow?

v1.8 - 2019-08-27

I'm going to teach you 4 things:

1. What parameter sniffing is
2. How to react to parameter sniffing emergencies
3. How to test a query with sniffing problems
4. Options to fix the query long term

Learn more later at:
https://www.BrentOzar.com/go/sniff


This demo requires:

* Any supported version of SQL Server or Azure SQL DB
* Any Stack Overflow database: https://www.BrentOzar.com/go/querystack
* DropIndexes proc: https://www.BrentOzar.com/go/dropindexes
* sp_BlitzCache: https://www.BrentOzar.com/blitzcache
*/
USE StackOverflow2013;
GO
ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 140;
GO
EXEC sys.sp_configure N'cost threshold for parallelism', N'50'
GO
EXEC sys.sp_configure N'max degree of parallelism', N'4'
GO
RECONFIGURE
GO
DropIndexes;
GO
/* Turn on actual execution plans and: */
SET STATISTICS IO, TIME ON;
GO

CREATE INDEX IX_Reputation ON dbo.Users(Reputation)
GO
SELECT TOP 10000 *
FROM dbo.Users
WHERE Reputation=2
ORDER BY DisplayName;
GO

SELECT TOP 10000 * 
FROM dbo.Users
WHERE Reputation=1
ORDER BY DisplayName;
GO



CREATE OR ALTER PROCEDURE dbo.usp_UsersByReputation
  @Reputation int
AS
SELECT TOP 10000 *
FROM dbo.Users
WHERE Reputation=@Reputation
ORDER BY DisplayName;
GO

EXEC dbo.usp_UsersByReputation @Reputation =1;
GO
EXEC dbo.usp_UsersByReputation @Reputation =2;
GO

DBCC FREEPROCCACHE
GO
EXEC dbo.usp_UsersByReputation @Reputation =2;
GO
EXEC dbo.usp_UsersByReputation @Reputation =1;
GO
sp_BlitzCache




DECLARE @Reputation INT = 2

--CREATE PROCEDURE dbo.usp_UsersByReputation
--  @Reputation int
--AS
SELECT TOP 10000 *
FROM dbo.Users
WHERE Reputation=@Reputation
ORDER BY DisplayName;
GO

DBCC SHOW_STATISTICS('dbo.Users', 'IX_Reputation')
GO



CREATE PROCEDURE #usp_UsersByReputation @Reputation int AS
SELECT * FROM dbo.Users
WHERE Reputation= @Reputation
GO

EXEC #usp_UsersByReputation 2
GO




/* "Normal" dynamic SQL: */
CREATE OR ALTER PROCEDURE dbo.usp_UsersByReputation
  @Reputation int
AS
BEGIN
DECLARE @StringToExecute NVARCHAR(4000);
SET @StringToExecute = N'SELECT TOP 10000 * FROM dbo.Users WHERE Reputation=@Reputation ORDER BY DisplayName;';

EXEC sp_executesql @StringToExecute, N'@Reputation INT', @Reputation;
END
GO

DBCC FREEPROCCACHE;
GO
EXEC usp_UsersByReputation @Reputation = 1;
GO
EXEC usp_UsersByReputation @Reputation = 2;
GO
sp_BlitzCache;
GO


/* "Bad" dynamic SQL building unparameterized strings: */
CREATE OR ALTER PROCEDURE dbo.usp_UsersByReputation
  @Reputation int
AS
BEGIN
DECLARE @StringToExecute NVARCHAR(4000);
SET @StringToExecute = N'SELECT TOP 10000 * FROM dbo.Users WHERE Reputation= '
	+ CAST(@Reputation AS NVARCHAR(10))
	+ N' ORDER BY DisplayName;';

EXEC sp_executesql @StringToExecute;
END
GO

DBCC FREEPROCCACHE;
GO
EXEC usp_UsersByReputation @Reputation = 1;
GO
EXEC usp_UsersByReputation @Reputation = 2;
GO
sp_BlitzCache;
GO



/* Parameterized, but with comment injection: */
CREATE OR ALTER PROCEDURE dbo.usp_UsersByReputation
  @Reputation int
AS
BEGIN
DECLARE @StringToExecute NVARCHAR(4000);
SET @StringToExecute = N'SELECT TOP 10000 * FROM dbo.Users WHERE Reputation=@Reputation ORDER BY DisplayName;';

IF @Reputation = 1
	SET @StringToExecute = @StringToExecute + N' /* Big data */';

EXEC sp_executesql @StringToExecute, N'@Reputation INT', @Reputation;
END
GO

DBCC FREEPROCCACHE;
GO
EXEC usp_UsersByReputation @Reputation = 1;
GO
EXEC usp_UsersByReputation @Reputation = 2;
GO
sp_BlitzCache;
GO




/* And for bonus points, this is how real-life complex IF branches
can be way worse than single-query procs: */
CREATE OR ALTER PROC dbo.usp_QueryStuff
    @TableToQuery NVARCHAR(50) = NULL,
    @UserReputation INT = NULL,
    @BadgeName NVARCHAR(40) = NULL AS
BEGIN
IF @TableToQuery = 'Users'
    SELECT TOP 10000 *
        FROM dbo.Users
        WHERE Reputation = @UserReputation
        ORDER BY DisplayName;
ELSE IF @TableToQuery = 'Badges'
    SELECT TOP 200 *
        FROM dbo.Badges
        WHERE Name = @BadgeName
        ORDER BY Date;
END
GO

DBCC FREEPROCCACHE

/* And here's a few sets of parameters that cause wildly different plans */
EXEC dbo.usp_QueryStuff @TableToQuery = 'Users', @UserReputation = 1;
GO
EXEC dbo.usp_QueryStuff @TableToQuery = 'Users', @UserReputation = 2;
GO
EXEC dbo.usp_QueryStuff @TableToQuery = 'Badges', @BadgeName = 'Student';
GO
EXEC dbo.usp_QueryStuff @TableToQuery = 'Badges', @BadgeName = 'dynamic-sql';
GO
EXEC dbo.usp_QueryStuff;
GO





/*
Learn more later at:
https://www.BrentOzar.com/go/sniff


License: Creative Commons Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)
More info: https://creativecommons.org/licenses/by-sa/3.0/

You are free to:
* Share - copy and redistribute the material in any medium or format
* Adapt - remix, transform, and build upon the material for any purpose, even 
  commercially

Under the following terms:
* Attribution - You must give appropriate credit, provide a link to the license,
  and indicate if changes were made.
* ShareAlike - If you remix, transform, or build upon the material, you must
  distribute your contributions under the same license as the original.
*/


License: Creative Commons Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)
More info: https://creativecommons.org/licenses/by-sa/3.0/

You are free to:
* Share - copy and redistribute the material in any medium or format
* Adapt - remix, transform, and build upon the material for any purpose, even 
  commercially

Under the following terms:
* Attribution - You must give appropriate credit, provide a link to the license,
  and indicate if changes were made.
* ShareAlike - If you remix, transform, or build upon the material, you must
  distribute your contributions under the same license as the original.
**************************************************************************************************************/