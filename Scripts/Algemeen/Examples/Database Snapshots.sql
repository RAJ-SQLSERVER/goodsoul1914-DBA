-- ===================
-- Database Snapshots
-- ===================

create database Playground_2020 on (name = 'Playground', filename = 'D:\Documents\MSSQL\SS\Playground_2020.ss') as snapshot of Playground;
go

use Playground;
go

-- OOPS !!!!

drop table Numbers;
go

-- But the dropped table is still part of the database snapshot

select *
from Playground_2020.dbo.Numbers;
go

-- Restore the database from the snapshot

use master;
go

restore database Playground from database_snapshot = 'Playground_2020';
go