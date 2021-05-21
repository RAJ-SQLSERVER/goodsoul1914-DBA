-- Get first day of a month
SELECT DATEADD(DAY, 1, EOMONTH('20180220', -1)) AS FirstDayOfMonth;

-- Get last day of 2 months ago
SELECT EOMONTH(DATEADD(MONTH, -2, GETDATE()));
SELECT EOMONTH(GETDATE(), -2);

