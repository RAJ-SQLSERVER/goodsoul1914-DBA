-- Determine last day of month

select EOMONTH(DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)) as LastDayOfCurrentMonthDate;