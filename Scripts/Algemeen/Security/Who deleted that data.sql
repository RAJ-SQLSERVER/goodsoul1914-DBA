--lab_trigger_deletes.sql

--create table to be monitored and add some data
CREATE TABLE t1 (c1 INT, c2 INT)
INSERT INTO t1 VALUES (1,7), (2,8), (3,9)

-- create audit table
CREATE TABLE t1_audit (c1 INT, c2 INT, c3 DATETIME, c4 sysname, c5 sysname, c6 sysname)

-- check contents of both tables
SELECT * FROM t1
SELECT * FROM t1_audit

-- create trigger
CREATE TRIGGER trg_ItemDelete 
ON dbo.t1 
AFTER DELETE 
AS
INSERT INTO dbo.t1_audit(c1, c2, c3, c4, c5, c6)
		SELECT d.c1, d.c2, GETDATE(), HOST_NAME(), SUSER_SNAME(), ORIGINAL_LOGIN()
		FROM Deleted d

-- delete a row (firing the trigger)
DELETE FROM t1 WHERE c1 = 2

-- check contents of both tables again
SELECT * FROM t1
SELECT * FROM t1_audit

-- tidy up
IF OBJECT_ID ('trg_ItemDelete', 'TR') IS NOT NULL DROP TRIGGER trg_ItemDelete;
DROP TABLE t1
DROP TABLE t1_audit