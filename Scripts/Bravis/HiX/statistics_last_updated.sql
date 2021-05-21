select object_name (i.id)as objectname,i.name as indexname,i.origfillfactor,i.rowcnt,i.rowmodctr ,STATS_DATE(i.id, i.indid) as ix_Statistics_Date,o.instrig,o.updtrig,o.deltrig,o.seltrig
from sysindexes i INNER JOIN dbo.sysobjects o ON i.id = o.id
where rowcnt >1000 and i.name not like'sys%'and object_name(i.id)not like'sys%'
order by rowcnt desc