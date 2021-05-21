-- Find the maintenance plan name and id that you want to delete.
SELECT name, id FROM msdb.dbo.sysmaintplan_plans

-- Place the id of the maintenance plan you want to delete
-- into the below query to delete the entry from the log table
DELETE FROM msdb.dbo.sysmaintplan_log WHERE plan_id = 'EF2F0EE6-13F4-492D-A8B4-3ACE425A3E8C'

-- Place the id of the maintenance plan you want to delete
-- into the below query and delete the entry from subplans table
DELETE FROM msdb.dbo.sysmaintplan_subplans WHERE plan_id = 'EF2F0EE6-13F4-492D-A8B4-3ACE425A3E8C'

-- Place the id of the maintenance plan you want to delete
-- into the below query to delete the entry from the plans table
DELETE FROM msdb.dbo.sysmaintplan_plans WHERE id = 'EF2F0EE6-13F4-492D-A8B4-3ACE425A3E8C'