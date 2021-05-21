use AdventureWorks;
go

select E.BusinessEntityID, 
	   E.LoginID, 
	   E.JobTitle, 
	   P.FirstName, 
	   P.LastName
from HumanResources.Employee as E
	 inner join Person.Person as P on P.BusinessEntityID = E.BusinessEntityID;

select *
from Sales.Customer;

-- Heaps are terrible when you will be joining to them

select *
from Person.Person
where PersonType = 'EM';

select FirstName, 
	   LastName
from Person.Person
where LastName = 'Smith';

-- SET STATISTICS IO ON;

select *
from Person.Person
where PersonType = 'EM';-- Scan count 1, logical reads 3819

select *
from Person.Person
where LastName = 'Smith';-- Scan count 1, logical reads 327

select FirstName, 
	   LastName
from Person.Person
where LastName = 'Smith';-- Scan count 1, logical reads 3

select FirstName, 
	   LastName
from Person.Person
where FirstName = 'Andrew';-- Scan count 1, logical reads 108
-- SET STATISTICS IO OFF;

select *
from Person.Person
order by PersonType asc;

--OPTION (MAXDOP 1);
-- Sorts can benefit from indexes too

select FirstName, 
	   LastName
from Person.Person
order by FirstName;

select FirstName, 
	   LastName
from Person.Person
order by LastName;

-- seeks are reserved for filtering data using predicates
-- Merge joins

select *
from Person.Person as P
	 inner join Person.EmailAddress as E on E.BusinessEntityID = P.BusinessEntityID
where LastName = 'Smith';

-- Hash match joins

select SOH.OrderDate, 
	   SOH.ShipDate, 
	   SOH.SubTotal
from Sales.SalesOrderDetail as SD
	 inner join Sales.SalesOrderHeader as SOH on SOH.SalesOrderID = SD.SalesOrderID
	 inner join Production.Product as P on P.ProductID = SD.ProductID
where SOH.OrderDate between '2013-01-01' and '2014-12-31';

-- Nested loop joins

select E.BusinessEntityID, 
	   E.LoginID, 
	   E.JobTitle, 
	   P.FirstName, 
	   P.LastName
from HumanResources.Employee as E
	 inner join Person.Person as P on P.BusinessEntityID = E.BusinessEntityID;

-- Parameter sniffing

select AddressLine1, 
	   AddressLine2, 
	   City, 
	   StateProvinceID, 
	   PostalCode
from Person.Address
where StateProvinceID = 55;

select AddressLine1, 
	   AddressLine2, 
	   City, 
	   StateProvinceID, 
	   PostalCode
from Person.Address
where StateProvinceID = 59;

select AddressLine1, 
	   AddressLine2, 
	   City, 
	   StateProvinceID, 
	   PostalCode
from Person.Address
where StateProvinceID = 9;
go

-- DROP PROCEDURE GetAddressForSpecificStateProvince

create procedure GetAddressForSpecificStateProvince
(
	@StateProvinceID int) 
as
begin
	begin
		select AddressLine1, 
			   AddressLine2, 
			   City, 
			   StateProvinceID, 
			   PostalCode
		from Person.Address
		where StateProvinceID = @StateProvinceID;
	end;

	execute GetAddressForSpecificStateProvince 9;
	end;
go

execute GetAddressForSpecificStateProvince 55;
go

-- How can we fix it?
-- Recompile?

alter procedure GetAddressForSpecificStateProvince
(
	@StateProvinceID int) 
with recompile
as
begin
	begin
		select AddressLine1, 
			   AddressLine2, 
			   City, 
			   StateProvinceID, 
			   PostalCode
		from Person.Address
		where StateProvinceID = @StateProvinceID;
	end;

	execute GetAddressForSpecificStateProvince 9;
	end;
go

execute GetAddressForSpecificStateProvince 55;
go

-- Optimize for specific value/unknown?

alter procedure GetAddressForSpecificStateProvince
(
	@StateProvinceID int) 
as
begin
	begin
		select AddressLine1, 
			   AddressLine2, 
			   City, 
			   StateProvinceID, 
			   PostalCode
		from Person.Address
		where StateProvinceID = @StateProvinceID option(optimize for(@StateProvinceID = 55));
	end;

	execute GetAddressForSpecificStateProvince 9;
	end;
go

execute GetAddressForSpecificStateProvince 55;
go

-- Demo 14.1 
-- Table variables vs. Temp tables

declare @Customers as table
(
	BusinessEntityID int, 
	CustomerFirst    nvarchar(255), 
	CustomerLast     nvarchar(255));

insert into @Customers (BusinessEntityID, 
						CustomerFirst, 
						CustomerLast) 
select top 1 P.BusinessEntityID, 
			 P.FirstName, 
			 P.LastName
from Person.Person as P
	 inner join Person.BusinessEntityAddress as BEA on BEA.BusinessEntityID = P.BusinessEntityID
	 inner join Person.Address as A on A.AddressID = BEA.AddressID
	 inner join Person.StateProvince as SP on A.StateProvinceID = SP.StateProvinceID
where SP.Name = 'Washington';

select *
from Sales.SalesOrderHeader as SOH
	 inner join Sales.SalesOrderDetail as SOD on SOD.SalesOrderID = SOH.SalesOrderID
	 inner join @Customers as C on C.BusinessEntityID = SOH.CustomerID;
go

-- Now, let's scale up!

set statistics io on;

declare @Customers as table
(
	BusinessEntityID int, 
	CustomerFirst    nvarchar(255), 
	CustomerLast     nvarchar(255));

insert into @Customers (BusinessEntityID, 
						CustomerFirst, 
						CustomerLast) 
select top 5000 P.BusinessEntityID, 
				P.FirstName, 
				P.LastName
from Person.Person as P
	 inner join Person.BusinessEntityAddress as BEA on BEA.BusinessEntityID = P.BusinessEntityID
	 inner join Person.Address as A on A.AddressID = BEA.AddressID
	 inner join Person.StateProvince as SP on A.StateProvinceID = SP.StateProvinceID
where SP.Name = 'Washington';

select *
from Sales.SalesOrderHeader as SOH
	 inner join Sales.SalesOrderDetail as SOD on SOD.SalesOrderID = SOH.SalesOrderID
	 inner join @Customers as C on C.BusinessEntityID = SOH.CustomerID;
go

-- Create an actual Temp table

create table #Customers
(
	BusinessEntityID int, 
	CustomerFirst    nvarchar(255), 
	CustomerLast     nvarchar(255));

insert into #Customers (BusinessEntityID, 
						CustomerFirst, 
						CustomerLast) 
select top 5000 P.BusinessEntityID, 
				P.FirstName, 
				P.LastName
from Person.Person as P
	 inner join Person.BusinessEntityAddress as BEA on BEA.BusinessEntityID = P.BusinessEntityID
	 inner join Person.Address as A on A.AddressID = BEA.AddressID
	 inner join Person.StateProvince as SP on A.StateProvinceID = SP.StateProvinceID
where SP.Name = 'Washington';

select *
from Sales.SalesOrderHeader as SOH
	 inner join Sales.SalesOrderDetail as SOD on SOD.SalesOrderID = SOH.SalesOrderID
	 inner join #Customers as C on C.BusinessEntityID = SOH.CustomerID;
go

-- Demo 15.1
-- 

use StackOverflow2010;
go

select *
from Posts as P
	 inner join Users as U on U.Id = P.OwnerUserId
where U.Location like '%OH';