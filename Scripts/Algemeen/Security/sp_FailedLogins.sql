
/******************************************************************************
Author: Adrian Buckman	
Revision date: 06/06/2017
Version: 1

www.sqlundercover.com 
******************************************************************************/

create procedure dbo.sp_FailedLogins
(
	@FromDate datetime = null, 
	@ToDate   datetime = null) 
as
begin
	-- Failed login attempts in the last 60 minutes

	if @FromDate is null
	begin
		set @FromDate = DATEADD(MINUTE, -60, GETDATE());
	end;
	if @ToDate is null
	begin
		set @ToDate = GETDATE();
	end;

	if OBJECT_ID('Tempdb..#Errors') is not null
		drop table #Errors;

	create table #Errors
	(
		Logdate     datetime, 
		Processinfo varchar(30), 
		Text        varchar(255));
	insert into #Errors
	exec xp_ReadErrorLog 0, 1, N'FAILED', N'login', @FromDate, @ToDate;

	select REPLACE(LoginErrors.Username, '''', '') as Username, 
		   CAST(LoginErrors.Attempts as nvarchar(6)) as Attempts, 
		   LatestDate.Logdate, 
		   Latestdate.LastError
	from
	(
		select SUBSTRING(text, PATINDEX('%''%''%', Text), CHARINDEX('.', Text) - PATINDEX('%''%''%', Text)) as Username, 
			   COUNT(*) as Attempts
		from #Errors as Errors
		group by SUBSTRING(text, PATINDEX('%''%''%', Text), CHARINDEX('.', Text) - PATINDEX('%''%''%', Text))
	) as LoginErrors
	cross apply
	(
		select top 1 Logdate, 
					 text as LastError
		from #Errors as LatestDate
		where LoginErrors.Username = SUBSTRING(text, PATINDEX('%''%''%', Text), CHARINDEX('.', Text) - PATINDEX('%''%''%', Text))
		order by Logdate desc
	) as LatestDate
	order by LoginErrors.Attempts desc;
end;
go