use AdventureWorks

create table AllCustomerOrders
(
	OrderID     bigint
	primary key, 
	CustomerID  bigint, 
	FirstName   varchar(100), 
	LastName    varchar(100), 
	ProductID   bigint, 
	UnitPrice   decimal(10, 2), 
	OrderAmount decimal(10, 2), 
	OrderDate   datetime, 
	ShipDate    datetime);
go

-- INSERT RECORDS NOW
declare @RowsRequired bigint = 10000000;

with CTE
	 as (select ROW_NUMBER() over(
				order by A.BusinessEntityID) as CustomerID, 
				A.FirstName, 
				B.LastName
		 from person.person as A
			  cross join person.person as B)
	 insert into AllCustomerOrders (OrderID, 
									CustomerID, 
									FirstName, 
									LastName, 
									ProductID, 
									UnitPrice, 
									OrderAmount, 
									OrderDate, 
									ShipDate) 
	 select distinct 
			OrderID, 
			X.CustomerID, 
			FirstName, 
			LastName, 
			ProductID, 
			UnitPrice, 
			OrderAmount, 
			OrderDate, 
			ShipDate
	 from (select ROW_NUMBER() over(
				  order by CAST(A.CustomerID as bigint)) as OrderID, 
				  A.*, 
				  SalesOrderID, 
				  ProductID, 
				  B.UnitPrice, 
				  LineTotal as OrderAmount
		   from CTE as A
				cross join sales.salesOrderDetail as B) as X
		  join Sales.SalesOrderHeader as C on C.SalesOrderID = X.SalesOrderID
	 where OrderID <= @RowsRequired;