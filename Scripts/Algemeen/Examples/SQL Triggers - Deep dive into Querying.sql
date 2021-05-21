select *
from HumanResources.Shift;
go

-- Create table-level trigger
create trigger Demo_Trigger on HumanResources.Shift
after insert
as
    begin
        print 'Insert is not allowed, you need approval!';
        rollback transaction;
    end;
go

-- Test
insert into HumanResources.Shift
(
    Name, 
    StartTime, 
    EndTime, 
    ModifiedDate
) 
values ('Rakesh', '07:00:00.0000000', '10:00:00.0000000', GETDATE());
go

-- Create database-level trigger
create trigger Demo_DbTrigger
on database
after create_table
as
begin
	print 'Creation of new tables not allowed!';
    rollback transaction;
end
go

-- Test
create table NewTable (Id int);
go

