use XEventsDemo;
go

declare @i int = 0;

while @i < 200
begin
	begin transaction;

	insert into DummyTable
	values (1, REPLICATE('x', 8000));

	commit transaction;

	set @i+=1;
end;
go