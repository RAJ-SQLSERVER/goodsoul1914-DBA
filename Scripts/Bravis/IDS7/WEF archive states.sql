--1 = original 
--4 =  copy 
--5 = failed 
--6 = warning 
--7 = retrieving 
--11 = parked 
--99 = archived 
select WEF_ARCHIVE_STATE, count(*)  
from W_EXAM_FOLDER where WEF_BF_ID <> 109 
group by  WEF_ARCHIVE_STATE  
order by WEF_ARCHIVE_STATE;