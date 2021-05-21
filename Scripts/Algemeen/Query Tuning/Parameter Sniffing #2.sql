--	Simple parameter sniffing example
--

create or alter proc GetCustomerOrders
(
	@CustomerID int) 
as
	select *
	from WideWorldImporters.Sales.Orders
	where CustomerID = @CustomerID;
go

exec GetCustomerOrders 1060;
go

exec GetCustomerOrders 90;
go

exec sp_recompile 'GetCustomerOrders';
go

exec GetCustomerOrders 90;
go

exec GetCustomerOrders 1060;
go

--	Local variable in Stored Procedure
--	(eliminates parameter sniffing)

create or alter proc GetCustomerOrders
(
	@CustomerID int) 
as
	declare @CID int;
	set @CID = @CustomerID;
	select *
	from WideWorldImporters.Sales.Orders
	where CustomerID = @CID;
go

exec GetCustomerOrders 1060;
go

exec GetCustomerOrders 90;
go

--	Parameter sniffing and OPTIMIZE FOR UNKNOWN
--

create or alter proc GetCustomerOrders
(
	@CustomerID int) 
as
	select *
	from WideWorldImporters.Sales.Orders
	where CustomerID = @CustomerID option(optimize for unknown); -- = use stats basically
go

-- Sample Stored Procedure

exec GetCustomerOrders 1060;

exec GetCustomerOrders 90;
go

--	Database-scoped Configuration - Parameter sniffing
--

use [WideWorldImporters];
go

alter database scoped configuration set parameter_sniffing = off;
go

-- Let us run the original stored procedure

create or alter proc GetCustomerOrders
(
	@CustomerID int) 
as
	select *
	from WideWorldImporters.Sales.Orders
	where CustomerID = @CustomerID;
go

-- Sample Stored Procedure

exec GetCustomerOrders 1060;

exec GetCustomerOrders 90;
go

--	Parameter sniffing and OPTION (RECOMPILE)
--

create or alter proc GetCustomerOrders
(
	@CustomerID int) 
as
	select *
	from WideWorldImporters.Sales.Orders
	where CustomerID = @CustomerID option(recompile);
go

exec GetCustomerOrders 1060;

exec GetCustomerOrders 90;
go