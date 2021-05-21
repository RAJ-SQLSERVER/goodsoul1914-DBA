-- Disable all constraints
exec sp_MSForEachTable 'ALTER TABLE ? NOCHECK CONSTRAINT all';

-- Delete data in all tables
exec sp_MSForEachTable 'DELETE FROM ?';

-- Enable all constraints
exec sp_MSForEachTable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all';

--It may also be worth considering reseeding Identity columns that your tables
--may have. You can do that with this Statement:
exec sp_MSforEachTable 'DBCC CHECKIDENT ( '?', RESEED, 0)';