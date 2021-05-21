declare @sql nvarchar(max) = N'';

select @sql+=N'SELECT * INTO [ZKH_Maintenance].dbo.' + QUOTENAME(name) + N' FROM [HIX_ONTWIKKEL].dbo.' + QUOTENAME(name) + N';'
from sys.tables
where name like N'MEDICAT_%'
order by name;

print @sql; -- Let op: PRINT toont alleen de eerste 4000 (NVARCHAR) or 8000 (VARCHAR) karakters !
--EXEC sp_executesql @sql;