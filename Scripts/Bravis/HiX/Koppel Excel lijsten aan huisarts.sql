select b.*, a.achternaam, a.liszcode AS HA_Liszcode, a.aanhef AS HA_Aanhef, a.adres as HA_Adres, a.huisnr as HA_Huisnr, a.postcode AS HA_Postcode, a.woonplaats AS HA_woonplaats, a.telefoon1 AS HA_telefoon1, a.telefoon2 AS HA_Telefoon2
from dbo.br2gnt3 b
left outer join dbo.PATIENT_PATIENT p ON p.patientnr = RIGHT(N'00000000' + RTRIM(CAST(b.patientnr AS BIGINT)), 8)
join dbo.CSZISLIB_ARTS a ON a.artscode = p.huisarts