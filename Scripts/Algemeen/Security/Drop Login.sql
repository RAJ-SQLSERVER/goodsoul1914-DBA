declare @loginNameToDrop sysname;
set @loginNameToDrop = '<victim login ID>';

declare sessionsToKill cursor fast_forward
for select 
        session_id
    from sys.dm_exec_sessions
    where login_name = @loginNameToDrop;
open sessionsToKill;

declare @sessionId int;
declare @statement nvarchar(200);

fetch next from sessionsToKill into @sessionId;

while @@FETCH_STATUS = 0
begin
    print 'Killing session ' + CAST(@sessionId as nvarchar(20)) + ' for login ' + @loginNameToDrop;

    set @statement = 'KILL ' + CAST(@sessionId as nvarchar(20));
    exec sp_executesql @statement;

    fetch next from sessionsToKill into @sessionId;
end;

close sessionsToKill;
deallocate sessionsToKill;

print 'Dropping login ' + @loginNameToDrop;
set @statement = 'DROP LOGIN [' + @loginNameToDrop + ']';
exec sp_executesql @statement;