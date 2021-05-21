create proc sp_GetFailedLoginsListFromLastWeeks
as
begin
    set nocount on;

    declare @ErrorLogCount int;
    declare @LastLogDate datetime;

    declare @ErrorLogInfo table
    (
        LogDate     datetime, 
        ProcessInfo nvarchar(50), 
        [Text]      nvarchar(max)
    );

    declare @EnumErrorLogs table
    (
        Archive#      int, 
        [Date]        datetime, 
        LogFileSizeMB int
    );

    insert into @EnumErrorLogs
    exec sp_enumerrorlogs;

    select 
        @ErrorLogCount=MIN(Archive#), 
        @LastLogDate=MAX([Date])
    from @EnumErrorLogs;

    while @ErrorLogCount is not null
    begin

        insert into @ErrorLogInfo
        exec sp_readerrorlog @ErrorLogCount;

        select 
            @ErrorLogCount=MIN(Archive#), 
            @LastLogDate=MAX([Date])
        from @EnumErrorLogs
        where Archive# > @ErrorLogCount
              and @LastLogDate > GETDATE() - 7;

    end;

    -- List all last week failed logins count of attempts and the Login failure message
    select 
        COUNT(TEXT) as NumberOfAttempts, 
        TEXT as Details, 
        MIN(LogDate) as MinLogDate, 
        MAX(LogDate) as MaxLogDate
    from @ErrorLogInfo
    where ProcessInfo = 'Logon'
          and TEXT like '%fail%'
          and LogDate > GETDATE() - 7
    group by 
        TEXT
    order by 
        NumberOfAttempts desc;

    set nocount off;
end;