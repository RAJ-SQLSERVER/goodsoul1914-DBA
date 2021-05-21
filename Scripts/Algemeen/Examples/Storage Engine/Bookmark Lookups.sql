use AdventureWorks2017;
go

-- ===============================================
-- Demonstrates the semantics of Bookmark Lookups
-- ===============================================

set statistics io on;

set statistics time on;
go

-- The PostalCode and the StateProvince column are used by this query.
-- By default no nonclustered index contains these columns, therefore
-- a bookmark lookup is required:
--		1. Nonclustered Index Seek
--		2. Clustered Key Lookup
--
-- Result: logical reads 18

select AddressID, 
	   PostalCode
from Person.Address
where StateProvinceID = 42;
go

-- Create a "carrying" nonclustered index that includes the PostalCode column

create nonclustered index idx_Address_StateProvinceID on Person.Address
(StateProvinceID) 
	include (PostalCode);
go

-- Result: logical reads 2

select AddressID, 
	   PostalCode
from Person.Address
where StateProvinceID = 42;
go