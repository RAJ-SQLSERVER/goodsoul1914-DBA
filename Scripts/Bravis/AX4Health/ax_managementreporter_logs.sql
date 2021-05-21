select CIG.[Description]
, ST.[Name]
, SM.[Text]
, DATEADD(minute, DATEDIFF(minute,GETUTCDATE(),GETDATE()), SL.[StartTime]) as LocalStartTime
, DATEADD(minute, DATEDIFF(minute,GETUTCDATE(),GETDATE()), SL.[EndTime]) as LocalEndTime
, SL.[TotalRetryNumber]
, SL.[IsFailed]
, STT.[Name] as TaskType
from [Scheduling].[Log] SL with (nolock)
inner join [Scheduling].[Task] ST with (nolock) on SL.TaskId = ST.Id
inner join [Scheduling].[Message] SM with (nolock) on SL.Id = SM.LogId
inner join [Scheduling].[TaskType] STT with (nolock) on ST.TypeId = STT.Id
inner join [Connector].[IntegrationGroup] CIG with (nolock) on CIG.[IntegrationId] = ST.[CategoryId]
order by SL.[StartTime] desc