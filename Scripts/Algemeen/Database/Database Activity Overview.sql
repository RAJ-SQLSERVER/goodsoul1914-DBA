SELECT DB = a.instance_name,
	'DBCC Logical Scans' = a.cntr_value,
	'Transactions/sec' = (
		SELECT d.cntr_value
		FROM master..sysperfinfo AS d
		WHERE d.object_name = a.object_name
			AND d.instance_name = a.instance_name
			AND d.counter_name = 'Transactions/sec'
		),
	'Active Transactions' = (
		SELECT CASE 
				WHEN i.cntr_value < 0
					THEN 0
				ELSE i.cntr_value
				END
		FROM master..sysperfinfo AS i
		WHERE i.object_name = a.object_name
			AND i.instance_name = a.instance_name
			AND i.counter_name = 'Active Transactions'
		),
	'Bulk Copy Rows' = (
		SELECT b.cntr_value
		FROM master..sysperfinfo AS b
		WHERE b.object_name = a.object_name
			AND b.instance_name = a.instance_name
			AND b.counter_name = 'Bulk Copy Rows/sec'
		),
	'Bulk Copy Throughput' = (
		SELECT c.cntr_value
		FROM master..sysperfinfo AS c
		WHERE c.object_name = a.object_name
			AND c.instance_name = a.instance_name
			AND c.counter_name = 'Bulk Copy Throughput/sec'
		),
	'Log Cache Reads' = (
		SELECT e.cntr_value
		FROM master..sysperfinfo AS e
		WHERE e.object_name = a.object_name
			AND e.instance_name = a.instance_name
			AND e.counter_name = 'Log Cache Reads/sec'
		),
	'Log Flushes' = (
		SELECT f.cntr_value
		FROM master..sysperfinfo AS f
		WHERE f.object_name = a.object_name
			AND f.instance_name = a.instance_name
			AND f.counter_name = 'Log Flushes/sec'
		),
	'Log Growths' = (
		SELECT g.cntr_value
		FROM master..sysperfinfo AS g
		WHERE g.object_name = a.object_name
			AND g.instance_name = a.instance_name
			AND g.counter_name = 'Log Growths'
		),
	'Log Shrinks' = (
		SELECT h.cntr_value
		FROM master..sysperfinfo AS h
		WHERE h.object_name = a.object_name
			AND h.instance_name = a.instance_name
			AND h.counter_name = 'Log Shrinks'
		)
FROM master..sysperfinfo AS a
WHERE a.object_name LIKE '%Databases%';
