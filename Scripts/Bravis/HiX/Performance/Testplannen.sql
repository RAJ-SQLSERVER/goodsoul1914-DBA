
select	tp.Id as 'TestPlanId'
		, tp.Name as 'TestPlanName'
		, tp.NumberOfRuns	
		, tg.Id as 'TestGroupId'
		, tg.Name as 'TestGroupName'
		, t.id as 'TestId'
		, t.Name as 'TestName'
		, t.Description as 'TestDescription'
		, t.Stream as 'TestStream'
		, t.IsDevTest
from	
	LOG_TESTPLANITEM tpi
join	
	LOG_TEST t on t.Id = tpi.TestId
join	
	LOG_TESTGRP tg on tg.Id = t.GroupId
join	
	LOG_TESTPLAN tp on tp.Id = tpi.TestPlanId
ORDER BY 
	TestPlanId, TestGroupId, TestId