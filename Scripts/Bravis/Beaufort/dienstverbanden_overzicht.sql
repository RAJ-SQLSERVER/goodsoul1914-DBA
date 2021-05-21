SELECT 
	arelsrt_kd	, count(*) AS aantal
FROM 
    dpic300 
WHERE 
	(uitdnst_dt IS NULL OR uitdnst_dt = '' OR uitdnst_dt >= CONVERT(VARCHAR(10), GETDATE(), 120)) AND (primfunc_kd NOT IN (789))
GROUP BY 
	arelsrt_kd
ORDER BY aantal DESC