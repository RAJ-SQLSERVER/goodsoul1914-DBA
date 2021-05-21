select ISNULL(c359.loner_oms, 'Niet Toegewezen') AS soort_loner, count(*) as aantal 
from dpic300 c300 left join dpic359 c359 on c300.loner_kd = c359.loner_kd 
where (c300.indnst_dt is not null) and ((c300.uitdnst_dt is null) OR (c300.uitdnst_dt='')) 
group by c359.loner_oms