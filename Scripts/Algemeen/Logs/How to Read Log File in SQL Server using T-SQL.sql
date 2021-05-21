/*
 sp_readerrorlog

 This procedure takes four parameters:

 - Value of error log file you want to read: 0 = current, 1 = Archive #1, 2 = Archive #2, etc...
 - Log file type: 1 or NULL = error log, 2 = SQL Agent log
 - Search string 1: String one you want to search for
 - Search string 2: String two you want to search for to further refine the results
 
 If you do not pass any parameters this will return the contents of the current error log.
*/
EXEC sp_readerrorlog @p1 = 6;
EXEC sp_readerrorlog @p1 = 1, @p2 = 1, @p3 = '18204';
EXEC sp_readerrorlog @p1 = 6, @p2 = 1, @p3 = 'mode', @p4 = 'mixed';

/*
 xp_readerrrorlog

 Even though sp_readerrolog accepts only 4 parameters, the extended stored procedure accepts at least 7 parameters.

 If this extended stored procedure is called directly the parameters are as follows:

 - Value of error log file you want to read: 0 = current, 1 = Archive #1, 2 = Archive #2, etc...
 - Log file type: 1 or NULL = error log, 2 = SQL Agent log
 - Search string 1: String one you want to search for
 - Search string 2: String two you want to search for to further refine the results
 - Search from start time
 - Search to end time
 - Sort order for results: N'asc' = ascending, N'desc' = descending
*/
EXEC master.dbo.xp_readerrorlog 0,
                                1,
                                "backup",
                                "failed",
                                "2017-01-02",
                                "2017-02-02",
                                "desc";
EXEC master.dbo.xp_readerrorlog 0, 1, "2005", "exec", NULL, NULL, "asc";

EXEC master.dbo.xp_readerrorlog 0,
                                1,
                                N'backup',
                                NULL,
                                N'2017-01-02',
                                N'2017-02-02',
                                N'desc';
EXEC master.dbo.xp_readerrorlog 0,
                                1,
                                N'backup',
                                N'failed',
                                NULL,
                                NULL,
                                N'asc';

