
/*
 ____  ____   ____  ____   ______ 
|    \|    \ |    ||    \ |      |
|  o  )  D  ) |  | |  _  ||      |
|   _/|    /  |  | |  |  ||_|  |_|
|  |  |    \  |  | |  |  |  |  |  
|  |  |  .  \ |  | |  |  |  |  |  
|__|  |__|\_||____||__|__|  |__|  
                                  
*/

declare @num1 integer;
declare @num2 integer;

set @num1 = 20;
set @num2 = 30;
 
if @num1 > @num2
	print '1st number is greater than 2nd number.';
else
	if @num2 > @num1
		print '2nd number is greater than 1st number.';
	else
		print 'The numbers are equal.';
go


/*
 ____  _____                        ___  _     _____   ___      ____  _____ 
|    ||     |                      /  _]| |   / ___/  /  _]    |    ||     |
 |  | |   __|                     /  [_ | |  (   \_  /  [_      |  | |   __|
 |  | |  |_                      |    _]| |___\__  ||    _]     |  | |  |_  
 |  | |   _]      __  __  __     |   [_ |     /  \ ||   [_      |  | |   _] 
 |  | |  |       |  ||  ||  |    |     ||     \    ||     |     |  | |  |   
|____||__|       |__||__||__|    |_____||_____|\___||_____|    |____||__|   
                                                                            
*/

declare @num1 integer;
declare @num2 integer;

set @num1 = 100;
set @num2 = 30;
 
if @num1 > @num2
begin
	print '1st number is greater than 2nd number.';
	if @num1 > 75
		print '1st number is greater than 75.';
	else
		if @num1 > 50
			print '1st number is greater than 50.';
		else
			print '1st number is less than or equal to 50.';
end;
else
	if @num2 > @num1
		print '2nd number is greater than 1st number.';
	else
		print 'The numbers are equal.';
go


/*
 _       ___    ___   ____    _____
| |     /   \  /   \ |    \  / ___/
| |    |     ||     ||  o  )(   \_ 
| |___ |  O  ||  O  ||   _/  \__  |
|     ||     ||     ||  |    /  \ |
|     ||     ||     ||  |    \    |
|_____| \___/  \___/ |__|     \___|
                                   
*/

declare @i integer;
set @i = 1;
while @i <= 10
begin
	print CONCAT('Pass...', @i);
	set @i = @i + 1;
end;
go

declare @i integer;
set @i = 1;
while @i <= 10
begin
	print CONCAT('Pass...', @i);
	if @i = 9
		break;
	set @i = @i + 1;
end;
go

declare @i integer;
set @i = 1;
while @i <= 10
begin
	print CONCAT('Pass...', @i);
	if @i = 9
		continue;
	set @i = @i + 1;
end;
go


/*
 _       ___    ___   ____    _____      ____  ____   ___        ___     ____  ______    ___  _____
| |     /   \  /   \ |    \  / ___/     /    ||    \ |   \      |   \   /    ||      |  /  _]/ ___/
| |    |     ||     ||  o  )(   \_     |  o  ||  _  ||    \     |    \ |  o  ||      | /  [_(   \_ 
| |___ |  O  ||  O  ||   _/  \__  |    |     ||  |  ||  D  |    |  D  ||     ||_|  |_||    _]\__  |
|     ||     ||     ||  |    /  \ |    |  _  ||  |  ||     |    |     ||  _  |  |  |  |   [_ /  \ |
|     ||     ||     ||  |    \    |    |  |  ||  |  ||     |    |     ||  |  |  |  |  |     |\    |
|_____| \___/  \___/ |__|     \___|    |__|__||__|__||_____|    |_____||__|__|  |__|  |_____| \___|
                                                                                                   
*/

declare @date_start date;
declare @date_end date;
declare @loop_date date;

set @date_start = '2020/11/11';
set @date_end = '2020/12/12';

set @loop_date = @date_start;
 
while @loop_date <= @date_end
begin
	print @loop_date;
	set @loop_date = DATEADD(DAY, 1, @loop_date);
end;
go


drop table if exists #dates;
create table #dates(report_date date);

declare @date_start date;
declare @date_end date;
declare @loop_date date;

set @date_start = '2020/11/11';
set @date_end = '2020/12/12';
set @loop_date = @date_start;

while @loop_date <= @date_end
begin
	insert into #dates (report_date) 
	values(@loop_date);
	set @loop_date = DATEADD(DAY, 1, @loop_date);
end;
 
select *
from #dates;

drop table if exists #dates;
go

