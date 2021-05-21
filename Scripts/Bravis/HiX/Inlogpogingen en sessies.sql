DECLARE @FromDate date;
DECLARE @PartialName varchar(max);

SET @FromDate = '2019-04-02';
SET @PartialName = '%lvdvlie1%'

-- Aantal inlogpogingen in HIX per gebruiker (opnieuw opstarten)
select top 10 * 
from ZISCON_LOGSESSI 
where winuser like @PartialName and INDATUM >= @FromDate
order by UITTIJD


-- Aantal unieke sessies per gebruiker in HIX, loginscherm na HIX-blokkade
select top 10 * 
from ZISCON_LOGUSER 
where INDATUM >= @FromDate and LOGSESS_ID in (
	select LOGSESS_ID 
	from ZISCON_LOGSESSI 
	where winuser like @PartialName and INDATUM >= @FromDate)

