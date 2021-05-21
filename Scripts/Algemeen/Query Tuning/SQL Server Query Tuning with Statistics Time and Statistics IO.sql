-------------------------------------------------------------------------------
-- SQL Server Query Tuning with Statistics Time and Statistics IO
-------------------------------------------------------------------------------

/*
Problem
I am working to improve the performance of a piece of SQL Server T-SQL code and 
I'm just not sure much the changes I am making are helping or hurting.  I need 
to be able to accurately track and report the performance improvement of my code 
changes.

Solution
The obvious answer is to look at the SQL Server query execution time, but that 
alone isn't always enough to determine that there is or isn't an improvement – 
or if that new index is helping. If the query was already finishing in a second 
or 2 that just isn't enough precision to determine if there is improvement. 
There are other things like caching and parallelism that can cause query 
execution time to be a misleading statistic.

This tip will look at how to analyze query executions to determine how many 
system resources were used and how long the query took to execute with far more 
precision than the query execution timer in SSMS so that a more definitive 
answer can be determined about whether – and to what extent – query 
optimization was changed.
*/

USE WideWorldImporters;
GO

/* ----------------------------------------------------------------------------
 – Measuring SQL Server query execution time with precision
---------------------------------------------------------------------------- */
SELECT *
FROM   Sales.Invoices
WHERE  InvoiceDate = '2014-03-15';

/*
Executing this query reports an execution time of 00:00:00 on this author's 
laptop. It seems unlikely that improving the speed of this query will be useful 
as it is already running in less than 1 second.  But what if this query runs 
1,000x per second?  Such occurrences are not uncommon in SQL Server OLTP 
workloads. How can an improvement be measured against 0?

The answer is that SQL Server offers a method to get execution times measured 
at the millisecond level which is 1000x more precise than the timer on the 
bottom right of the query results pane in SSMS.  The method is called STATISTICS 
TIME and can be enabled in one of 2 ways.

In SSMS the setting can be enabled on the session by right-clicking white space 
in the query pane and choosing query options.  It's all the way at the bottom of 
the context menu.  When the menu comes up choose "Advanced" on the left then 
check the box next to SET STATISTICS TIME.
*/

SET STATISTICS TIME ON;

SELECT *
FROM   Sales.Invoices
WHERE  InvoiceDate = '2014-03-15';

/*
Focus on the "SQL Server Execution Times:" section. 

SQL Server Execution Times:
   CPU time = 61 ms,  elapsed time = 1709 ms.
*/

/* ----------------------------------------------------------------------------
 – Measuring SQL Server resource usage for a query
---------------------------------------------------------------------------- */
SET STATISTICS TIME, IO ON;

SELECT *
FROM   Sales.Invoices
WHERE  InvoiceDate = '2014-03-15';

/*
Focus should be placed on the "logical reads" section. This statistic shows the 
number of 8kb data pages that were read from this table in total. 
The "physical reads" section shows how many of those reads were taken directly 
from disk.


Table 'Invoices'. Scan count 9, logical reads 8231

SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 29 ms
*/

/* ----------------------------------------------------------------------------
 – Comparing multiple SQL Server query executions
---------------------------------------------------------------------------- */

/*
SSMS offers a tool that allows the user to compare multiple query executions 
and easily compare the performance of them.  This feature is called Client 
Statistics. It can be enabled in one of 3 ways – a button, a keyboard shortcut, 
or a context menu.  The button is shown in the screenshot below. The keyboard 
shortcut is Shift+Alt+S.
*/

SELECT *
FROM   Sales.Invoices
WHERE  InvoiceDate = '2014-03-15';

/*
The most useful line for this demo is the "Wait time on server replies" as this 
is the number of milliseconds that were spent waiting for SQL Server to execute 
the query.
*/

/* ----------------------------------------------------------------------------
 – Improving SQL Server query execution
---------------------------------------------------------------------------- */
CREATE NONCLUSTERED INDEX MAKE_ME_FASTER ON Sales.Invoices (InvoiceDate);

SET STATISTICS TIME, IO ON;
-- Also set Client Statistics on

SELECT *
FROM   Sales.Invoices
WHERE  InvoiceDate = '2014-03-15';

/*
Table 'Invoices'. Scan count 1, logical reads 86

SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 3 ms.
*/