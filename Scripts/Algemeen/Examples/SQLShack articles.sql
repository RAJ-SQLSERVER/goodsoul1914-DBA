-- Database: our_first_database
create database our_first_database;
go

use our_first_database;
go

-- Table: city
create table city
(
	id         int not null identity(1, 1), 
	city_name  char(128) not null, 
	lat        decimal(9, 6) not null, 
	long       decimal(9, 6) not null, 
	country_id int not null, 
	constraint city_pk primary key(id));
go

-- Table: country
create table country
(
	id               int not null identity(1, 1), 
	country_name     char(128) not null, 
	country_name_eng char(128) not null, 
	country_code     char(8) not null, 
	constraint country_ak_1 unique(country_name), 
	constraint country_ak_2 unique(country_name_eng), 
	constraint country_ak_3 unique(country_code), 
	constraint country_pk primary key(id));
go

-- foreign keys
-- Reference: city_country (table: city)
alter table city
add constraint city_country foreign key(country_id) references country(id);
go

-- Check what is inside the tables
select *
from country;
select *
from city;
go

-- Insert some rows in country
insert into country (country_name, 
					 country_name_eng, 
					 country_code) 
values('Deutschland', 'Germany', 'DEU');
insert into country (country_name, 
					 country_name_eng, 
					 country_code) 
values('Srbija', 'Serbia', 'SRB');
insert into country (country_name, 
					 country_name_eng, 
					 country_code) 
values('Hrvatska', 'Croatia', 'HRV');
insert into country (country_name, 
					 country_name_eng, 
					 country_code) 
values('United Stated of America', 'United Stated of America', 'USA');
insert into country (country_name, 
					 country_name_eng, 
					 country_code) 
values('Polska', 'Poland', 'POL');
go

-- Insert some rows in city
insert into city (city_name, 
				  lat, 
				  long, 
				  country_id) 
values('Berlin', 52.520008, 13.404954, 1);
insert into city (city_name, 
				  lat, 
				  long, 
				  country_id) 
values('Belgrade', 44.787197, 20.457273, 2);
insert into city (city_name, 
				  lat, 
				  long, 
				  country_id) 
values('Zagreb', 45.815399, 15.966568, 3);
insert into city (city_name, 
				  lat, 
				  long, 
				  country_id) 
values('New York', 40.73061, -73.935242, 4);
insert into city (city_name, 
				  lat, 
				  long, 
				  country_id) 
values('Los Angeles', 34.052235, -118.243683, 4);
insert into city (city_name, 
				  lat, 
				  long, 
				  country_id) 
values('Warsaw', 52.237049, 21.017532, 5);
go

-- Check what was inserted
select *
from country;
select *
from city;
go

-- Check key constraints
select *
from sys.key_constraints
select * 
from sys.foreign_keys
go

-- Deleting from country will fail
delete from country
where id = 5;
go

-- Simple select
select city.id as city_id, 
	   city.city_name, 
	   country.id as country_id, 
	   country.country_name, 
	   country.country_name_eng, 
	   country.country_code
from city
inner join country on city.country_id = country.id
where country.id in (1, 4, 5);
go

-- Insert more data
insert into country (country_name, 
					 country_name_eng, 
					 country_code) 
values('España', 'Spain', 'ESP');
insert into country (country_name, 
					 country_name_eng, 
					 country_code) 
values('Rossiya', 'Russia', 'RUS');
go

-- inner join
select *
from country, city
where city.country_id = country.id;
    
select *
from country
inner join city on city.country_id = country.id;
go

-- left join
select *
from country
left join city on city.country_id = country.id;
go

-- right join
select *
from country
right join city on city.country_id = country.id;
go

/*
INNER JOIN vs LEFT JOIN? 
Actually, that is not the question at all. 
You’ll use INNER JOIN when you want to return only records having pair on both sides, 
and you’ll use LEFT JOIN when you need all records from the “left” table, no matter 
if they have pair in the “right” table or not. If you’ll need all records from both tables, 
no matter if they have pair, you’ll need to use CROSS JOIN (or simulate it using LEFT JOINs 
and UNION). More about that in the upcoming articles.
*/

-- Adding new tables
-- Table: call
create table call
(
	id              int not null identity(1, 1), 
	employee_id     int not null, 
	customer_id     int not null, 
	start_time      datetime not null, 
	end_time        datetime null, 
	call_outcome_id int null, 
	constraint call_ak_1 unique(employee_id, start_time), 
	constraint call_pk primary key(id));
    
-- Table: call_outcome
create table call_outcome
(
	id           int not null identity(1, 1), 
	outcome_text char(128) not null, 
	constraint call_outcome_ak_1 unique(outcome_text), 
	constraint call_outcome_pk primary key(id));
    
-- Table: customer
create table customer
(
	id               int not null identity(1, 1), 
	customer_name    varchar(255) not null, 
	city_id          int not null, 
	customer_address varchar(255) not null, 
	next_call_date   date null, 
	ts_inserted      datetime not null, 
	constraint customer_pk primary key(id));
    
-- Table: employee
create table employee
(
	id         int not null identity(1, 1), 
	first_name varchar(255) not null, 
	last_name  varchar(255) not null, 
	constraint employee_pk primary key(id));
    
-- foreign keys
-- Reference: call_call_outcome (table: call)
alter table call
add constraint call_call_outcome foreign key(call_outcome_id) references call_outcome(id);
    
-- Reference: call_customer (table: call)
alter table call
add constraint call_customer foreign key(customer_id) references customer(id);
 
-- Reference: call_employee (table: call)
alter table call
add constraint call_employee foreign key(employee_id) references employee(id);
 
-- Reference: customer_city (table: customer)
alter table customer
add constraint customer_city foreign key(city_id) references city(id);
    
-- insert values
insert into call_outcome (outcome_text) 
values('call started');
insert into call_outcome (outcome_text) 
values('finished - successfully');
insert into call_outcome (outcome_text) 
values('finished - unsuccessfully');
    
insert into employee (first_name, 
					  last_name) 
values('Thomas (Neo)', 'Anderson');
insert into employee (first_name, 
					  last_name) 
values('Agent', 'Smith');
    
insert into customer (customer_name, 
					  city_id, 
					  customer_address, 
					  next_call_date, 
					  ts_inserted) 
values('Jewelry Store', 4, 'Long Street 120', '2020/1/21', '2020/1/9 14:1:20');
insert into customer (customer_name, 
					  city_id, 
					  customer_address, 
					  next_call_date, 
					  ts_inserted) 
values('Bakery', 1, 'Kurfürstendamm 25', '2020/2/21', '2020/1/9 17:52:15');
insert into customer (customer_name, 
					  city_id, 
					  customer_address, 
					  next_call_date, 
					  ts_inserted) 
values('Café', 1, 'Tauentzienstraße 44', '2020/1/21', '2020/1/10 8:2:49');
insert into customer (customer_name, 
					  city_id, 
					  customer_address, 
					  next_call_date, 
					  ts_inserted) 
values('Restaurant', 3, 'Ulica lipa 15', '2020/1/21', '2020/1/10 9:20:21');
    
insert into call (employee_id, 
				  customer_id, 
				  start_time, 
				  end_time, 
				  call_outcome_id) 
values(1, 4, '2020/1/11 9:0:15', '2020/1/11 9:12:22', 2);
insert into call (employee_id, 
				  customer_id, 
				  start_time, 
				  end_time, 
				  call_outcome_id) 
values(1, 2, '2020/1/11 9:14:50', '2020/1/11 9:20:1', 2);
insert into call (employee_id, 
				  customer_id, 
				  start_time, 
				  end_time, 
				  call_outcome_id) 
values(2, 3, '2020/1/11 9:2:20', '2020/1/11 9:18:5', 3);
insert into call (employee_id, 
				  customer_id, 
				  start_time, 
				  end_time, 
				  call_outcome_id) 
values(1, 1, '2020/1/11 9:24:15', '2020/1/11 9:25:5', 3);
insert into call (employee_id, 
				  customer_id, 
				  start_time, 
				  end_time, 
				  call_outcome_id) 
values(1, 3, '2020/1/11 9:26:23', '2020/1/11 9:33:45', 2);
insert into call (employee_id, 
				  customer_id, 
				  start_time, 
				  end_time, 
				  call_outcome_id) 
values(1, 2, '2020/1/11 9:40:31', '2020/1/11 9:42:32', 2);
insert into call (employee_id, 
				  customer_id, 
				  start_time, 
				  end_time, 
				  call_outcome_id) 
values(2, 4, '2020/1/11 9:41:17', '2020/1/11 9:45:21', 2);
insert into call (employee_id, 
				  customer_id, 
				  start_time, 
				  end_time, 
				  call_outcome_id) 
values(1, 1, '2020/1/11 9:42:32', '2020/1/11 9:46:53', 3);
insert into call (employee_id, 
				  customer_id, 
				  start_time, 
				  end_time, 
				  call_outcome_id) 
values(2, 1, '2020/1/11 9:46:0', '2020/1/11 9:48:2', 2);
insert into call (employee_id, 
				  customer_id, 
				  start_time, 
				  end_time, 
				  call_outcome_id) 
values(2, 2, '2020/1/11 9:50:12', '2020/1/11 9:55:35', 2);
go

--
select *
from customer
inner join city on customer.city_id = city.id;
 
select *
from customer
left join city on customer.city_id = city.id;
 
select *
from city
left join customer on customer.city_id = city.id;
go

