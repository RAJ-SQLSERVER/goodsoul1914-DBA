select count(*) 
from dpic300 
where (indnst_dt is not null) and ((uitdnst_dt is null) OR (uitdnst_dt='')) 
