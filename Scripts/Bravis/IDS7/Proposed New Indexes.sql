use [WISE];
go

/*
The Query Processor estimates that implementing the following index could improve the query cost by 98.0831%.
*/

create nonclustered index [IX_1] on dbo.W_EXAM(WEXAM_BODY_PART) 
	include(WEXAM_ID, WEXAM_REQ_ID);
go

/*
The Query Processor estimates that implementing the following index could improve the query cost by 99.6382%.
*/

create nonclustered index [IX_2] on dbo.W_EXAM(WEXAM_READING_PHYSICIAN, WEXAM_DATE, WEXAM_CODE) 
	include(WEXAM_ID, WEXAM_REQ_ID);
go

