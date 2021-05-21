create or alter procedure myreport
as
begin
	select top (10000) a.*
	from master..spt_values as a, master..spt_values as b
	order by a.number desc, 
			 b.number desc;
end;
go

exec myreport;
go

