select *
from dbo.AGENDA_SUBAGEND
where agenda in (select agenda from dbo.AGENDA_AGENDA where naam like 'mdl%')