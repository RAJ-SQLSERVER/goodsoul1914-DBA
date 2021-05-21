use tempdb;
go

if OBJECT_ID('dbo.fn_GetHexaDecimal') is null
	exec ('CREATE FUNCTION dbo.fn_GetHexaDecimal () RETURNS int AS BEGIN RETURN (SELECT 1) END;');
go
alter function dbo.fn_GetHexaDecimal(
	@binvalue varbinary(256))
returns varchar(514)
as
	begin
		declare @hexvalue varchar(514);
		declare @charvalue varchar(514);
		declare @i int;
		declare @length int;
		declare @hexstring char(16);
		select @charvalue = '0x';
		select @i = 1;
		select @length = DATALENGTH(@binvalue);
		select @hexstring = '0123456789ABCDEF';
		while @i <= @length
		begin
			declare @tempint int;
			declare @firstint int;
			declare @secondint int;
			select @tempint = CONVERT(int, SUBSTRING(@binvalue, @i, 1));
			select @firstint = FLOOR(@tempint / 16);
			select @secondint = @tempint - @firstint * 16;
			select @charvalue = @charvalue + SUBSTRING(@hexstring, @firstint + 1, 1) + SUBSTRING(@hexstring, @secondint + 1, 1);
			select @i = @i + 1;
		end;

		set @hexvalue = @charvalue;
		return @hexvalue;
	end;
go

select p.name, 
	   p.type, 
	   p.sid, 
	   dbo.fn_GetHexaDecimal(p.sid) as sid_hex
from master.sys.server_principals as p
where p.type in ('S', 'G', 'U')
	  and p.name <> 'sa';