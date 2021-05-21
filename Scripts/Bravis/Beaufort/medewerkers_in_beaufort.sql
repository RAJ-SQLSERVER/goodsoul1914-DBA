SELECT 
	b010.pers_nr, 
	b010.naam_samen, 
	b010.vrvg_samen, 
	b010.gbrk_naam, 
	b010.tssnvgsl_kd, 
	b010.geslacht, 
	b010.e_naam, 
	b010.e_vrvg, 
	b010.e_vrlt, 
	b010.e_voornmn, 
	b010.e_roepnaam, 
	b010.e_titul, 
	b010.e_titul_na, 
	c300.dv_vlgnr, 
	CONVERT(nvarchar(20), c300.indnst_dt, 112) AS indnst_dt, 
	CONVERT(nvarchar(20), c300.uitdnst_dt, 112) AS uitdnst_dt, 
	c300.arelsrt_kd, 
	c300.primfunc_kd, 
	c300.uren_pw,
	c300.deelb_perc,
	c351.func_oms, 
	b015.oe_kort_nm, 
	b015.oe_vol_nm, 
	b015.oe_hoger_n, 
	b015.kstpl_kd, 
	CASE WHEN a032.rubriek_kd = 'P00288' THEN 1 ELSE 0 END AS pv, 
	dbo.dpib004.kstpl_nm
FROM 
	dbo.dpib010 AS b010 INNER JOIN
    dbo.dpic300 AS c300 ON b010.pers_nr = c300.pers_nr INNER JOIN
    dbo.dpic351 AS c351 ON c300.primfunc_kd = c351.func_kd INNER JOIN
    dbo.dpib015 AS b015 ON c300.oe_hier_sl = b015.dpib015_sl LEFT OUTER JOIN
    dbo.dpib004 ON b015.kstpl_kd = dbo.dpib004.kstpl_kd LEFT OUTER JOIN
    dbo.dpia032 AS a032 ON CAST(c300.pers_nr AS VARCHAR) + ' ' + CAST(c300.dv_vlgnr AS VARCHAR) = a032.object_id AND a032.rubriek_kd = 'P00288'
WHERE 
	(c300.uitdnst_dt IS NULL OR
    c300.uitdnst_dt = '' OR
    c300.uitdnst_dt >= CONVERT(VARCHAR(10), GETDATE(), 120)) AND (c300.primfunc_kd NOT IN (789))
ORDER BY 
	naam_samen