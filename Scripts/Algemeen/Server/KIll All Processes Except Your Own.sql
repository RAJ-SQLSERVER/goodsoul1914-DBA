declare @DbName nvarchar(50);

set @DbName = N'HIX_PRODUCTIE';

declare @EXECSQL varchar(max);

set @EXECSQL = '';

select @EXECSQL = @EXECSQL + 'Kill ' + CONVERT(varchar, SPId) + ';'
from MASTER..SysProcesses
where DBId = DB_ID(@DbName)
	  and spid <> @@SPId;

exec (@EXECSQL);