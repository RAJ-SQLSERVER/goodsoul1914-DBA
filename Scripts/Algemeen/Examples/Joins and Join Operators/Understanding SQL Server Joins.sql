/*****************
create sample data
*****************/
CREATE TABLE tablea (
	ID INT,
	Name CHAR(1)
	);

CREATE TABLE tableb (
	ID INT,
	Name CHAR(1)
	);

INSERT INTO tablea (
	ID,
	Name
	)
VALUES (
	1,
	'A'
	),
	(
	2,
	'B'
	),
	(
	NULL,
	'C'
	);

INSERT INTO tableb (
	ID,
	Name
	)
VALUES (
	1,
	'A'
	),
	(
	2,
	'B'
	),
	(
	NULL,
	'C'
	),
	(
	4,
	'D'
	),
	(
	1,
	'E'
	);

-- TURN ON ACTUAL EXECUTION PLAN
/*********
cross join
*********/
SELECT *
FROM tablea
CROSS JOIN tableb;

SELECT *
FROM tableb
CROSS JOIN tablea;

SELECT *
FROM tablea,
	tableb;

SELECT *
FROM tableb,
	tablea;

-- error, join predicate is missing!
SELECT *
FROM tablea,
	tableb
OPTION (HASH JOIN);

/*********
inner join
*********/
SELECT *
FROM tablea AS a
INNER JOIN tableb AS b ON a.ID = b.ID;

SELECT *
FROM tableb AS b
INNER JOIN tablea AS a ON b.ID = a.ID;

-- create unique clustered index ix_a_id on dbo.tablea(ID);
-- drop index ix_a_id on dbo.tablea;
-- create clustered index ix_b_id on dbo.tableb(ID);
-- drop index ix_b_id on dbo.tableb;
SELECT *
FROM tablea AS a
INNER JOIN tableb AS b ON a.ID = b.ID
OPTION (LOOP JOIN);

-- Non-equi join
SELECT *
FROM tablea AS a
INNER JOIN tableb AS b ON a.ID <> b.ID;

/**************
left outer join
**************/
SELECT *
FROM tablea AS a
LEFT OUTER JOIN tableb AS b ON a.ID = b.ID;

SELECT *
FROM tableb AS b
LEFT OUTER JOIN tablea AS a ON b.ID = a.ID;

/***************
right outer join
***************/
SELECT *
FROM tablea AS a
RIGHT OUTER JOIN tableb AS b ON a.ID = b.ID;

SELECT *
FROM tableb AS b
RIGHT OUTER JOIN tablea AS a ON b.ID = a.ID;

/**************
full outer join
**************/
SELECT *
FROM tablea AS a
FULL OUTER JOIN tableb AS b ON a.ID = b.ID;

SELECT *
FROM tableb AS b
FULL OUTER JOIN tablea AS a ON b.ID = a.ID;
